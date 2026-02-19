//
//  AppFileImportManager.swift
//  DataGridViewer
//
//  Created by Claude/Daryl Cox on 11/20/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: - AppFileImportManager Singleton:

// This class manages file imports from external sources like Mail, Files app, etc.
// This singleton bridges the App's .onOpenURL() with the SpreadsheetXMLViewer's import logic.

class AppFileImportManager:ObservableObject
{

    struct ClassInfo
    {
        static let sClsId        = "AppFileImportManager"
        static let sClsVers      = "v1.0501"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // MARK: - Singleton Instance...

        static let shared                               = AppFileImportManager()

    // MARK: - Published 'timer' Properties...

    //         let timerPublisherImportClock1Sec        = Timer.publish(every:1, on:.main, in:.common).autoconnect()
               var timerPublisherImportClock1Sec:Timer? = nil
                                                          // Note: implement .onReceive() on a field within the displaying 'View'...
                                                          //
                                                          // @ObservedObject private var importManager = AppFileImportManager.shared
                                                          // ...
                                                          // .onReceive(importManager.timerPublisherImportClock1Sec)
                                                          // { oldValue, newValue in
                                                          //     self.importManager.updateClockDateTimeCounter(newValue:newValue, oldValue:oldValue)
                                                          // }

    @State     var progressElapsedSeconds:Int           = 0

    // MARK: - Published 'import' Properties...

    @Published var urlToImport:URL?                     = nil      // URL to be imported - when set, triggers import in SpreadsheetXMLViewer
    @Published var isImporting:Bool                     = false    // Flag indicating if an import is in progress...
    @Published var dateUrlReceivedTimestamp:Date        = Date()   // Date the 'urlToImport' was received...
    @Published var lastImportError:Error?               = nil      // Last import error, if any...
    @Published var lastImportDate:Date?                 = nil      // Last successful import date
    @Published var lastImportedFileName:String?         = nil      // Last imported file name

    // MARK: - Initialization...

    private init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - Initializing AppFileImportManager singleton...")

        // Initialize any required state...
        
        // Stop any existing timer...

        self.stopProgressTimer()

        appLogMsg("\(sCurrMethodDisp) Exiting - AppFileImportManager singleton initialized...")

        return

    }   // End of private init().

    // MARK: - Progress Timer Management
    
    public func startProgressTimer()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - Starting progress timer...")

        // Stop any existing timer first...

        self.stopProgressTimer()
        
        // Create and schedule the timer to fire every second...

    //  self.timerPublisherImportClock1Sec = Timer.publish(every:1, on:.main, in:.common).autoconnect()
        self.timerPublisherImportClock1Sec = Timer.scheduledTimer(withTimeInterval:1.0, repeats:true)
        { _ in
            
            self.updateClockDateTimeCounter()
            
        }

    //  self.updateClockDateTimeCounter()

        // Exiting...
        
        appLogMsg("\(sCurrMethodDisp) Exiting - Progress timer started successfully...")

