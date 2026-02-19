//
//  SpreadsheetCSVParser.swift
//  DataGridViewer
//
//  Created by Claude/Daryl Cox on 12/09/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - SpreadsheetCSVParser

class SpreadsheetCSVParser
{
    
    struct ClassInfo
    {
        static let sClsId        = "SpreadsheetCSVParser"
        static let sClsVers      = "v1.0301"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // MARK: - Properties
    
    private var workbook:SpreadsheetXMLWorkbook
    private var currentWorksheet:SpreadsheetXMLWorksheet
    private var parsedRows:[[String]]                    = [[String]]()
    private var fileName:String                          = ""
    private var fileURL:URL?
    
    // CSV Parsing Settings...

    private var delimiter:String                         = ","      // Changed from Character to String to support multi-char delimiters...
    private var quote:Character                          = "\""
    private var hasHeaderRow:Bool                        = false
    private var autoDetectHeaders:Bool                   = true
    
    // Statistics...

    private var totalRowsParsed:Int                      = 0
    private var totalCellsParsed:Int                     = 0
    private var maxColumnsFound:Int                      = 0
    
    // MARK: - Initialization
    
    init()
    {
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")
        
        self.workbook         = SpreadsheetXMLWorkbook()
        self.currentWorksheet = SpreadsheetXMLWorksheet()
        
        appLogMsg("\(sCurrMethodDisp) Exiting - CSV parser initialized...")
        
        return
        
    }   // End of init().
    
    // MARK: - Public Parse Methods
    
    func parseCSV(from url:URL, 
                  delimiter:String = ",",
                  autoDetectHeaders:Bool = true, 
                  forceHeaderRow:Bool? = nil)->Result<SpreadsheetXMLWorkbook, Error>
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - parsing CSV from URL: [\(url.path)]...")
        appLogMsg("\(sCurrMethodDisp) Settings - delimiter: [\(delimiter)], autoDetectHeaders: [\(autoDetectHeaders)], forceHeaderRow: [\(String(describing:forceHeaderRow))]...")
        
        // Store settings...

        self.delimiter         = delimiter
        self.autoDetectHeaders = autoDetectHeaders
        self.fileURL           = url
        self.fileName          = url.lastPathComponent
        
        // Reset state...

        self.resetParserState()
        
        // Read file data...

        guard let csvData = self.readFileData(from:url)
        else
        {
            let error = NSError(domain:  "SpreadsheetCSVParser",
                                code:    2001,
                                userInfo:[NSLocalizedDescriptionKey:"Failed to read CSV file data"])
            
            appLogMsg("\(sCurrMethodDisp) Failed to read file data - returning - Error!")
            
            return .failure(error)
        }
        
        appLogMsg("\(sCurrMethodDisp) Successfully read #(\(csvData.count)) bytes from file...")
        
        // Parse CSV data into rows of strings...

        let parseResult = self.parseCSVData(csvData)
        
        switch parseResult
        {
        case .success(let rows):
            appLogMsg("\(sCurrMethodDisp) Successfully parsed #(\(rows.count)) rows from CSV data...")
            
            self.parsedRows = rows
            
            // Determine if first row is headers...

            if let forced = forceHeaderRow
            {
                self.hasHeaderRow = forced
                appLogMsg("\(sCurrMethodDisp) Header row FORCED to: [\(self.hasHeaderRow)]...")
            }
            else if (autoDetectHeaders == true)
            {
                self.hasHeaderRow = self.detectHeaderRow(rows:rows)
                appLogMsg("\(sCurrMethodDisp) Header row AUTO-DETECTED as: [\(self.hasHeaderRow)]...")
            }
            else
            {
                self.hasHeaderRow = false
                appLogMsg("\(sCurrMethodDisp) Header row set to: [false] (no auto-detection)...")
            }
            
            // Build workbook structure...

            let buildResult = self.buildWorkbookFromRows(rows:rows)
            
            switch buildResult
            {
            case .success(let workbook):
                appLogMsg("\(sCurrMethodDisp) Successfully built workbook with #(\(workbook.worksheets.count)) worksheet(s)...")
                appLogMsg("\(sCurrMethodDisp) Total cells parsed: #(\(self.totalCellsParsed)), max columns: #(\(self.maxColumnsFound))...")
                appLogMsg("\(sCurrMethodDisp) Exiting with SUCCESS...")
                
                return .success(workbook)
            case .failure(let error):
                appLogMsg("\(sCurrMethodDisp) Failed to build workbook - details: [\(error.localizedDescription)] - Error!")
                
                return .failure(error)
            }
        case .failure(let error):
            appLogMsg("\(sCurrMethodDisp) Failed to parse CSV data - details: [\(error.localizedDescription)] - Error!")
            
            return .failure(error)
        }
        
    }   // End of func parseCSV(from url:URL, autoDetectHeaders:Bool, forceHeaderRow:Bool?)->Result<SpreadsheetXMLWorkbook, Error>.
    
