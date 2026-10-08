//
//  AppXlsxWriter.swift
//  AnyPack
//
//  Created by Claude/Daryl Cox on 10/05/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import Foundation
import Compression

// <<CHICKEN-TRACKS>> (2026-10-05) Purpose-built SpreadsheetXMLWorkbook -> .xlsx writer.
//
// WHY NOT SwiftXLSX: it can't express per-side border weights, the source's fonts/number formats, row heights,
// row-level styles, frozen panes or sheet protection, and it has no way to store computed formula results - all
// of which the BigTest report needs (the colour shading / row markers are for Accounting; the cached formula
// results are what check_bigtest_xlsx.py reads via openpyxl data_only=True). This writer is Foundation +
// Compression only (no third-party dependency), so it is equally usable on iPad/iPhone/Mac.
//
// Formulas are converted R1C1 -> A1, written WITH a cached <v> from AppXlsxFormulaEngine, and the workbook is
// flagged fullCalcOnLoad so Excel recalculates everything on open regardless.

@JmEntityInfo(vers:"v1.0101")
final class AppXlsxWriter
{

    // MARK: - Style tables

    private var listFonts:[String]       = [String]()
    private var dictFonts:[String:Int]   = [String:Int]()
    private var listFills:[String]       = ["<fill><patternFill patternType=\"none\"/></fill>",
                                            "<fill><patternFill patternType=\"gray125\"/></fill>"]
    private var dictFills:[String:Int]   = [String:Int]()
    private var listBorders:[String]     = [String]()
    private var dictBorders:[String:Int] = [String:Int]()
    private var listNumFmts:[String]     = [String]()               // custom formatCode strings; id = 164 + index
    private var dictNumFmts:[String:Int] = [String:Int]()
    private var listXfs:[String]         = [String]()
    private var dictXfs:[String:Int]     = [String:Int]()           // StyleID -> xf index

    private var listSharedStrings:[String]     = [String]()
    private var dictSharedStrings:[String:Int] = [String:Int]()

    private let workbook:SpreadsheetXMLWorkbook
    private let engine:AppXlsxFormulaEngine

    private init(workbook:SpreadsheetXMLWorkbook)
    {
        self.workbook = workbook
        self.engine   = AppXlsxFormulaEngine(workbook:workbook)
    }

    // MARK: - Public entry point

    static func write(workbook:SpreadsheetXMLWorkbook, to url:URL) throws
    {

        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked - #(\(workbook.worksheets.count)) worksheet(s), #(\(workbook.styles.count)) style(s) to [\(url.path)]...")

        let writer:AppXlsxWriter = AppXlsxWriter(workbook:workbook)

        // xf 0 must be the workbook's Default style...

        _ = writer.xfIndex(forStyleID:"Default")

        var listSheetNames:[String] = [String]()
        var setUsed:Set<String>     = Set<String>()

        for (iSheet, worksheet) in workbook.worksheets.enumerated()
        {
            listSheetNames.append(AppXlsxConverter.uniqueSheetName(worksheet.name, index:iSheet, used:&setUsed))
        }

        // Build the sheet parts first (this populates the style + shared-string tables)...

        var listSheetXml:[Data] = [Data]()

        for (iSheet, worksheet) in workbook.worksheets.enumerated()
        {
            listSheetXml.append(Data(writer.sheetXml(worksheet, sheetIndex:iSheet).utf8))

            appLogMsg("\(sCurrMethodDisp) Built worksheet #(\(iSheet + 1)) of #(\(workbook.worksheets.count)) - [\(worksheet.name)]...")
        }

        let zip:AppZipWriter = try AppZipWriter(url:url)

        try zip.add(name:"[Content_Types].xml",   text:writer.contentTypesXml(sheetCount:listSheetXml.count))
        try zip.add(name:"_rels/.rels",           text:writer.rootRelsXml())
        try zip.add(name:"xl/workbook.xml",       text:writer.workbookXml(sheetNames:listSheetNames))
        try zip.add(name:"xl/_rels/workbook.xml.rels", text:writer.workbookRelsXml(sheetCount:listSheetXml.count))
        try zip.add(name:"xl/styles.xml",         text:writer.stylesXml())
        try zip.add(name:"xl/sharedStrings.xml",  text:writer.sharedStringsXml())

        for (iSheet, data) in listSheetXml.enumerated()
        {
            try zip.add(name:"xl/worksheets/sheet\(iSheet + 1).xml", data:data)
        }

        try zip.finish()

        appLogMsg("\(sCurrMethodDisp) Exiting - wrote [\(url.path)]...")

    }   // End of static func write(workbook:to:).

