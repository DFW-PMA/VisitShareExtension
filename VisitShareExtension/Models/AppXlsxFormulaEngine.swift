//
//  AppXlsxFormulaEngine.swift
//  AnyPack
//
//  Created by Claude/Daryl Cox on 10/05/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import Foundation

// <<CHICKEN-TRACKS>> (2026-10-05) Small SpreadsheetML (R1C1) formula evaluator.
//
// WHY: a BigTest .xls (SpreadsheetML XML) carries ~70K formulas with NO cached results - Excel computes them
// when it opens/saves the file. check_bigtest_xlsx.py reads the .xlsx with openpyxl 'data_only=True', i.e. it
// reads the CACHED values Excel stored. A converted .xlsx therefore needs those cached values written next to
// each formula, and the only way to have them without Excel is to calculate them here.
//
// Scope: exactly what this producer emits - IF, IFERROR, ISNUMBER, SEARCH, ROUND, SUM; operators
// + - * / & = <> < > <= >= and unary -; numbers, "strings", cell refs (R1C1 relative/absolute, optionally on
// another sheet) and ranges inside SUM. Anything unsupported evaluates to #NAME? (the file is still written
// with the formula; Excel recalculates on open - see fullCalcOnLoad in AppXlsxWriter).

enum AppXlsxValue:Equatable
{
    case empty
    case number(Double)
    case text(String)
    case bool(Bool)
    case error(String)
}

@JmEntityInfo(vers:"v1.0101")
final class AppXlsxFormulaEngine
{

    // MARK: - AST

    struct Axis
    {
        var isAbsolute:Bool
        var value:Int           // absolute -> 0-based index, relative -> offset
    }

    indirect enum Node
    {
        case num(Double)
        case str(String)
        case bool(Bool)
        case ref(sheet:String?, row:Axis, col:Axis)
        case range(Node, Node)
        case neg(Node)
        case bin(String, Node, Node)
        case call(String, [Node])
        case bad
    }

    // MARK: - Workbook data

    private struct SheetData
    {
        var name:String
        var index:[UInt64:Int]              // key(row,col) -> position in 'cells'
        var cells:[SpreadsheetXMLCell]
    }

    private var sheets:[SheetData]              = [SheetData]()
    private var sheetIndexByName:[String:Int]   = [String:Int]()
    private var dictResults:[UInt64:AppXlsxValue] = [UInt64:AppXlsxValue]()     // (sheet,row,col) -> value
    private var setInProgress:Set<UInt64>       = Set<UInt64>()
    private var dictParsed:[String:Node]        = [String:Node]()

    init(workbook:SpreadsheetXMLWorkbook)
    {

        for (iSheet, worksheet) in workbook.worksheets.enumerated()
        {
            var sheet:SheetData = SheetData(name:worksheet.name, index:[UInt64:Int](), cells:[SpreadsheetXMLCell]())

            for row in worksheet.rows
            {
                for cell in row.cells
                {
                    sheet.index[AppXlsxFormulaEngine.key(row.rowIndex, cell.columnIndex)] = sheet.cells.count
                    sheet.cells.append(cell)
                }
            }

            sheets.append(sheet)
            sheetIndexByName[worksheet.name.lowercased()] = iSheet
        }

    }   // End of init(workbook:).

    private static func key(_ iRow:Int, _ iCol:Int)->UInt64
    {
        return (UInt64(iRow) << 20) | UInt64(iCol)
    }

    private static func resultKey(_ iSheet:Int, _ iRow:Int, _ iCol:Int)->UInt64
    {
        return (UInt64(iSheet) << 48) | (UInt64(iRow) << 20) | UInt64(iCol)
    }

    // MARK: - Public

