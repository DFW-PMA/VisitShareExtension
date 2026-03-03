//
//  AppGeneralFileView.swift
//  VisitManagementApp (VMA)
//
//  Created by Claude/Daryl Cox on 02/10/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//
//  NOTE: Simplified clone of DataGridPack's ContentView for use in VMA
//        Always initialized with a file URL - no import/loading modes
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Display Mode Enum

// Determines which view to display based on file content
// Three-tier system: Spreadsheet → JSON/Tree → CSV/Tree → Raw Text

enum AppGeneralFileDisplayMode
{
    case progress
    case image          // Tier 0 - image media (jpg, jpeg, png, gif, heic, heif, webp, tiff, tif, bmp)
    case video          // Tier 0 - video media (mp4, mov, m4v, avi, mkv, wmv, flv, webm, mpeg, mpg, 3gp)
    case spreadsheet
    case json
    case rawText
    case error
}

// MARK: - AppGeneralFileView

struct AppGeneralFileView:View
{
    
    struct ClassInfo
    {
        static let sClsId        = "AppGeneralFileView"
        static let sClsVers      = "v1.0703"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // App Data field(s):

    @Environment(\.presentationMode)     var presentationMode
    @Environment(\.appGlobalDeviceType)  var appGlobalDeviceType

                            let iShowMaxLinesForLargeFile:Int          = 650    // # of 'max' lines to show for Large files...

                            var appGlobalInfo:AppGlobalInfo            = AppGlobalInfo.ClassSingleton.appGlobalInfo

    // File to display (passed in on init):
    
    let fileURL:URL
    
    // App Data field(s):

    @State          private var displayMode:AppGeneralFileDisplayMode  = .progress
    
    // Changed: Parser returns ONE workbook (not an array)...

    @State          private var parsedWorkbook:SpreadsheetXMLWorkbook? = nil
    @State          private var selectedWorksheetIndex:Int             = 0
    
    @State          private var jsonDisplayItems:[JsonDisplayItem]     = []
    
    @State          private var rawFileData:Data                       = Data()
    
    @State          private var errorMessage:String                    = ""
    
    // Large file expansion state...
    
    @State          private var isTopExpanded:Bool                     = false
    @State          private var isBottomExpanded:Bool                  = false

    // MARK: - Tier 0 Media State (Change 2)
    //
    // transientCineViewItem: Built on-the-fly from the fileURL when a media
    //   extension is detected.  @StateObject keeps it alive across the SwiftUI
    //   branch swap when displayMode transitions from .progress to .image/.video
    //   and the NavigationStack is torn down and mediaView is mounted.
    //   All CineViewLocItem fields are var so they can be populated on MainActor
    //   inside the Task before displayMode flips.
    //
    // bIsMediaPresented: The Binding<Bool> contract required by both viewers.
    //   In practice both viewers dismiss via presentationMode.wrappedValue.dismiss()
    //   rather than toggling this flag - it is informational, not the dismiss
    //   mechanism.  Initialised true because we are presenting when this view appears.

    @StateObject    private var transientCineViewItem:CineViewLocItem  = CineViewLocItem()
    @State          private var bIsMediaPresented:Bool                 = true

    // XML to JSON converter...

                    private let xmlToJSONConverter                     = AppXmlToJsonConverter()

    // MARK: - Initialization
    
    init(fileURL:URL)
    {
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        self.fileURL = fileURL
        
        appLogMsg("\(sCurrMethodDisp) Invoked - fileURL: [\(fileURL.path)]...")
        appLogMsg("\(sCurrMethodDisp) Exiting...")
    }

    // MARK: - Computed Properties
    
    private var currentRows:[SpreadsheetXMLRow]
    {
        guard let workbook = parsedWorkbook,
              selectedWorksheetIndex >= 0,
              selectedWorksheetIndex < workbook.worksheets.count
        else
        {
            return [SpreadsheetXMLRow]()
        }
        
        return workbook.worksheets[selectedWorksheetIndex].rows
    }
    
    private var currentColumnCount:Int
    {
        guard let workbook = parsedWorkbook,
              selectedWorksheetIndex >= 0,
              selectedWorksheetIndex < workbook.worksheets.count
        else
        {
            return 0
        }
        
        return workbook.worksheets[selectedWorksheetIndex].columnCount
    }
    
    private var currentWorksheetName:String
    {
        guard let workbook = parsedWorkbook,
              selectedWorksheetIndex >= 0,
              selectedWorksheetIndex < workbook.worksheets.count
        else
        {
            return "Sheet"
        }
        
        return workbook.worksheets[selectedWorksheetIndex].name
    }
    