    // MARK: - Fixed parts

    private static let sXmlHead:String = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n"
    private static let sMainNS:String  = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    private static let sRelNS:String   = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"

    private func contentTypesXml(sheetCount iCount:Int)->String
    {

        var s:String = AppXlsxWriter.sXmlHead
        s += "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">"
        s += "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>"
        s += "<Default Extension=\"xml\" ContentType=\"application/xml\"/>"
        s += "<Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>"

        for i in 1...max(iCount, 1)
        {
            s += "<Override PartName=\"/xl/worksheets/sheet\(i).xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>"
        }

        s += "<Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>"
        s += "<Override PartName=\"/xl/sharedStrings.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml\"/>"
        s += "</Types>"

        return s

    }

    private func rootRelsXml()->String
    {

        return AppXlsxWriter.sXmlHead
             + "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
             + "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/>"
             + "</Relationships>"

    }

    private func workbookXml(sheetNames listNames:[String])->String
    {

        var s:String = AppXlsxWriter.sXmlHead
        s += "<workbook xmlns=\"\(AppXlsxWriter.sMainNS)\" xmlns:r=\"\(AppXlsxWriter.sRelNS)\">"
        s += "<bookViews><workbookView xWindow=\"0\" yWindow=\"0\" windowWidth=\"28800\" windowHeight=\"17500\"/></bookViews>"
        s += "<sheets>"

        for (i, sName) in listNames.enumerated()
        {
            s += "<sheet name=\"\(AppXlsxWriter.attr(sName))\" sheetId=\"\(i + 1)\" r:id=\"rId\(i + 1)\"/>"
        }

        s += "</sheets>"
        s += "<calcPr calcId=\"191029\" fullCalcOnLoad=\"1\"/>"
        s += "</workbook>"

        return s

    }

    private func workbookRelsXml(sheetCount iCount:Int)->String
    {

        var s:String = AppXlsxWriter.sXmlHead
        s += "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"

        for i in 1...max(iCount, 1)
        {
            s += "<Relationship Id=\"rId\(i)\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet\(i).xml\"/>"
        }

        s += "<Relationship Id=\"rId\(iCount + 1)\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>"
        s += "<Relationship Id=\"rId\(iCount + 2)\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings\" Target=\"sharedStrings.xml\"/>"
        s += "</Relationships>"

        return s

    }

    private func sharedStringsXml()->String
    {

        var s:String = AppXlsxWriter.sXmlHead
        s += "<sst xmlns=\"\(AppXlsxWriter.sMainNS)\" count=\"\(listSharedStrings.count)\" uniqueCount=\"\(listSharedStrings.count)\">"

        for sText in listSharedStrings
        {
            s += "<si><t xml:space=\"preserve\">\(AppXlsxWriter.text(sText))</t></si>"
        }

        s += "</sst>"

        return s

    }

    private func sharedStringIndex(_ sText:String)->Int
    {

        if let i = dictSharedStrings[sText]
        {
            return i
        }

        let i:Int = listSharedStrings.count

        listSharedStrings.append(sText)
        dictSharedStrings[sText] = i

        return i

    }

    // MARK: - Styles

    private func stylesXml()->String
    {

        var s:String = AppXlsxWriter.sXmlHead
        s += "<styleSheet xmlns=\"\(AppXlsxWriter.sMainNS)\">"

        if (!listNumFmts.isEmpty)
        {
            s += "<numFmts count=\"\(listNumFmts.count)\">"

            for (i, sCode) in listNumFmts.enumerated()
            {
                s += "<numFmt numFmtId=\"\(164 + i)\" formatCode=\"\(AppXlsxWriter.attr(sCode))\"/>"
            }

            s += "</numFmts>"
        }

        s += "<fonts count=\"\(listFonts.count)\">" + listFonts.joined() + "</fonts>"
        s += "<fills count=\"\(listFills.count)\">" + listFills.joined() + "</fills>"
        s += "<borders count=\"\(listBorders.count)\">" + listBorders.joined() + "</borders>"
        s += "<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>"
        s += "<cellXfs count=\"\(listXfs.count)\">" + listXfs.joined() + "</cellXfs>"
        s += "<cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles>"
        s += "</styleSheet>"

        return s

    }

