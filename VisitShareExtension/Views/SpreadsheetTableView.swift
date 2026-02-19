//
//  SpreadsheetTableView.swift
//  SpreadsheetXMLViewer
//
//  Created by Claude/Daryl Cox on 11/19/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

struct SpreadsheetTableView:View
{
    
    struct ClassInfo 
    {
        static let sClsId        = "SpreadsheetTableView"
        static let sClsVers      = "v1.0601"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // MARK: - Properties...

//  @Environment(\.dismiss)      private var dismiss
    @Environment(\.presentationMode)     var presentationMode

    // The 'worksheet'...

                   let worksheet:SpreadsheetXMLWorksheet
    
    // User preference for column resizing...

    @AppStorage("enableColumnResizing") 
           private var enableColumnResizing                      = false
    
    // Selection and display state
    @State private var selectedCell:UUID?                        = nil
    @State private var selectedCellForDetail:SpreadsheetXMLCell? = nil
    @State private var showingCellDetail:Bool                    = false
    @State private var headerHeight:CGFloat                      = 44
    @State private var rowHeight:CGFloat                         = 36
    
    // MARK: - Priority #4: Row Highlighting State...
    
    @State private var selectedRowIndex:Int?                     = nil
    
    // Column width management (for resizing feature)...

    @State private var columnWidths:[Int:CGFloat]                = [:]
    @State private var draggingColumn:Int?                       = nil
    @State private var dragStartWidth:CGFloat                    = 0
    
    // Constants...

           private let defaultCellWidth:CGFloat                  = 120
           private let minColumnWidth:CGFloat                    = 60
           private let resizeHandleWidth:CGFloat                 = 10
           private let rowNumberWidth:CGFloat                    = 50
    
    // MARK: - Body
    
    var body:some View
    {
        
        ScrollView([.horizontal, .vertical])
        {
            VStack(alignment:.leading, spacing:0)
            {
                // Column Headers...

                if (worksheet.columnCount > 0)
                {
                    HStack(spacing:0)
                    {
                        // Row number header...

                        headerCell(text:"#", width:rowNumberWidth)
                        
                        // Column letters with optional resize handles...

                        ForEach(0..<worksheet.columnCount, id:\.self) 
                        { colIndex in

                            columnHeaderWithResize(colIndex:colIndex)

                        }
                    }
                }
                
                // Data Rows...

                ForEach(Array(worksheet.rows.enumerated()), id:\.element.id) 
                { rowIndex, row in

                    if (!row.isHidden)
                    {
                        // MARK: - Priority #4: Row with highlighting support...
                        
                        let isRowSelected = (selectedRowIndex == rowIndex)
                        
                        HStack(spacing:0)
                        {
                            // Row number (tappable for row selection)...

                            rowNumberCell(text:"\(rowIndex + 1)", 
                                          height:row.height ?? rowHeight,
                                          rowIndex:rowIndex,
                                          isSelected:isRowSelected)
                            
                            // Cells - Fill in missing cells for proper alignment...

                            ForEach(0..<worksheet.columnCount, id:\.self) 
                            { colIndex in

                                if let cell = row.cells.first(where: { $0.columnIndex == colIndex })
                                {
                                    dataCell(cell:cell, 
                                             height:row.height ?? rowHeight,
                                             isRowSelected:isRowSelected)
                                } 
                                else 
                                {
                                    emptyCell(colIndex:colIndex, 
                                              height:row.height ?? rowHeight,
                                              isRowSelected:isRowSelected)
                                }

                            }
                        }
                    }

                }
            }
            .padding(8)
        }
    //  .background(Color(UIColor.systemBackground))
    #if os(macOS)
        .background(Color(nsColor:.windowBackgroundColor))
    #endif
    #if os(iOS)
        .background(Color(uiColor:UIColor.systemBackground))
    #endif
        .sheet(isPresented: $showingCellDetail)
        {
            if let cell = selectedCellForDetail 
            {
                CellDetailView(cell: cell, worksheet: worksheet)
            }
        }

    }   // End of var body:some View.
    
    // MARK: - Column Header with Optional Resize
    
    private func columnHeaderWithResize(colIndex:Int)->some View
    {
        
        ZStack(alignment:.trailing)
        {
            // Header cell...

            headerCell(text:columnLetter(for:colIndex), width:columnWidth(for:colIndex))
            
            // Resize handle (only when resizing is enabled)...

            if enableColumnResizing 
            {
                self.resizeHandle(for:colIndex)
            }
        }

    }   // End of private func columnHeaderWithResize(colIndex:Int)->some View.
    
