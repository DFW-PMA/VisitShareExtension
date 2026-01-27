//
//  VVMessageHandoff.swift
//  Shared between Helper App, Share Extension, and all Target Apps
//
//  Data model for transferring shared content between the extension and target apps.
//

import Foundation

// Data structure for passing shared content to target apps...

struct VVMessageHandoff:Codable, Equatable
{
    
    struct ClassInfo
    {
        static let sClsId        = "VVMessageHandoff"
        static let sClsVers      = "v1.0601"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2025. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = false
    }
    
    // MARK: - Properties...

    let requestID:UUID                      // Unique identifier for this handoff...
    let targetApp:String                    // Which app should receive this handoff (Store as String for Codable simplicity)...
    let handoffPath:String                  // The action path (e.g., "ticket", "management", "metadata")...
    let messageText:String                  // The shared text content...
    let timestamp:Date                      // When the share action occurred...
    let sourceAppBundleID:String?           // Source app bundle ID if available...
    let metadata:[String:String]?           // Additional metadata (extensible)...
    
    // MARK:- Computed Properties...
    
    // Get the target app enum value...

    var target:VVSharedTargetApps?
    {
        VVSharedTargetApps(rawValue:targetApp)
    }
    
    // MARK:- Initialization...
    
    init(targetApp:VVSharedTargetApps,
         messageText:String,
         requestID:UUID = UUID(),
         timestamp:Date = Date(),
         sourceAppBundleID:String? = nil,
         metadata:[String:String]? = nil)
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")
        
        self.requestID         = requestID
        self.targetApp         = targetApp.rawValue
        self.handoffPath       = targetApp.handoffPath  // Derive from enum
        self.messageText       = messageText
        self.timestamp         = timestamp
        self.sourceAppBundleID = sourceAppBundleID
        self.metadata          = metadata

        // Exit...
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Exiting - 'self' is [\(self.debugDescription)]...")
        
        return

    }   // End of init(...).
    
    // MARK:- File Operations...
    
    func write() throws
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Invoked...")
        
        // Write this handoff to the shared container (ensure directory exists)...
        
        try VVSharedConfig.ensureHandoffsDirectoryExists()
        
        guard let target  = self.target,
              let fileURL = VVSharedConfig.handoffFileURL(for:target, requestID:requestID) 
        else { throw VVHandoffError.invalidConfiguration }
        
        let encoder                  = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting     = [.prettyPrinted, .sortedKeys]
        let data                     = try encoder.encode(self)
        try data.write(to:fileURL, options:.atomic)
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Exiting - Wrote handoff to: [\(fileURL.lastPathComponent)]...")

        return

    }   // End of func write() throws.
    
    // Read a handoff from file:
    // - Parameter fileURL:URL to the handoff file
    // - Returns:          Decoded handoff

    static func read(from fileURL:URL) throws ->VVMessageHandoff
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Invoked - 'fileURL' is [\(fileURL)]...")
        
        let data                     = try Data(contentsOf:fileURL)
        let decoder                  = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(VVMessageHandoff.self, from:data)

    }   // End of static func read(from fileURL:URL) throws ->VVMessageHandoff.
    
    static func read(for targetApp:VVSharedTargetApps, requestID:UUID) throws ->VVMessageHandoff
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Invoked - 'targetApp' is [\(targetApp.displayName)] - 'requestID' is [\(requestID)]...")
        
        // Read a specific handoff by target app and request ID...

        guard let fileURL = VVSharedConfig.handoffFileURL(for:targetApp, requestID:requestID) 
        else { throw VVHandoffError.invalidConfiguration }
        
        guard FileManager.default.fileExists(atPath:fileURL.path) 
        else { throw VVHandoffError.handoffNotFound }
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Intermediate - 'targetApp' is [\(targetApp.displayName)] - 'requestID' is [\(requestID)] - 'fileURL' is [\(fileURL)]...")
        
        return try read(from:fileURL)

    }   // End of static func read(for targetApp:VVSharedTargetApps, requestID:UUID) throws ->VVMessageHandoff.
    
    func delete() 
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")
        
        // Delete this handoff file...

        guard let target  = self.target,
              let fileURL = VVSharedConfig.handoffFileURL(for:target, requestID:requestID)
        else { return }
        
        try? FileManager.default.removeItem(at:fileURL)

        appLogMsg("\(sCurrMethodDisp) Deleted handoff: [\(fileURL.lastPathComponent)]...")

        return

    }   // End of func delete().
    
    static func delete(for targetApp:VVSharedTargetApps, requestID:UUID)
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")
        
        // Delete a handoff by target and ID...

        guard let fileURL = VVSharedConfig.handoffFileURL(for:targetApp, requestID:requestID)
        else { return }
        
        try? FileManager.default.removeItem(at:fileURL)

        appLogMsg("\(sCurrMethodDisp) Deleted handoff: [\(fileURL.lastPathComponent)]...")

        return

    }   // End of static func delete(for targetApp:VVSharedTargetApps, requestID:UUID).

}   // End of struct VVMessageHandoff:Codable.

// MARK:- Errors...

enum VVHandoffError:LocalizedError
{
    case invalidConfiguration
    case handoffNotFound
    case decodingFailed
    case targetAppNotInstalled
    
    var errorDescription:String?
    {
        switch self
        {
        case .invalidConfiguration:
            return "Invalid handoff configuration. Check App Group setup."
        case .handoffNotFound:
            return "No pending handoff found for this request."
        case .decodingFailed:
            return "Failed to decode handoff data."
        case .targetAppNotInstalled:
            return "Target app is not installed."
        }
    }
}

// MARK:- Debug...

extension VVMessageHandoff:CustomDebugStringConvertible
{
    var debugDescription:String
    {
        """
        VVMessageHandoff:
          ID:\(requestID)
          TargetApp:\(targetApp)
          HandoffPath:\(handoffPath)
          Timestamp:\(timestamp)
          Source:\(sourceAppBundleID ?? "unknown")
          Text:\(messageText.prefix(80))...
        """
    }
}