    private func fontIndex(_ style:SpreadsheetXMLStyle)->Int
    {

        var s:String = "<font>"

        if (style.bold)      { s += "<b/>" }
        if (style.italic)    { s += "<i/>" }
        if (style.underline) { s += "<u/>" }

        s += "<sz val=\"\(AppXlsxFormulaEngine.numberText(style.fontSize ?? 11))\"/>"
        s += "<color rgb=\"\(AppXlsxWriter.argb(style.fontColor) ?? "FF000000")\"/>"
        s += "<name val=\"\(AppXlsxWriter.attr(style.fontName ?? "Calibri"))\"/>"
        s += "</font>"

        if let i = dictFonts[s]
        {
            return i
        }

        let i:Int = listFonts.count

        listFonts.append(s)
        dictFonts[s] = i

        return i

    }

    private func fillIndex(_ style:SpreadsheetXMLStyle)->Int
    {

        guard let sArgb = AppXlsxWriter.argb(style.fillColor)
        else
        {
            return 0
        }

        let s:String = "<fill><patternFill patternType=\"solid\"><fgColor rgb=\"\(sArgb)\"/><bgColor indexed=\"64\"/></patternFill></fill>"

        if let i = dictFills[s]
        {
            return i
        }

        let i:Int = listFills.count

        listFills.append(s)
        dictFills[s] = i

        return i

    }

    private func borderIndex(_ style:SpreadsheetXMLStyle)->Int
    {

        func side(_ sElement:String, _ sPosition:String)->String
        {
            guard let iWeight = style.borders[sPosition]
            else
            {
                return "<\(sElement)/>"
            }

            let sStyle:String = (iWeight >= 3) ? "thick" : ((iWeight == 2) ? "medium" : "thin")

            return "<\(sElement) style=\"\(sStyle)\"><color auto=\"1\"/></\(sElement)>"
        }

        let s:String = "<border>" + side("left", "Left") + side("right", "Right") + side("top", "Top") + side("bottom", "Bottom") + "<diagonal/></border>"

        if let i = dictBorders[s]
        {
            return i
        }

        let i:Int = listBorders.count

        listBorders.append(s)
        dictBorders[s] = i

        return i

    }

    private func numFmtId(_ style:SpreadsheetXMLStyle)->Int
    {

        guard let sFormat = style.numberFormat, !sFormat.isEmpty, sFormat.lowercased() != "general"
        else
        {
            return 0
        }

        if let i = dictNumFmts[sFormat]
        {
            return (164 + i)
        }

        let i:Int = listNumFmts.count

        listNumFmts.append(sFormat)
        dictNumFmts[sFormat] = i

        return (164 + i)

    }

    private func xfIndex(forStyleID sStyleID:String?)->Int
    {

        let sKey:String = (sStyleID ?? "Default")

        if let i = dictXfs[sKey]
        {
            return i
        }

        // First style ever requested also seeds the (mandatory) first border...

        if (listBorders.isEmpty)
        {
            _ = borderIndex(SpreadsheetXMLStyle())
        }

        // Unknown IDs fall back to the Default style, then to a blank style...

        let style:SpreadsheetXMLStyle = (workbook.styles[sKey] ?? workbook.styles["Default"] ?? SpreadsheetXMLStyle())

        if (workbook.styles[sKey] == nil && sKey != "Default")
        {
            let i:Int = xfIndex(forStyleID:"Default")
            dictXfs[sKey] = i
            return i
        }

        let iFont:Int   = fontIndex(style)
        let iFill:Int   = fillIndex(style)
        let iBorder:Int = borderIndex(style)
        let iFmt:Int    = numFmtId(style)

        var s:String = "<xf numFmtId=\"\(iFmt)\" fontId=\"\(iFont)\" fillId=\"\(iFill)\" borderId=\"\(iBorder)\" xfId=\"0\""
        s += " applyNumberFormat=\"1\" applyFont=\"1\" applyFill=\"1\" applyBorder=\"1\" applyAlignment=\"1\" applyProtection=\"1\">"

        s += "<alignment"

        if let sH = style.horizontal { s += " horizontal=\"\(AppXlsxWriter.hAlign(sH))\"" }
        if let sV = style.vertical   { s += " vertical=\"\(AppXlsxWriter.vAlign(sV))\"" }
        if (style.wrapText)          { s += " wrapText=\"1\"" }

        s += "/>"
        s += "<protection locked=\"\(style.isLocked ? 1 : 0)\"/>"
        s += "</xf>"

        let i:Int = listXfs.count

        listXfs.append(s)
        dictXfs[sKey] = i

        return i

    }