        return

    }   // End of public func startProgressTimer().

    public func updateClockDateTimeCounter(newValue:Date? = nil, oldValue:Date? = nil)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - Updating progress timer...")

        // Update the timer counter...

        jmAppSyncUpdateUIOnMainThread
        {
            self.progressElapsedSeconds = Int(Date().timeIntervalSince(self.dateUrlReceivedTimestamp))

            appLogMsg("\(ClassInfo.sClsDisp) Progress timer updated - elapsed: \(self.progressElapsedSeconds) seconds...")
        }

        // Exiting.

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func updateClockDateTimeCounter(newValue:Date? = nil, oldValue:Date? = nil).
    
    public func stopProgressTimer()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - Stopping progress timer...")

        if (self.timerPublisherImportClock1Sec != nil)
        {
            self.timerPublisherImportClock1Sec!.invalidate()
            self.timerPublisherImportClock1Sec = nil
            self.progressElapsedSeconds        = 0
        }
        
        appLogMsg("\(sCurrMethodDisp) Exiting - Progress timer stopped...")

        return

    }   // End of public func stopProgressTimer().

    // MARK: - Public 'import' Methods...

    func requestImport(url:URL)
    {

        // Request import of a file URL (called from App's .onOpenURL())...

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - requesting import for URL: [\(url)]...")

        // Clear previous error...

        lastImportError = nil

        // Validate URL...

        guard url.isFileURL
        else
        {
            appLogMsg("\(sCurrMethodDisp) WARNING: URL is not a file URL: [\(url)]...")

            let error = NSError(domain:  "AppFileImportManager",
                                code:    1001,
                                userInfo:[NSLocalizedDescriptionKey:"URL is not a file URL"])

            self.lastImportError = error

            appLogMsg("\(sCurrMethodDisp) Exiting - invalid URL: [\(url)]...")

            return
        }

        // Check if file exists...
        // NOTE: For security-scoped resources (Mail attachments, Files app, etc.),
        //       we cannot check file existence without first calling startAccessingSecurityScopedResource().
        //       Since SpreadsheetXMLViewer will properly handle security-scoped access and validation,
        //       we skip this check here to avoid false negatives with Mail attachments.
        //       The viewer will report appropriate errors if the file cannot be read.

    //  guard FileManager.default.fileExists(atPath:url.path)
    //  else
    //  {
    //      appLogMsg("\(sCurrMethodDisp) WARNING: File does not exist at path: [\(url.path)]...")
    //
    //      let error = NSError(domain:  "AppFileImportManager",
    //                          code:    1002,
    //                          userInfo:[NSLocalizedDescriptionKey:"File does not exist at path: \(url.path)"])
    //
    //      lastImportError = error
    //
    //      appLogMsg("\(sCurrMethodDisp) Exiting - file not found at URL: [\(url)]...")
    //
    //      return
    //  }

        appLogMsg("\(sCurrMethodDisp) File validation skipped for security-scoped resources...")

        // Set import flag...

        self.isImporting = true

        // Store file name...

        self.lastImportedFileName = url.lastPathComponent

        // Trigger import by setting the URL (this will be observed by SpreadsheetXMLViewer)...

        self.dateUrlReceivedTimestamp = Date()
        self.urlToImport              = url

        appLogMsg("\(sCurrMethodDisp) Import requested for file: [\(url.lastPathComponent)]...")
        appLogMsg("\(sCurrMethodDisp) Exiting - urlToImport set, waiting for SpreadsheetXMLViewer to process...")

        return

    }   // End of func requestImport(url:URL).

    func importCompleted(fileName:String)
    {

        // Mark import as completed successfully...

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - import completed for file: [\(fileName)]...")

        // Update state...

        self.isImporting              = false
        self.lastImportDate           = Date()
        self.lastImportedFileName     = fileName
        self.lastImportError          = nil

        // Clear the URL trigger (so same file can be imported again if needed)...

        self.dateUrlReceivedTimestamp = Date()
        self.urlToImport              = nil

        appLogMsg("\(sCurrMethodDisp) Exiting - import marked as completed...")

        return

    }   // End of func importCompleted(fileName:String).

    func importFailed(error:Error, fileName:String)
    {

        // Mark import as failed with error...

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - import failed for file: [\(fileName)] - error: [\(error.localizedDescription)]...")

        // Update state...

        self.isImporting              = false
        self.lastImportError          = error
        self.lastImportedFileName     = fileName

        // Clear the URL trigger...

        self.dateUrlReceivedTimestamp = Date()
        self.urlToImport              = nil

        appLogMsg("\(sCurrMethodDisp) Exiting - import marked as failed...")

        return

    }   // End of func importFailed(error:Error, fileName:String).

    func resetImportState()
    {

        // Reset import state (for cleanup or testing)...

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - resetting import state...")

        self.urlToImport              = nil
        self.dateUrlReceivedTimestamp = Date()
        self.isImporting              = false
        self.lastImportError          = nil
        self.lastImportDate           = nil
        self.lastImportedFileName     = nil

        appLogMsg("\(sCurrMethodDisp) Exiting - import state reset...")

        return

    }   // End of func resetImportState().

}   // End of class AppFileImportManager:ObservableObject.

// MARK: - Import Status Enum

enum AppFileImportStatus
{

    case idle
    case importing
    case success(fileName:String, date:Date)
    case failed(error:Error, fileName:String)

    var isImporting:Bool
    {
        if case .importing = self
        {
            return true
        }

        return false
    }

    var errorMessage:String?
    {
        if case .failed(let error, _) = self
        {
            return error.localizedDescription
        }

        return nil
    }

}   // End of enum AppFileImportStatus.

