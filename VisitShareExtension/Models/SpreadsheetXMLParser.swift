//
//  SpreadsheetXMLParser.swift
//  SpreadsheetXMLViewer
//
//  Created by Claude/Daryl Cox on 11/19/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation

class SpreadsheetXMLParser:NSObject 
{

    struct ClassInfo 
    {
        static let sClsId        = "SpreadsheetXMLParser"
        static let sClsVers      = "v1.0205"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // MARK: - Parser State...

    private var workbook:SpreadsheetXMLWorkbook?          = nil
    private var currentWorksheet:SpreadsheetXMLWorksheet? = nil
    private var currentRow:SpreadsheetXMLRow?             = nil
    private var currentCell:SpreadsheetXMLCell?           = nil
    private var currentElementValue:String                = ""

    private var currentRowIndex:Int                       = 0
    private var currentColumnIndex:Int                    = 0
    private var maxColumnIndex:Int                        = 0

    // Element tracking...

    private var isInWorkbook:Bool                         = false
    private var isInWorksheet:Bool                        = false
    private var isInTable:Bool                            = false
    private var isInRow:Bool                              = false
    private var isInCell:Bool                             = false
    private var isInData:Bool                             = false

    private var parseError:Error?                         = nil

    // MARK: - Public Parse Method...

    func parse(url:URL)->Result<SpreadsheetXMLWorkbook, Error> 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parsing file at URL: [\(url.path)]...")

        // Initialize parsing state...

        self.resetParserState()

        // Create workbook...

        workbook                        = SpreadsheetXMLWorkbook()

        workbook?.fileName              = url.lastPathComponent
        workbook?.fileURL               = url
        workbook?.parseDate             = Date()

        guard let originalData = try? Data(contentsOf:url) 
        else 
        {
            let error = NSError(domain:  "SpreadsheetXMLParser",
                                code:    1001,
                                userInfo:[NSLocalizedDescriptionKey:"Failed to read file at URL: [\(url.path)]..."])

            appLogMsg("\(sCurrMethodDisp) ERROR: Failed to read file data...")

            return .failure(error)
        }

        appLogMsg("\(sCurrMethodDisp) File data loaded, size: [\(originalData.count)] bytes...")

        // Pre-process XML to fix common issues (defensive programming)...

        let data = self.preprocessXMLData(originalData)

        if (data.count != originalData.count)
        {
            appLogMsg("\(sCurrMethodDisp) XML pre-processing made changes - original: [\(originalData.count)] bytes, fixed: [\(data.count)] bytes...")
        }

        // Create and configure XML parser...

        let xmlParser:XMLParser                 = XMLParser(data:data)

        xmlParser.delegate                      = self
        xmlParser.shouldProcessNamespaces       = true
        xmlParser.shouldReportNamespacePrefixes = true

        // Parse the XML...

        let success = xmlParser.parse()

        if !success 
        {
            if let parseError = parseError 
            {
                appLogMsg("\(sCurrMethodDisp) Parse failed with error: [\(parseError.localizedDescription)]...")

                return .failure(parseError)
            }
            else if let xmlError = xmlParser.parserError 
            {
                appLogMsg("\(sCurrMethodDisp) Parse failed with XML error: [\(xmlError.localizedDescription)]...")

                return .failure(xmlError)
            }
            else 
            {
                let unknownError = NSError(domain:  "SpreadsheetXMLParser",
                                           code:    1002,
                                           userInfo:[NSLocalizedDescriptionKey:"Unknown parsing error occurred"])

                appLogMsg("\(sCurrMethodDisp) Parse failed with unknown error...")

                return .failure(unknownError)
            }
        }

        guard let finalWorkbook = workbook 
        else 
        {
            let error = NSError(domain:  "SpreadsheetXMLParser",
                                code:    1003,
                                userInfo:[NSLocalizedDescriptionKey:"No workbook data was parsed..."])

            appLogMsg("\(sCurrMethodDisp) ERROR: Workbook is nil after parsing...")

            return .failure(error)
        }

        appLogMsg("\(sCurrMethodDisp) Successfully parsed workbook with [\(finalWorkbook.worksheets.count)] worksheet(s)...")