    // MARK: - Worksheet

    private func sheetXml(_ worksheet:SpreadsheetXMLWorksheet, sheetIndex iSheet:Int)->String
    {

        var iMaxRow:Int = 0
        var iMaxCol:Int = 0

        for row in worksheet.rows
        {
            iMaxRow = max(iMaxRow, row.rowIndex + 1)

            for cell in row.cells
            {
                iMaxCol = max(iMaxCol, cell.columnIndex + 1)
            }
        }

        var s:String = String()

        s.reserveCapacity(max(worksheet.totalCellCount, 1) * 90)

        s += AppXlsxWriter.sXmlHead
        s += "<worksheet xmlns=\"\(AppXlsxWriter.sMainNS)\" xmlns:r=\"\(AppXlsxWriter.sRelNS)\">"
        s += "<dimension ref=\"A1:\(AppXlsxWriter.colName(max(iMaxCol, 1) - 1))\(max(iMaxRow, 1))\"/>"

        // Views (+ frozen panes)...

        s += "<sheetViews><sheetView\(iSheet == 0 ? " tabSelected=\"1\"" : "") workbookViewId=\"0\">"

        if (worksheet.freezeRows > 0 || worksheet.freezeColumns > 0)
        {
            let sTopLeft:String = "\(AppXlsxWriter.colName(worksheet.freezeColumns))\(worksheet.freezeRows + 1)"
            let sPane:String    = ((worksheet.freezeRows > 0 && worksheet.freezeColumns > 0) ? "bottomRight"
                                                                                             : (worksheet.freezeRows > 0 ? "bottomLeft" : "topRight"))

            s += "<pane"

            if (worksheet.freezeColumns > 0) { s += " xSplit=\"\(worksheet.freezeColumns)\"" }
            if (worksheet.freezeRows    > 0) { s += " ySplit=\"\(worksheet.freezeRows)\"" }

            s += " topLeftCell=\"\(sTopLeft)\" activePane=\"\(sPane)\" state=\"frozen\"/>"
            s += "<selection pane=\"\(sPane)\" activeCell=\"\(sTopLeft)\" sqref=\"\(sTopLeft)\"/>"
        }

        s += "</sheetView></sheetViews>"

        // Default row height / column widths (SpreadsheetML points -> xlsx character units: pt / 7, as Excel itself converts)...

        let dDefRow:Double = (worksheet.defaultRowHeight ?? 15)
        let dDefCol:Double = ((worksheet.defaultColumnWidth ?? 64) / 7.0)

        s += "<sheetFormatPr baseColWidth=\"10\" defaultColWidth=\"\(AppXlsxFormulaEngine.numberText(dDefCol))\" defaultRowHeight=\"\(AppXlsxFormulaEngine.numberText(dDefRow))\" customHeight=\"1\"/>"

        if (!worksheet.columnWidths.isEmpty)
        {
            s += "<cols>"

            let listCols:[Int] = worksheet.columnWidths.keys.sorted()
            var i:Int          = 0

            while (i < listCols.count)
            {
                let iStart:Int   = listCols[i]
                let dWidth:Double = (worksheet.columnWidths[iStart] ?? 0)
                var iEnd:Int     = iStart

                // Collapse runs of adjacent columns having the same width...

                while ((i + 1) < listCols.count && listCols[i + 1] == (iEnd + 1) && worksheet.columnWidths[listCols[i + 1]] == dWidth)
                {
                    iEnd += 1
                    i    += 1
                }

                s += "<col min=\"\(iStart + 1)\" max=\"\(iEnd + 1)\" width=\"\(AppXlsxFormulaEngine.numberText(dWidth / 7.0))\" customWidth=\"1\"/>"

                i += 1
            }

            s += "</cols>"
        }