    /// Value of any cell (0-based row/col) - formulas are evaluated on demand and memoized.
    func cellValue(sheet iSheet:Int, row iRow:Int, col iCol:Int)->AppXlsxValue
    {

        guard iSheet >= 0, iSheet < sheets.count, iRow >= 0, iCol >= 0
        else
        {
            return .error("#REF!")
        }

        guard let iPos = sheets[iSheet].index[AppXlsxFormulaEngine.key(iRow, iCol)]
        else
        {
            return .empty
        }

        let cell:SpreadsheetXMLCell = sheets[iSheet].cells[iPos]

        if let sFormula = cell.formula, !sFormula.isEmpty
        {
            let k:UInt64 = AppXlsxFormulaEngine.resultKey(iSheet, iRow, iCol)

            if let cached = dictResults[k]
            {
                return cached
            }

            if setInProgress.contains(k)
            {
                return .error("#REF!")          // circular reference...
            }

            setInProgress.insert(k)

            let node:Node = parsedFormula(sFormula)
            var result:AppXlsxValue = evaluate(node, sheet:iSheet, row:iRow, col:iCol)

            // A formula that yields a reference to an empty cell shows 0 in Excel...

            if (result == .empty)
            {
                result = .number(0)
            }

            setInProgress.remove(k)
            dictResults[k] = result

            return result
        }

        // Literal cell...

        // An explicit empty String <Data> is a real empty-text cell (it yields "" - not 0 - when referenced)...

        if cell.value.isEmpty
        {
            return ((cell.hasData && cell.type == .string) ? .text("") : .empty)
        }

        switch cell.type
        {
        case .number:
            if let dValue = Double(cell.value)
            {
                return .number(dValue)
            }

            return .text(cell.value)
        case .boolean:
            return .bool(cell.value == "1" || cell.value.lowercased() == "true")
        default:
            return .text(cell.value)
        }

    }   // End of func cellValue(sheet:row:col:).

    // MARK: - Parsing

    private func parsedFormula(_ sFormula:String)->Node
    {

        if let node = dictParsed[sFormula]
        {
            return node
        }

        var parser:FormulaParser = FormulaParser(chars:Array(sFormula.hasPrefix("=") ? String(sFormula.dropFirst()) : sFormula))
        let node:Node            = parser.parseExpression()

        // Anything left over means we didn't understand the formula...

        let result:Node = (parser.atEnd ? node : .bad)

        dictParsed[sFormula] = result

        return result

    }   // End of private func parsedFormula(_:).

    private struct FormulaParser
    {

        let chars:[Character]
        var pos:Int = 0

        init(chars:[Character])
        {
            self.chars = chars
        }

        var atEnd:Bool
        {
            var i:Int = pos
            while (i < chars.count && chars[i] == " ") { i += 1 }
            return (i >= chars.count)
        }

        private mutating func skipSpaces()
        {
            while (pos < chars.count && chars[pos] == " ") { pos += 1 }
        }

        private func peek(_ iOff:Int = 0)->Character?
        {
            let i:Int = (pos + iOff)
            return (i < chars.count) ? chars[i] : nil
        }

        mutating func parseExpression()->Node
        {
            return parseComparison()
        }

        private mutating func parseComparison()->Node
        {

            var left:Node = parseConcat()

            while true
            {
                skipSpaces()

                var sOp:String? = nil

                if let c = peek()
                {
                    if (c == "<" && peek(1) == "=")      { sOp = "<=" }
                    else if (c == ">" && peek(1) == "=") { sOp = ">=" }
                    else if (c == "<" && peek(1) == ">") { sOp = "<>" }
                    else if (c == "=")                   { sOp = "="  }
                    else if (c == "<")                   { sOp = "<"  }
                    else if (c == ">")                   { sOp = ">"  }
                }

                guard let sFoundOp = sOp
                else
                {
                    return left
                }

                pos += sFoundOp.count

                let right:Node = parseConcat()

                left = .bin(sFoundOp, left, right)
            }

        }

        private mutating func parseConcat()->Node
        {

            var left:Node = parseAdditive()

            while true
            {
                skipSpaces()

                guard peek() == "&"
                else
                {
                    return left
                }

                pos += 1

                left = .bin("&", left, parseAdditive())
            }

        }

