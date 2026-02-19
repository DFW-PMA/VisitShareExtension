//
//  SpreadsheetXMLViewer.swift
//  SpreadsheetXMLViewer
//
//  Created by Claude/Daryl Cox on 11/19/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct SpreadsheetXMLViewer:View
{
    
    struct ClassInfo
    {
        static let sClsId        = "SpreadsheetXMLViewer"
        static let sClsVers      = "v1.0601"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // MARK: - Import Manager
    
    @ObservedObject private var importManager           = AppFileImportManager.shared
    
    // MARK: - State Properties
    
    @State private var workbook:SpreadsheetXMLWorkbook? = nil
    @State private var selectedWorksheetIndex:Int       = 0
    @State private var showImportPicker:Bool            = false
    @State private var showExportPicker:Bool            = false
    @State private var showAlert:Bool                   = false
    @State private var alertTitle:String                = ""
    @State private var alertMessage:String              = ""
    @State private var isProcessing:Bool                = false
    @State private var exportURL:URL?                   = nil
    
    // MARK: - Body
    
    var body:some View
    {
        
        NavigationView
        {
            ZStack 
            {
                // Main Content...

                if let workbook = workbook, !workbook.worksheets.isEmpty
                {
                    VStack(spacing:0)
                    {
                        // Worksheet Tabs...

                        if (workbook.worksheets.count > 1)
                        {
                            worksheetTabBar(workbook:workbook)
                        }
                        
                        // Spreadsheet Display...

                        if (selectedWorksheetIndex >= 0 && 
                            selectedWorksheetIndex  < workbook.worksheets.count)
                        {
                            SpreadsheetTableView(worksheet:workbook.worksheets[selectedWorksheetIndex])
                        }
                        
                        // Status Bar...

                        statusBar(workbook:workbook)
                    }
                } 
                else
                {
                    // Empty State...

                    emptyStateView()
                }
                
                // Loading Overlay...

                if (isProcessing) 
                {
                    loadingOverlay()
                }
            }
            .navigationTitle("Spreadsheet XML Viewer")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar
            {
                toolbarContent()
            }
            .sheet(isPresented:$showImportPicker)
            {
                importPickerView()
            }
            .sheet(isPresented:$showExportPicker)
            {
                exportPickerView()
            }
            .alert(isPresented:$showAlert)
            {
                Alert(title:        Text(alertTitle),
                      message:      Text(alertMessage),
                      dismissButton:.default(Text("OK"))
                )
            }
            .onChange(of:importManager.urlToImport)
            { oldValue, newValue in

                let sCurrMethod:String     = #function
                let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"

                if let url = newValue
                {
                    appLogMsg("\(sCurrMethodDisp) Import URL changed - triggering import for URL: [\(url)]...")

                    // Trigger import using existing handleImportResult logic...

                    self.handleImportResult(.success(url))

                    appLogMsg("\(sCurrMethodDisp) Import triggered for URL: [\(url.lastPathComponent)]...")
                }
                else
                {
                    appLogMsg("\(sCurrMethodDisp) Import URL cleared (no action needed)...")
                }
            }
        }
    #if os(iOS)
        .navigationViewStyle(.stack)
    #endif

    }
    
    // MARK: - View Components...
    
    private func emptyStateView()->some View
    {
        
        VStack(spacing:20)
        {
            Image(systemName:"doc.text.magnifyingglass")
                .font(.system(size:72))
                .foregroundColor(.gray)
            
            Text("No Spreadsheet Loaded")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the import button to load a SpreadsheetXML (.xml) file")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action:
                   { showImportPicker = true } ) 
            {
                HStack 
                {
                    Image(systemName:"square.and.arrow.down")
                    Text("Import SpreadsheetXML File")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.top, 20)
        }

    }   // End of private func emptyStateView()->some View.
    
    private func worksheetTabBar(workbook:SpreadsheetXMLWorkbook)->some View
    {
        
        ScrollView(.horizontal, showsIndicators:false)
        {
            HStack(spacing:4)
            {
                ForEach(Array(workbook.worksheets.enumerated()), id:\.element.id) 
                { index, worksheet in

                    Button(action: 
                           {
                               selectedWorksheetIndex = index

                               appLogMsg("\(ClassInfo.sClsDisp) Selected worksheet: [\(worksheet.name)]...")
                           }) 
                    {
                        Text(worksheet.name)
                            .font(.system(size:14, weight:selectedWorksheetIndex == index ? .semibold :.regular))
                            .foregroundColor(selectedWorksheetIndex == index ? .blue : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        //  .background(selectedWorksheetIndex == index ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemBackground))
                        #if os(macOS)
                            .background(selectedWorksheetIndex == index ? Color.blue.opacity(0.1) : Color(nsColor: .windowBackgroundColor))
                        #endif
                        #if os(iOS)
                            .background(selectedWorksheetIndex == index ? Color.blue.opacity(0.1) : Color(uiColor:UIColor.secondarySystemBackground))
                        #endif
                            .cornerRadius(8)
                    }

                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    //  .background(Color(UIColor.systemBackground))
    #if os(macOS)
        .background(Color(nsColor: .windowBackgroundColor))
    #endif
    #if os(iOS)
        .background(Color(uiColor:UIColor.systemBackground))
    #endif
        .border(Color.gray.opacity(0.2), width:0.5)

    }   // End of private func worksheetTabBar(workbook:SpreadsheetXMLWorkbook)->some View.
    
    private func statusBar(workbook:SpreadsheetXMLWorkbook)->some View
    {
        
        HStack
        {
            if (selectedWorksheetIndex >= 0 && 
                selectedWorksheetIndex  < workbook.worksheets.count)
            {
                let worksheet = workbook.worksheets[selectedWorksheetIndex]
                
                Text("Rows: \(worksheet.rowCount)")
                    .font(.system(size:12))
                    .foregroundColor(.secondary)
                
                Divider()
                    .frame(height:12)
                
                Text("Columns: \(worksheet.columnCount)")
                    .font(.system(size:12))
                    .foregroundColor(.secondary)
                
                Divider()
                    .frame(height:12)
                
                Text("Cells: \(worksheet.totalCellCount)")
                    .font(.system(size:12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("File: \(workbook.fileName)")
                    .font(.system(size:12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    //  .background(Color(UIColor.secondarySystemBackground))
    #if os(macOS)
        .background(Color(nsColor: .windowBackgroundColor))
    #endif
    #if os(iOS)
        .background(Color(uiColor:UIColor.secondarySystemBackground))
    #endif
        .border(Color.gray.opacity(0.2), width:0.5)

    }   // End of private func statusBar(workbook:SpreadsheetXMLWorkbook)->some View.
    
    private func loadingOverlay()->some View
    {
        
        ZStack 
        {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing:16) 
            {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint:.white))
                
                Text("Processing...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(40)
        //  .background(Color(UIColor.systemGray))
        #if os(macOS)
            .background(Color(nsColor:.systemGray))
        #endif
        #if os(iOS)
            .background(Color(UIColor.systemGray))
        #endif
            .cornerRadius(12)
        }

    }   // End of private func loadingOverlay()->some View.
    
    @ToolbarContentBuilder
    private func toolbarContent()->some ToolbarContent
    {
        
    //  ToolbarItem(placement:.navigationBarLeading)
        ToolbarItem(placement:.principal)
        {
            Button(action:
                   {
                       showImportPicker = true
                   })
            {
                Label("Import XML", systemImage:"square.and.arrow.down")
            }
        }
        
    //  ToolbarItem(placement:.navigationBarLeading)
        ToolbarItem(placement:.principal)
        {
            Button(action:
                   {
                       exportWorksheetToCSV()
                   })
            {
                Label("Export (tab) CSV", systemImage:"square.and.arrow.up")
            }
            .disabled(workbook == nil)
        }
        
    //  ToolbarItem(placement:.navigationBarTrailing)
        ToolbarItem(placement:.primaryAction)
        {
            Button(action:
                   {
                       workbook = nil
                   })
            {
                Label("Done XML", systemImage:"pip.remove")
            }
            .disabled(workbook == nil)
        }

    }   // End of @ToolbarContentBuilder private func toolbarContent()->some ToolbarContent.
    
    // MARK: - Document Pickers
    
    private func importPickerView()->some View
    {

    #if os(macOS)
        return AnyView(EmptyView())
    #endif
    #if os(iOS)
    //  AppDocumentImportPickerView(contentTypes:[.xml, UTType(filenameExtension:"xml")!],
        AppDocumentImportPickerView(contentTypes:[.xml, UTType(filenameExtension:"xml")!, UTType(filenameExtension:"xls")!, UTType(filenameExtension:"json")!],
                                    completion:  handleImportResult)
    #endif

    }   // End of private func importPickerView()->some View.
    
    private func exportPickerView()->some View
    {
        
    #if os(macOS)
        return AnyView(EmptyView())
    #endif
    #if os(iOS)
        if let url = exportURL 
        {
            return AnyView(AppDocumentExportPickerView(url:url, completion:handleExportResult))
        } 
        else 
        {
            return AnyView(EmptyView())
        }
    #endif

    }   // End of private func exportPickerView()->some View.
    
    // MARK: - Import/Export Handlers...
    
    private func handleImportResult(_ result:Result<URL, Error>)
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        switch result
        {
        case .success(let url):
            appLogMsg("\(sCurrMethodDisp) Import succeeded - URL: [\(url.path)]...")
            
            isProcessing = true
            
            // Process on background thread...

            DispatchQueue.global(qos:.userInitiated).async
            {
                // Critical: Start accessing the 'security-scoped' resource...

                appLogMsg("\(sCurrMethodDisp) Intermediate - Attempting to access security scoped resource for URL: [\(url.path)]...")

                guard url.startAccessingSecurityScopedResource()
                else 
                {
                    appLogMsg("\(sCurrMethodDisp) Intermediate - Failed to access security scoped resource for URL: [\(url.path)]...")
                    
                    showAlert(title:  "Import Failed",
                              message:"Failed to to access security scoped resource for URL: [\(url.path)]")
                    
                    return
                }

                defer 
                {
                    // Always stop accessing when done...

                    url.stopAccessingSecurityScopedResource()
                }

            //  let accessing = url.startAccessingSecurityScopedResource()
            //
            //  defer 
            //  {
            //      if accessing 
            //      {
            //          url.stopAccessingSecurityScopedResource()
            //      }
            //  }

                let parser      = SpreadsheetXMLParser()
                let parseResult = parser.parse(url:url)
                
                DispatchQueue.main.async
                {
                    isProcessing = false
                    
                    switch parseResult
                    {
                    case .success(let parsedWorkbook):
                        appLogMsg("\(sCurrMethodDisp) Parse succeeded - Workbook has #(\(parsedWorkbook.worksheets.count)) worksheet(s)...")
                        
                        self.workbook               = parsedWorkbook
                        self.selectedWorksheetIndex = 0
                        
                        // Notify import manager of success...

                        importManager.importCompleted(fileName:url.lastPathComponent)
                        
                        showAlert(title:  "Import Successful",
                                  message:"Loaded ['\(parsedWorkbook.fileName)'] with #(\(parsedWorkbook.worksheets.count)) worksheet(s) and #(\(parsedWorkbook.totalCellCount)) cell(s)")
                    case .failure(let error):
                        appLogMsg("\(sCurrMethodDisp) Parse failed - Error: [\(error.localizedDescription)]...")
                        
                        // Notify import manager of failure...

                        importManager.importFailed(error:error, fileName:url.lastPathComponent)
                        
                        showAlert(title:  "Import Failed",
                                  message:"Failed to parse SpreadsheetXML file:\n[\(error.localizedDescription)]")
                    }
                }
            }
        case .failure(let error):
            appLogMsg("\(sCurrMethodDisp) Import failed - Error: [\(error.localizedDescription)]...")
            
            showAlert(title:  "Import Failed",
                      message:"Failed to import file:\n[\(error.localizedDescription)]...")
        }

    }   // End of private func handleImportResult(_ result:Result<URL, Error>).
    
    private func exportWorksheetToCSV()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        guard let workbook = workbook 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) No workbook loaded...")

            return
        }
        
        guard selectedWorksheetIndex >= 0 &&
              selectedWorksheetIndex  < workbook.worksheets.count 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) Invalid worksheet index: [\(selectedWorksheetIndex)]...")

            return
        }
        
        appLogMsg("\(sCurrMethodDisp) Exporting worksheet (tab) to CSV...")
        
        // Convert to CSV...

        guard let csvString = workbook.toCSV(worksheetIndex:selectedWorksheetIndex) 
        else 
        {
            showAlert(title:  "Export (tab) Failed",
                      message:"Failed to convert worksheet (tab) to CSV format")

            return
        }
        
        // Create temporary file...

        let worksheet = workbook.worksheets[selectedWorksheetIndex]
        let fileName  = "\(worksheet.name.replacingOccurrences(of:" ", with:"_")).csv"
        let tempURL   = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do 
        {
            try csvString.write(to:tempURL, atomically:true, encoding:.utf8)

            appLogMsg("\(sCurrMethodDisp) CSV worksheet (tab) written to temp file: [\(tempURL.path)]...")
            
            // Set export URL and show picker...

            exportURL        = tempURL
            showExportPicker = true
        } 
        catch 
        {
            appLogMsg("\(sCurrMethodDisp) Failed to write CSV worksheet (tab) - Error: [\(error.localizedDescription)]..")
            
            showAlert(title:  "Export (tab) Failed",
                      message:"Failed to create CSV file:\n\(error.localizedDescription)")
        }

    }   // End of private func exportWorksheetToCSV().
    
    private func handleExportResult(_ result:Result<URL, Error>)
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        switch result
        {
        case .success(let url):
            appLogMsg("\(sCurrMethodDisp) Export succeeded - URL: [\(url.path)]...")
            
            showAlert(title:  "Export (tab) Successful",
                      message:"CSV file exported to:\n\(url.lastPathComponent)")
        case .failure(let error):
            appLogMsg("\(sCurrMethodDisp) Export failed - Error: [\(error.localizedDescription)]...")
            
            showAlert(title:  "Export (tab) Failed",
                      message:"Failed to export file:\n\(error.localizedDescription)")
        }

    }   // End of private func handleExportResult(_ result:Result<URL, Error>).
    
    // MARK: - Helper Methods
    
    private func showAlert(title:String, message:String)
    {
        
        alertTitle   = title
        alertMessage = message
        showAlert    = true

    }   // End of private func showAlert(title:String, message:String).
    
}   // End of struct SpreadsheetXMLViewer:View.

// MARK: - Preview

struct SpreadsheetXMLViewer_Previews:PreviewProvider
{
    
    static var previews:some View
    {

        SpreadsheetXMLViewer()
            .previewDevice("iPad Pro (11-inch)")
            .previewDisplayName("iPad Pro 11-inch")

    }
    
}   // End of struct SpreadsheetXMLViewer_Previews:PreviewProvider.