        // Data...

        s += "<sheetData>"

        var listMerges:[String] = [String]()

        for row in worksheet.rows.sorted(by:{ $0.rowIndex < $1.rowIndex })
        {
            let iXRow:Int = (row.rowIndex + 1)

            s += "<row r=\"\(iXRow)\""

            if let sRowStyle = row.styleID
            {
                s += " s=\"\(xfIndex(forStyleID:sRowStyle))\" customFormat=\"1\""
            }

            if let dHeight = row.height
            {
                s += " ht=\"\(AppXlsxFormulaEngine.numberText(dHeight))\" customHeight=\"1\""
            }

            if (row.isHidden)
            {
                s += " hidden=\"1\""
            }

            s += ">"

            for cell in row.cells.sorted(by:{ $0.columnIndex < $1.columnIndex })
            {
                let sRef:String = "\(AppXlsxWriter.colName(cell.columnIndex))\(iXRow)"
                // A cell with no StyleID of its own takes its row's style (that is how Excel reads SpreadsheetML)...
                let iXf:Int     = xfIndex(forStyleID:(cell.styleID ?? row.styleID))

                if (cell.mergeAcross > 0 || cell.mergeDown > 0)
                {
                    listMerges.append("\(sRef):\(AppXlsxWriter.colName(cell.columnIndex + cell.mergeAcross))\(iXRow + cell.mergeDown)")
                }

                if let sFormula = cell.formula, !sFormula.isEmpty
                {
                    let value:AppXlsxValue = engine.cellValue(sheet:iSheet, row:row.rowIndex, col:cell.columnIndex)

                    s += "<c r=\"\(sRef)\" s=\"\(iXf)\""

                    var sV:String = ""

                    switch value
                    {
                    case .number(let d):
                        sV = "<v>\(AppXlsxWriter.numberString(d))</v>"
                    case .text(let t):
                        s += " t=\"str\""
                        sV = "<v>\(AppXlsxWriter.text(t))</v>"
                    case .bool(let b):
                        s += " t=\"b\""
                        sV = "<v>\(b ? 1 : 0)</v>"
                    case .error(let e):
                        s += " t=\"e\""
                        sV = "<v>\(AppXlsxWriter.text(e))</v>"
                    case .empty:
                        sV = "<v>0</v>"
                    }

                    s += "><f>\(AppXlsxWriter.text(AppXlsxWriter.r1c1ToA1(sFormula, row:row.rowIndex, col:cell.columnIndex)))</f>\(sV)</c>"
                    continue
                }

                if cell.value.isEmpty
                {
                    if (cell.hasData && cell.type == .string)
                    {
                        s += "<c r=\"\(sRef)\" s=\"\(iXf)\" t=\"s\"><v>\(sharedStringIndex(""))</v></c>"       // like Excel: an empty-text cell...
                    }
                    else
                    {
                        s += "<c r=\"\(sRef)\" s=\"\(iXf)\"/>"
                    }

                    continue
                }

                switch cell.type
                {
                case .number:
                    if let d = Double(cell.value)
                    {
                        s += "<c r=\"\(sRef)\" s=\"\(iXf)\"><v>\(AppXlsxWriter.numberString(d))</v></c>"
                    }
                    else
                    {
                        s += "<c r=\"\(sRef)\" s=\"\(iXf)\" t=\"s\"><v>\(sharedStringIndex(cell.value))</v></c>"
                    }
                case .boolean:
                    s += "<c r=\"\(sRef)\" s=\"\(iXf)\" t=\"b\"><v>\((cell.value == "1" || cell.value.lowercased() == "true") ? 1 : 0)</v></c>"
                default:
                    s += "<c r=\"\(sRef)\" s=\"\(iXf)\" t=\"s\"><v>\(sharedStringIndex(cell.value))</v></c>"
                }
            }

            s += "</row>"
        }

        s += "</sheetData>"

        if (worksheet.isProtected)
        {
            s += "<sheetProtection sheet=\"1\"/>"
        }