        private mutating func parseAdditive()->Node
        {

            var left:Node = parseMultiplicative()

            while true
            {
                skipSpaces()

                guard let c = peek(), (c == "+" || c == "-")
                else
                {
                    return left
                }

                pos += 1

                left = .bin(String(c), left, parseMultiplicative())
            }

        }

        private mutating func parseMultiplicative()->Node
        {

            var left:Node = parseUnary()

            while true
            {
                skipSpaces()

                guard let c = peek(), (c == "*" || c == "/")
                else
                {
                    return left
                }

                pos += 1

                left = .bin(String(c), left, parseUnary())
            }

        }

        private mutating func parseUnary()->Node
        {

            skipSpaces()

            if peek() == "-"
            {
                pos += 1
                return .neg(parseUnary())
            }

            if peek() == "+"
            {
                pos += 1
                return parseUnary()
            }

            return parsePrimary()

        }

        private mutating func parsePrimary()->Node
        {

            skipSpaces()

            guard let c = peek()
            else
            {
                return .bad
            }

            // ( expr )

            if (c == "(")
            {
                pos += 1

                let inner:Node = parseExpression()

                skipSpaces()

                if (peek() == ")") { pos += 1 } else { return .bad }

                return inner
            }

            // "string"

            if (c == "\"")
            {
                pos += 1

                var sText:String = ""

                while (pos < chars.count)
                {
                    if (chars[pos] == "\"")
                    {
                        if (peek(1) == "\"")
                        {
                            sText.append("\"")
                            pos += 2
                            continue
                        }

                        break
                    }

                    sText.append(chars[pos])
                    pos += 1
                }

                pos += 1        // closing quote...

                return .str(sText)
            }

            // number

            if (c.isNumber || c == ".")
            {
                var sNum:String = ""

                while let d = peek(), (d.isNumber || d == ".")
                {
                    sNum.append(d)
                    pos += 1
                }

                if let d = peek(), (d == "E" || d == "e"), let n = peek(1), (n.isNumber || n == "-" || n == "+")
                {
                    sNum.append(d)
                    pos += 1

                    while let e = peek(), (e.isNumber || e == "-" || e == "+")
                    {
                        sNum.append(e)
                        pos += 1
                    }
                }

                return .num(Double(sNum) ?? 0)
            }

            // 'Quoted Sheet'!ref

            if (c == "'")
            {
                pos += 1

                var sName:String = ""

                while (pos < chars.count)
                {
                    if (chars[pos] == "'")
                    {
                        if (peek(1) == "'")
                        {
                            sName.append("'")
                            pos += 2
                            continue
                        }

                        break
                    }

                    sName.append(chars[pos])
                    pos += 1
                }

                pos += 1        // closing quote...

                guard peek() == "!"
                else
                {
                    return .bad
                }

                pos += 1

                return parseReference(sheet:sName)
            }

            // R1C1 reference (tried first, so 'RC' / 'R[-1]C' aren't taken as identifiers)...

            if (c == "R" || c == "r")
            {
                let iSave:Int = pos

                if let node = tryParseRef(sheet:nil)
                {
                    return finishRange(node, sheet:nil)
                }

                pos = iSave
            }

            // identifier: function / Sheet! / TRUE / FALSE

            if (c.isLetter || c == "_")
            {
                var sIdent:String = ""

                while let d = peek(), (d.isLetter || d.isNumber || d == "_" || d == ".")
                {
                    sIdent.append(d)
                    pos += 1
                }

                if (peek() == "(")
                {
                    pos += 1

                    var listArgs:[Node] = [Node]()

                    skipSpaces()

                    if (peek() == ")")
                    {
                        pos += 1
                        return .call(sIdent.uppercased(), listArgs)
                    }

                    while true
                    {
                        skipSpaces()

                        // An omitted argument ("IF(a,b,)") behaves as 0...

                        if (peek() == "," || peek() == ")")
                        {
                            listArgs.append(.num(0))
                        }
                        else
                        {
                            listArgs.append(parseExpression())
                        }

                        skipSpaces()

                        if (peek() == ",")
                        {
                            pos += 1
                            continue
                        }

                        if (peek() == ")")
                        {
                            pos += 1
                            break
                        }

                        return .bad
                    }

                    return .call(sIdent.uppercased(), listArgs)
                }

                if (peek() == "!")
                {
                    pos += 1
                    return parseReference(sheet:sIdent)
                }

                if (sIdent.uppercased() == "TRUE")  { return .bool(true) }
                if (sIdent.uppercased() == "FALSE") { return .bool(false) }

                return .bad
            }

            return .bad

        }   // End of private mutating func parsePrimary().

