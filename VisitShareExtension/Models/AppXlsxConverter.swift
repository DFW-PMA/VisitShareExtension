//
//  AppXlsxConverter.swift
//  AnyPack
//
//  Created by Claude/Daryl Cox on 10/05/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import Foundation
import SwiftXLSX                // Write side - VMA's local (write-only) package, vendored in Local_Packages...
import CoreXLSX                 // Read  side - CoreOffice/CoreXLSX (read-only)...

// <<CHICKEN-TRACKS>> (2026-10-05) Bi-directional .xlsx support for AnyPack - prep for putting
// JMABigTestReview on iOS. Both directions go through the existing SpreadsheetXML* model
// (SpreadsheetXMLWorkbook/Worksheet/Row/Cell) so the viewer, CSV export, etc. all work unchanged:
//
//     SpreadsheetML .xls/.xml  --SpreadsheetXMLParser-->  SpreadsheetXMLWorkbook  --writeXlsx-->  .xlsx
//     .xlsx                    --readXlsx-->              SpreadsheetXMLWorkbook  (displayed as-is)
//
// Fidelity decision: every cell is written through as plain TEXT (the raw SpreadsheetXML string),
// never reinterpreted as a native numeric/date XLSX type - the BigTest checks regex-match the raw
// cell strings, and this avoids any type-coercion surprises on the reading side. Fonts/fills/borders
// are not carried (the XML model only holds a styleID string anyway).

enum AppXlsxError:LocalizedError
{

    case noWorksheets
    case cannotOpen(String)
    case noWorkbookInfo
    case writeFailed(String)

    var errorDescription:String?
    {
        switch self
        {
        case .noWorksheets:
            return "The workbook has no worksheet(s) to convert."
        case .cannotOpen(let sPath):
            return "Unable to open [\(sPath)] as an .xlsx file (not a valid .xlsx/zip package)."
        case .noWorkbookInfo:
            return "The .xlsx file contains no workbook/worksheet information."
        case .writeFailed(let sMsg):
            return "Failed to write the .xlsx file: \(sMsg)"
        }
    }

}   // End of enum AppXlsxError:LocalizedError.

@JmEntityInfo(vers:"v1.0202")
struct AppXlsxConverter
{

    // MARK: - Write (SpreadsheetXMLWorkbook -> .xlsx)

    /// <<CHICKEN-TRACKS>> (2026-10-05) Full-fidelity writer (styles, borders, widths, frozen panes, formulas +
    /// cached results) - see AppXlsxWriter. Writes into the temp directory and returns the file's URL.
    static func writeXlsx(workbook:SpreadsheetXMLWorkbook, sXlsxFilename:String)->Result<URL, Error>
    {

        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        guard !workbook.worksheets.isEmpty
        else
        {
            return .failure(AppXlsxError.noWorksheets)
        }

        let url:URL = FileManager.default.temporaryDirectory.appendingPathComponent(sXlsxFilename)

        do
        {
            try AppXlsxWriter.write(workbook:workbook, to:url)

            return .success(url)
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Failed - Error: [\(error)]...")

            return .failure(error)
        }

    }   // End of static func writeXlsx(workbook:sXlsxFilename:).

    /// Same, but off the caller's thread, on a thread with a big stack (the formula engine recurses through
    /// dependent cells). Safe to await from the main actor.
    static func writeXlsxAsync(workbook:SpreadsheetXMLWorkbook, sXlsxFilename:String) async -> Result<URL, Error>
    {

        return await withCheckedContinuation
        { (continuation:CheckedContinuation<Result<URL, Error>, Never>) in

            let thread:Thread = Thread
            {
                continuation.resume(returning:AppXlsxConverter.writeXlsx(workbook:workbook, sXlsxFilename:sXlsxFilename))
            }

            thread.stackSize = (256 * 1024 * 1024)
            thread.qualityOfService = .userInitiated
            thread.start()
        }

    }   // End of static func writeXlsxAsync(workbook:sXlsxFilename:).