        if (!listMerges.isEmpty)
        {
            s += "<mergeCells count=\"\(listMerges.count)\">"

            for sMerge in listMerges
            {
                s += "<mergeCell ref=\"\(sMerge)\"/>"
            }

            s += "</mergeCells>"
        }

        s += "<pageMargins left=\"0.7\" right=\"0.7\" top=\"0.75\" bottom=\"0.75\" header=\"0.3\" footer=\"0.3\"/>"
        s += "</worksheet>"

        return s

    }   // End of private func sheetXml(_:sheetIndex:).

    // MARK: - Helpers

    static func colName(_ iZeroBased:Int)->String
    {

        var iNum:Int    = (iZeroBased + 1)
        var sName:String = ""

        while (iNum > 0)
        {
            let iRem:Int = ((iNum - 1) % 26)

            sName = String(UnicodeScalar(UInt8(65 + iRem))) + sName
            iNum  = ((iNum - 1) / 26)
        }

        return sName

    }

    private static func numberString(_ d:Double)->String
    {
        return ((d == d.rounded() && abs(d) < 1e15) ? String(Int64(d)) : "\(d)")
    }

    /// "#RRGGBB" -> "FFRRGGBB"
    private static func argb(_ sHex:String?)->String?
    {

        guard var s = sHex
        else
        {
            return nil
        }

        if s.hasPrefix("#") { s.removeFirst() }

        guard s.count == 6, s.allSatisfy({ $0.isHexDigit })
        else
        {
            return nil
        }

        return ("FF" + s.uppercased())

    }

    private static func hAlign(_ s:String)->String
    {
        switch s.lowercased()
        {
        case "center":
            return "center"
        case "right":
            return "right"
        case "justify":
            return "justify"
        case "fill":
            return "fill"
        case "centeracrossselection":
            return "centerContinuous"
        case "distributed":
            return "distributed"
        default:
            return "left"
        }
    }

    private static func vAlign(_ s:String)->String
    {
        switch s.lowercased()
        {
        case "top":
            return "top"
        case "center":
            return "center"
        case "justify":
            return "justify"
        case "distributed":
            return "distributed"
        default:
            return "bottom"
        }
    }

    /// XML text/attribute escaping, dropping characters that are illegal in XML 1.0.
    private static func text(_ s:String)->String
    {

        var out:String = String()

        out.reserveCapacity(s.utf8.count)

        for u in s.unicodeScalars
        {
            switch u
            {
            case "&":
                out += "&amp;"
            case "<":
                out += "&lt;"
            case ">":
                out += "&gt;"
            case "\"":
                out += "&quot;"
            default:
                if (u.value >= 0x20 || u.value == 0x09 || u.value == 0x0A || u.value == 0x0D)
                {
                    out.unicodeScalars.append(u)
                }
            }
        }

        return out

    }

    private static func attr(_ s:String)->String
    {
        return text(s)
    }

    /// SpreadsheetML formulas are R1C1 ("=RC[-2]-R[1]C"); .xlsx wants A1 ("C5-B6"), without the leading "=".
    static func r1c1ToA1(_ sFormula:String, row iRow:Int, col iCol:Int)->String
    {

        let chars:[Character]  = Array(sFormula.hasPrefix("=") ? String(sFormula.dropFirst()) : sFormula)
        var out:String         = String()
        var i:Int              = 0

        func isIdent(_ c:Character)->Bool
        {
            return (c.isLetter || c.isNumber || c == "_" || c == ".")
        }

        // Parses "[n]" / digits / nothing at 'i', returns (isAbsolute, value) or nil...

        func axis()->(Bool, Int)?
        {
            if (i < chars.count && chars[i] == "[")
            {
                var j:Int       = (i + 1)
                var sNum:String = ""

                while (j < chars.count && (chars[j].isNumber || chars[j] == "-" || chars[j] == "+"))
                {
                    sNum.append(chars[j])
                    j += 1
                }

                guard j < chars.count, chars[j] == "]", let n = Int(sNum.hasPrefix("+") ? String(sNum.dropFirst()) : sNum)
                else
                {
                    return nil
                }

                i = (j + 1)

                return (false, n)
            }

            var sDigits:String = ""

            while (i < chars.count && chars[i].isNumber)
            {
                sDigits.append(chars[i])
                i += 1
            }

            if sDigits.isEmpty
            {
                return (false, 0)
            }

            guard let n = Int(sDigits)
            else
            {
                return nil
            }

            return (true, n)
        }

        while (i < chars.count)
        {
            let c:Character = chars[i]

            // String literal - copy verbatim...

            if (c == "\"")
            {
                out.append(c)
                i += 1

                while (i < chars.count)
                {
                    out.append(chars[i])

                    if (chars[i] == "\"")
                    {
                        if (i + 1 < chars.count && chars[i + 1] == "\"")
                        {
                            out.append("\"")
                            i += 2
                            continue
                        }

                        i += 1
                        break
                    }

                    i += 1
                }

                continue
            }

            // Quoted sheet name - copy verbatim...

            if (c == "'")
            {
                out.append(c)
                i += 1

                while (i < chars.count)
                {
                    out.append(chars[i])

                    if (chars[i] == "'")
                    {
                        if (i + 1 < chars.count && chars[i + 1] == "'")
                        {
                            out.append("'")
                            i += 2
                            continue
                        }

                        i += 1
                        break
                    }

                    i += 1
                }

                continue
            }

            // Possible R1C1 reference (only at the start of a token)...

            if ((c == "R" || c == "r") && (i == 0 || !isIdent(chars[i - 1])))
            {
                let iSave:Int = i

                i += 1

                if let r = axis(), i < chars.count, (chars[i] == "C" || chars[i] == "c")
                {
                    i += 1

                    if let col = axis(), !(i < chars.count && (isIdent(chars[i]) || chars[i] == "("))
                    {
                        // Relative offsets wrap around the sheet edges, exactly as Excel does...

                        let iMaxR:Int   = AppXlsxFormulaEngine.cMaxRows
                        let iMaxC:Int   = AppXlsxFormulaEngine.cMaxCols
                        let iRowNum:Int = (r.0   ? r.1         : ((((iRow + r.1)   % iMaxR) + iMaxR) % iMaxR) + 1)
                        let iColIdx:Int = (col.0 ? (col.1 - 1) : ((((iCol + col.1) % iMaxC) + iMaxC) % iMaxC))

                        out += (col.0 ? "$" : "") + colName(iColIdx) + (r.0 ? "$" : "") + String(iRowNum)

                        continue
                    }
                }

                i = iSave
            }

            out.append(c)
            i += 1
        }

        return out

    }   // End of static func r1c1ToA1(_:row:col:).

}   // End of final class AppXlsxWriter.