        private mutating func parseReference(sheet sSheet:String?)->Node
        {

            if let node = tryParseRef(sheet:sSheet)
            {
                return finishRange(node, sheet:sSheet)
            }

            return .bad

        }

        private mutating func finishRange(_ first:Node, sheet sSheet:String?)->Node
        {

            if (peek() == ":")
            {
                let iSave:Int = pos

                pos += 1

                if let second = tryParseRef(sheet:sSheet)
                {
                    return .range(first, second)
                }

                pos = iSave
            }

            return first

        }

        /// R[n]C[n] / R5C3 / RC / R[-1]C ... (relative offsets are signed, absolute numbers are 1-based).
        private mutating func tryParseRef(sheet sSheet:String?)->Node?
        {

            guard let c0 = peek(), (c0 == "R" || c0 == "r")
            else
            {
                return nil
            }

            pos += 1

            guard let rowAxis = parseAxis()
            else
            {
                return nil
            }

            guard let c1 = peek(), (c1 == "C" || c1 == "c")
            else
            {
                return nil
            }

            pos += 1

            guard let colAxis = parseAxis()
            else
            {
                return nil
            }

            // Must not run on into more identifier characters (e.g. 'RCX', 'ROUND')...

            if let d = peek(), (d.isLetter || d.isNumber || d == "_" || d == "(")
            {
                return nil
            }

            return .ref(sheet:sSheet, row:rowAxis, col:colAxis)

        }

        private mutating func parseAxis()->Axis?
        {

            if (peek() == "[")
            {
                pos += 1

                var sNum:String = ""

                while let d = peek(), (d.isNumber || d == "-" || d == "+")
                {
                    sNum.append(d)
                    pos += 1
                }

                guard peek() == "]", let iOff = Int(sNum.hasPrefix("+") ? String(sNum.dropFirst()) : sNum)
                else
                {
                    return nil
                }

                pos += 1

                return Axis(isAbsolute:false, value:iOff)
            }

            var sDigits:String = ""

            while let d = peek(), d.isNumber
            {
                sDigits.append(d)
                pos += 1
            }

            if sDigits.isEmpty
            {
                return Axis(isAbsolute:false, value:0)      // 'R' / 'C' alone = same row / column...
            }

            guard let iAbs = Int(sDigits)
            else
            {
                return nil
            }

            return Axis(isAbsolute:true, value:(iAbs - 1))

        }

    }   // End of private struct FormulaParser.

    // MARK: - Evaluation

    // <<CHICKEN-TRACKS>> Excel wraps relative offsets around the sheet edges (R[-175] from row 172 is row 1048573),
    //                    which this producer's "sum every 5th row" formulas rely on - so wrap, don't fail.
    static let cMaxRows:Int = 1048576
    static let cMaxCols:Int = 16384

    private func resolve(_ axis:Axis, current iCurrent:Int, isRow:Bool = true)->Int
    {

        if (axis.isAbsolute)
        {
            return axis.value
        }

        let iMod:Int = (isRow ? AppXlsxFormulaEngine.cMaxRows : AppXlsxFormulaEngine.cMaxCols)

        return ((((iCurrent + axis.value) % iMod) + iMod) % iMod)

    }

