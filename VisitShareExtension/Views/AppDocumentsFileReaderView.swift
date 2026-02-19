//
//  AppDocumentsFileReaderView.swift
//  <<< App 'dependent' >>>
//
//  Created by Claude/Daryl Cox on 02/10/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: - ItemDetailsPresentation item

struct ItemDetailsPresentationItem:Identifiable, Equatable
{
    let id = UUID()
    let item:FileItem

    static func == (lhs:ItemDetailsPresentationItem, rhs:ItemDetailsPresentationItem)->Bool
    {
        return lhs.id == rhs.id
    }
}

// MARK: - FileViewPresentation item

struct FileViewPresentationItem:Identifiable, Equatable
{
    let id = UUID()
    let fileURL:URL

    static func == (lhs:FileViewPresentationItem, rhs:FileViewPresentationItem)->Bool
    {
        return lhs.id == rhs.id
    }
}

// MARK: - FileItem Model

final class FileItem:Identifiable, Hashable, ObservableObject
{

    let id:UUID                   = UUID()
    let url:URL
    let sName:String
    let bIsDirectory:Bool
    let iFileSize:Int
    let iItemCount:Int?           // For directories: number of items inside
    let dateModified:Date? 
    let dateCreated:Date?

    @Published
    var isShowingItemDetails:Bool = false

    @Published
    var isShowingPreview:Bool = false

    var sSizeString:String
    {
        if bIsDirectory
        {
            if let count = iItemCount
            {
                let itemWord = count == 1 ? "Item" : "Items"
                return "Folder - \(count) \(itemWord)"
            }
            else
            {
                return "Folder"
            }
        }
        else
        {
            return ByteCountFormatter.string(fromByteCount:Int64(iFileSize), countStyle:.file)
        }
    }

    var sIcon:String
    {
        if bIsDirectory
        {
            return "📁"
        }
        else
        {
            let ext = url.pathExtension.lowercased()

            switch ext
            {
            case "mp4", "mov", "m4v", "avi", "mkv", "wmv", "flv", "webm":
                return "🎬"
            case "mp3", "m4a", "wav", "aac", "flac":
                return "🎵"
            case "jpg", "jpeg", "png", "gif", "heic", "webp", "bmp":
                return "🖼️"
            case "pdf":
                return "📕"
            case "txt", "md", "rtf":
                return "📝"
            case "json", "xml", "plist":
                return "📋"
            case "swift", "h", "m", "c", "cpp", "py", "js":
                return "💻"
            case "cineview":
                return "🎞️"
            case "log":
                return "📜"
            case "zip", "tar", "gz", "rar":
                return "📦"
            default:
                return "📄"
            }
        }
    }
    
    init(url:URL,
         sName:String,
         bIsDirectory:Bool,
         iFileSize:Int,
         iItemCount:Int? = nil,
         dateModified:Date,
         dateCreated:Date)
    {
        
        self.url          = url
        self.sName        = sName
        self.bIsDirectory = bIsDirectory
        self.iFileSize    = iFileSize
        self.iItemCount   = iItemCount
        self.dateModified = dateModified
        self.dateCreated  = dateCreated
        
    }

    // MARK: - Hashable Conformance...
    
    func hash(into hasher:inout Hasher)
    {
        // Hash based on identity properties only, excluding @Published UI state
        hasher.combine(id)
    }
    
    // MARK: - Equatable Conformance...
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool
    {
        // Compare based on identity properties only, excluding @Published UI state
        return lhs.id == rhs.id
    }
    
}   // End of struct FileItem.

// MARK: - AppDocumentsFileReaderView (Main View with Navigation)

struct AppDocumentsFileReaderView:View 
{

    struct ClassInfo
    {
        static let sClsId        = "AppDocumentsFileReaderView"
        static let sClsVers      = "v1.1203"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // App Data field(s):

//  @Environment(\.dismiss)              var dismiss
    @Environment(\.presentationMode)     var presentationMode
    @Environment(\.openWindow)           var openWindow
    @Environment(\.openURL)              var openURL
    @Environment(\.appGlobalDeviceType)  var appGlobalDeviceType

                   var appGlobalInfo:AppGlobalInfo    = AppGlobalInfo.ClassSingleton.appGlobalInfo

#if os(macOS)
           private let pasteboard                     = NSPasteboard.general
#elseif os(iOS)
           private let pasteboard                     = UIPasteboard.general
#endif

    // Navigation state...

    @State private var navigationPath:[URL]           = [URL]()

    // File list for root directory...

    @State private var files:[FileItem]               = [FileItem]()

    // UI state...

    @State private var cAppAboutButtonPresses:Int     = 0
    @State private var isAppAboutViewModal:Bool       = false

    @State private var errorMessage:String            = ""
    @State private var bShowHiddenFiles:Bool          = false
    @State private var bIsShowingDeleteConfirm:Bool   = false
    @State private var itemToDelete:FileItem?         = nil
    @State private var bIsShowingClearAllConfirm:Bool = false

    // Selected directory for viewing (starts with .documents)...

    @State private var selectedDirectoryURL:URL?      = nil

    // Navigation 'title' based on the selectedDirectoryURL...

    private var sCurrentSelectedDirectory:String
    {
        guard let selectedDirectoryURL = selectedDirectoryURL
        else { return "-None-" }

        return selectedDirectoryURL.lastPathComponent
    }

    // Root documents directory...

    private var documentsURL:URL?
    {
        FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first
    }

    // Container subdirectories (all directories at same level as .documents)...

    private var containerSubdirectories:[URL]
    {
        guard let documentsURL = documentsURL
        else { return [] }
        
        // Go up one level to get container directory
        let containerURL = documentsURL.deletingLastPathComponent()
        
        do
        {
            let urls = try FileManager.default.contentsOfDirectory(
                at:                        containerURL,
                includingPropertiesForKeys:[.isDirectoryKey],
                options:                   [.skipsHiddenFiles]
            )
            
            // Filter to only directories
            let directories = urls.filter
            { url in
                let resourceValues = try? url.resourceValues(forKeys:[.isDirectoryKey])
                return resourceValues?.isDirectory == true
            }
            
            // Sort alphabetically
            return directories.sorted { $0.lastPathComponent < $1.lastPathComponent }
        }
        catch
        {
            appLogMsg("\(ClassInfo.sClsDisp):containerSubdirectories - Error reading container: \(error.localizedDescription)")
            return []
        }
    }