    private func resizeHandle(for colIndex:Int)->some View
    {
        
        Rectangle()
            .fill(Color.blue.opacity(draggingColumn == colIndex ? 0.3 : 0.001))
            .frame(width:resizeHandleWidth)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance:0)
                    .onChanged 
                    { value in
                        handleResizeDrag(columnIndex:colIndex, value:value)
                    }
                    .onEnded 
                    { _ in
                        draggingColumn = nil
                        appLogMsg("\(ClassInfo.sClsDisp) Column [\(colIndex)] resize complete: [\(columnWidth(for:colIndex))] px...")
                    }
            )

    }   // End of private func resizeHandle(for colIndex:Int)->some View.
    
    // MARK: - View Components:
    
    private func headerCell(text:String, width:CGFloat)->some View
    {
        
        Text(text)
            .font(.system(size:14, weight:.semibold))
            .foregroundColor(.white)
            .frame(width:width, height:headerHeight)
            .background(Color.blue.opacity(0.8))
            .border(Color.gray.opacity(0.3), width:0.5)

    }   // End of private func headerCell(text:String, width:CGFloat)->some View.
    
    // MARK: - Priority #4: Enhanced Row Number Cell with Tap Gesture...
    
    private func rowNumberCell(text:String, height:CGFloat, rowIndex:Int, isSelected:Bool)->some View
    {
        
        Text(text)
            .font(.system(size:12, weight:isSelected ? .bold : .medium))
            .foregroundColor(.white)
            .frame(width:rowNumberWidth, height:height)
            .background(isSelected ? Color.orange.opacity(0.9) : Color.blue.opacity(0.6))
            .border(isSelected ? Color.orange : Color.gray.opacity(0.3), width:isSelected ? 2.0 : 0.5)
            .contentShape(Rectangle())
            .onTapGesture
            {
                // Toggle row selection - tap same row to deselect...
                
                if selectedRowIndex == rowIndex
                {
                    appLogMsg("\(ClassInfo.sClsDisp) Row #[\(rowIndex + 1)] deselected...")
                    
                    selectedRowIndex = nil
                }
                else
                {
                    appLogMsg("\(ClassInfo.sClsDisp) Row #[\(rowIndex + 1)] selected - highlighting entire row...")
                    
                    selectedRowIndex = rowIndex
                }
            }

    }   // End of private func rowNumberCell(text:String, height:CGFloat, rowIndex:Int, isSelected:Bool)->some View.
    
    // MARK: - Priority #4: Enhanced Data Cell with Row Highlighting...
    
    private func dataCell(cell:SpreadsheetXMLCell, height:CGFloat, isRowSelected:Bool)->some View
    {
        
        let isCellSelected = selectedCell == cell.id
        
        return Text(cell.displayValue)
            .font(.system(size:13))
            .foregroundColor(cellTextColor(for:cell))
            .lineLimit(3)
            .truncationMode(.tail)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .frame(width:columnWidth(for:cell.columnIndex), height:height, alignment:cellAlignment(for:cell))
            .background(cellBackground(for:cell, isSelected:isCellSelected, isRowSelected:isRowSelected))
            .border(isRowSelected ? Color.orange.opacity(0.6) : Color.gray.opacity(0.3), width:isRowSelected ? 1.5 : 0.5)
            .contentShape(Rectangle())
            .onTapGesture 
            {
                // Tapping a cell clears row selection and shows cell detail...
                
                selectedRowIndex      = nil
                selectedCell          = cell.id
                selectedCellForDetail = cell
                showingCellDetail     = true

                appLogMsg("\(ClassInfo.sClsDisp) Cell tapped: [\(cell.displayValue)] at column [\(cell.columnIndex)] - showing detail sheet...")
            }

    }   // End of private func dataCell(cell:SpreadsheetXMLCell, height:CGFloat, isRowSelected:Bool)->some View.
    
    // MARK: - Priority #4: Enhanced Empty Cell with Row Highlighting...
    
    private func emptyCell(colIndex:Int, height:CGFloat, isRowSelected:Bool)->some View
    {
        
        Rectangle()
            .fill(isRowSelected ? Color.orange.opacity(0.15) : Color.clear)
            .frame(width:columnWidth(for:colIndex), height:height)
            .border(isRowSelected ? Color.orange.opacity(0.6) : Color.gray.opacity(0.3), 
                    width:isRowSelected ? 1.5 : 0.5)

    }   // End of private func emptyCell(colIndex:Int, height:CGFloat, isRowSelected:Bool)->some View.
    
    // MARK: - Cell Styling:
    
    private func cellTextColor(for cell:SpreadsheetXMLCell)->Color
    {
        
        switch cell.type
        {
        case .number:
            return .primary
        case .dateTime:
            return .purple
        case .boolean:
            return .green
        case .error:
            return .red
        default:
            return .primary
        }

    }   // End of private func cellTextColor(for cell:SpreadsheetXMLCell)->Color.
    
    // MARK: - Priority #4: Enhanced Cell Background with Row Highlighting...
    
    private func cellBackground(for cell:SpreadsheetXMLCell, isSelected:Bool, isRowSelected:Bool)->Color
    {
        
        // Priority: cell selection > row selection > alternating > default...
        
        if isSelected
        {
            return Color.blue.opacity(0.3)
        }
        else if isRowSelected
        {
            return Color.orange.opacity(0.25)
        }
        else
        {
        //  return Color(UIColor.systemBackground)
        #if os(macOS)
            return Color(nsColor: .windowBackgroundColor)
        #endif
        #if os(iOS)
            return Color(uiColor:UIColor.systemBackground)
        #endif
        }

    }   // End of private func cellBackground(for cell:SpreadsheetXMLCell, isSelected:Bool, isRowSelected:Bool)->Color.
    
    private func cellAlignment(for cell:SpreadsheetXMLCell)->Alignment
    {
        
        switch cell.type
        {
        case .number:
            return .trailing
        case .boolean:
            return .center
        default:
            return .leading
        }

    }   // End of private func cellAlignment(for cell:SpreadsheetXMLCell)->Alignment.
    
    // MARK: - Column Width Management:
    
    private func columnWidth(for index:Int)->CGFloat
    {
        
        return columnWidths[index] ?? defaultCellWidth

    }   // End of private func columnWidth(for index:Int)->CGFloat.
    
    private func handleResizeDrag(columnIndex:Int, value:DragGesture.Value)
    {
        
        if (draggingColumn == nil)
        {
            // Start drag - record initial width...

            draggingColumn  = columnIndex
            dragStartWidth  = columnWidth(for:columnIndex)

            appLogMsg("\(ClassInfo.sClsDisp) Started resizing column [\(columnIndex)] from width [\(dragStartWidth)] px...")
        }
        
        if (draggingColumn == columnIndex)
        {
            let newWidth = max(minColumnWidth, dragStartWidth + value.translation.width)

            columnWidths[columnIndex] = newWidth
        }

    }   // End of private func handleResizeDrag(columnIndex:Int, value:DragGesture.Value).
    
    // MARK: - Helper Functions:
    
    private func columnLetter(for index:Int)->String
    {
        
        var column = index
        var result = ""
        
        while column >= 0
        {
            result = String(UnicodeScalar(65 + (column % 26))!) + result
            column = (column / 26) - 1

            if (column < 0)
            {
                break
            }
        }
        
        return result

    }   // End of private func columnLetter(for index:Int)->String.
    
}   // End of struct SpreadsheetTableView:View.

