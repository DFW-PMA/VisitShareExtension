//
//  AppJsonDisplayView.swift
//  SpreadsheetML Viewer
//
//  Displays JSON data from non-spreadsheet XML files
//  v1.0300 - Fallback view for generic XML content
//

import Foundation
import SwiftUI

// View for displaying JSON data with expandable sections
// Used when XML file is not a valid spreadsheet

struct AppJsonDisplayView:View
{
    
    struct ClassInfo
    {
        static let sClsId        = "AppJsonDisplayView"
        static let sClsVers      = "v1.0401"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // MARK: - Properties
    
                       let items:[JsonDisplayItem]
                       let rawData:Data
    
    @State     private var expandedItems = Set<String>()
    @State     private var searchText    = ""
    @State     private var showRawView   = false
    
    // MARK: - Computed Properties
    
    private var filteredItems:[JsonDisplayItem]
    {
        guard !searchText.isEmpty
        else 
        {
            return items
        }
        
        return items.filter 
        { item in

            item.key.localizedCaseInsensitiveContains(searchText) ||
            item.value.localizedCaseInsensitiveContains(searchText)

        }

    }

    #if os(macOS)
               private let pasteboard                                = NSPasteboard.general
    #elseif os(iOS)
               private let pasteboard                                = UIPasteboard.general
    #endif
    
    // MARK: - Body
    
    var body: some View
    {

        VStack(spacing:0)
        {
            // Header...

            headerView
            
            // Content...

            if filteredItems.isEmpty && 
               !searchText.isEmpty
            {
                emptySearchView
            } 
            else
            {
                contentListView
            }
        }
        .navigationTitle("JSON View")
    #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
    #endif
    //  .toolbar
    //  {
    //  //  ToolbarItemGroup(placement:.primaryAction)
    //      ToolbarItemGroup(placement:.navigationBarTrailing)
    //      {
    //          expandCollapseButtons
    //          rawViewButton
    //      }
    //  }
        .sheet(isPresented:$showRawView)
        {
            RawDataView(data:rawData)
        }
        .searchable(text:$searchText, prompt:"Search JSON keys and values")
        .onAppear 
        {
            appLogMsg("✓ AppJsonDisplayView: Appeared with #(\(items.count)) item(s)...")
        }

    }
    
    // MARK: - Subviews
    
    private var headerView:some View
    {
        HStack 
        {
            Image(systemName:"doc.text.magnifyingglass")
                .foregroundStyle(.blue)
            
            Text("JSON Data")
                .font(.headline)
            
            Spacer()
            
            Text("\(items.count) items")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            expandCollapseButtons
            rawViewButton
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    #if os(macOS)
        .background(Color(nsColor: .windowBackgroundColor))
    #endif
    #if os(iOS)
        .background(Color(uiColor:.systemGroupedBackground))
    #endif
    }
    
    private var contentListView:some View
    {
        List 
        {
            ForEach(filteredItems) 
            { item in

                if item.isExpandable 
                {
                    DisclosureGroup(
                        isExpanded:Binding(
                            get: { expandedItems.contains(item.id.uuidString) },
                            set: { isExpanded in
                                if isExpanded 
                                {
                                    expandedItems.insert(item.id.uuidString)
                                    appLogMsg("→ AppJsonDisplayView: Expanded item '\(item.key)'")
                                } 
                                else
                                {
                                    expandedItems.remove(item.id.uuidString)
                                    appLogMsg("→ AppJsonDisplayView: Collapsed item '\(item.key)'")
                                }
                            }
                        ) ) 
                    {
                        ForEach(item.children) 
                        { child in

                            childItemView(child, depth:1)

                        }
                    } 
                    label:
                    {
                        itemRowView(item)
                    }
                    .contextMenu
                    {
                        contextMenuButtons(for:item)
                    }
                } 
                else
                {
                    itemRowView(item)
                        .contextMenu
                        {
                            Button 
                            {
                            //  UIPasteboard.general.string = item.value
                            #if os(macOS)
                                pasteboard.prepareForNewContents()
                                pasteboard.setString(item.value, forType:.string)
                            #elseif os(iOS)
                                pasteboard.string = item.value
                            #endif
                                appLogMsg("✓ AppJsonDisplayView: Copied value to clipboard: '\(item.value)'")
                            } 
                            label:
                            {
                                Label("Copy Value", systemImage: "doc.on.doc")
                            }
                            
                            Button
                            {
                            //  UIPasteboard.general.string = "\(item.key): \(item.value)"
                            #if os(macOS)
                                pasteboard.prepareForNewContents()
                                pasteboard.setString("\(item.key): \(item.value)", forType:.string)
                            #elseif os(iOS)
                                pasteboard.string = "\(item.key): \(item.value)"
                            #endif
                                appLogMsg("✓ AppJsonDisplayView: Copied key-value pair to clipboard")
                            } 
                            label:
                            {
                                Label("Copy Key & Value", systemImage: "doc.on.doc.fill")
                            }
                        }
                }

            }
        }
    #if os(iOS)
        .listStyle(.insetGrouped)
    #endif
        
    }
    
    private func childItemView(_ item:JsonDisplayItem, depth:Int)->AnyView 
    {

        AnyView(
            Group 
            {
                if item.isExpandable
                {
                    DisclosureGroup(
                        isExpanded:Binding(
                            get: { expandedItems.contains(item.id.uuidString) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedItems.insert(item.id.uuidString)
                                } else {
                                    expandedItems.remove(item.id.uuidString)
                                }
                            }
                        ) ) 
                    {
                        ForEach(item.children) 
                        { child in

                            childItemView(child, depth:depth + 1)

                        }
                    } 
                    label:
                    {
                        itemRowView(item)
                    }
                    .contextMenu
                    {
                        contextMenuButtons(for:item)
                    }
                } 
                else
                {
                    itemRowView(item)
                        .padding(.leading, CGFloat(depth * 8))
                        .contextMenu 
                        {
                            Button 
                            {
                            //  UIPasteboard.general.string = item.value
                            #if os(macOS)
                                pasteboard.prepareForNewContents()
                                pasteboard.setString(item.value, forType:.string)
                            #elseif os(iOS)
                                pasteboard.string = item.value
                            #endif
                            } 
                            label:
                            {
                                Label("Copy Value", systemImage: "doc.on.doc")
                            }
                        }
                }
            }
        )

    }   // End of private func childItemView(_ item:JsonDisplayItem, depth:Int)->AnyView.
    