    var body:some View 
    {

        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - [\(String(describing:JmXcodeBuildSettings.jmAppVersionAndBuildNumber))]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'appGlobalDeviceType' is (\(String(describing:appGlobalDeviceType)))...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'AppGlobalInfo.bIsAppLoggingByVisitor' is [\(AppGlobalInfo.bIsAppLoggingByVisitor)] and 'AppGlobalInfo.sAppLoggingMethod' is [\(AppGlobalInfo.sAppLoggingMethod)]...")

        NavigationStack(path:$navigationPath)
        {
            VStack(alignment:.leading, spacing:0)
            {
                // Header section...

                VStack(alignment:.leading, spacing:10)
                {
                    Text("File Browser")
                        .font(.headline)
                        .padding(.top)

                    // Path display...

                    if let url = selectedDirectoryURL
                    {
                        HStack
                        {
                            Image(systemName:"folder.fill")
                                .foregroundColor(.blue)

                            Text(url.path)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.head)
                        }
                    }

                    // Action buttons...

                    HStack(spacing:15)
                    {
                        Button("Refresh View")
                        {
                            readDocumentsDirectory()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)

                        Button("Clear All Files")
                        {
                            bIsShowingClearAllConfirm = true
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)

                        Spacer()

                        Toggle("Show Hidden Files", isOn:$bShowHiddenFiles)
                            .toggleStyle(.button)
                            .font(.caption)
                            .onChange(of:bShowHiddenFiles)
                            { _, _ in
                                readDocumentsDirectory()
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                // Error message...

                if !errorMessage.isEmpty
                {
                    HStack
                    {
                        Image(systemName:"exclamationmark.triangle.fill")
                            .foregroundColor(.red)

                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                }

                // Item count bar...

                HStack
                {
                    Text("Items found: \(files.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Tap folder to navigate")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            #if os(macOS)
                .background(Color(.systemGray))
            #endif
            #if os(iOS)
                .background(Color(.systemGray6))
            #endif

                // File list...

                if files.isEmpty && errorMessage.isEmpty
                {
                    VStack(spacing:16)
                    {
                        Spacer()

                        Image(systemName:"folder")
                            .font(.system(size:60))
                            .foregroundColor(.secondary)

                        Text("Empty Directory")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("Click 'Refresh' to read the directory")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    .frame(maxWidth:.infinity)
                }
                else
                {
                    List
                    {
                        ForEach(files)
                        { item in

                            FileItemRow(item:item)
                                .contentShape(Rectangle())
                                .onTapGesture
                                {
                                    if item.bIsDirectory
                                    {
                                        navigationPath.append(item.url)
                                    }
                                }
                                .swipeActions(edge:.trailing, allowsFullSwipe:false)
                                {
                                    Button(role:.destructive)
                                    {
                                        itemToDelete            = item
                                        bIsShowingDeleteConfirm = true
                                    }
                                    label:{ Label("Delete", systemImage:"trash") }
                                    .tint(.red)

                                    Button 
                                    {
                                        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).List.ForEach.FileItemRow.Button 'Item Details'...")
                                        item.isShowingItemDetails.toggle()
                                    } 
                                    label: { Label("Item Details", systemImage:"info.circle") }
                                    .tint(.blue)

                                //  Button 
                                //  {
                                //      let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).List.ForEach.FileItemRow.Button 'Preview File'...")
                                //      item.isShowingPreview.toggle()
                                //  } 
                                //  label: { Label("Preview File", systemImage:"doc.text.magnifyingglass") }
                                //  .tint(.green)
                                }
                                .contextMenu
                                {
                                    if item.bIsDirectory
                                    {
                                        Button
                                        {
                                            navigationPath.append(item.url)
                                        }
                                        label:
                                        {
                                            Label("Open Folder", systemImage:"folder")
                                        }
                                    }

                                    Button
                                    {
                                    //  UIPasteboard.general.string = item.url.path
                                    #if os(macOS)
                                        pasteboard.prepareForNewContents()
                                        pasteboard.setString(item.url.path, forType:.string)
                                    #elseif os(iOS)
                                        pasteboard.string = item.url.path
                                    #endif
                                    }
                                    label:
                                    {
                                        Label("Copy Path", systemImage:"doc.on.doc")
                                    }

                                    Divider()

                                    Button(role:.destructive)
                                    {
                                        itemToDelete            = item
                                        bIsShowingDeleteConfirm = true
                                    }
                                    label:
                                    {
                                        Label("Delete", systemImage:"trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        //  .navigationTitle("[\(selectedDirectoryURL.lastPathComponent)]")
            .navigationTitle("[\(sCurrentSelectedDirectory)]")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar
            {
                // Directory picker menu
                ToolbarItem(placement:.principal)
                {
                    Menu
                    {
                        ForEach(containerSubdirectories, id:\.self)
                        { dirURL in
                            
                            Button
                            {
                                selectedDirectoryURL = dirURL
                                readDocumentsDirectory()
                                
                                appLogMsg("\(ClassInfo.sClsDisp):Menu.Button - Selected directory: [\(dirURL.lastPathComponent)]...")
                            }
                            label:
                            {
                                HStack
                                {
                                    if dirURL == selectedDirectoryURL
                                    {
                                        Image(systemName:"checkmark")
                                    }
                                    Text(dirURL.lastPathComponent)
                                }
                            }
                        }
                    }
                    label:
                    {
                        VStack(alignment:.center)
                        {
                            Label("", systemImage:"folder")
                                .help(Text("Select directory to view"))
                                .imageScale(.small)
                            Text(selectedDirectoryURL?.lastPathComponent ?? "Dir")
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                #if os(macOS)
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(10)
                    .foregroundColor(Color.primary)
                #endif
                    .padding()
                }
                
                ToolbarItem(placement:.principal) 
                {
                    Button
                    {
                        self.cAppAboutButtonPresses += 1

                        let _ = appLogMsg("AppDocumentsFileReaderView.Button(Xcode).'App About'.#(\(self.cAppAboutButtonPresses))...")

                    #if os(iOS)
                        self.isAppAboutViewModal.toggle()
                    #endif
                    #if os(macOS)
                        openWindow(id:"AppAboutView")
                    #endif
                    }
                    label:
                    {
                        VStack(alignment:.center)
                        {
                            Label("", systemImage: "questionmark.diamond")
                                .help(Text("App About Information"))
                                .imageScale(.small)
                            Text("About")
                                .font(.caption2)
                        }
                    }
                #if os(macOS)
                    .sheet(isPresented:$isAppAboutViewModal, content:
                    {
                        AppAboutView()
                    })
                #endif
                #if os(iOS)
                    .fullScreenCover(isPresented:$isAppAboutViewModal)
                    {
                        AppAboutView()
                    }
                #endif
                #if os(macOS)
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(10)
                    .foregroundColor(Color.primary)
                #endif
                    .padding()
                }
                ToolbarItem(placement:.principal)
                {
                    Button
                    {
                        printDirectoryTree()
                    }
                    label:
                    {
                    //  Image(systemName:"text.alignleft")
                        Label("", systemImage:"text.alignleft").imageScale(.small)
                        Text("LogData").font(.caption2)
                    }
                    .help("Print directory tree to log...")
                }
                ToolbarItem(placement:.primaryAction)
                {
                    Button { self.presentationMode.wrappedValue.dismiss() }
                    label:
                    {
                        VStack(alignment:.center)
                        {
                            Label("", systemImage:"xmark.circle").imageScale(.small)
                            Text("Dismiss").font(.caption2)
                        }
                    }
                }
            }
            .refreshable
            {
                readDocumentsDirectory()
            }
            .navigationDestination(for:URL.self)
            { url in

                // Subdirectory view...

                SubdirectoryView(urlDirectory:    url,
                                 bShowHiddenFiles:$bShowHiddenFiles,
                                 navigationPath:  $navigationPath)
            }
        }
        .onAppear
        {
            // Initialize selected directory to .documents on first load
            if selectedDirectoryURL == nil
            {
                selectedDirectoryURL = documentsURL
            }
            
            readDocumentsDirectory()
        }
        .alert("Delete Item?", isPresented:$bIsShowingDeleteConfirm)
        {
            Button("Cancel", role:.cancel) { itemToDelete = nil }
            Button("Delete", role:.destructive)
            {
                if let item = itemToDelete
                {
                    deleteItem(item)
                }
                itemToDelete = nil
            }
        }
        message:
        {
            if let item = itemToDelete
            {
                Text("Are you sure you want to delete '\(item.sName)'?\(item.bIsDirectory ? " This will delete all contents." : "")")
            }
        }
        .alert("Clear All Files?", isPresented:$bIsShowingClearAllConfirm)
        {
            Button("Cancel", role:.cancel) { }
            Button("Clear All", role:.destructive)
            {
                clearDocumentsDirectory()
            }
        }
        message:
        {
            Text("Are you sure you want to delete ALL files and folders in the Documents directory? This cannot be undone.")
        }

    }   // End of var body:some View.

    // MARK: - Directory Reading

    private func readDocumentsDirectory()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        files.removeAll()
        errorMessage = ""

        guard let directoryURL = selectedDirectoryURL
        else
        {
            errorMessage = "Could not access selected directory"

            return
        }

        appLogMsg("\(sCurrMethodDisp) Reading directory: [\(directoryURL.lastPathComponent)]...")

        do
        {
            let options:FileManager.DirectoryEnumerationOptions = bShowHiddenFiles ? [] : .skipsHiddenFiles

            let fileURLs = try FileManager.default.contentsOfDirectory(
                at:                        directoryURL,
                includingPropertiesForKeys:[.isDirectoryKey, .totalFileSizeKey, .contentModificationDateKey],
                options:                   options
            )

            var fileList:[FileItem] = [FileItem]()

            for fileURL in fileURLs
            {
                let resourceValues = try fileURL.resourceValues(forKeys:[.isDirectoryKey, .totalFileSizeKey, .contentModificationDateKey, .creationDateKey])
                var bIsDirectory   = resourceValues.isDirectory ?? false
                var iFileSize      = resourceValues.totalFileSize ?? 0
                let dateModified   = resourceValues.contentModificationDate
                let dateCreated    = resourceValues.creationDate

                // Defensive check: If item has a file extension, it's USUALLY NOT a directory
                // BUT verify with actual file attributes to handle edge cases (app bundles, packages, etc.)
                let fileExtension = fileURL.pathExtension.lowercased()
                if !fileExtension.isEmpty && bIsDirectory == true
                {
                    // Has extension AND detected as directory - verify with file attributes
                    do
                    {
                        let attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                        if let fileType = attrs[.type] as? FileAttributeType
                        {
                            if fileType == .typeDirectory
                            {
                                // It REALLY IS a directory, despite having an extension (e.g., MyApp.app, MyDoc.pages)
                                appLogMsg("\(sCurrMethodDisp) INFO: Item [\(fileURL.lastPathComponent)] has extension .[\(fileExtension)] but is ACTUALLY a directory - keeping as directory")
                                bIsDirectory = true  // Keep as directory
                            }
                            else
                            {
                                // It's a file that was misdetected as directory
                                appLogMsg("\(sCurrMethodDisp) WARNING: File [\(fileURL.lastPathComponent)] detected as directory but has extension .[\(fileExtension)] and type is [\(fileType)] - overriding to file")
                                bIsDirectory = false
                            }
                        }
                    }
                    catch
                    {
                        // If we can't get attributes, assume file (has extension)
                        appLogMsg("\(sCurrMethodDisp) WARNING: Could not verify file type for [\(fileURL.lastPathComponent)] - assuming file due to extension")
                        bIsDirectory = false
                    }
                }
                else if !fileExtension.isEmpty && bIsDirectory == false
                {
                    // Has extension and already detected as file - all good, no action needed
                }

                // Sanitize URL: Remove directory flag for files
                var sanitizedURL = fileURL
                if !bIsDirectory && fileURL.hasDirectoryPath
                {
                    // URL was marked as directory, but it's actually a file
                    // Recreate URL without directory flag (removes trailing slash)
                    sanitizedURL = URL(fileURLWithPath: fileURL.path, isDirectory: false)
                    
                    appLogMsg("\(sCurrMethodDisp) Sanitized file URL: [\(fileURL.absoluteString)] -> [\(sanitizedURL.absoluteString)]")
                    
                    // CRITICAL: Re-fetch file size using JmFileIO (bypasses URL caching)
                    // The original URL with trailing slash returned 0 bytes
                    let fetchedSize = JmFileIO.getFilespecSize(sFilespec: sanitizedURL.path)
                    iFileSize = Int(fetchedSize)
                    
                    appLogMsg("\(sCurrMethodDisp) Re-fetched file size via JmFileIO: [\(iFileSize)] bytes")
                }

                // Get item count for directories (fast - no full enumeration)
                var iItemCount:Int? = nil
                if bIsDirectory
                {
                    do
                    {
                        let contents = try FileManager.default.contentsOfDirectory(atPath: sanitizedURL.path)
                        iItemCount = contents.count
                    }
                    catch
                    {
                        // If we can't read directory, leave count as nil
                        appLogMsg("\(sCurrMethodDisp) Could not get item count for directory [\(sanitizedURL.lastPathComponent)]: \(error)")
                    }
                }

                let item = FileItem(url:          sanitizedURL,
                                    sName:        sanitizedURL.lastPathComponent,
                                    bIsDirectory: bIsDirectory,
                                    iFileSize:    iFileSize,
                                    iItemCount:   iItemCount,
                                    dateModified: (dateModified ?? Date(timeIntervalSince1970:0)),
                                    dateCreated:  (dateCreated  ?? Date(timeIntervalSince1970:0)))

                fileList.append(item)
            }

            // Sort: directories first, then files, both alphabetically...

            files = fileList.sorted
            { item1, item2 in

                if item1.bIsDirectory != item2.bIsDirectory
                {
                    return item1.bIsDirectory
                }

                return item1.sName.lowercased() < item2.sName.lowercased()
            }

            appLogMsg("\(sCurrMethodDisp) Read directory: [\(directoryURL.path)] - Found #(\(files.count)) items...")
        }
        catch
        {
            errorMessage = "Error reading directory: \(error.localizedDescription)"

            appLogMsg("\(sCurrMethodDisp) Error reading directory: \(error)...")
        }

    }   // End of private func readDocumentsDirectory().

    // MARK: - Delete Item

    private func deleteItem(_ item:FileItem)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        do
        {
            try FileManager.default.removeItem(at:item.url)

            appLogMsg("\(sCurrMethodDisp) Deleted: [\(item.sName)]...")

            readDocumentsDirectory()
        }
        catch
        {
            errorMessage = "Failed to delete '\(item.sName)': \(error.localizedDescription)"

            appLogMsg("\(sCurrMethodDisp) Failed to delete [\(item.sName)]: \(error)...")
        }

    }   // End of private func deleteItem(_ item:FileItem).

    // MARK: - Clear Documents Directory

    private func clearDocumentsDirectory()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        guard let directoryURL = documentsURL
        else
        {
            errorMessage = "Could not access Documents' directory"

            return
        }

        do
        {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at:                        directoryURL,
                includingPropertiesForKeys:nil,
                options:                   .skipsHiddenFiles
            )

            var deletedCount         = 0
            var failedFiles:[String] = [String]()

            for fileURL in fileURLs
            {
                do
                {
                    try FileManager.default.removeItem(at:fileURL)

                    deletedCount += 1

                    appLogMsg("\(sCurrMethodDisp) Deleted: [\(fileURL.lastPathComponent)]...")
                }
                catch
                {
                    failedFiles.append(fileURL.lastPathComponent)

                    appLogMsg("\(sCurrMethodDisp) Failed to delete [\(fileURL.lastPathComponent)]: \(error)...")
                }
            }

            if failedFiles.isEmpty
            {
                errorMessage = ""

                appLogMsg("\(sCurrMethodDisp) Successfully deleted all #(\(deletedCount)) files from Documents directory...")
            }
            else
            {
                errorMessage = "Failed to delete \(failedFiles.count) files"

                appLogMsg("\(sCurrMethodDisp) Deleted #(\(deletedCount)) files, failed to delete #(\(failedFiles.count)) files...")
            }

            readDocumentsDirectory()
        }
        catch
        {
            errorMessage = "Error accessing directory: \(error.localizedDescription)"

            appLogMsg("\(sCurrMethodDisp) Error clearing Documents directory: \(error)...")
        }

    }   // End of private func clearDocumentsDirectory().

    // MARK: - Print Directory Tree

    private func printDirectoryTree()
    {

        guard let url = documentsURL else { return }

        appLogMsg("========== Directory Tree: \(url.path) ==========")

        printDirectoryContents(url:url, indent:"")

        appLogMsg("========== End Directory Tree ==========")

    }   // End of private func printDirectoryTree().

    private func printDirectoryContents(url:URL, indent:String)
    {

        do
        {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at:                        url,
                includingPropertiesForKeys:[.isDirectoryKey, .totalFileSizeKey],
                options:                   bShowHiddenFiles ? [] : .skipsHiddenFiles
            )

            for fileURL in fileURLs.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
            {
                let resourceValues = try fileURL.resourceValues(forKeys:[.isDirectoryKey, .totalFileSizeKey])
                let bIsDirectory   = resourceValues.isDirectory ?? false
                let iFileSize      = resourceValues.totalFileSize ?? 0

                if bIsDirectory
                {
                    appLogMsg("\(indent)📁 \(fileURL.lastPathComponent)/")

                    printDirectoryContents(url:fileURL, indent:indent + "    ")
                }
                else
                {
                    let sizeStr = ByteCountFormatter.string(fromByteCount:Int64(iFileSize), countStyle:.file)

                    appLogMsg("\(indent)📄 \(fileURL.lastPathComponent) (\(sizeStr))")
                }
            }
        }
        catch
        {
            appLogMsg("\(indent)⚠️ Error reading: \(error.localizedDescription)")
        }

    }   // End of private func printDirectoryContents(url:URL, indent:String).

}   // End of struct AppDocumentsFileReaderView:View.

// MARK: - SubdirectoryView (For navigated subdirectories)

struct SubdirectoryView:View
{

    struct ClassInfo
    {
        static let sClsId        = "SubdirectoryView"
        static let sClsVers      = "v1.0701"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

             let urlDirectory:URL

    @Binding var bShowHiddenFiles:Bool
    @Binding var navigationPath:[URL]

    // Local state for this subdirectory...

    @State private var files:[FileItem]                                          = [FileItem]()
    @State private var errorMessage:String                                       = ""
    @State private var bIsShowingDeleteConfirm:Bool                              = false
    @State private var itemToDelete:FileItem?                                    = nil
    
    // Presentation items for Item Details and File Preview...
    
    @State private var itemDetailsPresentationItem:ItemDetailsPresentationItem?  = nil
    @State private var fileViewPresentationItem:FileViewPresentationItem?        = nil
    
    #if os(macOS)
           private let pasteboard                                                = NSPasteboard.general
    #elseif os(iOS)
           private let pasteboard                                                = UIPasteboard.general
    #endif

    // MARK: - File List Content
    
    private var fileListContent: some View
    {
        Group
        {
            if files.isEmpty && errorMessage.isEmpty
            {
                VStack(spacing:16)
                {
                    Spacer()

                    Image(systemName:"folder")
                        .font(.system(size:60))
                        .foregroundColor(.secondary)

                    Text("Empty Folder")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .frame(maxWidth:.infinity)
            }
            else
            {
                List
                {
                    ForEach(files)
                    { item in

                        FileItemRow(item:item)
                            .contentShape(Rectangle())
                            .onTapGesture
                            {
                                if item.bIsDirectory
                                {
                                    navigationPath.append(item.url)
                                }
                            }
                            .swipeActions(edge:.trailing, allowsFullSwipe:false)
                            {
                                Button(role:.destructive)
                                {
                                    itemToDelete            = item
                                    bIsShowingDeleteConfirm = true
                                }
                                label:{ Label("Delete", systemImage:"trash") }
                                .tint(.red)

                                Button 
                                {
                                    appLogMsg("\(ClassInfo.sClsDisp):body(some View).List.ForEach.FileItemRow.Button 'Item Details'...")
                                    item.isShowingItemDetails.toggle()
                                } 
                                label: { Label("Item Details", systemImage:"info.circle") }
                                .tint(.blue)
                            //
                            //  Button 
                            //  {
                            //      appLogMsg("\(ClassInfo.sClsDisp):body(some View).List.ForEach.FileItemRow.Button 'Preview File'...")
                            //      item.isShowingPreview.toggle()
                            //  } 
                            //  label: { Label("Preview File", systemImage:"doc.text.magnifyingglass") }
                            //  .tint(.green)
                            }
                            .contextMenu
                            {
                                if item.bIsDirectory
                                {
                                    Button
                                    {
                                        navigationPath.append(item.url)
                                    }
                                    label:
                                    {
                                        Label("Open Folder", systemImage:"folder")
                                    }
                                }

                                Button
                                {
                                //  UIPasteboard.general.string = item.url.path
                                #if os(macOS)
                                    pasteboard.prepareForNewContents()
                                    pasteboard.setString(item.url.path, forType:.string)
                                #elseif os(iOS)
                                    pasteboard.string = item.url.path
                                #endif
                                }
                                label:
                                {
                                    Label("Copy Path", systemImage:"doc.on.doc")
                                }

                                Divider()

                                Button(role:.destructive)
                                {
                                    itemToDelete            = item
                                    bIsShowingDeleteConfirm = true
                                }
                                label:
                                {
                                    Label("Delete", systemImage:"trash")
                                }
                            }
                            .onChange(of:item.isShowingItemDetails)
                            { _, newValue in
                                if newValue == true
                                {
                                    itemDetailsPresentationItem   = ItemDetailsPresentationItem(item:item)
                                    item.isShowingItemDetails     = false
                                }
                            }
                            .onChange(of:item.isShowingPreview)
                            { _, newValue in
                                if newValue == true
                                {
                                    fileViewPresentationItem   = FileViewPresentationItem(fileURL:item.url)
                                    item.isShowingPreview      = false
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    var body:some View
    {
        VStack(alignment:.leading, spacing:0)
        {
            // Path display...

            HStack
            {
                Image(systemName:"folder.fill")
                    .foregroundColor(.blue)

                Text(urlDirectory.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.head)

                Spacer()

                Text("\(files.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        #if os(macOS)
            .background(Color(.systemGray))
        #endif
        #if os(iOS)
            .background(Color(.systemGray6))
        #endif

            // Error message...

            if !errorMessage.isEmpty
            {
                HStack
                {
                    Image(systemName:"exclamationmark.triangle.fill")
                        .foregroundColor(.red)

                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
            }

            // File list...

            fileListContent
        }
        .navigationTitle(urlDirectory.lastPathComponent)
    #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
    #endif
        .toolbar
        {
            ToolbarItem(placement:.primaryAction)
            {
                Toggle("Hidden", isOn:$bShowHiddenFiles)
                    .toggleStyle(.button)
                    .font(.caption)
                    .onChange(of:bShowHiddenFiles)
                    { _, _ in
                        readDirectory()
                    }
            }
        }
        .onAppear
        {
            readDirectory()
        }
        .refreshable
        {
            readDirectory()
        }
        .alert("Delete Item?", isPresented:$bIsShowingDeleteConfirm)
        {
            Button("Cancel", role:.cancel) { itemToDelete = nil }
            Button("Delete", role:.destructive)
            {
                if let item = itemToDelete
                {
                    deleteItem(item)
                }
                itemToDelete = nil
            }
        }
        message:
        {
            if let item = itemToDelete
            {
                Text("Are you sure you want to delete '\(item.sName)'?\(item.bIsDirectory ? " This will delete all contents." : "")")
            }
        }
    #if os(macOS)
        .sheet(item:$itemDetailsPresentationItem)
        { presentationItem in
            AppDocumentsFileItemDetails(item:presentationItem.item)
        }
        .sheet(item:$fileViewPresentationItem)
        { presentationItem in
            AppGeneralFileView(fileURL:presentationItem.fileURL)
        }
    #endif
    #if os(iOS)
        .fullScreenCover(item:$itemDetailsPresentationItem)
        { presentationItem in
            AppDocumentsFileItemDetails(item:presentationItem.item)
        }
        .fullScreenCover(item:$fileViewPresentationItem)
        { presentationItem in
            AppGeneralFileView(fileURL:presentationItem.fileURL)
        }
    #endif

    }   // End of var body:some View.

    // MARK: - Local Functions

    private func readDirectory()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        files.removeAll()
        errorMessage = ""

        do
        {
            let options:FileManager.DirectoryEnumerationOptions = bShowHiddenFiles ? [] : .skipsHiddenFiles

            let fileURLs = try FileManager.default.contentsOfDirectory(
                at:                        urlDirectory,
                includingPropertiesForKeys:[.isDirectoryKey, .totalFileSizeKey, .contentModificationDateKey],
                options:                   options
            )

            var fileList:[FileItem] = [FileItem]()

            for fileURL in fileURLs
            {
                let resourceValues = try fileURL.resourceValues(forKeys:[.isDirectoryKey, .totalFileSizeKey, .contentModificationDateKey, .creationDateKey])
                var bIsDirectory   = resourceValues.isDirectory ?? false
                var iFileSize      = resourceValues.totalFileSize ?? 0
                let dateModified   = resourceValues.contentModificationDate
                let dateCreated    = resourceValues.creationDate

                // Defensive check: If item has a file extension, it's USUALLY NOT a directory
                // BUT verify with actual file attributes to handle edge cases (app bundles, packages, etc.)
                let fileExtension = fileURL.pathExtension.lowercased()
                if !fileExtension.isEmpty && bIsDirectory == true
                {
                    // Has extension AND detected as directory - verify with file attributes
                    do
                    {
                        let attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                        if let fileType = attrs[.type] as? FileAttributeType
                        {
                            if fileType == .typeDirectory
                            {
                                // It REALLY IS a directory, despite having an extension (e.g., MyApp.app, MyDoc.pages)
                                appLogMsg("\(sCurrMethodDisp) INFO: Item [\(fileURL.lastPathComponent)] has extension .[\(fileExtension)] but is ACTUALLY a directory - keeping as directory")
                                bIsDirectory = true  // Keep as directory
                            }
                            else
                            {
                                // It's a file that was misdetected as directory
                                appLogMsg("\(sCurrMethodDisp) WARNING: File [\(fileURL.lastPathComponent)] detected as directory but has extension .[\(fileExtension)] and type is [\(fileType)] - overriding to file")
                                bIsDirectory = false
                            }
                        }
                    }
                    catch
                    {
                        // If we can't get attributes, assume file (has extension)
                        appLogMsg("\(sCurrMethodDisp) WARNING: Could not verify file type for [\(fileURL.lastPathComponent)] - assuming file due to extension")
                        bIsDirectory = false
                    }
                }
                else if !fileExtension.isEmpty && bIsDirectory == false
                {
                    // Has extension and already detected as file - all good, no action needed
                }

                // Sanitize URL: Remove directory flag for files
                var sanitizedURL = fileURL
                if !bIsDirectory && fileURL.hasDirectoryPath
                {
                    // URL was marked as directory, but it's actually a file
                    // Recreate URL without directory flag (removes trailing slash)
                    sanitizedURL = URL(fileURLWithPath: fileURL.path, isDirectory: false)
                    
                    appLogMsg("\(sCurrMethodDisp) Sanitized file URL: [\(fileURL.absoluteString)] -> [\(sanitizedURL.absoluteString)]")
                    
                    // CRITICAL: Re-fetch file size using JmFileIO (bypasses URL caching)
                    // The original URL with trailing slash returned 0 bytes
                    let fetchedSize = JmFileIO.getFilespecSize(sFilespec: sanitizedURL.path)
                    iFileSize = Int(fetchedSize)
                    
                    appLogMsg("\(sCurrMethodDisp) Re-fetched file size via JmFileIO: [\(iFileSize)] bytes")
                }

                // Get item count for directories (fast - no full enumeration)
                var iItemCount:Int? = nil
                if bIsDirectory
                {
                    do
                    {
                        let contents = try FileManager.default.contentsOfDirectory(atPath: sanitizedURL.path)
                        iItemCount = contents.count
                    }
                    catch
                    {
                        // If we can't read directory, leave count as nil
                        appLogMsg("\(sCurrMethodDisp) Could not get item count for directory [\(sanitizedURL.lastPathComponent)]: \(error)")
                    }
                }

                let item = FileItem(url:          sanitizedURL,
                                    sName:        sanitizedURL.lastPathComponent,
                                    bIsDirectory: bIsDirectory,
                                    iFileSize:    iFileSize,
                                    iItemCount:   iItemCount,
                                    dateModified: (dateModified ?? Date(timeIntervalSince1970:0)),
                                    dateCreated:  (dateCreated  ?? Date(timeIntervalSince1970:0)))

                fileList.append(item)
            }

            files = fileList.sorted
            { item1, item2 in

                if item1.bIsDirectory != item2.bIsDirectory
                {
                    return item1.bIsDirectory
                }

                return item1.sName.lowercased() < item2.sName.lowercased()
            }

            appLogMsg("\(sCurrMethodDisp) Read subdirectory: [\(urlDirectory.path)] - Found #(\(files.count)) items...")
        }
        catch
        {
            errorMessage = "Error reading directory: \(error.localizedDescription)"

            appLogMsg("\(sCurrMethodDisp) Error reading subdirectory: \(error)...")
        }

    }   // End of private func readDirectory().

    private func deleteItem(_ item:FileItem)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        do
        {
            try FileManager.default.removeItem(at:item.url)

            appLogMsg("\(sCurrMethodDisp) Deleted: [\(item.sName)]...")

            readDirectory()
        }
        catch
        {
            errorMessage = "Failed to delete '\(item.sName)': \(error.localizedDescription)"

            appLogMsg("\(sCurrMethodDisp) Failed to delete [\(item.sName)]: \(error)...")
        }

    }   // End of private func deleteItem(_ item:FileItem).

}   // End of struct SubdirectoryView:View.

// MARK: - FileItemRow

struct FileItemRow:View
{

    struct ClassInfo
    {
        static let sClsId        = "FileItemRow"
        static let sClsVers      = "v1.1101"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

//  let item:FileItem
    @ObservedObject var item:FileItem

    // MARK: - Item-based FullScreenCover State

    @State private var itemDetailsPresentationItem:ItemDetailsPresentationItem? = nil
//  @State private var itemPreviewPresentationItem:ItemDetailsPresentationItem? = nil

    var body:some View
    {
        HStack(spacing:12)
        {
            // Icon...

            Text(item.sIcon)
                .font(.title2)

            // File info...

            VStack(alignment:.leading, spacing:2)
            {
                Text(item.sName)
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing:8)
                {
                    Text("Size: #(\(item.sSizeString))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let dateModified = item.dateModified
                    {
                        Text("• Modified 'on': ")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(dateModified, style:.date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let dateCreated = item.dateCreated
                    {
                        Text("• Created 'on': ")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(dateCreated, style:.date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                HStack 
                {
                    Spacer()
                    Text("...swipe to your left for file 'actions'...")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
            }

            Spacer()

            // Navigation chevron for directories...

            if item.bIsDirectory
            {
                Image(systemName:"chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    #if os(macOS)
        .sheet(item:$itemDetailsPresentationItem)
        { presentationItem in

            let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).HStack.sheet(item:) #1 - 'item' is [\(item)]...")

            AppDocumentsFileItemDetails(item:presentationItem.item)
        }
    #endif
    #if os(iOS)
        .fullScreenCover(item:$itemDetailsPresentationItem)
        { presentationItem in

            let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).HStack.fullScreenCover(item:) #1 - 'item' is [\(item)]...")

            AppDocumentsFileItemDetails(item:presentationItem.item)
        }
    //  .fullScreenCover(item:$itemPreviewPresentationItem)
    //  { presentationItem in
    //
    //      let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).HStack.fullScreenCover(item:) #2 - 'item' is [\(item)]...")
    //
    //      AppBasicFileView(item:presentationItem)
    //  }
    #endif
        .onChange(of:item.isShowingItemDetails)
        { _, newValue in

            // Bridge the old @Published property to the new item-based presentation...

            let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).HStack.onChange(of:) #1 - 'newValue' is [\(newValue)]...")

            if newValue == true
            {
                itemDetailsPresentationItem   = ItemDetailsPresentationItem(item:item)
                item.isShowingItemDetails     = false  // Reset the old flag
            }
        }
    //  .onChange(of:item.isShowingPreview)
    //  { _, newValue in
    //
    //      // Bridge the old @Published property to the new item-based presentation...
    //
    //      let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).HStack.onChange(of:) #2 - 'newValue' is [\(newValue)]...")
    //
    //      if newValue == true
    //      {
    //          itemPreviewPresentationItem = ItemDetailsPresentationItem(item:item)
    //          item.isShowingPreview       = false  // Reset the old flag
    //      }
    //  }

    }   // End of var body:some View.

}   // End of struct FileItemRow:View.


// MARK: - AppDocumentsFileItemDetails

struct AppDocumentsFileItemDetails:View 
{

    struct ClassInfo
    {
        static let sClsId        = "AppDocumentsFileItemDetails"
        static let sClsVers      = "v1.1101"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    @Environment(\.presentationMode) var presentationMode

                            var appGlobalInfo:AppGlobalInfo                        = AppGlobalInfo.ClassSingleton.appGlobalInfo
                            var jmAppDelegateVisitor:JmAppDelegateVisitor          = JmAppDelegateVisitor.ClassSingleton.appDelegateVisitor

    @ObservedObject         var item:FileItem
    @State          private var isAppUploadFileShowing:Bool                        = false
    @State                  var fileUrl:URL?
    @State          private var showingFileView:Bool                               = false
    @State          private var fileViewPresentationItem:FileViewPresentationItem? = nil
    
    var body:some View 
    {

        NavigationStack
        {
            ScrollView
            {
                VStack(alignment:.leading, spacing:12) 
                {
                    Group
                    {
                        DetailRow(label:"File UUID",       value:String(describing:item.id))
                        DetailRow(label:"Filename",        value:item.sName)
                        DetailRow(label:"File Type",       value:item.sIcon)
                        DetailRow(label:"File Size",       value:item.sSizeString)
                        DetailRow(label:"Modified On",     value:formatFileDate(item.dateModified))
                        DetailRow(label:"Created  On",     value:formatFileDate(item.dateCreated))
                        DetailRow(label:"Is 'Directory'?", value:String(describing:item.bIsDirectory))
                        DetailRow(label:"File URL",        value:String(describing:item.url))
                    }
                }
                .padding()
            }
            .navigationTitle("File Details")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar
            {
                ToolbarItem(placement:.principal)
                {
                    Button
                    {
                        self.fileUrl    = self.item.url
                        showingFileView = true

                        appLogMsg("\(ClassInfo.sClsDisp):Button('Preview File') performed for the URL of [\(String(describing:self.fileUrl))]...")
                    }
                    label:
                    {
                        VStack(alignment:.center)
                        {
                            Label("", systemImage:"text.viewfinder")
                                .help(Text("Preview the file..."))
                                .imageScale(.medium)
                            Text("Preview File")
                                .font(.caption2)
                        }
                    }
                //  .quickLookPreview($fileUrl)
                #if os(macOS)
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .cornerRadius(10)
                    .foregroundColor(Color.primary)
                #endif
                    .padding()
                }
                ToolbarItem(placement:.principal)
                {
                    Button
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):Button('Upload File') performed for the URL of [\(String(describing:self.fileUrl))]...")

                        self.isAppUploadFileShowing.toggle()
                    }
                    label:
                    {
                        VStack(alignment:.center)
                        {
                            Label("", systemImage: "arrow.up.message")
                                .help(Text("'Send' current App file"))
                                .imageScale(.large)
                            Text("Upload File")
                                .font(.caption)
                        }
                    }
                    .alert("Upload the file [\(String(describing:self.fileUrl).stripOptionalStringWrapper())] to the developer(s)?", isPresented:$isAppUploadFileShowing)
                    {
                        Button("Cancel", role:.cancel)
                        {
                            let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Cancel' to 'send' the file - resuming...")
                        }
                        Button("Ok", role:.destructive)
                        {
                            let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Ok' to 'send' the file [\(String(describing:self.fileUrl))] to the developer(s) - sending...")

                            self.uploadCurrentAppFileToDevs()
                        }
                    }
                }
                ToolbarItem(placement:.primaryAction)
                {
                    Button { self.presentationMode.wrappedValue.dismiss() }
                    label:
                    {
                        VStack(alignment:.center)
                        {
                            Label("", systemImage:"xmark.circle").imageScale(.small)
                            Text("Dismiss").font(.caption2)
                        }
                    }
                }
            }
        }
    #if os(macOS)
        .sheet(item:$fileViewPresentationItem)
        { presentationItem in

            let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).ScrollView.sheet(item:) #1 - 'fileURL' is [\(presentationItem.fileURL)]...")

            AppGeneralFileView(fileURL:presentationItem.fileURL)
        }
    #endif
    #if os(iOS)
        .fullScreenCover(item:$fileViewPresentationItem)
        { presentationItem in

            let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).ScrollView.fullScreenCover(item:) #1 - 'fileURL' is [\(presentationItem.fileURL)]...")

            AppGeneralFileView(fileURL:presentationItem.fileURL)
        }
    #endif
        .onChange(of:showingFileView)
        { _, newValue in

            // Bridge the Bool flag to the item-based presentation...

            let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).ScrollView.onChange(of:) #1 - 'newValue' is [\(newValue)]...")

            if newValue == true
            {
                let urlToUse             = fileUrl ?? item.url
                fileViewPresentationItem = FileViewPresentationItem(fileURL:urlToUse)
                showingFileView          = false  // Reset the flag
            }
        }

    }

    private func formatFileDate(_ date:Date?)->String
    {

        guard let date = date 
        else { return "-N/A-" }
        
        let formatter       = DateFormatter()
        formatter.timeZone  = TimeZone.current      // Uses current timezone..
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        return formatter.string(from:date)

    }

    private func uploadCurrentAppFileToDevs()
    {
  
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Prepare specifics to 'upload' the App file...

        guard let urlAppCurrentFilespec:URL = self.fileUrl
        else
        {
            // Exit...
      
            appLogMsg("\(sCurrMethodDisp) Exiting - upload of the file was bypassed - supplied file URL is 'nil' - Warning!")
      
            return
        }

    //  var sAppCurrentFilespec:String    = urlAppCurrentFilespec.absoluteString
        let sAppCurrentFilespec:String    = urlAppCurrentFilespec.path
        let sAppCurrentFilenameExt:String = urlAppCurrentFilespec.lastPathComponent

        appLogMsg("[\(sCurrMethodDisp)] 'sAppCurrentFilespec'    (computed) is [\(String(describing: sAppCurrentFilespec))]...")
        appLogMsg("[\(sCurrMethodDisp)] 'sAppCurrentFilenameExt' (computed) is [\(String(describing: sAppCurrentFilenameExt))]...")

        // Check that the 'current' App file 'exists'...

        let bIsAppCurrentFilePresent:Bool = JmFileIO.fileExists(sFilespec:sAppCurrentFilespec)

        if (bIsAppCurrentFilePresent == true)
        {
            appLogMsg("[\(sCurrMethodDisp)] Preparing to Zip the 'current' filespec of [\(String(describing: sAppCurrentFilespec))]...")
        }
        else
        {
            let sZipFileErrorMsg:String = "Unable to Zip the 'current' filespec of [\(String(describing: sAppCurrentFilespec))] - the file does NOT exist - 'bIsAppCurrentFilePresent' is [\(bIsAppCurrentFilePresent)] - Error!"

            DispatchQueue.main.async
            {
                self.jmAppDelegateVisitor.setAppDelegateVisitorSignalGlobalAlert("Alert::\(sZipFileErrorMsg)",
                                                                                 alertButtonText:"Ok")
            }

            appLogMsg("[\(sCurrMethodDisp)] \(sZipFileErrorMsg)")

            // Exit...

            appLogMsg("\(sCurrMethodDisp) Exiting...")

            return
        }

        // Create the AppLog's 'multipartRequestInfo' object (but WITHOUT any Data (yet))...

        let multipartRequestInfo:MultipartRequestInfo = MultipartRequestInfo()

        multipartRequestInfo.bAppZipSourceToUpload    = false
        multipartRequestInfo.sAppUploadURL            = ""          // "" takes the Upload URL 'default'...
        multipartRequestInfo.sAppUploadNotifyTo       = ""          // This is email notification - "" defaults to all Dev(s)...
        multipartRequestInfo.sAppUploadNotifyCc       = ""          // This is email notification - "" defaults to 'none'...
        multipartRequestInfo.sAppSourceFilespec       = sAppCurrentFilespec
        multipartRequestInfo.sAppSourceFilename       = sAppCurrentFilenameExt
        multipartRequestInfo.sAppZipFilename          = sAppCurrentFilenameExt
        multipartRequestInfo.sAppSaveAsFilename       = sAppCurrentFilenameExt
        multipartRequestInfo.sAppFileMimeType         = "text/plain"

        // Create the AppLog's 'multipartRequestInfo.dataAppFile' object...

        multipartRequestInfo.dataAppFile              = FileManager.default.contents(atPath: sAppCurrentFilespec)

        appLogMsg("\(sCurrMethodDisp) The 'upload' is using 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo.toString()))]...")

        // Attempting to 'zip' the file (content(s))...

        let multipartZipFileCreator:MultipartZipFileCreator = MultipartZipFileCreator()
        multipartRequestInfo.sAppZipFilename                = multipartRequestInfo.sAppSourceFilename

        var urlCreatedZipFile:URL? = multipartZipFileCreator.createTargetZipFileFromSource(multipartRequestInfo:multipartRequestInfo)

        // Check if we actually got the 'target' Zip file created...

        if let urlCreatedZipFile = urlCreatedZipFile 
        {
            appLogMsg("\(sCurrMethodDisp) Produced a Zip file 'urlCreatedZipFile' of [\(urlCreatedZipFile)]...")

            multipartRequestInfo.sAppZipFilename  = "\(multipartRequestInfo.sAppZipFilename).zip"
        } 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) Failed to produce a Zip file - the 'target' Zip filename was [\(multipartRequestInfo.sAppZipFilename)] - Error!")

            multipartRequestInfo.sAppZipFilename  = "-N/A-"
            multipartRequestInfo.sAppFileMimeType = "text/plain"
            multipartRequestInfo.dataAppFile      = FileManager.default.contents(atPath: sAppCurrentFilespec)

            appLogMsg("\(sCurrMethodDisp) Reset the 'multipartRequestInfo' to upload the <raw> file without 'zipping'...")

            urlCreatedZipFile = nil
        }

        // Send the AppLog as an 'upload' to the Server...

        let multipartRequestDriver:MultipartRequestDriver = MultipartRequestDriver(bGenerateResponseLongMsg:true)

        appLogMsg("\(sCurrMethodDisp) Using 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo.toString()))]...")
        appLogMsg("\(sCurrMethodDisp) Calling 'multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:)'...")
        multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:multipartRequestInfo)
        appLogMsg("\(sCurrMethodDisp) Called  'multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:)'...")

        // Exit...
  
        appLogMsg("\(sCurrMethodDisp) Exiting...")
  
        return
  
    }   // End of private func uploadCurrentAppFileToDevs().

}

// MARK: - DetailRow Helper View

struct DetailRow:View
{

    struct ClassInfo
    {
        static let sClsId        = "DetailRow"
        static let sClsVers      = "v1.1003"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    let label:String
    let value:String

#if os(macOS)
    private let pasteboard = NSPasteboard.general
#elseif os(iOS)
    private let pasteboard = UIPasteboard.general
#endif
    
    var body:some View
    {
        VStack(alignment:.leading, spacing:2)
        {
            Text(label)
                .contextMenu
                {
                    Button
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).VStack.Text.contextMenu(Button).'copy (label)' button #1...")
                        
                        copyDetailRowValueToClipboard()
                    }
                    label:
                    {
                        Text("Copy to Clipboard")
                    }
                }
                .font(.caption)
                .foregroundColor(.cyan)
            Text(value)
                .contextMenu
                {
                    Button
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).VStack.Text.contextMenu(Button).'copy (value)' button #2...")
                        
                        copyDetailRowValueToClipboard()
                    }
                    label:
                    {
                        Text("Copy to Clipboard")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }

    private func copyDetailRowValueToClipboard()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked - for a label of [\(label)] and value of [\(value)]...")
        
    #if os(macOS)
        pasteboard.prepareForNewContents()
        pasteboard.setString(value, forType:.string)
    #elseif os(iOS)
        pasteboard.string = value
    #endif

        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting...")
    
        return
        
    }   // End of private func copyDetailRowValueToClipboard().
    
}

// MARK: - AppBasicFileView

struct AppBasicFileView:View 
{
    
    struct ClassInfo
    {
        static let sClsId        = "AppBasicFileView"
        static let sClsVers      = "v1.0901"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // App Data field(s):

    @Environment(\.presentationMode) var presentationMode

    let item:ItemDetailsPresentationItem

    @State private var showingFileView:Bool                               = false
    @State private var fileViewPresentationItem:FileViewPresentationItem? = nil
    
#if os(macOS)
    private let pasteboard = NSPasteboard.general
#elseif os(iOS)
    private let pasteboard = UIPasteboard.general
#endif
    
    init(item:ItemDetailsPresentationItem)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        self.item = item
        
        appLogMsg("\(sCurrMethodDisp) Invoked - 'item' is [\(item)]...")

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of init().

    var body:some View 
    {
        
        VStack
        {
            HStack(alignment:.center)
            {
            #if os(macOS)
                Spacer()
            #endif

                Button
                {
                    appLogMsg("\(ClassInfo.sClsDisp):AppBasicFileView.Button('Preview File') performed for the URL of [\(String(describing:self.item.item.url))]...")
                    
                    showingFileView = true
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage:"text.viewfinder")
                            .help(Text("Preview the file..."))
                            .imageScale(.medium)
                        Text("Preview File")
                            .font(.caption2)
                    }
                }
            #if os(macOS)
                .buttonStyle(.borderedProminent)
                .padding()
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
                .padding()

                Spacer()

            #if os(iOS)
                Button
                {
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):AppBasicFileView.Button(Xcode).'Dismiss' pressed...")

                    self.presentationMode.wrappedValue.dismiss()
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage:"xmark.circle")
                            .help(Text("Dismiss this Screen"))
                            .imageScale(.medium)
                        Text("Dismiss")
                            .font(.caption2)
                    }
                }
                .padding()
            #endif
            }

            Spacer()

            Text("File:")
                .font(.callout)
                .contextMenu
                {
                    Button
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):AppBasicFileView in Text.contextMenu.'copy' button #1...")
                        
                        copyFilePathToClipboard()
                    }
                    label:
                    {
                        Text("Copy to Clipboard")
                    }
                }

            Text("")

            Text(self.item.item.sName)
                .contextMenu
                {
                    Button
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):AppBasicFileView in Text.contextMenu.'copy' button #2...")
                        
                        copyFilePathToClipboard()
                    }
                    label:
                    {
                        Text("Copy to Clipboard")
                    }
                }

            Text("")

            Text("File path:")
                .font(.callout)
                .contextMenu
                {
                    Button
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):AppBasicFileView in Text.contextMenu.'copy' button #3...")
                        
                        copyFilePathToClipboard()
                    }
                    label:
                    {
                        Text("Copy to Clipboard")
                    }
                }

            Text("")

            Text(self.item.item.url.path)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .truncationMode(.middle)
                .contextMenu
                {
                    Button
                    {
                        
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):AppBasicFileView in Text.contextMenu.'copy' button #4...")
                        
                        copyFilePathToClipboard()
                    }
                    label:
                    {
                        Text("Copy to Clipboard")
                    }
                }

            Text("")
            Text("File size is: [\(self.item.item.sSizeString)]")
            Spacer()
        }
    #if os(macOS)
        .sheet(item:$fileViewPresentationItem)
        { presentationItem in

            let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).VStack.sheet(item:) #2 - 'fileURL' is [\(presentationItem.fileURL)]...")

            AppGeneralFileView(fileURL:presentationItem.fileURL)
        }
    #endif
    #if os(iOS)
        .fullScreenCover(item:$fileViewPresentationItem)
        { presentationItem in

            let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).VStack.fullScreenCover(item:) #2 - 'fileURL' is [\(presentationItem.fileURL)]...")

            AppGeneralFileView(fileURL:presentationItem.fileURL)
        }
    #endif
        .onChange(of:showingFileView)
        { _, newValue in

            // Bridge the Bool flag to the item-based presentation...

            let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View).VStack.onChange(of:) #2 - 'newValue' is [\(newValue)]...")

            if newValue == true
            {
                fileViewPresentationItem = FileViewPresentationItem(fileURL:item.item.url)
                showingFileView          = false  // Reset the flag
            }
        }
        
    }   // End of var body:some View.
    
    private func copyFilePathToClipboard()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked - for text of [\(item.item.url.path)]...")
        
    #if os(macOS)
        pasteboard.prepareForNewContents()
        pasteboard.setString(item.item.url.path, forType:.string)
    #elseif os(iOS)
        pasteboard.string = item.item.url.path
    #endif

        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting...")
    
        return
        
    }   // End of private func copyFilePathToClipboard().
    
}   // End of struct AppBasicFileView:View.

// MARK: - Preview

struct AppDocumentsFileReaderView_Previews:PreviewProvider 
{
    static var previews:some View 
    {
        AppDocumentsFileReaderView()
    }
}

// MARK: - FileManager Extension

extension FileManager 
{

    // Simple function to print all files in Documents directory...

    static func printDocumentsDirectoryContents() 
    {

        guard let documentsURL = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first 
        else 
        {
            appLogMsg("Could not access Documents' directory...")

            return
        }

        do 
        {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at:                        documentsURL,
                includingPropertiesForKeys:nil,
                options:                   .skipsHiddenFiles
            )

            appLogMsg("Documents Directory: \(documentsURL.path)...")
            appLogMsg("Files:")

            for fileURL in fileURLs.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) 
            {
                appLogMsg("  • \(fileURL.lastPathComponent)")
            }

            appLogMsg("Total: \(fileURLs.count) files...")
        }
        catch 
        {
            appLogMsg("Error reading Documents' directory: \(error)...")
        }

    }   // End of static func printDocumentsDirectoryContents().