    // MARK: - Private Helper Methods
    
    private func resetParserState()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Resetting parser state...")
        
        self.workbook         = SpreadsheetXMLWorkbook()
        self.currentWorksheet = SpreadsheetXMLWorksheet()
        self.parsedRows       = []
        self.totalRowsParsed  = 0
        self.totalCellsParsed = 0
        self.maxColumnsFound  = 0
        self.hasHeaderRow     = false
        
        appLogMsg("\(sCurrMethodDisp) Parser state reset complete...")
        
        return
        
    }   // End of private func resetParserState().
    
    private func readFileData(from url:URL)->Data?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - reading file from URL: [\(url.path)]...")
        
        // Handle security-scoped resources (files from Mail, Files app, etc.)...

        let didStartAccess = url.startAccessingSecurityScopedResource()
        
        appLogMsg("\(sCurrMethodDisp) Security-scoped resource access: [\(didStartAccess ? "GRANTED" : "NOT REQUIRED")]...")
        
        defer
        {
            if (didStartAccess == true)
            {
                url.stopAccessingSecurityScopedResource()
                appLogMsg("\(sCurrMethodDisp) Security-scoped resource access RELEASED...")
            }
        }
        
        // Read file data...

        do
        {
            let data = try Data(contentsOf:url)
            
            appLogMsg("\(sCurrMethodDisp) Successfully read [\(data.count)] bytes from file...")
            appLogMsg("\(sCurrMethodDisp) Exiting with file data...")
            
            return data
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Failed to read file - details: [\(error.localizedDescription)] - Error!")
            appLogMsg("\(sCurrMethodDisp) Exiting with NIL...")
            
            return nil
        }
        
    }   // End of private func readFileData(from url:URL)->Data?.
    
    private func parseCSVData(_ data:Data)->Result<[[String]], Error>
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - parsing [\(data.count)] bytes of CSV data...")
        
        // Try to decode with multiple encodings - try UTF-8 first, then fallback...

        var csvString:String? = nil
        
        // Try UTF-8 encoding first...

        if let utf8String = String(data:data, encoding:.utf8)
        {
            csvString = utf8String
            appLogMsg("\(sCurrMethodDisp) Successfully decoded as UTF-8...")
        }
        else
        {
            // Fallback to UTF-16...

            appLogMsg("\(sCurrMethodDisp) UTF-8 decoding failed, trying UTF-16...")
            
            if let utf16String = String(data:data, encoding:.utf16)
            {
                csvString = utf16String
                appLogMsg("\(sCurrMethodDisp) Successfully decoded as UTF-16...")
            }
            else
            {
                // Fallback to ISO Latin 1...

                appLogMsg("\(sCurrMethodDisp) UTF-16 decoding failed, trying ISO Latin 1...")
                
                if let latin1String = String(data:data, encoding:.isoLatin1)
                {
                    csvString = latin1String
                    appLogMsg("\(sCurrMethodDisp) Successfully decoded as ISO Latin 1...")
                }
                else
                {
                    let error = NSError(domain:  "SpreadsheetCSVParser",
                                        code:    2002,
                                        userInfo:[NSLocalizedDescriptionKey:"Unable to decode CSV file with UTF-8, UTF-16, or ISO Latin 1 encoding"])
                    
                    appLogMsg("\(sCurrMethodDisp) All encoding attempts failed - Error!")
                    
                    return .failure(error)
                }
            }
        }
        
        // Verify we got a valid string...

        guard var finalCSVString = csvString
        else
        {
            let error = NSError(domain:  "SpreadsheetCSVParser",
                                code:    2003,
                                userInfo:[NSLocalizedDescriptionKey:"Failed to decode CSV file data to string"])
            
            appLogMsg("\(sCurrMethodDisp) 'csvString' is nil after all encoding attempts - Error!")
            
            return .failure(error)
        }
        
        appLogMsg("\(sCurrMethodDisp) Successfully decoded CSV string, length: #(\(finalCSVString.count)) character(s)...")
        
        // Remove BOM if present (Excel sometimes adds this)...

        if (finalCSVString.hasPrefix("\u{FEFF}") == true)
        {
            finalCSVString.removeFirst()
            appLogMsg("\(sCurrMethodDisp) Removed UTF-8 BOM from beginning of CSV data...")
        }
        
        // Parse CSV string into rows...

        let rows = self.parseCSVString(finalCSVString)
        
        appLogMsg("\(sCurrMethodDisp) Parsed #(\(rows.count)) rows from CSV string...")
        appLogMsg("\(sCurrMethodDisp) Exiting with SUCCESS...")
        
        return .success(rows)
        
    }   // End of private func parseCSVData(_ data:Data)->Result<[[String]], Error>.
    
    private func parseCSVString(_ csvString:String) -> [[String]]
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - parsing CSV string of #(\(csvString.count)) character(s)...")
        appLogMsg("\(sCurrMethodDisp) Using delimiter: [\(self.delimiter)] (length: #(\(self.delimiter.count)) character(s))...")
        
        var rows:[[String]]     = [[String]]()
        var currentRow:[String] = [String]()
        var currentField:String = ""
        var insideQuotes:Bool   = false
        var charIndex:Int       = 0
        let characters          = Array(csvString)
        let charCount           = characters.count
        let delimiterLength     = self.delimiter.count
        
        appLogMsg("\(sCurrMethodDisp) Beginning character-by-character parse of #(\(charCount)) character(s)...")
        
        while (charIndex < charCount)
        {
            let char = characters[charIndex]
            
            // Handle quote character...

            if (char == self.quote)
            {
                if (insideQuotes == true)
                {
                    // Check for escaped quote (double quote)...

                    if ((charIndex + 1)            < charCount &&
                        characters[charIndex + 1] == self.quote)
                    {
                        // Escaped quote - add single quote to field...

                        currentField.append(self.quote)
                        charIndex += 1      // Skip next quote...
                    }
                    else
                    {
                        // End of quoted field...

                        insideQuotes = false
                    }
                }
                else
                {
                    // Start of quoted field...

                    insideQuotes = true
                }
            }
            // Handle delimiter (can be multi-character like "->;" or "|")
            else if (insideQuotes == false &&
                     self.matchesDelimiter(at:charIndex, in:characters))
            {
                // End of field...

                currentRow.append(currentField)
                currentField = ""
                
                // Skip past the delimiter (may be multi-character)...

                charIndex += (delimiterLength - 1)      // -1 because we increment at end of loop...
            }
            // Handle newline (end of row)
            else if ((char == "\n" || char == "\r") && insideQuotes == false)
            {
                // End of row...

                currentRow.append(currentField)
                currentField = ""
                
                // Only add row if it has content (skip empty lines)...

                if (currentRow.isEmpty == false &&
                    (currentRow.count > 1 || currentRow[0].isEmpty == false))
                {
                    rows.append(currentRow)
                    self.maxColumnsFound = max(self.maxColumnsFound, currentRow.count)
                }
                
                currentRow = [String]()
                
                // Handle Windows line endings (\r\n)...

                if (char == "\r" &&
                    (charIndex + 1) < charCount && characters[charIndex + 1] == "\n")
                {
                    charIndex += 1      // Skip the \n...
                }
            }
            else
            {
                // Regular character - add to current field...

                currentField.append(char)
            }
            
            charIndex += 1
        }
        
        // Don't forget the last field and row...

        if (currentField.isEmpty == false ||
            currentRow.isEmpty   == false)
        {
            currentRow.append(currentField)
            
            if (currentRow.isEmpty == false &&
                (currentRow.count > 1 || currentRow[0].isEmpty == false))
            {
                rows.append(currentRow)
                self.maxColumnsFound = max(self.maxColumnsFound, currentRow.count)
            }
        }
        
        self.totalRowsParsed = rows.count
        
        appLogMsg("\(sCurrMethodDisp) Parsing complete - found #(\(rows.count)) rows, max columns: #(\(self.maxColumnsFound))...")
        appLogMsg("\(sCurrMethodDisp) Exiting with #(\(rows.count)) row(s)...")
        
        return rows
        
    }   // End of private func parseCSVString(_ csvString:String)->[[String]].
    
    private func matchesDelimiter(at index:Int, in characters:[Character])->Bool
    {

        // Check if the characters starting at 'index' match the delimiter string...
        
        let delimiterChars = Array(self.delimiter)
        
        // Check bounds - make sure we have enough characters left...

        guard (index + delimiterChars.count) <= characters.count
        else
        {
            return false
        }
        
        // Compare each character of the delimiter...

        for i in 0..<delimiterChars.count
        {
            if (characters[index + i] != delimiterChars[i])
            {
                return false
            }
        }
        
        return true
        
    }   // End of private func matchesDelimiter(at index:Int, in characters:[Character])->Bool.
    
    private func detectHeaderRow(rows:[[String]])->Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - auto-detecting header row...")
        
        guard rows.count >= 2
        else
        {
            appLogMsg("\(sCurrMethodDisp) Less than 2 rows - assuming NO header row...")
            return false
        }
        
        let firstRow  = rows[0]
        let secondRow = rows[1]
        
        appLogMsg("\(sCurrMethodDisp) Analyzing first row (#(\(firstRow.count)) cells) vs second row (#(\(secondRow.count)) cells)...")
        
        // Heuristic: If first row is all non-numeric strings and second row has numbers,
        // then first row is likely headers...
        
        var firstRowNumericCount:Int  = 0
        var secondRowNumericCount:Int = 0
        
        for cell in firstRow
        {
            if (self.isNumeric(cell) == true)
            {
                firstRowNumericCount += 1
            }
        }
        
        for cell in secondRow
        {
            if (self.isNumeric(cell) == true)
            {
                secondRowNumericCount += 1
            }
        }
        
        let firstRowNumericRatio  = Double(firstRowNumericCount)  / Double(max(firstRow.count,  1))
        let secondRowNumericRatio = Double(secondRowNumericCount) / Double(max(secondRow.count, 1))
        
        appLogMsg("\(sCurrMethodDisp) First row numeric ratio: (\(String(format:"%.2f", firstRowNumericRatio))), Second row numeric ratio: (\(String(format:"%.2f", secondRowNumericRatio)))...")
        
        // If first row has fewer numbers than second row, it's likely headers...

        let isHeader = (firstRowNumericRatio < secondRowNumericRatio)
        
        appLogMsg("\(sCurrMethodDisp) Header detection result: [\(isHeader ? "YES (first row is headers)" : "NO (all rows are data)")]...")
        appLogMsg("\(sCurrMethodDisp) Exiting with result: 'isHeader' is [\(isHeader)]...")
        
        return isHeader
        
    }   // End of private func detectHeaderRow(rows:[[String]])->Bool.
    
    private func buildWorkbookFromRows(rows:[[String]])->Result<SpreadsheetXMLWorkbook, Error>
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - building workbook from #(\(rows.count)) row(s)...")
        
        guard rows.isEmpty == false
        else
        {
            let error = NSError(domain:  "SpreadsheetCSVParser",
                                code:    2004,
                                userInfo:[NSLocalizedDescriptionKey:"CSV file is empty - no rows to parse"])
            
            appLogMsg("\(sCurrMethodDisp) No rows to parse - Error!")
            
            return .failure(error)
        }
        
        // Create worksheet...

        var worksheet  = SpreadsheetXMLWorksheet()
        worksheet.name = self.fileName.replacingOccurrences(of:".csv", with:"")
        
        appLogMsg("\(sCurrMethodDisp) Creating worksheet named: [\(worksheet.name)]...")
        
        // Determine starting row (skip header if present)...

        let dataStartRow = (self.hasHeaderRow == true) ? 1 : 0
        
        appLogMsg("\(sCurrMethodDisp) Data starts at row: #(\(dataStartRow)) (hasHeaderRow: [\(self.hasHeaderRow)])...")
        
        // Build rows...

        for (rowIndex, rowData) in rows.enumerated()
        {
            var row = SpreadsheetXMLRow()
            
            row.rowIndex = rowIndex
            
            // Build cells for this row...

            for (colIndex, cellValue) in rowData.enumerated()
            {
                var cell = SpreadsheetXMLCell()
                
                cell.columnIndex = colIndex
                cell.value       = cellValue
                cell.type        = self.inferCellType(cellValue)
                
                row.cells.append(cell)
                self.totalCellsParsed += 1
            }
            
            worksheet.rows.append(row)
        }
        
        worksheet.rowCount    = worksheet.rows.count
        worksheet.columnCount = self.maxColumnsFound
        
        appLogMsg("\(sCurrMethodDisp) Worksheet created with #(\(worksheet.rowCount)) row(s) and #(\(worksheet.columnCount)) column(s)...")
        appLogMsg("\(sCurrMethodDisp) Total cell(s) created: #(\(self.totalCellsParsed))...")
        
        // Create workbook...

        var workbook = SpreadsheetXMLWorkbook()
        
        workbook.fileName  = self.fileName
        workbook.fileURL   = self.fileURL
        workbook.parseDate = Date()
        workbook.worksheets.append(worksheet)
        
        appLogMsg("\(sCurrMethodDisp) Workbook created successfully...")
        appLogMsg("\(sCurrMethodDisp) Exiting with SUCCESS...")
        
        return .success(workbook)
        
    }   // End of private func buildWorkbookFromRows(rows:[[String]])->Result<SpreadsheetXMLWorkbook, Error>.
    
    // MARK: - Type Inference Helpers
    
    private func inferCellType(_ value:String)->SpreadsheetXMLDataType
    {

        // Infer the data type from the cell value string...
        
        // Empty or whitespace-only = String...

        let trimmed = value.trimmingCharacters(in:.whitespacesAndNewlines)
        
        guard trimmed.isEmpty == false
        else
        {
            return .string
        }
        
        // Try to parse as number...

        if (self.isNumeric(trimmed) == true)
        {
            return .number
        }
        
        // Try to parse as boolean...

        if (trimmed.lowercased() == "true"  ||
            trimmed.lowercased() == "false" ||
            trimmed              == "1"     ||
            trimmed              == "0")
        {
            return .boolean
        }
        
        // Try to parse as date...

        if (self.isDateTime(trimmed) == true)
        {
            return .dateTime
        }
        
        // Default to string...

        return .string
        
    }   // End of private func inferCellType(_ value:String)->SpreadsheetXMLDataType.
    
    private func isNumeric(_ value:String)->Bool
    {

        // Check if string can be parsed as a number
        
        let trimmed = value.trimmingCharacters(in:.whitespacesAndNewlines)
        
        guard trimmed.isEmpty == false
        else
        {
            return false
        }
        
        // Try to parse as Double...

        if let _ = Double(trimmed)
        {
            return true
        }
        
        // Try with locale-specific number formatter...

        let formatter         = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if let _ = formatter.number(from:trimmed)
        {
            return true
        }
        
        return false
        
    }   // End of private func isNumeric(_ value:String)->Bool.
    
    private func isDateTime(_ value:String)->Bool
    {

        // Check if string can be parsed as a date/time...
        
        let trimmed = value.trimmingCharacters(in:.whitespacesAndNewlines)
        
        guard trimmed.isEmpty == false
        else
        {
            return false
        }
        
        // Try ISO8601 format...

        let iso8601Formatter = ISO8601DateFormatter()
        
        if let _ = iso8601Formatter.date(from:trimmed)
        {
            return true
        }
        
        // Try common date formats...

        let dateFormatter = DateFormatter()
        
        let commonFormats = [
                             "yyyy-MM-dd",
                             "MM/dd/yyyy",
                             "dd/MM/yyyy",
                             "yyyy-MM-dd HH:mm:ss",
                             "MM/dd/yyyy HH:mm:ss",
                             "dd/MM/yyyy HH:mm:ss"
                            ]
        
        for format in commonFormats
        {
            dateFormatter.dateFormat = format
            
            if let _ = dateFormatter.date(from:trimmed)
            {
                return true
            }
        }
        
        return false
        
    }   // End of private func isDateTime(_ value:String)->Bool.
    
}   // End of class SpreadsheetCSVParser.