        for (index, sheet) in finalWorkbook.worksheets.enumerated() 
        {
            appLogMsg("\(sCurrMethodDisp)   Worksheet [\(index)]: '\(sheet.name)' - [\(sheet.rowCount)] rows, [\(sheet.columnCount)] columns...")
        }

        return .success(finalWorkbook)

    }   // End of func parse(url:URL)->Result<SpreadsheetXMLWorkbook, Error>.

    // MARK: - Private Helper Methods

    private func preprocessXMLData(_ data:Data)->Data
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"

        appLogMsg("\(sCurrMethodDisp) Pre-processing XML data...")

        // Convert to string for manipulation...

        guard var xmlString = String(data:data, encoding:.utf8)
        else 
        {
            appLogMsg("\(sCurrMethodDisp) WARNING: Could not convert data to UTF-8 string, returning original data...")

            return data
        }

        var madeChanges:Bool = false

        // Fix 1: Malformed XML declaration - missing space between attributes...
        // Example: <?xml version="1.0"encoding="UTF-8"?>
        // Should be: <?xml version="1.0" encoding="UTF-8"?>
        // Simple approach: Replace "encoding= with " encoding= (add space)

        if (xmlString.hasPrefix("<?xml"))
        {
            // Find the XML declaration...

            if let declarationEnd = xmlString.range(of:"?>")
            {
                let declarationRange = xmlString.startIndex..<declarationEnd.upperBound
                let declaration      = String(xmlString[declarationRange])

                // Check if encoding attribute is missing space...

                if (declaration.contains("\"encoding=") || 
                    declaration.contains("'encoding="))
                {
                    appLogMsg("\(sCurrMethodDisp) Found malformed XML declaration (missing space before encoding)...")

                    // Simple fix: Replace "encoding= with " encoding= (add space before encoding)...

                    var fixedDeclaration = declaration
                        .replacingOccurrences(of:"\"encoding=", with:"\" encoding=")
                        .replacingOccurrences(of:"'encoding=",  with:"' encoding=")

                    // Also handle version="X.X"standalone= case...

                    fixedDeclaration = fixedDeclaration
                        .replacingOccurrences(of:"\"standalone=", with:"\" standalone=")
                        .replacingOccurrences(of:"'standalone=",  with:"' standalone=")

                    // Replace the declaration in the XML string...

                    xmlString.replaceSubrange(declarationRange, with:fixedDeclaration)

                    madeChanges = true

                    appLogMsg("\(sCurrMethodDisp) Fixed malformed XML declaration...")
                }
            }
        }

        // Fix 2: Remove any BOM (Byte Order Mark) that might cause issues...

        if (xmlString.hasPrefix("\u{FEFF}"))
        {
            appLogMsg("\(sCurrMethodDisp) Removing BOM from XML string...")

            xmlString.removeFirst()

            madeChanges = true
        }

        // Fix 3: Validate the XML declaration was properly fixed...

        if (xmlString.hasPrefix("<?xml") && madeChanges)
        {
            // Verify the fix worked...

            if let declarationEnd = xmlString.range(of:"?>")
            {
                let declaration = String(xmlString[..<declarationEnd.upperBound])

                if (!declaration.contains(" encoding=") && 
                     declaration.contains("encoding="))
                {
                    appLogMsg("\(sCurrMethodDisp) WARNING: XML declaration STILL missing space before encoding attribute after fix attempt...")
                }
                else if (declaration.contains(" encoding="))
                {
                    appLogMsg("\(sCurrMethodDisp) Verified: XML declaration now properly formatted...")
                }
            }
        }

        if (madeChanges)
        {
            appLogMsg("\(sCurrMethodDisp) XML pre-processing completed with modifications...")
        }
        else
        {
            appLogMsg("\(sCurrMethodDisp) XML pre-processing completed - no changes needed...")
        }

        // Convert back to Data...

        guard let processedData = xmlString.data(using:.utf8)
        else 
        {
            appLogMsg("\(sCurrMethodDisp) WARNING: Could not convert processed string back to data, returning original...")

            return data
        }