// MARK: - Cell Detail View

struct CellDetailView:View
{
    
    struct ClassInfo 
    {
        static let sClsId        = "CellDetailView"
        static let sClsVers      = "v1.0501"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // MARK: - Properties...

//  @Environment(\.dismiss)      private var dismiss
    @Environment(\.presentationMode)     var presentationMode

                   let cell:SpreadsheetXMLCell
                   let worksheet:SpreadsheetXMLWorksheet
    
    var body:some View
    {
        
        NavigationStack 
        {
            Form 
            {
                // Display Value Section...

                Section("Display Value") 
                {
                    Text(cell.displayValue)
                        .textSelection(.enabled)
                        .font(.body)
                }
                
            //  // Raw Value Section (if different from display)...
            //
            //  if let rawValue  = cell.rawValue, 
            //         rawValue != cell.displayValue 
            //  {
            //      Section("Raw Value") 
            //      {
            //          Text(rawValue)
            //              .textSelection(.enabled)
            //              .font(.system(.body, design:.monospaced))
            //      }
            //  }
                
                // Formula Section (if present)...

                if let formula = cell.formula 
                {
                    Section("Formula") 
                    {
                        Text(formula)
                            .textSelection(.enabled)
                            .font(.system(.body, design:.monospaced))
                            .foregroundStyle(.green)
                    }
                }
                
                // Cell Information...

                Section("Cell Information") 
                {
                    LabeledContent("Type",   value:cell.type.rawValue)
                    LabeledContent("Column", value:columnLetter(for:cell.columnIndex))
                    LabeledContent("Row",    value:String(findRowIndex(for:cell) + 1))
                    
                    if let styleID = cell.styleID 
                    {
                        LabeledContent("Style ID", value:styleID)
                    }
                    
//                    if cell.isMerged 
//                    {
//                        LabeledContent("Merged",   value:"Yes")
//                    }
                    
//                    if cell.isHidden 
//                    {
//                        LabeledContent("Hidden",   value:"Yes")
//                    }
                }
            }
            .navigationTitle("Cell Details")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar
            {
            //  ToolbarItem(placement:.navigationBarTrailing)
                ToolbarItem(placement:.primaryAction)
                {
                    Button
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsView.Button(Xcode).'Dismiss' pressed...")

                        self.presentationMode.wrappedValue.dismiss()
                    }
                    label:
                    {
                        VStack(alignment:.center)
                        {
                            Label("", systemImage:"xmark.circle")
                                .help(Text("Dismiss this Screen"))
                                .imageScale(.small)
                            Text("Dismiss")
                                .font(.caption2)
                        }
                    }
                #if os(macOS)
                    .buttonStyle(.borderedProminent)
                //  .background(???.isPressed ? .blue : .gray)
                    .cornerRadius(10)
                    .foregroundColor(Color.primary)
                #endif
                    .padding()
                }

            //  ToolbarItem(placement:.confirmationAction) 
            //  {
            //      Button("Done") 
            //      {
            //          dismiss()
            //      }
            //  }
            }
        }

    }   // End of var body:some View.
    