    // <<CHICKEN-TRACKS>> (2026-10-05) Original SwiftXLSX-based writer, retired (lost fills/borders/fonts/formulas) -
    //                    kept per the no-deletion policy, no longer called.
    static func writeXlsxViaSwiftXLSX(workbook:SpreadsheetXMLWorkbook, sXlsxFilename:String)->Result<URL, Error>
    {

        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked - for 'workbook' of [\(workbook.fileName)] with #(\(workbook.worksheets.count)) worksheet(s) and 'sXlsxFilename' of [\(sXlsxFilename)]...")

        guard !workbook.worksheets.isEmpty
        else
        {
            appLogMsg("\(sCurrMethodDisp) The workbook has no worksheet(s) - Error!")

            return .failure(AppXlsxError.noWorksheets)
        }

        let xlsxWorkBook:XWorkBook = XWorkBook()
        var setUsedNames:Set<String> = Set<String>()

        for (iSheetIdx, worksheet) in workbook.worksheets.enumerated()
        {
            let sSheetName:String = uniqueSheetName(worksheet.name, index:iSheetIdx, used:&setUsedNames)
            let xlsxSheet:XSheet  = xlsxWorkBook.NewSheet(sSheetName)

            var dictColMaxLen:[Int:Int] = [Int:Int]()
            var cCellsWritten:Int       = 0

            for row in worksheet.rows
            {
                for cell in row.cells
                {
                    let bIsMergeOrigin:Bool = (cell.mergeAcross > 0 || cell.mergeDown > 0)

                    // Empty, un-merged cells carry nothing - skip them (keeps the file small)...

                    if (cell.value.isEmpty && !bIsMergeOrigin)
                    {
                        continue
                    }

                    let iXRow:Int = (row.rowIndex    + 1)           // SpreadsheetXML model is 0-based, SwiftXLSX is 1-based...
                    let iXCol:Int = (cell.columnIndex + 1)

                    let xlsxCell:XCell        = xlsxSheet.AddCell(XCoords(row:iXRow, col:iXCol))
                    xlsxCell.value            = .text(cell.value)
                    xlsxCell.alignmentHorizontal = .left

                    cCellsWritten += 1

                    // Track the longest (first line) text per column for a sane column width...

                    let iLineLen:Int = (cell.value.components(separatedBy:"\n").map { $0.count }.max() ?? 0)

                    if (cell.mergeAcross == 0 && iLineLen > (dictColMaxLen[iXCol] ?? 0))
                    {
                        dictColMaxLen[iXCol] = iLineLen
                    }

                    if (bIsMergeOrigin)
                    {
                        xlsxSheet.MergeRect(XRect(iXRow, iXCol, (cell.mergeAcross + 1), (cell.mergeDown + 1)))
                    }
                }
            }

            // A worksheet with no cells at all still needs one cell so SwiftXLSX has something to size...

            if (cCellsWritten == 0)
            {
                let xlsxCell:XCell = xlsxSheet.AddCell(XCoords(row:1, col:1))
                xlsxCell.value     = .text("")
            }

            xlsxSheet.buildindex()

            for (iXCol, iMaxLen) in dictColMaxLen
            {
                xlsxSheet.ForColumnSetWidth(iXCol, min(max((iMaxLen * 8) + 20, 60), 500))
            }

            appLogMsg("\(sCurrMethodDisp) Converted worksheet [\(sSheetName)] - #(\(cCellsWritten)) cell(s) written...")
        }

        let sXlsxFilespec:String = xlsxWorkBook.save(sXlsxFilename)

        guard FileManager.default.fileExists(atPath:sXlsxFilespec)
        else
        {
            appLogMsg("\(sCurrMethodDisp) 'save' returned a 'sXlsxFilespec' of [\(sXlsxFilespec)] but the file is NOT present - Error!")

            return .failure(AppXlsxError.writeFailed("SwiftXLSX did not produce [\(sXlsxFilename)]"))
        }

        appLogMsg("\(sCurrMethodDisp) Created .xlsx file [\(sXlsxFilespec)]...")

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return .success(URL(fileURLWithPath:sXlsxFilespec))

    }   // End of static func writeXlsx(workbook:sXlsxFilename:).