    // Recursive function to print entire directory tree...

    static func printDocumentsDirectoryTree()
    {

        guard let documentsURL = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first
        else
        {
            appLogMsg("Could not access Documents' directory...")

            return
        }

        appLogMsg("========== Documents Directory Tree ==========")
        appLogMsg("Root: \(documentsURL.path)")

        printDirectoryContentsRecursive(url:documentsURL, indent:"")

        appLogMsg("========== End Directory Tree ==========")

    }   // End of static func printDocumentsDirectoryTree().

    private static func printDirectoryContentsRecursive(url:URL, indent:String)
    {

        do
        {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at:                        url,
                includingPropertiesForKeys:[.isDirectoryKey, .totalFileSizeKey],
                options:                   .skipsHiddenFiles
            )

            for fileURL in fileURLs.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
            {
                let resourceValues = try fileURL.resourceValues(forKeys:[.isDirectoryKey, .totalFileSizeKey])
                let bIsDirectory   = resourceValues.isDirectory ?? false
                let iFileSize      = resourceValues.totalFileSize ?? 0

                if bIsDirectory
                {
                    appLogMsg("\(indent)📁 \(fileURL.lastPathComponent)/")

                    printDirectoryContentsRecursive(url:fileURL, indent:indent + "    ")
                }
                else
                {
                    let sizeStr = ByteCountFormatter.string(fromByteCount:Int64(iFileSize), countStyle:.file)

                    appLogMsg("\(indent)📄 \(fileURL.lastPathComponent) (\(sizeStr))")
                }
            }
        }
        catch
        {
            appLogMsg("\(indent)⚠️ Error: \(error.localizedDescription)")
        }

    }   // End of private static func printDirectoryContentsRecursive(url:URL, indent:String).

