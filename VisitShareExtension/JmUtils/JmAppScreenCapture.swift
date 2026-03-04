//
//  JmAppScreenCapture.swift
//  JmUtils_Library
//
//  Created by JustMacApps.net on 03/02/2026.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 14.0, *)
@objc(JmAppScreenCapture)
class JmAppScreenCapture:NSObject
{

    struct ClassInfo
    {
        static let sClsId        = "JmAppScreenCapture"
        static let sClsVers      = "v1.0301"
        static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // Singleton - NSObject subclass, so accessible from ObjC via @objc:

    @objc(jmAppScreenCapture)
    static var jmAppScreenCapture:JmAppScreenCapture           = JmAppScreenCapture()

    // App Data field(s):

                 var jmAppDelegateVisitor:JmAppDelegateVisitor = JmAppDelegateVisitor.ClassSingleton.appDelegateVisitor

    // Compile-time retry tuning constants:

                 let iMaxRetries:Int                           = 6               // Total attempts before giving up
                 let iRetryIntervalNs:UInt64                   = 333_000_000     // 1/3 second between retries (nanoseconds)

    // Compile-time screenshot(s) subdirectory name:

                 let sScreenshotsSubdirectory:String           = "JMA_Screenshots"

    private override init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        super.init()

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Invoked...")
        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Exiting...")

        return

    }

    // MARK:- ObjC Bridge Entry Point
    // Called from AppDelegate.m for storyboard-based views.
    // Safe to call from main thread — dispatches capture internally via Task { @MainActor }.

    @objc public func triggerScreenCaptureUpload(_ tag:     String,
                                                 notifyFrom:String  = "",
                                                 notifyTo:  String  = "",
                                                 notifyCc:  String  = "")
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Invoked - tag[\(tag)]...")
        
        var sNotifyFrom:String = notifyFrom
        var sNotifyTo:String   = notifyTo
        var sNotifyCc:String   = notifyCc
        
        if (sNotifyFrom.count < 1)
        {
            sNotifyFrom = AppGlobalInfo.sAppUploadNotifyFrom
        }
        
        if (sNotifyTo.count < 1)
        {
            sNotifyTo = "dcox@justmacapps.net;tony@dfwpts.net"
        }
        
        if (sNotifyCc.count < 1)
        {
            sNotifyCc = "tony@dfwpts.net;dcox@justmacapps.net"
        }
        
        Task 
        { @MainActor in

            await self.captureAndUpload(tag:       tag,
                                        uploadURL: "",            // "" takes the default URL in MultipartRequestDriver
                                        notifyFrom:sNotifyFrom,
                                        notifyTo:  sNotifyTo,
                                        notifyCc:  sNotifyCc,
                                        bZip:      false,
                                        bSilent:   true)          // No user-facing Alert for background debug captures

        }

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Exiting - Task dispatched...")