    // MARK: - Read (.xlsx -> SpreadsheetXMLWorkbook)

    static func readXlsx(url:URL)->Result<SpreadsheetXMLWorkbook, Error>
    {

        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked - for 'url' of [\(url.path)]...")

        guard let xlsxFile = XLSXFile(filepath:url.path)
        else
        {
            appLogMsg("\(sCurrMethodDisp) XLSXFile could not open [\(url.path)] - Error!")

            return .failure(AppXlsxError.cannotOpen(url.lastPathComponent))
        }

        do
        {
            let listWorkbooks:[Workbook] = try xlsxFile.parseWorkbooks()

            guard let xlsxWorkbook = listWorkbooks.first
            else
            {
                return .failure(AppXlsxError.noWorkbookInfo)
            }

            let sharedStrings:SharedStrings?                     = try xlsxFile.parseSharedStrings()
            let listSheets:[(name:String?, path:String)]         = try xlsxFile.parseWorksheetPathsAndNames(workbook:xlsxWorkbook)

            var workbook:SpreadsheetXMLWorkbook = SpreadsheetXMLWorkbook()
            workbook.fileName                   = url.lastPathComponent
            workbook.fileURL                    = url

            for (iSheetIdx, sheetInfo) in listSheets.enumerated()
            {
                let xlsxWorksheet:Worksheet = try xlsxFile.parseWorksheet(at:sheetInfo.path)

                var worksheet:SpreadsheetXMLWorksheet = SpreadsheetXMLWorksheet()
                worksheet.name                        = (sheetInfo.name ?? "Sheet\(iSheetIdx + 1)")

                var iMaxRow:Int = -1
                var iMaxCol:Int = -1

                for xlsxRow in xlsxWorksheet.data?.rows ?? []
                {
                    var row:SpreadsheetXMLRow = SpreadsheetXMLRow()
                    row.rowIndex              = (Int(xlsxRow.reference) - 1)        // Back to the 0-based model...
                    row.height                = xlsxRow.height

                    for xlsxCell in xlsxRow.cells
                    {
                        var cell:SpreadsheetXMLCell = SpreadsheetXMLCell()
                        cell.columnIndex            = (columnNumber(xlsxCell.reference.column.value) - 1)
                        cell.formula                = xlsxCell.formula?.value

                        // Shared string first, then inline string, then the raw <v> value...

                        if let sharedStrings = sharedStrings,
                           let sShared       = xlsxCell.stringValue(sharedStrings)
                        {
                            cell.value = sShared
                        }
                        else if let sInline = xlsxCell.inlineString?.text
                        {
                            cell.value = sInline
                        }
                        else
                        {
                            cell.value = (xlsxCell.value ?? "")
                        }

                        switch xlsxCell.type
                        {
                        case .number?:
                            cell.type = .number
                        case .bool?:
                            cell.type = .boolean
                        case .date?:
                            cell.type = .dateTime
                        case .error?:
                            cell.type = .error
                        default:
                            // nil <t> means a plain number in OOXML - keep text-vs-number honest...
                            cell.type = ((xlsxCell.type == nil && Double(cell.value) != nil) ? .number : .string)
                        }

                        // Skip fully-empty cells (style-only placeholders)...

                        if (cell.value.isEmpty && cell.formula == nil)
                        {
                            continue
                        }

                        row.cells.append(cell)

                        iMaxCol = max(iMaxCol, cell.columnIndex)
                    }

                    iMaxRow = max(iMaxRow, row.rowIndex)

                    if (!row.cells.isEmpty)
                    {
                        worksheet.rows.append(row)
                    }
                }

                // Apply merged ranges ("A1:C2") to the origin cell's mergeAcross/mergeDown...

                for mergeCell in xlsxWorksheet.mergeCells?.items ?? []
                {
                    let listParts:[String] = mergeCell.reference.components(separatedBy:":")

                    guard listParts.count == 2,
                          let (iCol1, iRow1) = cellAddress(listParts[0]),
                          let (iCol2, iRow2) = cellAddress(listParts[1])
                    else
                    {
                        continue
                    }

                    if let iRowPos  = worksheet.rows.firstIndex(where: { $0.rowIndex == (iRow1 - 1) }),
                       let iCellPos = worksheet.rows[iRowPos].cells.firstIndex(where: { $0.columnIndex == (iCol1 - 1) })
                    {
                        worksheet.rows[iRowPos].cells[iCellPos].mergeAcross = max(iCol2 - iCol1, 0)
                        worksheet.rows[iRowPos].cells[iCellPos].mergeDown   = max(iRow2 - iRow1, 0)
                    }
                }

                worksheet.rowCount    = (iMaxRow + 1)
                worksheet.columnCount = (iMaxCol + 1)

                appLogMsg("\(sCurrMethodDisp) Read worksheet [\(worksheet.name)] - #(\(worksheet.rowCount)) row(s), #(\(worksheet.columnCount)) column(s), #(\(worksheet.totalCellCount)) cell(s)...")

                workbook.worksheets.append(worksheet)
            }

            // Exit...

            appLogMsg("\(sCurrMethodDisp) Exiting - #(\(workbook.worksheets.count)) worksheet(s)...")

            return .success(workbook)
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Failed to read [\(url.path)] - Error: [\(error)]...")

            return .failure(error)
        }

    }   // End of static func readXlsx(url:).