    private func itemRowView(_ item:JsonDisplayItem)->some View
    {
        HStack(alignment:.top, spacing:12)
        {
            // Icon...

            Image(systemName: item.isExpandable ? "folder.fill" : "doc.text.fill")
                .foregroundStyle(item.isExpandable ? .blue : .secondary)
                .font(.body)
                .frame(width:20)
            
            // Key...

            Text(item.key)
                .font(.system(.body, design:.monospaced))
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            Spacer()
            
            // Value...

            Text(item.value)
                .font(.system(.caption, design:.monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.vertical, 4)

    }   // End of private func itemRowView(_ item:JsonDisplayItem)->some View.
    
    private var emptySearchView:some View
    {
        VStack(spacing:16)
        {
            Image(systemName: "magnifyingglass")
                .font(.system(size:48))
                .foregroundStyle(.secondary)
            
            Text("No Results")
                .font(.headline)
            
            Text("No items match '\(searchText)'")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth:.infinity, maxHeight:.infinity)
    }
    
    private var expandCollapseButtons:some View
    {
        HStack
        {
            Button
            {
                self.expandAllItems()
            }
            label:
            {
                Label("Expand All", systemImage:"arrow.up.left.and.arrow.down.right")
            }
            
            Button
            {
                self.collapseAllItems()
            }
            label:
            {
                Label("Collapse All", systemImage:"arrow.down.right.and.arrow.up.left")
            }
        }
    }
    
    private var rawViewButton:some View
    {
        Button
        {
            showRawView = true

            appLogMsg("→ AppJsonDisplayView: Opening raw data view")
        } 
        label:
        {
            Label("Raw Data", systemImage:"doc.plaintext")
        //  Image(systemName:"doc.plaintext")
        }
    }
    
    private func contextMenuButtons(for item:JsonDisplayItem)->some View
    {

        Group 
        {
            Button
            {
                if expandedItems.contains(item.id.uuidString)
                {
                    expandedItems.remove(item.id.uuidString)
                } 
                else
                {
                    expandedItems.insert(item.id.uuidString)
                }
            } 
            label:
            {
                Label(expandedItems.contains(item.id.uuidString) ? "Collapse" : "Expand",
                      systemImage:expandedItems.contains(item.id.uuidString) ? "chevron.up" : "chevron.down")
            }
            
            Button 
            {
                expandItem(item, recursively:true)
            } 
            label:
            {
                Label("Expand All Children", systemImage:"arrow.down.right.and.arrow.up.left")
            }
            
            Button
            {
                collapseItem(item, recursively:true)
            } 
            label:
            {
                Label("Collapse All Children", systemImage:"arrow.up.left.and.arrow.down.right")
            }
            
            Divider()
            
            Button 
            {
            //  UIPasteboard.general.string = item.key
            #if os(macOS)
                pasteboard.prepareForNewContents()
                pasteboard.setString(item.key, forType:.string)
            #elseif os(iOS)
                pasteboard.string = item.key
            #endif
                appLogMsg("✓ AppJsonDisplayView: Copied key to clipboard: '\(item.key)'...")
            } 
            label:
            {
                Label("Copy Key", systemImage: "key")
            }
        }

    }   // End of private func contextMenuButtons(for item:JsonDisplayItem)->some View.
    
    // MARK: - Private Methods
    
    private func expandAllItems()
    {

        appLogMsg("→ AppJsonDisplayView: Expanding all items")
        
        func addAllIds(_ items:[JsonDisplayItem])
        {

            for item in items
            {
                if item.isExpandable
                {
                    expandedItems.insert(item.id.uuidString)
                    addAllIds(item.children)
                }
            }

        }   // End of func addAllIds(_ items:[JsonDisplayItem]).
        
        addAllIds(items)

        appLogMsg("✓ AppJsonDisplayView: Expanded #(\(expandedItems.count)) item(s)...")

    }   // End of private func expandAllItems().
    
    private func collapseAllItems()
    {

        appLogMsg("→ AppJsonDisplayView: Collapsing all items")

        expandedItems.removeAll()

        appLogMsg("✓ AppJsonDisplayView: All items collapsed")

    }   // End of private func collapseAllItems().
    
    private func expandItem(_ item:JsonDisplayItem, recursively:Bool)
    {

        expandedItems.insert(item.id.uuidString)
        
        if recursively
        {
            for child in item.children where child.isExpandable
            {
                expandItem(child, recursively:true)
            }
        }
        
        appLogMsg("✓ AppJsonDisplayView: Expanded item '\(item.key)'\(recursively ? " and children" : "")...")

    }   // End of private func expandItem(_ item:JsonDisplayItem, recursively:Bool).
    
    private func collapseItem(_ item:JsonDisplayItem, recursively:Bool)
    {

        expandedItems.remove(item.id.uuidString)
        
        if recursively
        {
            for child in item.children where child.isExpandable
            {
                collapseItem(child, recursively:true)
            }
        }
        
        appLogMsg("✓ AppJsonDisplayView: Collapsed item '\(item.key)'\(recursively ? " and children" : "")...")

    }   // End of private func collapseItem(_ item:JsonDisplayItem, recursively:Bool).
    
}   // End of struct AppJsonDisplayView:View.

// MARK: - Raw Data View

// Displays raw XML/JSON text content...

struct RawDataView:View
{
    
    struct ClassInfo
    {
        static let sClsId        = "RawDataView"
        static let sClsVers      = "v1.0301"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    
                       let data:Data
    
    @State private var displayText:String     = ""
    @State private var fontSize:CGFloat       = 12
    @State private var isLoading:Bool         = true
    @State private var loadError:String?      = nil
    
    // MARK: - Constants
    
           private let largeFileThreshold:Int = 100_000  // 100KB threshold for "large" files

    #if os(macOS)
           private let pasteboard             = NSPasteboard.general
    #elseif os(iOS)
           private let pasteboard             = UIPasteboard.general
    #endif
    
    var body:some View
    {

        NavigationStack
        {
            ZStack
            {
                if isLoading
                {
                    // Loading view...
                    
                    VStack(spacing:16)
                    {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Loading \(formatByteCount(data.count))...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                else if let error = loadError
                {
                    // Error view...
                    
                    VStack(spacing:16)
                    {
                        Image(systemName:"exclamationmark.triangle.fill")
                            .font(.system(size:48))
                            .foregroundStyle(.orange)
                        
                        Text("Loading Error")
                            .font(.headline)
                        
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                else
                {
                    // Content view - use TextEditor for better performance with large text...
                    
                    TextEditor(text:.constant(displayText))
                        .font(.system(size:fontSize, design:.monospaced))
                        .padding(8)
                        .scrollContentBackground(.hidden)
                    #if os(macOS)
                        .background(Color(nsColor: .windowBackgroundColor))
                    #endif
                    #if os(iOS)
                        .background(Color(uiColor:.systemGroupedBackground))
                    #endif
                }
            }
            .navigationTitle("Raw Data")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar
            {
                ToolbarItem(placement:.cancellationAction)
                {
                    Button("Done")
                    {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement:.primaryAction)
                {
                    // Font size controls...

                    Button
                    {
                        fontSize = max(8, fontSize - 1)
                    } 
                    label:
                    {
                        Image(systemName:"textformat.size.smaller")
                    }
                    .disabled(fontSize <= 8 || isLoading)
                    
                    Button
                    {
                        fontSize = min(24, fontSize + 1)
                    } 
                    label:
                    {
                        Image(systemName: "textformat.size.larger")
                    }
                    .disabled(fontSize >= 24 || isLoading)
                    
                    // Copy button...

                    Button
                    {
                    //  UIPasteboard.general.string = displayText
                    #if os(macOS)
                        pasteboard.prepareForNewContents()
                        pasteboard.setString(displayText, forType:.string)
                    #elseif os(iOS)
                        pasteboard.string = displayText
                    #endif
                        appLogMsg("✓ RawDataView: Copied text to clipboard #(\(displayText.count)) characters...")
                    } 
                    label:
                    {
                        Image(systemName:"doc.on.doc")
                    }
                    .disabled(isLoading || displayText.isEmpty)
                }
            }
            .task
            {
                await loadTextAsync()
            }
        }

    }
    
    private func loadTextAsync() async
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Loading text from data of #(\(data.count)) byte(s)...")
        
        // Check if this is a large file...
        
        let isLargeFile = data.count > largeFileThreshold
        
        if isLargeFile
        {
            appLogMsg("\(sCurrMethodDisp) Large file detected (\(formatByteCount(data.count))), loading asynchronously...")
        }
        
        // Perform the text conversion on a background thread...
        
        let result = await Task.detached(priority:.userInitiated)
        {
            () -> Result<String, Error> in
            
            // Simulate a small delay for very large files to ensure UI updates...
            
            if isLargeFile
            {
                try? await Task.sleep(nanoseconds:100_000_000) // 0.1 seconds
            }
            
            guard let text = String(data:data, encoding:.utf8)
            else
            {
                return .failure(NSError(domain:   "RawDataView",
                                        code:     1001,
                                        userInfo: [NSLocalizedDescriptionKey: "Unable to decode data as UTF-8 text"]))
            }
            
            return .success(text)
            
        }.value
        
        // Update UI on main thread...
        
        await MainActor.run
        {
            switch result
            {
            case .success(let text):
                displayText = text
                isLoading   = false
                
                appLogMsg("\(sCurrMethodDisp) Successfully loaded #(\(text.count)) character(s)...")
                
            case .failure(let error):
                loadError = error.localizedDescription
                isLoading = false
                
                appLogMsg("\(sCurrMethodDisp) Failed to decode data - Error: [\(error.localizedDescription)]!")
            }
        }

    }   // End of private func loadTextAsync() async.
    
    private func formatByteCount(_ bytes:Int)->String
    {

        let formatter = ByteCountFormatter()
        
        formatter.allowedUnits        = [.useKB, .useMB]
        formatter.countStyle          = .file
        formatter.includesUnit        = true
        formatter.includesCount       = true
        formatter.includesActualByteCount = false
        
        return formatter.string(fromByteCount:Int64(bytes))

    }   // End of private func formatByteCount(_ bytes:Int)->String.
    
}   // End of struct RawDataView:View.

// MARK: - Preview(s)

#Preview("JSON Display")
{
    NavigationStack 
    {
        AppJsonDisplayView(
            items: [
                JsonDisplayItem(key: "name", value: "John Doe", children: []),
                JsonDisplayItem(key: "user", value: "[3 items]", children: [
                    JsonDisplayItem(key: "id", value: "12345", children: []),
                    JsonDisplayItem(key: "email", value: "john@example.com", children: []),
                    JsonDisplayItem(key: "active", value: "true", children: [])
                ]),
                JsonDisplayItem(key: "items", value: "[2 items]", children: [
                    JsonDisplayItem(key: "[0]", value: "First", children: []),
                    JsonDisplayItem(key: "[1]", value: "Second", children: [])
                ])
            ],
            rawData: Data()
        )
    }
}

#Preview("Raw Data") 
{
    RawDataView(data: "Sample XML/JSON content\nLine 2\nLine 3".data(using: .utf8)!)
}