// MARK: - Minimal ZIP writer (deflate via Compression framework)

@JmEntityInfo(vers:"v1.0101")
final class AppZipWriter
{

    private struct Entry
    {
        var name:[UInt8]
        var crc:UInt32
        var compressedSize:UInt32
        var size:UInt32
        var method:UInt16
        var offset:UInt32
    }

    private let handle:FileHandle
    private var entries:[Entry]   = [Entry]()
    private var iOffset:UInt64    = 0

    private static let crcTable:[UInt32] = {
        (0..<256).map
        { (n:Int) -> UInt32 in
            var c:UInt32 = UInt32(n)
            for _ in 0..<8 { c = ((c & 1) != 0) ? (0xEDB88320 ^ (c >> 1)) : (c >> 1) }
            return c
        }
    }()

    init(url:URL) throws
    {
        try? FileManager.default.removeItem(at:url)

        guard FileManager.default.createFile(atPath:url.path, contents:nil)
        else
        {
            throw AppXlsxError.writeFailed("cannot create [\(url.path)]")
        }

        self.handle = try FileHandle(forWritingTo:url)
    }

    func add(name sName:String, text sText:String) throws
    {
        try add(name:sName, data:Data(sText.utf8))
    }

    func add(name sName:String, data:Data) throws
    {

        var crc:UInt32 = 0xFFFFFFFF

        data.withUnsafeBytes
        { (raw:UnsafeRawBufferPointer) in
            for b in raw
            {
                crc = AppZipWriter.crcTable[Int((crc ^ UInt32(b)) & 0xFF)] ^ (crc >> 8)
            }
        }

        crc = ~crc

        var payload:Data = data
        var method:UInt16 = 0

        if (data.count > 64), let deflated = AppZipWriter.deflate(data), deflated.count < data.count
        {
            payload = deflated
            method  = 8
        }

        guard (iOffset + UInt64(payload.count)) < 0xFFFF0000, data.count < 0xFFFF0000
        else
        {
            throw AppXlsxError.writeFailed("workbook is too large for a (non-ZIP64) .xlsx package")
        }

        let nameBytes:[UInt8] = Array(sName.utf8)

        var header:Data = Data()

        header.appendLE32(0x04034B50)
        header.appendLE16(20)                       // version needed
        header.appendLE16(0)                        // flags
        header.appendLE16(method)
        header.appendLE16(0)                        // mod time
        header.appendLE16(0x0021)                   // mod date 1980-01-01
        header.appendLE32(crc)
        header.appendLE32(UInt32(payload.count))
        header.appendLE32(UInt32(data.count))
        header.appendLE16(UInt16(nameBytes.count))
        header.appendLE16(0)                        // extra length
        header.append(contentsOf:nameBytes)

        entries.append(Entry(name:nameBytes, crc:crc, compressedSize:UInt32(payload.count), size:UInt32(data.count), method:method, offset:UInt32(iOffset)))

        try handle.write(contentsOf:header)
        try handle.write(contentsOf:payload)

        iOffset += UInt64(header.count + payload.count)

    }   // End of func add(name:data:).