        return

    }   // End of @objc public func triggerScreenCaptureUpload(...).

    // MARK:- Primary Capture + Upload

    @MainActor
    public func captureAndUpload(tag:       String  = "JMA",
                                 uploadURL: String  = "",
                                 notifyFrom:String  = "",
                                 notifyTo:  String  = "",
                                 notifyCc:  String  = "",
                                 bZip:      Bool    = false,
                                 bSilent:   Bool    = true) async
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Invoked - tag[\(tag)] bZip[\(bZip)] bSilent[\(bSilent)]...")

        // 1. Capture key window...

        guard let image = await captureKeyWindow() 
        else
        {
            appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> captureKeyWindow() returned nil - Error!")
            return
        }

        guard let pngData = image.pngData() 
        else
        {
            appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> pngData() conversion failed - Error!")
            return
        }

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Captured PNG - size[\(pngData.count) bytes]...")

        // 2. Build filenames with timestamp...

        let sTimestamp:String   = buildTimestamp()
        let sPngFilename:String = "JMA_Screen_\(tag)_\(sTimestamp).png"
        let sZipFilename:String = "JMA_Screen_\(tag)_\(sTimestamp)"     // No extension — Driver appends .zip

        // 3.1. Backup to Documents always (developer-accessible via device probe tools)...

        let sDocsSavedPath:String = saveToDocuments(data:pngData, filename:sPngFilename)
        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Backed up to Documents:[\(sDocsSavedPath)]...")

        // 3.2. Build the notification email addresses...

        var sNotifyFrom:String = notifyFrom
        var sNotifyTo:String   = notifyTo
        var sNotifyCc:String   = notifyCc
        
        if (sNotifyFrom.count < 1)
        {
            sNotifyFrom = AppGlobalInfo.sAppUploadNotifyFrom
        }
        
        if (sNotifyTo.count < 1)
        {
            sNotifyTo = "dcox@justmacapps.net;tony@dfwpts.net"
        }
        
        if (sNotifyCc.count < 1)
        {
            sNotifyCc = "tony@dfwpts.net;dcox@justmacapps.net"
        }
        
        // 4. Build MultipartRequestInfo...

        let multipartRequestInfo:MultipartRequestInfo = MultipartRequestInfo()
        multipartRequestInfo.sAppUploadURL            = uploadURL
        multipartRequestInfo.sAppUploadNotifyFrom     = sNotifyFrom
        multipartRequestInfo.sAppUploadNotifyTo       = sNotifyTo
        multipartRequestInfo.sAppUploadNotifyCc       = sNotifyCc
        multipartRequestInfo.sAppSourceFilespec       = sDocsSavedPath
        multipartRequestInfo.sAppSourceFilename       = sPngFilename
        multipartRequestInfo.sAppSaveAsFilename       = sPngFilename
        multipartRequestInfo.bAppZipSourceToUpload    = bZip

        if (bZip)
        {
            // Pre-zip here so Driver's zip-check path sees "application/zip" and bypasses its own zip...

            multipartRequestInfo.sAppZipFilename   = sZipFilename
            multipartRequestInfo.sAppFileMimeType  = "application/zip"
            let zipCreator:MultipartZipFileCreator = MultipartZipFileCreator()
            let urlZip:URL?                        = zipCreator.createTargetZipFileFromSource(multipartRequestInfo:multipartRequestInfo)

            if (urlZip == nil)
            {
                // Zip failed — fall back to raw PNG, Driver will handle gracefully..

                appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Zip creation failed - falling back to raw PNG - Warning!")

                multipartRequestInfo.sAppZipFilename       = "-N/A-"
                multipartRequestInfo.sAppFileMimeType      = "image/png"
                multipartRequestInfo.dataAppFile           = pngData
                multipartRequestInfo.bAppZipSourceToUpload = false
            }
            else
            {
                appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Zip created at [\(String(describing:urlZip!))]...")
            }
        }
        else
        {
            // Raw PNG — populate dataAppFile directly.
            // Driver sees "image/png" mime + "-N/A-" zip name → skips zip path entirely.

            multipartRequestInfo.sAppZipFilename   = "-N/A-"
            multipartRequestInfo.sAppFileMimeType  = "image/png"
            multipartRequestInfo.dataAppFile       = pngData
        }

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> MultipartRequestInfo populated:[\(multipartRequestInfo.toString())]...")

        // 5. Fire the driver.
        //    bAlertIsBypassed:true   = no user-facing Alert for background debug captures.
        //    bGenerateResponseLongMsg:false = terse log entry only.
        //    MultipartRequestDriver is 'final :Sendable' — not a singleton, instantiate fresh each use.

        let multipartRequestDriver:MultipartRequestDriver = MultipartRequestDriver(bGenerateResponseLongMsg:false, bAlertIsBypassed:bSilent)

        multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:multipartRequestInfo)

        appLogMsg("\(sCurrMethodDisp)<CaptureScreenshot>  Exiting - executeMultipartRequest dispatched...")

        return

    }   // End of public func captureAndUpload().

    // MARK:- Key Window Capture

    @MainActor
    private func captureKeyWindow() async ->UIImage?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Invoked - max retries[\(iMaxRetries)] interval[\(iRetryIntervalNs)ns]...")

        var iAttempt:Int = 0

        repeat
        {
            if let windowScene = UIApplication.shared.connectedScenes
                  .compactMap({ $0 as? UIWindowScene })
                  .first(where:{ $0.activationState == .foregroundActive }),
               let window = windowScene.keyWindow
            {
                let renderer:UIGraphicsImageRenderer = UIGraphicsImageRenderer(bounds:window.bounds)

                let image:UIImage = renderer.image
                { _ in

                    // afterScreenUpdates:true ensures SwiftData-driven UI is fully rendered before capture
                    window.drawHierarchy(in:window.bounds, afterScreenUpdates:true)

                }

                appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Exiting - captured [\(Int(window.bounds.width))x\(Int(window.bounds.height))] pts on attempt [\(iAttempt + 1)]...")

                return image
            }

            iAttempt += 1

            if (iAttempt < iMaxRetries)
            {
                appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> No foreground keyWindow on attempt [\(iAttempt)] of [\(iMaxRetries)] - retrying in 1/3s...")
                try? await Task.sleep(nanoseconds:iRetryIntervalNs)
            }

        } while (iAttempt < iMaxRetries)

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> No foreground keyWindow after [\(iMaxRetries)] attempts - Error!")

        return nil

    }   // End of private func captureKeyWindow().

    // MARK:- Save to Documents (Developer Probe Accessible via device tools)

    @discardableResult
    private func saveToDocuments(data:Data, filename:String)->String
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Invoked - filename[\(filename)]...")

        let docsURL:URL        = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask)[0]
        let screenshotsURL:URL = docsURL.appendingPathComponent(self.sScreenshotsSubdirectory, isDirectory:true)

        do
        {
            try FileManager.default.createDirectory(at:screenshotsURL,
                                                    withIntermediateDirectories:true,
                                                    attributes:nil)

            let fileURL:URL = screenshotsURL.appendingPathComponent(filename)

            try data.write(to:fileURL, options:.atomic)

            appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Exiting - saved to [\(fileURL.path)]...")

            return fileURL.path
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Write failed - Details:[\(error)] - Error!")
            return ""
        }

    }   // End of private func saveToDocuments().

    // MARK:- Screenshot Directory Listing

    // Returns a recursive tree listing of .documents/JMA_Screenshots as a [String].
    // Builds the canonical JMA_Screenshots URL then delegates to returnScreenshotDirectoryContents().

    @objc public func returnScreenshotDirectory()->[String]
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Invoked...")

        let docsURL:URL             = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask)[0]
        let screenshotsURL:URL      = docsURL.appendingPathComponent(self.sScreenshotsSubdirectory, isDirectory:true)
        let sScreenshotsPath:String = screenshotsURL.path
        let asLines:[String]        = returnScreenshotDirectoryContents(sScreenshotsPath)

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Exiting - returning [\(asLines.count)] line(s)...")

        return asLines

    }   // End of public func returnScreenshotDirectory().

    // Returns a recursive tree listing of the directory at the supplied path as a [String].
    // Includes header and footer banner lines. Caller decides where output is directed.

    @objc public func returnScreenshotDirectoryContents(_ directoryPath:String)->[String]
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Invoked - 'directoryPath' is [\(directoryPath)]...")

        var asLines:[String] = [String]()
        let targetURL:URL    = URL(fileURLWithPath:directoryPath, isDirectory:true)

        guard FileManager.default.fileExists(atPath:directoryPath)
        else
        {
            asLines.append("========== [\(self.sScreenshotsSubdirectory)] Directory Tree ==========")
            asLines.append("Directory not found: \(directoryPath)")
            asLines.append("========== End Directory Tree ==========")

            appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Directory not found at [\(directoryPath)] - Warning!")

            return asLines
        }

        asLines.append("========== [\(self.sScreenshotsSubdirectory)] Directory Tree ==========")
        asLines.append("Root: \(targetURL.path)")

        collectDirectoryContentsRecursive(url:targetURL, indent:"", into:&asLines)

        asLines.append("========== End Directory Tree ==========")

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Exiting - returning [\(asLines.count)] line(s)...")

        return asLines

    }   // End of public func returnScreenshotDirectoryContents().

    // Private recursive helper — walks a directory tree and appends formatted entries to 'lines'.

    private func collectDirectoryContentsRecursive(url:URL, indent:String, into lines:inout [String])
    {

        do
        {
            let fileURLs:[URL] = try FileManager.default.contentsOfDirectory(
                at:                        url,
                includingPropertiesForKeys:[.isDirectoryKey, .totalFileSizeKey],
                options:                   .skipsHiddenFiles
            )

            for fileURL in fileURLs.sorted(by:{ $0.lastPathComponent < $1.lastPathComponent })
            {
                let resourceValues       = try fileURL.resourceValues(forKeys:[.isDirectoryKey, .totalFileSizeKey])
                let bIsDirectory:Bool    = resourceValues.isDirectory  ?? false
                let iFileSize:Int        = resourceValues.totalFileSize ?? 0

                if (bIsDirectory)
                {
                    lines.append("\(indent)[DIR] \(fileURL.lastPathComponent)/")

                    collectDirectoryContentsRecursive(url:fileURL, indent:indent + "    ", into:&lines)
                }
                else
                {
                    let sSizeStr:String = ByteCountFormatter.string(fromByteCount:Int64(iFileSize), countStyle:.file)

                    lines.append("\(indent)[FILE] \(fileURL.lastPathComponent) (\(sSizeStr))")
                }
            }
        }
        catch
        {
            lines.append("\(indent)[ERROR] \(error.localizedDescription)")
        }

    }   // End of private func collectDirectoryContentsRecursive().

    // MARK:- Timestamp Helper

    private func buildTimestamp() -> String
    {

        let formatter:ISO8601DateFormatter = ISO8601DateFormatter()
        formatter.formatOptions            = [.withFullDate, .withTime, .withColonSeparatorInTime]

        return formatter.string(from:Date()).replacingOccurrences(of:":", with:"-")

    }   // End of private func buildTimestamp().

}   // End of class JmAppScreenCapture:NSObject.

