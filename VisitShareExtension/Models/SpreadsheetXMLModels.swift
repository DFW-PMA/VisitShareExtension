//
//  SpreadsheetXMLModels.swift
//  SpreadsheetXMLViewer
//
//  Created by Claude/Daryl Cox on 11/19/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import Foundation
import SwiftUI

// MARK: - SpreadsheetXML Data Models

// <<CHICKEN-TRACKS>> (2026-10-05) Style info captured from <Styles>/<Style> so a SpreadsheetML file can be
//                    converted to .xlsx WITHOUT losing the fills/borders/fonts/number formats Accounting relies on.
@JmEntityInfo(vers:"v1.0101")
struct SpreadsheetXMLStyle
{

    var fontName:String?     = nil
    var fontSize:Double?     = nil
    var fontColor:String?    = nil          // "#RRGGBB"
    var bold:Bool            = false
    var italic:Bool          = false
    var underline:Bool       = false
    var fillColor:String?    = nil          // "#RRGGBB" (solid pattern only)
    var borders:[String:Int] = [String:Int]()   // Position (Left/Right/Top/Bottom) -> ss:Weight (1 thin, 2 medium, 3 thick)
    var horizontal:String?   = nil          // Left / Center / Right ...
    var vertical:String?     = nil          // Top / Center / Bottom ...
    var wrapText:Bool        = false
    var numberFormat:String? = nil
    var isLocked:Bool        = true         // ss:Protected="0" -> false

}   // End of struct SpreadsheetXMLStyle.

@JmEntityInfo(vers:"v1.0201")
struct SpreadsheetXMLWorkbook:Identifiable 
{

    //  struct ClassInfo
    //  {
        //  static let sClsId        = "SpreadsheetXMLWorkbook"
        //  static let sClsVers      = "v1.0101"
        //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
        //  static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    let id:UUID                              = UUID()
    var fileName:String                      = ""
    var worksheets:[SpreadsheetXMLWorksheet] = [SpreadsheetXMLWorksheet]()
    var parseDate:Date                       = Date()
    var fileURL:URL?                         = nil
    var styles:[String:SpreadsheetXMLStyle]  = [String:SpreadsheetXMLStyle]()      // <<CHICKEN-TRACKS>> keyed by ss:ID

    var isEmpty:Bool 
    {
        return worksheets.isEmpty || worksheets.allSatisfy 
        {
            $0.rows.isEmpty
        }
    }

    var totalCellCount:Int 
    {
        return worksheets.reduce(0) 
        {
            $0 + $1.totalCellCount
        }
    }

}   // End of struct SpreadsheetXMLWorkbook:Identifiable.

@JmEntityInfo(vers:"v1.0201")
struct SpreadsheetXMLWorksheet:Identifiable 
{

    //  struct ClassInfo
    //  {
        //  static let sClsId        = "SpreadsheetXMLWorksheet"
        //  static let sClsVers      = "v1.0101"
        //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
        //  static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    let id:UUID                  = UUID()
    var name:String              = "Sheet1"
    var rows:[SpreadsheetXMLRow] = [SpreadsheetXMLRow]()
    var columnCount:Int          = 0
    var rowCount:Int             = 0
    // <<CHICKEN-TRACKS>> (2026-10-05) layout info for faithful .xlsx conversion...
    var columnWidths:[Int:Double] = [Int:Double]()      // 0-based column -> ss:Width (points)
    var defaultColumnWidth:Double? = nil
    var defaultRowHeight:Double?   = nil
    var freezeRows:Int             = 0
    var freezeColumns:Int          = 0
    var isProtected:Bool           = false

    var isEmpty:Bool 
    {
        return rows.isEmpty || rows.allSatisfy 
        {
            $0.cells.isEmpty
        }
    }

    var totalCellCount:Int 
    {
        return rows.reduce(0) 
        {
            $0 + $1.cells.count
        }
    }

}   // End of struct SpreadsheetXMLWorksheet:Identifiable.

@JmEntityInfo(vers:"v1.0201")
struct SpreadsheetXMLRow:Identifiable 
{