    func finish() throws
    {

        let iCdStart:UInt64 = iOffset
        var cd:Data         = Data()

        for e in entries
        {
            cd.appendLE32(0x02014B50)
            cd.appendLE16(20)                       // version made by
            cd.appendLE16(20)                       // version needed
            cd.appendLE16(0)
            cd.appendLE16(e.method)
            cd.appendLE16(0)
            cd.appendLE16(0x0021)
            cd.appendLE32(e.crc)
            cd.appendLE32(e.compressedSize)
            cd.appendLE32(e.size)
            cd.appendLE16(UInt16(e.name.count))
            cd.appendLE16(0)                        // extra
            cd.appendLE16(0)                        // comment
            cd.appendLE16(0)                        // disk start
            cd.appendLE16(0)                        // internal attrs
            cd.appendLE32(0)                        // external attrs
            cd.appendLE32(e.offset)
            cd.append(contentsOf:e.name)
        }

        var end:Data = Data()

        end.appendLE32(0x06054B50)
        end.appendLE16(0)
        end.appendLE16(0)
        end.appendLE16(UInt16(entries.count))
        end.appendLE16(UInt16(entries.count))
        end.appendLE32(UInt32(cd.count))
        end.appendLE32(UInt32(iCdStart))
        end.appendLE16(0)

        try handle.write(contentsOf:cd)
        try handle.write(contentsOf:end)
        try handle.close()

    }   // End of func finish().

    /// Raw DEFLATE (RFC 1951) - what a ZIP 'method 8' entry holds; Apple's COMPRESSION_ZLIB emits exactly that.
    private static func deflate(_ data:Data)->Data?
    {

        let iCap:Int = (data.count + (data.count / 8) + 1024)
        let dst:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity:iCap)

        defer { dst.deallocate() }

        let iSize:Int = data.withUnsafeBytes
        { (raw:UnsafeRawBufferPointer) -> Int in
            guard let base = raw.bindMemory(to:UInt8.self).baseAddress
            else
            {
                return 0
            }

            return compression_encode_buffer(dst, iCap, base, data.count, nil, COMPRESSION_ZLIB)
        }

        guard iSize > 0
        else
        {
            return nil
        }

        return Data(bytes:dst, count:iSize)

    }

}   // End of final class AppZipWriter.

private extension Data
{

    mutating func appendLE16(_ v:UInt16)
    {
        append(UInt8(v & 0xFF))
        append(UInt8((v >> 8) & 0xFF))
    }

    mutating func appendLE32(_ v:UInt32)
    {
        append(UInt8(v & 0xFF))
        append(UInt8((v >> 8) & 0xFF))
        append(UInt8((v >> 16) & 0xFF))
        append(UInt8((v >> 24) & 0xFF))
    }

}