    // MARK: - Helper Functions:
    
    private func columnLetter(for index:Int)->String
    {
        
        var column = index
        var result = ""
        
        while column >= 0
        {
            result = String(UnicodeScalar(65 + (column % 26))!) + result
            column = (column / 26) - 1

            if (column < 0)
            {
                break
            }
        }
        
        return result

    }   // End of private func columnLetter(for index:Int)->String.
    
    private func findRowIndex(for cell:SpreadsheetXMLCell)->Int
    {
        
        for (index, row) in worksheet.rows.enumerated() 
        {
            if row.cells.contains(where: { $0.id == cell.id }) 
            {
                return index
            }
        }
        
        return 0

    }   // End of private func findRowIndex(for cell:SpreadsheetXMLCell)->Int.
    
}   // End of struct CellDetailView:View.

// MARK: - Preview

struct SpreadsheetTableView_Previews:PreviewProvider
{
    
    static var previews:some View 
    {

        let worksheet = SpreadsheetXMLWorksheet(
            name: "Sample Sheet",
            rows: [
                SpreadsheetXMLRow(
                    rowIndex: 0,
                    cells: [
                        SpreadsheetXMLCell(columnIndex: 0, value: "Name", type: .string),
                        SpreadsheetXMLCell(columnIndex: 1, value: "Value", type: .string),
                        SpreadsheetXMLCell(columnIndex: 2, value: "Date", type: .string)
                    ]
                ),
                SpreadsheetXMLRow(
                    rowIndex: 1,
                    cells: [
                        SpreadsheetXMLCell(columnIndex: 0, value: "Item 1", type: .string),
                        SpreadsheetXMLCell(columnIndex: 1, value: "123.45", type: .number),
                        SpreadsheetXMLCell(columnIndex: 2, value: "2025-11-19T10:30:00", type: .dateTime)
                    ]
                )
            ],
            columnCount: 3,
            rowCount: 2
        )
        
        SpreadsheetTableView(worksheet: worksheet)
            .previewDevice("iPad Pro (11-inch)")
            .previewDisplayName("iPad Pro 11-inch")

    }
    
}   // End of struct SpreadsheetTableView_Previews:PreviewProvider.