    // MARK: - Helpers

    /// Excel sheet names: max 31 chars, none of  : \ / ? * [ ]  and unique within the workbook.
    static func uniqueSheetName(_ sName:String, index:Int, used:inout Set<String>)->String
    {

        var sClean:String = sName

        for sBad in [":", "\\", "/", "?", "*", "[", "]"]
        {
            sClean = sClean.replacingOccurrences(of:sBad, with:" ")
        }

        // <<CHICKEN-TRACKS>> (2026-10-05) NO whitespace trimming: a sheet name like 'Eric Powell  Admin ' (trailing
        //                    space) is legal, formulas reference it verbatim, and trimming it made Excel treat those
        //                    references as links to an EXTERNAL workbook (the "contains links to external sources" prompt).
    //  sClean = sClean.trimmingCharacters(in:.whitespaces)

        if (sClean.trimmingCharacters(in:.whitespaces).isEmpty)
        {
            sClean = "Sheet\(index + 1)"
        }

        var sCandidate:String = String(sClean.prefix(31))
        var iSuffix:Int       = 2

        while (used.contains(sCandidate.lowercased()))
        {
            let sTail:String = " (\(iSuffix))"

            sCandidate = String(sClean.prefix(31 - sTail.count)) + sTail
            iSuffix   += 1
        }

        used.insert(sCandidate.lowercased())

        return sCandidate

    }   // End of private static func uniqueSheetName(_:index:used:).

    /// "A" -> 1, "Z" -> 26, "AA" -> 27 ...
    private static func columnNumber(_ sColumn:String)->Int
    {

        var iResult:Int = 0

        for scalar in sColumn.uppercased().unicodeScalars
        {
            iResult = (iResult * 26) + Int(scalar.value - 64)
        }

        return iResult

    }   // End of private static func columnNumber(_:).

    /// "C12" -> (col:3, row:12)
    private static func cellAddress(_ sAddress:String)->(Int, Int)?
    {

        let sLetters:String = String(sAddress.prefix(while:{ $0.isLetter }))
        let sDigits:String  = String(sAddress.drop(while:{ $0.isLetter }))

        guard !sLetters.isEmpty, let iRow = Int(sDigits)
        else
        {
            return nil
        }

        return (columnNumber(sLetters), iRow)

    }   // End of private static func cellAddress(_:).

}   // End of struct AppXlsxConverter.