        return processedData

    }   // End of private func preprocessXMLData(_ data:Data)->Data.

    private func resetParserState() 
    {

        let sCurrMethod: String = #function
        let sCurrMethodDisp = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"

        appLogMsg("\(sCurrMethodDisp) Resetting parser state")

        self.workbook            = nil
        self.currentWorksheet    = nil
        self.currentRow          = nil
        self.currentCell         = nil
        self.currentElementValue = ""
        
        self.currentRowIndex     = 0
        self.currentColumnIndex  = 0
        self.maxColumnIndex      = 0
        
        self.isInWorkbook        = false
        self.isInWorksheet       = false
        self.isInTable           = false
        self.isInRow             = false
        self.isInCell            = false
        self.isInData            = false
        
        self.parseError          = nil

    }   // End of private func resetParserState().

    private func getAttributeValue(from attributeDict:[String:String],
                                   name:String,
                                   namespace:String = "urn:schemas-microsoft-com:office:spreadsheet")->String? 
    {

        // Try with ss: prefix...

        if let value = attributeDict["ss:\(name)"] 
        {
            return value
        }

        // Try without prefix...

        if let value = attributeDict[name] 
        {
            return value
        }

        return nil

    }   // End of private func getAttributeValue(from attributeDict:[String:String], name:String, namespace:String)->String? 

}   // End of class SpreadsheetXMLParser:NSObject.

// MARK: - XMLParserDelegate

extension SpreadsheetXMLParser:XMLParserDelegate 
{

    func parser(_ parser:XMLParser,
                didStartElement elementName:String,
                namespaceURI:String?,
                qualifiedName qName:String?,
                attributes attributeDict:[String:String] = [String:String]()) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"

        // Clear element value...

        currentElementValue = ""

