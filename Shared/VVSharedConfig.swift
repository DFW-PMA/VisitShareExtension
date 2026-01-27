//
//  VVSharedConfig.swift
//  Shared between Helper App, Share Extension, and all Target Apps
//
//  Central configuration for the JustMacApps shared infrastructure.
//  IMPORTANT:Add this file to ALL targets that participate in sharing.
//

import Foundation

// Shared configuration for JustMacApps suite communication...

enum VVSharedConfig
{
    
    struct ClassInfo
    {
        static let sClsId        = "VVSharedConfig"
        static let sClsVers      = "v1.0301"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2025. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = false
    }
    
    // MARK:- App Group
    
    // The shared App Group identifier
    // Must match:
    // - Apple Developer Portal App Group
    // - All participating apps' entitlements
    // - Share Extension entitlements

    static let appGroupID                   = "group.com.PreferredMobileApplications.sharedVisitApps1"
    
    // MARK:- File Paths
    
    // Directory name for pending handoffs...

    static let handoffDirectory             = "PendingHandoffs"
    
    // URL to the shared container...

    static var sharedContainerURL:URL? 
    {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:appGroupID)
    }
    
    // URL to the handoffs directory...

    static var handoffsDirectoryURL:URL?
    {
        sharedContainerURL?.appendingPathComponent(handoffDirectory, isDirectory:true)
    }
    
    // Build the file URL for a specific handoff:
    // - Parameters:
    //   - targetApp:The app this handoff is intended for
    //   - requestID:Unique identifier for this request
    // - Returns:    URL to the handoff file

    static func handoffFileURL(for targetApp:VVSharedTargetApps, requestID:UUID)->URL?
    {

        // File format:{app}_{uuid}.json
        // e.g., visitreportingapp_550e8400-e29b-41d4-a716-446655440000.json...

        let filename = "\(targetApp.rawValue)_\(requestID.uuidString).json"

        return handoffsDirectoryURL?.appendingPathComponent(filename)

    }   // End of static func handoffFileURL(for targetApp:VVSharedTargetApps, requestID:UUID)->URL?.
    
    // Ensure the handoffs directory exists...

    static func ensureHandoffsDirectoryExists() throws
    {

        guard let dirURL = handoffsDirectoryURL 
        else { throw VVConfigError.noSharedContainer }
        
        if !FileManager.default.fileExists(atPath:dirURL.path)
        {
            try FileManager.default.createDirectory(at:dirURL, withIntermediateDirectories:true)
        }

        return

    }   // End of static func ensureHandoffsDirectoryExists() throws.
    
    // MARK:- Cleanup
    
    // Maximum age for handoff files (in seconds)..

    static let maxHandoffAge:TimeInterval   = 300               // 5 minutes...
    
    static func cleanupStaleHandoffs(for targetApp:VVSharedTargetApps? = nil)
    {

        // Clean up stale handoff files for a specific app
        // Call this on app launch...

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        guard let dirURL = handoffsDirectoryURL 
        else { return }
        
        let fileManager  = FileManager.default
        guard let files  = try? fileManager.contentsOfDirectory(at:dirURL, includingPropertiesForKeys:[.contentModificationDateKey])
        else { return }
        
        let now          = Date()
        
        for fileURL in files
        {
            // Filter by app if specified...

            if let targetApp = targetApp 
            {
                guard fileURL.lastPathComponent.hasPrefix(targetApp.rawValue)
                else { continue }
            }
            
            // Check age...

            guard let attributes = try? fileURL.resourceValues(forKeys:[.contentModificationDateKey]),
                  let modDate    = attributes.contentModificationDate 
            else { continue }
            
            if (now.timeIntervalSince(modDate) > maxHandoffAge)
            {
                try? fileManager.removeItem(at:fileURL)

                appLogMsg("\(sCurrMethodDisp) Cleaned up stale handoff: [\(fileURL.lastPathComponent)]...")
            }
        }

        return

    }   // End of static func cleanupStaleHandoffs(for targetApp:VVSharedTargetApps?).
    
    // Find pending handoffs for a specific app:
    // - Parameter targetApp:The app to find handoffs for
    // - Returns:            Array of file URLs for pending handoffs

    static func pendingHandoffs(for targetApp:VVSharedTargetApps)->[URL]
    {

        guard let dirURL = handoffsDirectoryURL else { return [] }
        
        let fileManager  = FileManager.default
        guard let files  = try? fileManager.contentsOfDirectory(at:dirURL, includingPropertiesForKeys:nil)
        else { return [URL]() }
        
        return files.filter { $0.lastPathComponent.hasPrefix(targetApp.rawValue) }

    }   // End of static func pendingHandoffs(for targetApp:VVSharedTargetApps)->[URL].
}

// MARK:- Errors

enum VVConfigError:LocalizedError
{
    case noSharedContainer
    case directoryCreationFailed
    
    var errorDescription:String?
    {
        switch self
        {
        case .noSharedContainer:
            return "Unable to access shared App Group container. Verify App Group configuration in all targets."
        case .directoryCreationFailed:
            return "Failed to create handoffs directory in shared container."
        }
    }
}