    private func sheetIndex(_ sName:String?, current iSheet:Int)->Int?
    {

        guard let sName = sName
        else
        {
            return iSheet
        }

        return sheetIndexByName[sName.lowercased()]

    }

    private func evaluate(_ node:Node, sheet iSheet:Int, row iRow:Int, col iCol:Int)->AppXlsxValue
    {

        switch node
        {
        case .num(let d):
            return .number(d)
        case .str(let s):
            return .text(s)
        case .bool(let b):
            return .bool(b)
        case .bad:
            return .error("#NAME?")
        case .range:
            return .error("#VALUE!")
        case .ref(let sSheet, let rowAxis, let colAxis):
            guard let iTarget = sheetIndex(sSheet, current:iSheet)
            else
            {
                return .error("#REF!")
            }

            return cellValue(sheet:iTarget, row:resolve(rowAxis, current:iRow), col:resolve(colAxis, current:iCol, isRow:false))
        case .neg(let inner):
            let v:AppXlsxValue = evaluate(inner, sheet:iSheet, row:iRow, col:iCol)

            switch toNumber(v)
            {
            case .success(let d):
                return .number(-d)
            case .failure(let e):
                return .error(e.message)
            }
        case .bin(let sOp, let left, let right):
            let l:AppXlsxValue = evaluate(left,  sheet:iSheet, row:iRow, col:iCol)
            let r:AppXlsxValue = evaluate(right, sheet:iSheet, row:iRow, col:iCol)

            if case .error = l { return l }
            if case .error = r { return r }

            switch sOp
            {
            case "+", "-", "*", "/":
                let nl = toNumber(l)
                let nr = toNumber(r)

                guard case .success(let dl) = nl
                else
                {
                    if case .failure(let e) = nl { return .error(e.message) }
                    return .error("#VALUE!")
                }

                guard case .success(let dr) = nr
                else
                {
                    if case .failure(let e) = nr { return .error(e.message) }
                    return .error("#VALUE!")
                }

                switch sOp
                {
                case "+":
                    return .number(dl + dr)
                case "-":
                    return .number(dl - dr)
                case "*":
                    return .number(dl * dr)
                default:
                    return (dr == 0) ? .error("#DIV/0!") : .number(dl / dr)
                }
            case "&":
                return .text(toText(l) + toText(r))
            default:
                return compare(sOp, l, r)
            }
        case .call(let sName, let listArgs):
            return evaluateCall(sName, listArgs, sheet:iSheet, row:iRow, col:iCol)
        }

    }   // End of private func evaluate(_:sheet:row:col:).

