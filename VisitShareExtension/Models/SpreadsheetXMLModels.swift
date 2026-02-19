//
//  SpreadsheetXMLModels.swift
//  SpreadsheetXMLViewer
//
//  Created by Claude/Daryl Cox on 11/19/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - SpreadsheetXML Data Models

struct SpreadsheetXMLWorkbook:Identifiable 
{

    struct ClassInfo 
    {
        static let sClsId        = "SpreadsheetXMLWorkbook"
        static let sClsVers      = "v1.0101"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    let id:UUID                              = UUID()
    var fileName:String                      = ""
    var worksheets:[SpreadsheetXMLWorksheet] = [SpreadsheetXMLWorksheet]()
    var parseDate:Date                       = Date()
    var fileURL:URL?                         = nil

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

struct SpreadsheetXMLWorksheet:Identifiable 
{

    struct ClassInfo 
    {
        static let sClsId        = "SpreadsheetXMLWorksheet"
        static let sClsVers      = "v1.0101"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    let id:UUID                  = UUID()
    var name:String              = "Sheet1"
    var rows:[SpreadsheetXMLRow] = [SpreadsheetXMLRow]()
    var columnCount:Int          = 0
    var rowCount:Int             = 0

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

struct SpreadsheetXMLRow:Identifiable 
{

    struct ClassInfo 
    {
        static let sClsId        = "SpreadsheetXMLRow"
        static let sClsVers      = "v1.0101"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    let id:UUID                    = UUID()
    var rowIndex:Int               = 0
    var cells:[SpreadsheetXMLCell] = [SpreadsheetXMLCell]()
    var height:Double?             = nil
    var isHidden:Bool              = false

}   // End of struct SpreadsheetXMLRow:Identifiable.

struct SpreadsheetXMLCell:Identifiable 
{

    struct ClassInfo 
    {
        static let sClsId        = "SpreadsheetXMLCell"
        static let sClsVers      = "v1.0201"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    let id:UUID                     = UUID()
    var columnIndex:Int             = 0
    var value:String                = ""
    var type:SpreadsheetXMLDataType = .string
    var formula:String?             = nil
    var styleID:String?             = nil
    var mergeAcross:Int             = 0
    var mergeDown:Int               = 0

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