    //  struct ClassInfo
    //  {
        //  static let sClsId        = "SpreadsheetXMLRow"
        //  static let sClsVers      = "v1.0101"
        //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
        //  static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    let id:UUID                    = UUID()
    var rowIndex:Int               = 0
    var cells:[SpreadsheetXMLCell] = [SpreadsheetXMLCell]()
    var height:Double?             = nil
    var isHidden:Bool              = false
    var styleID:String?            = nil        // <<CHICKEN-TRACKS>> (2026-10-05) row-level ss:StyleID

}   // End of struct SpreadsheetXMLRow:Identifiable.

@JmEntityInfo(vers:"v1.0301")
struct SpreadsheetXMLCell:Identifiable 
{

    //  struct ClassInfo
    //  {
        //  static let sClsId        = "SpreadsheetXMLCell"
        //  static let sClsVers      = "v1.0201"
        //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
        //  static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    let id:UUID                     = UUID()
    var columnIndex:Int             = 0
    var value:String                = ""
    var type:SpreadsheetXMLDataType = .string
    var formula:String?             = nil
    var styleID:String?             = nil
    var mergeAcross:Int             = 0
    var mergeDown:Int               = 0
    var hasData:Bool                = false     // <<CHICKEN-TRACKS>> (2026-10-05) a <Data> element was present (even if empty)

    var displayValue:String 
    {
        // Format the value based on type...

        switch type 
        {
        case .string:
            return value
        case .number:
            if let doubleValue = Double(value) 
            {
                return formatNumber(doubleValue)
            }

            return value
        case .dateTime:
            if let date = parseDateTime(value) 
            {
                return formatDate(date)
            }

            return value
        case .boolean:
            return value.lowercased() == "1" || value.lowercased() == "true" ? "TRUE" : "FALSE"
        case .error:
            return value
        }
    }

    private func formatNumber(_ number:Double)->String 
    {

        // Simple number formatting...

        let formatter:NumberFormatter   = NumberFormatter()

        formatter.numberStyle           = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        formatter.usesGroupingSeparator = false

        return formatter.string(from:NSNumber(value:number)) ?? "\(number)"

    }   // End of private func formatNumber(_ number:Double)->String.

    private func formatDate(_ date:Date)->String 
    {

        let formatter:DateFormatter = DateFormatter()

        formatter.dateStyle         = .medium
        formatter.timeStyle         = .short

        return formatter.string(from:date)

    }   // End of private func formatDate(_ date:Date)->String.

    private func parseDateTime(_ value:String)->Date? 
    {

        // SpreadsheetXML uses ISO8601 format...

        let formatter = ISO8601DateFormatter()

        return formatter.date(from:value)

    }   // End of private func parseDateTime(_ value:String)->Date?.

}   // End of struct SpreadsheetXMLCell:Identifiable.

enum SpreadsheetXMLDataType:String 
{

    case string   = "String"
    case number   = "Number"
    case dateTime = "DateTime"
    case boolean  = "Boolean"
    case error    = "Error"

    static func fromString(_ string: String)->SpreadsheetXMLDataType 
    {

        return SpreadsheetXMLDataType(rawValue:string) ?? .string

    }

}   // End of enum SpreadsheetXMLDataType:String.

// MARK: - Helper Extensions

extension SpreadsheetXMLWorkbook 
{

    func toCSV(worksheetIndex:Int = 0)->String? 
    {

        guard worksheetIndex >= 0 && worksheetIndex < worksheets.count 
        else 
        {
            appLogMsg("\(ClassInfo.sClsDisp).toCSV(): Invalid worksheet index [\(worksheetIndex)]...")

            return nil
        }

        let worksheet = worksheets[worksheetIndex]
        var csvString = ""

        for row in worksheet.rows 
        {
            let rowValues = row.cells.map 
            { cell -> String in

                let value = cell.displayValue

                // Escape quotes and wrap in quotes if contains comma, quote, or newline...

                if value.contains(",") || value.contains("\"") || value.contains("\n") 
                {
                    return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
                }

                return value
            }

            csvString += rowValues.joined(separator:",") + "\n"
        }

        return csvString

    }   // End of func toCSV(worksheetIndex:Int = 0)->String?.

}   // End of extension SpreadsheetXMLWorkbook.