    private func evaluateCall(_ sName:String, _ listArgs:[Node], sheet iSheet:Int, row iRow:Int, col iCol:Int)->AppXlsxValue
    {

        func eval(_ n:Node)->AppXlsxValue
        {
            return evaluate(n, sheet:iSheet, row:iRow, col:iCol)
        }

        switch sName
        {
        case "IF":
            guard listArgs.count >= 2
            else
            {
                return .error("#VALUE!")
            }

            let cond:AppXlsxValue = eval(listArgs[0])

            if case .error = cond { return cond }

            switch toBool(cond)
            {
            case .failure(let e):
                return .error(e.message)
            case .success(let b):
                if (b == true)
                {
                    return eval(listArgs[1])
                }

                return (listArgs.count >= 3) ? eval(listArgs[2]) : .bool(false)
            }
        case "IFERROR":
            guard listArgs.count == 2
            else
            {
                return .error("#VALUE!")
            }

            let v:AppXlsxValue = eval(listArgs[0])

            if case .error = v
            {
                return eval(listArgs[1])
            }

            return v
        case "ISNUMBER":
            guard listArgs.count == 1
            else
            {
                return .error("#VALUE!")
            }

            if case .number = eval(listArgs[0]) { return .bool(true) }

            return .bool(false)
        case "SEARCH":
            guard listArgs.count >= 2
            else
            {
                return .error("#VALUE!")
            }

            let vFind:AppXlsxValue   = eval(listArgs[0])
            let vWithin:AppXlsxValue = eval(listArgs[1])

            if case .error = vFind   { return vFind }
            if case .error = vWithin { return vWithin }

            let sFind:String   = toText(vFind)
            let sWithin:String = toText(vWithin)

            var iStart:Int = 1

            if (listArgs.count >= 3)
            {
                switch toNumber(eval(listArgs[2]))
                {
                case .success(let d):
                    iStart = Int(d)
                case .failure(let e):
                    return .error(e.message)
                }
            }

            guard iStart >= 1, iStart <= (sWithin.count + 1)
            else
            {
                return .error("#VALUE!")
            }

            let idxFrom:String.Index = sWithin.index(sWithin.startIndex, offsetBy:(iStart - 1))

            if let found = sWithin.range(of:sFind, options:.caseInsensitive, range:idxFrom..<sWithin.endIndex)
            {
                return .number(Double(sWithin.distance(from:sWithin.startIndex, to:found.lowerBound) + 1))
            }

            return .error("#VALUE!")
        case "ROUND":
            guard listArgs.count == 2
            else
            {
                return .error("#VALUE!")
            }

            let vNum:AppXlsxValue    = eval(listArgs[0])
            let vDigits:AppXlsxValue = eval(listArgs[1])

            if case .error = vNum    { return vNum }
            if case .error = vDigits { return vDigits }

            guard case .success(let dNum) = toNumber(vNum), case .success(let dDigits) = toNumber(vDigits)
            else
            {
                return .error("#VALUE!")
            }

            return .number(AppXlsxFormulaEngine.excelRound(dNum, digits:Int(dDigits)))
        case "SUM":
            var dTotal:Double = 0

            for arg in listArgs
            {
                if case .range(let a, let b) = arg
                {
                    guard case .ref(let sSheetA, let rowA, let colA) = a,
                          case .ref(_,           let rowB, let colB) = b,
                          let iTarget = sheetIndex(sSheetA, current:iSheet)
                    else
                    {
                        return .error("#REF!")
                    }

                    let iR1:Int = resolve(rowA, current:iRow)
                    let iR2:Int = resolve(rowB, current:iRow)
                    let iC1:Int = resolve(colA, current:iCol, isRow:false)
                    let iC2:Int = resolve(colB, current:iCol, isRow:false)

                    for iR in min(iR1, iR2)...max(iR1, iR2)
                    {
                        for iC in min(iC1, iC2)...max(iC1, iC2)
                        {
                            let v:AppXlsxValue = cellValue(sheet:iTarget, row:iR, col:iC)

                            switch v
                            {
                            case .number(let d):
                                dTotal += d
                            case .error:
                                return v
                            default:
                                break                   // text/blank inside a range is ignored by SUM...
                            }
                        }
                    }

                    continue
                }

                let v:AppXlsxValue = eval(arg)

                if case .error = v { return v }

                switch toNumber(v)
                {
                case .success(let d):
                    dTotal += d
                case .failure(let e):
                    return .error(e.message)
                }
            }

            return .number(dTotal)
        default:
            return .error("#NAME?")
        }

    }   // End of private func evaluateCall(_:_:sheet:row:col:).

    // MARK: - Coercion / comparison helpers

    private struct EvalError:Error
    {
        let message:String
    }

    private func toNumber(_ v:AppXlsxValue)->Result<Double, EvalError>
    {

        switch v
        {
        case .empty:
            return .success(0)
        case .number(let d):
            return .success(d)
        case .bool(let b):
            return .success(b ? 1 : 0)
        case .error(let s):
            return .failure(EvalError(message:s))
        case .text(let s):
            if let d = Double(s.trimmingCharacters(in:.whitespaces))
            {
                return .success(d)
            }

            return .failure(EvalError(message:"#VALUE!"))
        }

    }