    // Clear all contents of Documents directory...

    static func clearDocumentsDirectoryContents() 
    {

        guard let documentsURL = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first 
        else 
        {
            appLogMsg("Could not access Documents' directory...")

            return
        }

        do 
        {
            let fileURLs             = try FileManager.default.contentsOfDirectory(
                at:                        documentsURL,
                includingPropertiesForKeys:nil,
                options:                   .skipsHiddenFiles
            )

            var deletedCount         = 0
            var failedFiles:[String] = [String]()

            for fileURL in fileURLs 
            {
                do 
                {
                    try FileManager.default.removeItem(at:fileURL)

                    deletedCount += 1

                    appLogMsg("Deleted: \(fileURL.lastPathComponent)...")
                }
                catch 
                {
                    failedFiles.append(fileURL.lastPathComponent)

                    appLogMsg("Failed to delete \(fileURL.lastPathComponent): \(error)...")
                }
            }

            if failedFiles.isEmpty 
            {
                appLogMsg("Successfully deleted all \(deletedCount) files from Documents' directory...")
            }
            else 
            {
                appLogMsg("Deleted \(deletedCount) files, failed to delete \(failedFiles.count) files:")

                failedFiles.forEach { appLogMsg("  • \($0)") }
            }
        }
        catch 
        {
            appLogMsg("Error clearing Documents directory: \(error)...")
        }

    }   // End of static func clearDocumentsDirectoryContents().

}   // End of extension FileManager.