        switch elementName 
        {
        case "Workbook":
            isInWorkbook = true

            appLogMsg("\(sCurrMethodDisp) Found <Workbook> element...")
        case "Worksheet":
            isInWorksheet    = true
            let sheetName    = getAttributeValue(from: attributeDict, name: "Name") ?? "Sheet\(workbook?.worksheets.count ?? 0 + 1)"
            currentWorksheet = SpreadsheetXMLWorksheet(name: sheetName)
            currentRowIndex  = 0
            maxColumnIndex   = 0

            appLogMsg("\(sCurrMethodDisp) Found <Worksheet> element: '\(sheetName)'...")
        case "Table":
            isInTable = true

            appLogMsg("\(sCurrMethodDisp) Found <Table> element...")
        case "Row":
            isInRow            = true
            currentColumnIndex = 0

            // Check for row index override...

            if let indexStr = getAttributeValue(from:attributeDict, name:"Index"),
               let index    = Int(indexStr) 
            {
                currentRowIndex = (index - 1)           // Convert to 0-based...

                appLogMsg("\(sCurrMethodDisp) Found <Row> with explicit index: [\(index)]")
            }

            currentRow = SpreadsheetXMLRow(rowIndex:currentRowIndex)

            // Check for row height...

            if let heightStr = getAttributeValue(from:attributeDict, name:"Height"),
               let height    = Double(heightStr) 
            {
                currentRow?.height = height
            }

            // Check for hidden...

            if let hiddenStr = getAttributeValue(from:attributeDict, name:"Hidden"),
               hiddenStr     == "1" 
            {
                currentRow?.isHidden = true
            }
        case "Cell":
            isInCell = true

            // Check for cell index override (for sparse columns)...

            if let indexStr = getAttributeValue(from: attributeDict, name: "Index"),
               let index = Int(indexStr) 
            {
                currentColumnIndex = (index - 1)        // Convert to 0-based

                appLogMsg("\(sCurrMethodDisp) Found <Cell> with explicit index: [\(index)]...")
            }

            currentCell = SpreadsheetXMLCell(columnIndex:currentColumnIndex)

            // Check for style...

            if let styleID = getAttributeValue(from:attributeDict, name:"StyleID") 
            {
                currentCell?.styleID = styleID
            }

            // Check for merge...

            if let mergeAcrossStr = getAttributeValue(from:attributeDict, name:"MergeAcross"),
               let mergeAcross    = Int(mergeAcrossStr) 
            {
                currentCell?.mergeAcross = mergeAcross
            }

            if let mergeDownStr = getAttributeValue(from:attributeDict, name:"MergeDown"),
               let mergeDown    = Int(mergeDownStr) 
            {
                currentCell?.mergeDown = mergeDown
            }

            // Check for formula...

            if let formula = getAttributeValue(from:attributeDict, name:"Formula") 
            {
                currentCell?.formula = formula
            }
        case "Data":
            isInData = true

            // Get data type...

            if let typeStr = getAttributeValue(from:attributeDict, name:"Type") 
            {
                currentCell?.type = SpreadsheetXMLDataType.fromString(typeStr)

                appLogMsg("\(sCurrMethodDisp) Found <Data> with type: [\(typeStr)]...")
            }
        default:
            break
        }

    }   // End of func parser(_ parser:XMLParser, didStartElement elementName:String, namespaceURI:String?, qualifiedName qName:String?, attributes attributeDict:[String:String]).

    func parser(_ parser:XMLParser, foundCharacters string:String) 
    {

        if isInData 
        {
            currentElementValue += string
        }

    }   // End of func parser(_ parser:XMLParser, foundCharacters string:String).

    func parser(_ parser:XMLParser, didEndElement elementName:String, namespaceURI:String?, qualifiedName qName:String?) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"

        switch elementName 
        {
        case "Workbook":
            isInWorkbook = false

            appLogMsg("\(sCurrMethodDisp) Closed </Workbook> element...")
        case "Worksheet":
            isInWorksheet = false

            // Finalize worksheet...

            if var worksheet = currentWorksheet 
            {
                worksheet.rowCount    = (currentRowIndex + 1)
                worksheet.columnCount = (maxColumnIndex  + 1)

                workbook?.worksheets.append(worksheet)

                appLogMsg("\(sCurrMethodDisp) Closed </Worksheet>: '\(worksheet.name)' - [\(worksheet.rowCount)] rows, [\(worksheet.columnCount)] columns, [\(worksheet.totalCellCount)] cells...")
            }

            currentWorksheet = nil
        case "Table":
            isInTable = false

            appLogMsg("\(sCurrMethodDisp) Closed </Table> element...")
        case "Row":
            isInRow = false

            // Add row to worksheet...

            if let row = currentRow 
            {
                currentWorksheet?.rows.append(row)
            }

            currentRow       = nil
            currentRowIndex += 1
        case "Cell":
            isInCell = false

            // Add cell to row...

            if let cell = currentCell 
            {
                currentRow?.cells.append(cell)

                // Track max column index...

                if cell.columnIndex > maxColumnIndex 
                {
                    maxColumnIndex = cell.columnIndex
                }
            }

            currentCell         = nil
            currentColumnIndex += 1
        case "Data":
            isInData = false

            // Set cell value from accumulated text...

            if currentCell != nil 
            {
                currentCell?.value = currentElementValue.trimmingCharacters(in:.whitespacesAndNewlines)

                appLogMsg("\(sCurrMethodDisp) Set cell value: [\(currentCell?.value ?? "")] (type: \(currentCell?.type.rawValue ?? "unknown"))...")
            }

            currentElementValue = ""
        default:
            break
        }

    }   // End of func parser(_ parser:XMLParser, didEndElement elementName:String, namespaceURI:String?, qualifiedName qName:String?).

    func parser(_ parser:XMLParser, parseErrorOccurred parseError:Error)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"

        self.parseError = parseError

        appLogMsg("\(sCurrMethodDisp) ERROR: Parse error occurred: [\(parseError.localizedDescription)]...")

    }   // End of func parser(_ parser:sXMLParser, parseErrorOccurred parseError:Error).

    func parser(_ parser:XMLParser, validationErrorOccurred validationError:Error) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"

        appLogMsg("\(sCurrMethodDisp) WARNING: Validation error: [\(validationError.localizedDescription)]...")

    }   // End of func parser(_ parser:XMLParser, validationErrorOccurred validationError:Error).

}   // End of class SpreadsheetXMLParser:NSObject.