    private func toBool(_ v:AppXlsxValue)->Result<Bool, EvalError>
    {

        switch v
        {
        case .empty:
            return .success(false)
        case .number(let d):
            return .success(d != 0)
        case .bool(let b):
            return .success(b)
        case .error(let s):
            return .failure(EvalError(message:s))
        case .text(let s):
            if (s.uppercased() == "TRUE")  { return .success(true) }
            if (s.uppercased() == "FALSE") { return .success(false) }

            return .failure(EvalError(message:"#VALUE!"))
        }

    }

    private func toText(_ v:AppXlsxValue)->String
    {

        switch v
        {
        case .empty:
            return ""
        case .number(let d):
            return AppXlsxFormulaEngine.numberText(d)
        case .bool(let b):
            return (b ? "TRUE" : "FALSE")
        case .error(let s):
            return s
        case .text(let s):
            return s
        }

    }

    static func numberText(_ d:Double)->String
    {

        if (d == d.rounded() && abs(d) < 1e15)
        {
            return String(Int64(d))
        }

        return "\(d)"

    }

    /// Excel's comparison rules: blank equals 0 or "", numbers sort before text, text compares case-insensitively.
    private func compare(_ sOp:String, _ l:AppXlsxValue, _ r:AppXlsxValue)->AppXlsxValue
    {

        var iOrder:Int = 0          // -1 l<r, 0 equal, 1 l>r

        func rank(_ v:AppXlsxValue)->Int
        {
            switch v
            {
            case .number, .empty:
                return 0
            case .text:
                return 1
            case .bool:
                return 2
            case .error:
                return 3
            }
        }

        var lv:AppXlsxValue = l
        var rv:AppXlsxValue = r

        // Blank takes on the type of the other side...

        if (lv == .empty)
        {
            switch rv
            {
            case .text:
                lv = .text("")
            case .bool:
                lv = .bool(false)
            default:
                lv = .number(0)
            }
        }

        if (rv == .empty)
        {
            switch lv
            {
            case .text:
                rv = .text("")
            case .bool:
                rv = .bool(false)
            default:
                rv = .number(0)
            }
        }

        if (rank(lv) != rank(rv))
        {
            iOrder = (rank(lv) < rank(rv)) ? -1 : 1
        }
        else
        {
            switch (lv, rv)
            {
            case (.number(let a), .number(let b)):
                iOrder = (a < b) ? -1 : ((a > b) ? 1 : 0)
            case (.text(let a), .text(let b)):
                let cmp:ComparisonResult = a.compare(b, options:.caseInsensitive)
                iOrder = (cmp == .orderedAscending) ? -1 : ((cmp == .orderedDescending) ? 1 : 0)
            case (.bool(let a), .bool(let b)):
                iOrder = (a == b) ? 0 : (a ? 1 : -1)
            default:
                iOrder = 0
            }
        }

        switch sOp
        {
        case "=":
            return .bool(iOrder == 0)
        case "<>":
            return .bool(iOrder != 0)
        case "<":
            return .bool(iOrder < 0)
        case ">":
            return .bool(iOrder > 0)
        case "<=":
            return .bool(iOrder <= 0)
        default:
            return .bool(iOrder >= 0)
        }

    }

    /// Excel ROUND: half away from zero, on the 15-significant-digit decimal value (so 2.675 -> 2.68).
    static func excelRound(_ d:Double, digits iDigits:Int)->Double
    {

        guard d.isFinite
        else
        {
            return d
        }

        var dDecimal:Decimal = Decimal(string:String(format:"%.15g", d), locale:Locale(identifier:"en_US_POSIX")) ?? Decimal(d)
        var dResult:Decimal  = Decimal()

        NSDecimalRound(&dResult, &dDecimal, iDigits, .plain)

        return (NSDecimalNumber(decimal:dResult).doubleValue)

    }

}   // End of final class AppXlsxFormulaEngine.