    private var currentWorksheet:SpreadsheetXMLWorksheet?
    {
        guard let workbook = parsedWorkbook,
              selectedWorksheetIndex >= 0,
              selectedWorksheetIndex < workbook.worksheets.count
        else
        {
            return nil
        }
        
        return workbook.worksheets[selectedWorksheetIndex]
    }

    var body:some View
    {
        
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - [\(String(describing:JmXcodeBuildSettings.jmAppVersionAndBuildNumber))]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'appGlobalDeviceType' is (\(String(describing:appGlobalDeviceType)))...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'fileURL' (full) is [\(fileURL)]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'fileURL' (path) is [\(fileURL.path)]...")

        // CHANGE 5: Body restructure.
        //
        // Media modes (.image / .video) bypass the NavigationStack entirely so
        // full-screen viewers are not capped by nav-bar chrome.
        //
        // displayMode starts as .progress so the NavigationStack branch always
        // renders first and onAppear fires processFile(at:fileURL).
        // If Tier 0 detects a media extension, it populates transientCineViewItem
        // on MainActor then flips displayMode to .image or .video.  SwiftUI
        // re-evaluates the if/else, tears down the NavigationStack, and mounts
        // mediaView.  The @StateObject transientCineViewItem is owned by
        // AppGeneralFileView and survives the branch swap with all fields intact.
        //
        // Non-media files follow the original NavigationStack / three-tier path
        // with zero regression risk.

        if displayMode == .image || displayMode == .video
        {
            // Tier 0 path: full-screen media viewer, no NavigationStack chrome.

            mediaView
        }
        else
        {
            // Tiers 1-3 / Error path: original NavigationStack layout unchanged.

            NavigationStack
            {
                VStack
                {
                    // Four-Tier Display System - Main Content:

                    Group
                    {
                        switch displayMode
                        {
                        case .progress:
                            progressView
                        case .spreadsheet:
                            spreadsheetView
                        case .json:
                            jsonView
                        case .rawText:
                            rawTextView
                        case .error:
                            errorView
                        default:
                            // .image and .video are handled in the if-branch above.
                            // This default is unreachable at runtime but required by
                            // the compiler because AppGeneralFileDisplayMode is not
                            // exhaustively matched here.
                            EmptyView()
                        }
                    }
                }
                .navigationTitle("File Viewer")
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
                            let _ = appLogMsg("\(ClassInfo.sClsDisp):AppGeneralFileView.Button(Xcode).'Dismiss' pressed...")

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
                        .cornerRadius(10)
                        .foregroundColor(Color.primary)
                    #endif
                        .padding()
                    }
                }
                .onAppear
                {
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):AppGeneralFileView.onAppear() - Starting file processing...")

                    // Immediately process the file
                    processFile(at:fileURL)
                }
            }
        }

    }   // End of var body:some View.
    
    // MARK: - Progress View
    
    private var progressView:some View
    {
        VStack(spacing:20)
        {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle())
            
            Text("Loading file...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(fileURL.lastPathComponent)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Spreadsheet View
    
    private var spreadsheetView:some View
    {
        Group
        {
            if let worksheet = currentWorksheet
            {
                SpreadsheetTableView(worksheet:worksheet)
            }
            else
            {
                Text("No worksheet available")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - JSON View
    
    private var jsonView:some View
    {
        AppJsonDisplayView(items:jsonDisplayItems,
                           rawData:rawFileData)
    }
    
    // MARK: - Raw Text View
    
    private var rawTextView:some View
    {
        VStack(alignment:.leading, spacing:0)
        {
            if let text = String(data:rawFileData, encoding:.utf8)
            {
                let fileSize            = rawFileData.count
                let iMaxDisplaySize:Int = (950 * 1024)              // 950KB limit...
                
            //  if fileSize < 500_000           // Less than 500KB - show full content
                if fileSize < iMaxDisplaySize   // Less than 'size' limit - show full content...
                {
                    TextEditor(text:.constant(text))
                        .font(.system(.body, design:.monospaced))
                        .foregroundColor(.primary)  // Explicit color for dark vs light mode...
                        .padding()
                }
                else  // Over the limit - show summary + first/last portions...
                {
                    // File info header
                    VStack(alignment:.leading, spacing:8)
                    {
                        HStack
                        {
                            Image(systemName:"doc.text")
                                .foregroundColor(.orange)
                            Text("Large Text File")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Text("File size: \(formatFileSize(fileSize))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Tap sections to expand (10 → \(iShowMaxLinesForLargeFile) lines)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Divider()
                    }
                    .padding()
                    
                    // Content display - TextEditor handles its own scrolling
                    VStack(alignment:.leading, spacing:12)
                    {
                        // Top section - expandable
                        Group
                        {
                            Button
                            {
                                withAnimation(.easeInOut(duration:0.3))
                                {
                                    isTopExpanded.toggle()
                                }
                                    
                                    appLogMsg("\(ClassInfo.sClsDisp):rawTextView.Button('Top Section') toggled - isTopExpanded: [\(isTopExpanded)]...")
                                }
                                label:
                                {
                                    HStack
                                    {
                                        Image(systemName:isTopExpanded ? "chevron.down.circle.fill" : "chevron.right.circle")
                                            .foregroundColor(.cyan)
                                        Text("Beginning of file")
                                            .font(.caption)
                                            .foregroundColor(.cyan)
                                        Spacer()
                                        Text(isTopExpanded ? "\(iShowMaxLinesForLargeFile) lines" : "10 lines")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.bottom, 4)
                                
                                TextEditor(text:.constant(getFirstLines(from:text, count:isTopExpanded ? iShowMaxLinesForLargeFile : 10)))
                                    .font(.system(.body, design:.monospaced))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth:.infinity)
                                    .frame(height:isTopExpanded ? 600 : 200)
                                    .scrollContentBackground(.hidden)
                            }
                            
                            // Separator
                            VStack(spacing:4)
                            {
                                Divider()
                                Text("... \(formatLineCount(text)) total lines ...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Divider()
                            }
                            .padding(.vertical, 8)
                            
                            // Bottom section - expandable
                            Group
                            {
                                Button
                                {
                                    withAnimation(.easeInOut(duration:0.3))
                                    {
                                        isBottomExpanded.toggle()
                                    }
                                    
                                    appLogMsg("\(ClassInfo.sClsDisp):rawTextView.Button('Bottom Section') toggled - isBottomExpanded: [\(isBottomExpanded)]...")
                                }
                                label:
                                {
                                    HStack
                                    {
                                        Image(systemName:isBottomExpanded ? "chevron.down.circle.fill" : "chevron.right.circle")
                                            .foregroundColor(.cyan)
                                        Text("End of file")
                                            .font(.caption)
                                            .foregroundColor(.cyan)
                                        Spacer()
                                        Text(isBottomExpanded ? "\(iShowMaxLinesForLargeFile) lines" : "10 lines")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.bottom, 4)
                                
                                TextEditor(text:.constant(getLastLines(from:text, count:isBottomExpanded ? iShowMaxLinesForLargeFile : 10)))
                                    .font(.system(.body, design:.monospaced))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth:.infinity)
                                    .frame(height:isBottomExpanded ? 600 : 200)
                                    .scrollContentBackground(.hidden)
                            }
                        }
                        .frame(maxWidth:.infinity)
                        .padding()
                }
            }
            else
            {
                VStack(spacing:12)
                {
                    Image(systemName:"doc.text.fill")
                        .font(.system(size:48))
                        .foregroundColor(.secondary)
                    
                    Text("Unable to display as text")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("File may be binary or use unsupported encoding")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth:.infinity, maxHeight:.infinity)
            }
        }
    }
    
    // MARK: - Error View
    
    private var errorView:some View
    {
        VStack(spacing:20)
        {
            Image(systemName:"exclamationmark.triangle")
                .font(.system(size:60))
                .foregroundColor(.red)
            
            Text("Unable to Display File")
                .font(.headline)
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("File: \(fileURL.lastPathComponent)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    // MARK: - CHANGE 3: Media View
    //
    // Rendered instead of NavigationStack when displayMode is .image or .video.
    //
    // transientCineViewItem is fully populated (all var fields assigned) before
    // displayMode is switched on MainActor, so both viewers receive valid data
    // on first render.
    //
    // For video: bCanResume on CineViewLocItem delegates to
    //   videoMetadata?.bCanResume which requires progress > 5s AND < 95%.
    //   This works automatically for any video that already has a .cineview
    //   sidecar - the sidecar is loaded in processFile Tier 0 block below.
    //
    // Both viewers dismiss via presentationMode.wrappedValue.dismiss() which
    // dismisses the .fullScreenCover that presented AppGeneralFileView itself.

    private var mediaView:some View
    {

        let _ = appLogMsg("\(ClassInfo.sClsDisp):mediaView - Rendering for: [\(fileURL.lastPathComponent)] mediaType: [\(transientCineViewItem.mediaType.displayName)]...")

        return Group
        {
            switch displayMode
            {
            case .image:

                let _ = appLogMsg("\(ClassInfo.sClsDisp):mediaView - Presenting FullScreenImageViewer...")

                FullScreenImageViewer(
                    imageURL:    fileURL,
                    isPresented: $bIsMediaPresented,
                    cineViewItem:transientCineViewItem
                )

            case .video:

                let _ = appLogMsg("\(ClassInfo.sClsDisp):mediaView - Presenting FullScreenVideoPlayer - bCanResume: [\(transientCineViewItem.bCanResume)]...")

                FullScreenVideoPlayer(
                    videoURL:            fileURL,
                    isPresented:         $bIsMediaPresented,
                    cineViewItem:        transientCineViewItem,
                    bResumeFromProgress: transientCineViewItem.bCanResume
                )

            default:
                // Unreachable: body if-guard ensures only .image/.video reach here.
                EmptyView()
            }
        }

    }   // End of private var mediaView:some View.

    // MARK: - File Processing Functions
    
    private func processFile(at url:URL)
    {
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - 'url' is [\(url)] - processing file: [\(url.lastPathComponent)]...")
        appLogMsg("\(sCurrMethodDisp) Full URL path: [\(url.path)]...")
        appLogMsg("\(sCurrMethodDisp) Absolute URL: [\(url.absoluteString)]...")
        appLogMsg("\(sCurrMethodDisp) Has directory path flag: [\(url.hasDirectoryPath)]...")
        
        // Check if file exists
        let fileExists = FileManager.default.fileExists(atPath: url.path)
        appLogMsg("\(sCurrMethodDisp) File exists at path: [\(fileExists)]...")
        
        if !fileExists
        {
            appLogMsg("\(sCurrMethodDisp) ERROR: File does NOT exist at path!")
            
            // Try without trailing slash if it has one
            if url.hasDirectoryPath
            {
                let cleanURL = URL(fileURLWithPath: url.path, isDirectory: false)
                let cleanExists = FileManager.default.fileExists(atPath: cleanURL.path)
                appLogMsg("\(sCurrMethodDisp) Tried clean URL (no dir flag): [\(cleanURL.absoluteString)] - exists: [\(cleanExists)]...")
            }
        }

        // After "File exists at path: [true]"...

        do
        {
            let attrs = try FileManager.default.attributesOfItem(atPath:url.path)
            appLogMsg("\(sCurrMethodDisp) File attributes:")
            appLogMsg("  - Owner: \(attrs[.ownerAccountName] ?? "unknown")")
            appLogMsg("  - Group: \(attrs[.groupOwnerAccountName] ?? "unknown")")
            appLogMsg("  - Permissions: \(attrs[.posixPermissions] ?? "unknown")")
            appLogMsg("  - Type: \(attrs[.type] ?? "unknown")")
            appLogMsg("  - Size: \(attrs[.size] ?? "unknown")")
            
            // Check if it's readable
            let isReadable = FileManager.default.isReadableFile(atPath: url.path)
            appLogMsg("  - Is readable: \(isReadable)")
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Failed to get attributes - Details:[\(error)] - Error!")
        }
        
        // Run the import asynchronously to avoid blocking the UI...

        Task
        {
            // CRITICAL CHECK: Is this actually a directory?
            // Must be inside Task for async/await support
            do
            {
                let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                if let fileType = attrs[.type] as? FileAttributeType, fileType == .typeDirectory
                {
                    appLogMsg("\(sCurrMethodDisp) This is a DIRECTORY (despite having file extension) - showing directory message...")
                    
                    // Check if directory has contents
                    let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path)
                    let itemCount = contents?.count ?? 0
                    
                    await MainActor.run
                    {
                        if itemCount == 0
                        {
                            errorMessage = "'\(url.lastPathComponent)' is an empty directory"
                        }
                        else
                        {
                            errorMessage = "'\(url.lastPathComponent)' is a directory containing \(itemCount) item(s)"
                        }
                        displayMode = .error
                    }
                    
                    appLogMsg("\(sCurrMethodDisp) Exiting - directory detected...")
                    return
                }
            }
            catch
            {
                appLogMsg("\(sCurrMethodDisp) Could not verify if directory: \(error)")
            }

            // MARK: - CHANGE 4: Tier 0 - Media Early Exit
            //
            // Uses MediaType.from(fileExtension:) from CineViewLocItem.swift -
            // the same extension classifier used across all CinemaPack apps.
            //
            // Runs BEFORE any file Data read.  Media files are never loaded into
            // memory here; FullScreenImageViewer uses UIImage(contentsOfFile:)
            // and FullScreenVideoPlayer uses AVPlayer - both handle their own I/O.
            //
            // Steps:
            //   1. Detect extension via MediaType.from()
            //   2. Pull file size + mod date via resourceValues  (no full read)
            //   3. Load any existing .cineview sidecar  (gives video resume free)
            //   4. Populate all var fields on transientCineViewItem on MainActor
            //   5. Set displayMode to .image or .video  ->  body branch-swaps
            //   6. return  -  skips the entire three-tier text pipeline
            //
            // Supported image extensions : jpg  jpeg  png  gif  heic  heif
            //                              webp  tiff  tif  bmp
            // Supported video extensions : mp4  mov  m4v  avi  mkv  wmv  flv
            //                              webm  mpeg  mpg  3gp

            let fileExtension = url.pathExtension.lowercased()

            appLogMsg("\(sCurrMethodDisp) Tier 0 check - file extension: [\(fileExtension)]...")

            if let detectedMediaType = MediaType.from(fileExtension:fileExtension)
            {
                appLogMsg("\(sCurrMethodDisp) Tier 0 match - mediaType: [\(detectedMediaType.displayName)] file: [\(url.lastPathComponent)]...")

                // Pull file size and modification date without a full Data read...

                let iFileSize    = (try? url.resourceValues(forKeys:[.fileSizeKey]).fileSize) ?? 0
                let dateModified = (try? url.resourceValues(forKeys:[.contentModificationDateKey])
                                        .contentModificationDate) ?? Date()

                let sSizeMB             = formatFileSize(iFileSize)
                let dateFormatter       = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                let sModifiedOn         = dateFormatter.string(from:dateModified)

                // Load any existing .cineview sidecar.
                // For video: supplies bCanResume / dPlaybackProgressSeconds so
                // FullScreenVideoPlayer can seek to the last position automatically.
                // For image: carries prior-viewed state (bHasBeenWatched).

                let existingMetadata = VideoMetadataManager.shared.loadMetadata(for:url)

                appLogMsg("\(sCurrMethodDisp) Tier 0 - size: [\(sSizeMB)] sidecar: [\((existingMetadata != nil) ? "found" : "none")]...")
                          
                await MainActor.run
                {
                    transientCineViewItem.sCineViewLocFilespec       = url.path
                    transientCineViewItem.sCineViewLocFilenameExt    = url.lastPathComponent
                    transientCineViewItem.urlCineViewLocFile         = url
                    transientCineViewItem.sCineViewLocFileSizeMB     = sSizeMB
                    transientCineViewItem.sCineViewLocFileModifiedOn = sModifiedOn
                    transientCineViewItem.dateItemTimestamp          = dateModified
                    transientCineViewItem.mediaType                  = detectedMediaType
                    transientCineViewItem.videoMetadata              = existingMetadata

                    displayMode = (detectedMediaType == .image) ? .image : .video
                }

                appLogMsg("\(sCurrMethodDisp) Tier 0 complete - displayMode set to [\(detectedMediaType.displayName)] - Exiting...")
                return
            }

            appLogMsg("\(sCurrMethodDisp) Tier 0 - not a media file, continuing to three-tier text pipeline...")

            do
            {
                // Determine if we need security-scoped resource access
                // Only needed for files OUTSIDE the app's container
                let isInAppContainer = url.path.contains("/Containers/Data/Application/")
                
                appLogMsg("\(sCurrMethodDisp) File is in app container: [\(isInAppContainer)]...")
                
                // Start accessing security-scoped resource ONLY for external files
                var accessing = false
                if !isInAppContainer
                {
                    accessing = url.startAccessingSecurityScopedResource()
                    appLogMsg("\(sCurrMethodDisp) Started security-scoped resource access: [\(accessing)]...")
                }
                else
                {
                    appLogMsg("\(sCurrMethodDisp) Skipping security-scoped resource access (file in app container)...")
                }
                
                defer
                {
                    if accessing
                    {
                        url.stopAccessingSecurityScopedResource()
                        appLogMsg("\(sCurrMethodDisp) Stopped security-scoped resource access...")
                    }
                }
                
                appLogMsg("\(sCurrMethodDisp) About to read file data...")
                
                // Try multiple approaches to read the file
                var data: Data? = nil
                var readMethod = ""
                
                // Method 1: Data(contentsOf:) - Standard approach
                do
                {
                    appLogMsg("\(sCurrMethodDisp) Attempting Method 1: Data(contentsOf:)...")
                    data = try Data(contentsOf:url)
                    readMethod = "Data(contentsOf:)"
                    appLogMsg("\(sCurrMethodDisp) Method 1 SUCCESS - Read #(\(data!.count)) bytes")
                }
                catch let error as NSError
                {
                    appLogMsg("\(sCurrMethodDisp) Method 1 FAILED - Domain: [\(error.domain)], Code: [\(error.code)], Description: [\(error.localizedDescription)]")
                    
                    // Method 2: FileManager.contents(atPath:) - More permissive
                    appLogMsg("\(sCurrMethodDisp) Attempting Method 2: FileManager.contents(atPath:)...")
                    if let fileData = FileManager.default.contents(atPath: url.path)
                    {
                        data = fileData
                        readMethod = "FileManager.contents(atPath:)"
                        appLogMsg("\(sCurrMethodDisp) Method 2 SUCCESS - Read #(\(data!.count)) bytes")
                    }
                    else
                    {
                        appLogMsg("\(sCurrMethodDisp) Method 2 FAILED - FileManager.contents returned nil")
                        
                        // Method 3: FileHandle - Low-level approach
                        do
                        {
                            appLogMsg("\(sCurrMethodDisp) Attempting Method 3: FileHandle...")
                            let fileHandle = try FileHandle(forReadingFrom: url)
                            data = fileHandle.readDataToEndOfFile()
                            try fileHandle.close()
                            readMethod = "FileHandle"
                            appLogMsg("\(sCurrMethodDisp) Method 3 SUCCESS - Read #(\(data!.count)) bytes")
                        }
                        catch let error3 as NSError
                        {
                            appLogMsg("\(sCurrMethodDisp) Method 3 FAILED - Domain: [\(error3.domain)], Code: [\(error3.code)], Description: [\(error3.localizedDescription)]")
                        }
                    }
                }
                
                // Check if we successfully read data

                guard let fileData = data 
                else
                {
                    let sFileContents = JmFileIO.readFile(sFilespec:url.path)

                    if (sFileContents        != nil &&
                        sFileContents!.count  > 0)
                    {
                        appLogMsg("\(sCurrMethodDisp) Success - JmFileIO.readFile(sFilespec:\(url.path)) read the file contents of [\(String(describing: sFileContents))]...")
                    }
                    else
                    {
                        appLogMsg("\(sCurrMethodDisp) Failed - JmFileIO.readFile(sFilespec:\(url.path)) read of the file contents of [\(String(describing: sFileContents))] - Error!")
                    }

                    appLogMsg("\(sCurrMethodDisp) Failed - ALL read methods failed!")
                    
                    await MainActor.run
                    {
                        errorMessage = "Failed to read file: All read methods failed"
                        displayMode  = .error
                    }
                    
                    appLogMsg("\(sCurrMethodDisp) Exiting...")
                    return
                }
                
                await MainActor.run
                {
                    rawFileData = fileData
                }
                
                appLogMsg("\(sCurrMethodDisp) Processing - Successfully read #(\(fileData.count)) bytes using [\(readMethod)]")
                
                // Check for empty file...

                if fileData.isEmpty
                {
                    appLogMsg("\(sCurrMethodDisp) Warning - File is empty!")
                    
                    await MainActor.run
                    {
                        errorMessage = "File is empty"
                        displayMode  = .error
                    }
                    
                    appLogMsg("\(sCurrMethodDisp) Exiting...")
                    
                    return
                }
                
                // Try parsing as spreadsheet first (Tier 1)...

                if await tryParseAsSpreadsheet(url:url)
                {
                    appLogMsg("\(sCurrMethodDisp) Success - Using Spreadsheet View (Tier 1)...")
                    appLogMsg("\(sCurrMethodDisp) Exiting...")
                    
                    return
                }
                
                appLogMsg("\(sCurrMethodDisp) Processing - Not a spreadsheet, trying Tree View conversion (Tier 2)...")
                
                // Try converting to JSON using primary method (Tier 2a)...

                if await tryConvertToJSON(data:fileData)
                {
                    appLogMsg("\(sCurrMethodDisp) Success - Using Tree View (Tier 2a - xmlToJSONConverter)...")
                    appLogMsg("\(sCurrMethodDisp) Exiting...")
                    
                    return
                }
                
                appLogMsg("\(sCurrMethodDisp) Processing - Primary JSON conversion failed, trying secondary JSON parsing (Tier 2b)...")
                
                // Try secondary JSON parsing using JSONSerialization (Tier 2b)...
                
                if await tryParseAsDirectJSON(data:fileData)
                {
                    appLogMsg("\(sCurrMethodDisp) Success - Using Tree View (Tier 2b - JSONSerialization)...")
                    appLogMsg("\(sCurrMethodDisp) Exiting...")
                    
                    return
                }
                
                appLogMsg("\(sCurrMethodDisp) Processing - All JSON conversions failed, falling through to Raw Text View (Tier 3)...")
                
                // Fallback to raw text view (Tier 3)...

                await MainActor.run
                {
                    displayMode = .rawText
                }
                
                appLogMsg("\(sCurrMethodDisp) Success - Using Raw Text View (Tier 3) - always works!")
            }
        //  NOTE: the do{} block doen't have a 'throws', so this catch{} is unreachable...
        //
        //  catch
        //  {
        //      appLogMsg("\(sCurrMethodDisp) Failed - Outer 'Task' catch - Unable to read 'url' of [\(url)] - Detail(s): [\(error)] - Error!")
        //  }
            
            appLogMsg("\(sCurrMethodDisp) Exiting...")
        }

        return

    }   // End of private func processFile(at url:URL).
    
    private func tryParseAsSpreadsheet(url:URL) async -> Bool
    {
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - attempting to parse as SpreadsheetXML or CSV (Tier 1)...")
        
        // Check file extension to determine parser
        let fileExtension = url.pathExtension.lowercased()
        
        appLogMsg("\(sCurrMethodDisp) File extension detected: [\(fileExtension)]...")
        
        // Handle CSV files
        if (fileExtension == "csv")
        {
            appLogMsg("\(sCurrMethodDisp) Detected CSV file - using CSV parser...")
            
            // Get CSV settings from UserDefaults
            let autoDetectHeaders = UserDefaults.standard.bool(forKey:"csvAutoDetectHeaders")
            let forceHeaderRow    = UserDefaults.standard.bool(forKey:"csvForceHeaderRow")
            
            // Get delimiter settings
            let delimiterTypeString = UserDefaults.standard.string(forKey:"csvDelimiterType") ?? "comma"
            let customDelimiter     = UserDefaults.standard.string(forKey:"csvCustomDelimiter") ?? ","
            
            // Determine actual delimiter to use
            var actualDelimiter:String = ","
            
            switch delimiterTypeString
            {
            case "comma":
                actualDelimiter = ","
            case "pipe":
                actualDelimiter = "|"
            case "semicolon":
                actualDelimiter = ";"
            case "tab":
                actualDelimiter = "\t"
            case "custom":
                actualDelimiter = customDelimiter
            default:
                actualDelimiter = ","
            }
            
            appLogMsg("\(sCurrMethodDisp) CSV Settings - autoDetect: [\(autoDetectHeaders)], forceHeader: [\(forceHeaderRow)], delimiter: [\(actualDelimiter)]...")
            
            let csvParser = SpreadsheetCSVParser()
            let result    = csvParser.parseCSV(from:url,
                                               delimiter:actualDelimiter,
                                               autoDetectHeaders:autoDetectHeaders,
                                               forceHeaderRow:forceHeaderRow ? true : nil)
            
            switch result
            {
            case .success(let workbook):
                appLogMsg("\(sCurrMethodDisp) Processing - Successfully parsed CSV with #(\(workbook.worksheets.count)) worksheet(s)...")
                
                let totalCells = workbook.totalCellCount
                
                appLogMsg("\(sCurrMethodDisp) Processing - Total cells in CSV: #(\(totalCells))...")
                
                if (workbook.worksheets.isEmpty || totalCells == 0)
                {
                    appLogMsg("\(sCurrMethodDisp) Warning - Empty CSV result...")
                    appLogMsg("\(sCurrMethodDisp) Exiting with [false]...")
                    
                    return false
                }
                
                // Success - show spreadsheet view

                await MainActor.run
                {
                    parsedWorkbook         = workbook
                    selectedWorksheetIndex = 0
                    displayMode            = .spreadsheet
                }
                
                appLogMsg("\(sCurrMethodDisp) CSV parsing successful - Exiting with [true]...")
                
                return true
                
            case .failure(let error):
                appLogMsg("\(sCurrMethodDisp) Failed - CSV parsing error: [\(error.localizedDescription)]...")
                appLogMsg("\(sCurrMethodDisp) Exiting with [false]...")
                
                return false
            }
        }
        
        // Handle XML/XLS files with SpreadsheetXML parser

        appLogMsg("\(sCurrMethodDisp) Using SpreadsheetXML parser for file extension: [\(fileExtension)]...")
        
        let parser = SpreadsheetXMLParser()
        let result = parser.parse(url:url)
        
        switch result
        {
        case .success(let workbook):
            appLogMsg("\(sCurrMethodDisp) Processing - Successfully parsed workbook with #(\(workbook.worksheets.count)) worksheet(s)...")
            
            // Check if we got any meaningful data...

            let totalCells = workbook.totalCellCount
            
            appLogMsg("\(sCurrMethodDisp) Processing - Total cells across all worksheets: #(\(totalCells))...")
            
            if (workbook.worksheets.isEmpty ||
                totalCells == 0)
            {
                appLogMsg("\(sCurrMethodDisp) Warning - Empty result, treating as generic XML, falling back to Tier 2...")
                appLogMsg("\(sCurrMethodDisp) Exiting with [false]...")
                
                return false
            }
            
            // Success - show spreadsheet view...

            await MainActor.run
            {
                parsedWorkbook         = workbook
                selectedWorksheetIndex = 0
                displayMode            = .spreadsheet
            }
            
            appLogMsg("\(sCurrMethodDisp) Exiting with [true]...")
            
            return true
        case .failure(let error):
            appLogMsg("\(sCurrMethodDisp) Failed - SpreadsheetXML parsing error: [\(error.localizedDescription)]...")
            appLogMsg("\(sCurrMethodDisp) Processing - This is normal for non-spreadsheet XML, falling back to Tier 2...")
            appLogMsg("\(sCurrMethodDisp) Exiting with [false]...")
            
            return false
        }

    }   // End of private func tryParseAsSpreadsheet(url:URL) async -> Bool.
    
    private func tryConvertToJSON(data:Data) async -> Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - attempting XML to Tree View conversion (Tier 2a - xmlToJSONConverter)...")
        
        let displayItems = xmlToJSONConverter.getDisplayItems(xmlData:data)
        
        if displayItems.isEmpty
        {
            appLogMsg("\(sCurrMethodDisp) Warning - Tree conversion returned no items, trying fallback method...")
            appLogMsg("\(sCurrMethodDisp) Exiting with [false]...")
            
            return false
        }
        
        appLogMsg("\(sCurrMethodDisp) Success - Created [\(displayItems.count)] tree display item(s)...")
        
        await MainActor.run
        {
            jsonDisplayItems = displayItems
            displayMode      = .json
        }
        
        appLogMsg("\(sCurrMethodDisp) Exiting with [true]...")
        
        return true

    }   // End of private func tryConvertToJSON(data:Data) async -> Bool.
    
    private func tryParseAsDirectJSON(data:Data) async -> Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - attempting direct JSON parsing (Tier 2b - JSONSerialization)...")
        
        do
        {
            // Try to parse as JSON directly...

            let jsonObject = try JSONSerialization.jsonObject(with:data, options:[])
            
            appLogMsg("\(sCurrMethodDisp) Processing - Successfully parsed JSON data...")
            
            // Convert to display items using JsonDisplayItem's static methods...

            var displayItems:[JsonDisplayItem] = []
            
            if let jsonDict = jsonObject as? [String:Any]
            {
                appLogMsg("\(sCurrMethodDisp) Processing - JSON is a Dictionary with #(\(jsonDict.count)) key(s)...")
                
                displayItems = JsonDisplayItem.fromDictionary(jsonDict)
            }
            else if let jsonArray = jsonObject as? [Any]
            {
                appLogMsg("\(sCurrMethodDisp) Processing - JSON is an Array with #(\(jsonArray.count)) element(s)...")
                
                // Wrap array in a dictionary so we can use fromDictionary (since fromArray is private)...

                let wrappedDict:[String:Any] = ["root": jsonArray]
                displayItems = JsonDisplayItem.fromDictionary(wrappedDict)
            }
            else
            {
                appLogMsg("\(sCurrMethodDisp) Warning - JSON is neither Dictionary nor Array, unsupported type...")
                appLogMsg("\(sCurrMethodDisp) Exiting with [false]...")
                
                return false
            }
            
            if displayItems.isEmpty
            {
                appLogMsg("\(sCurrMethodDisp) Warning - Conversion resulted in empty display items...")
                appLogMsg("\(sCurrMethodDisp) Exiting with [false]...")
                
                return false
            }
            
            appLogMsg("\(sCurrMethodDisp) Success - Created [\(displayItems.count)] display item(s) from JSON...")
            
            await MainActor.run
            {
                jsonDisplayItems = displayItems
                displayMode      = .json
            }
            
            appLogMsg("\(sCurrMethodDisp) Exiting with [true]...")
            
            return true
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Failed - JSON parsing error: [\(error.localizedDescription)]...")
            appLogMsg("\(sCurrMethodDisp) Exiting with [false]...")
            
            return false
        }

    }   // End of private func tryParseAsDirectJSON(data:Data) async -> Bool.
    
    // MARK: - Text Display Helper Functions
    
    private func formatFileSize(_ bytes:Int)->String
    {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount:Int64(bytes))
    }
    
    private func formatLineCount(_ text:String)->String
    {
        let lineCount = text.components(separatedBy:.newlines).count
        return "\(lineCount) lines"
    }
    
    private func getFirstLines(from text:String, count:Int)->String
    {
        let lines = text.components(separatedBy:.newlines)
        let firstLines = lines.prefix(count)
        return firstLines.joined(separator:"\n")
    }
    
    private func getLastLines(from text:String, count:Int)->String
    {
        let lines = text.components(separatedBy:.newlines)
        let lastLines = lines.suffix(count)
        return lastLines.joined(separator:"\n")
    }

}   // End of struct AppGeneralFileView:View.

