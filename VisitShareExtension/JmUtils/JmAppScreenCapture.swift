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
        static let sClsVers      = "v1.0107"
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

            self.captureAndUpload(tag:       tag,
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
    public func captureAndUpload(tag:       String  = "VV",
                                 uploadURL: String  = "",
                                 notifyFrom:String  = "",
                                 notifyTo:  String  = "",
                                 notifyCc:  String  = "",
                                 bZip:      Bool    = false,
                                 bSilent:   Bool    = true)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Invoked - tag[\(tag)] bZip[\(bZip)] bSilent[\(bSilent)]...")

        // 1. Capture key window...

        guard let image = captureKeyWindow() 
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
        let sPngFilename:String = "VV_Screen_\(tag)_\(sTimestamp).png"
        let sZipFilename:String = "VV_Screen_\(tag)_\(sTimestamp)"     // No extension — Driver appends .zip

        // 3.1. Backup to Documents always (developer-accessible via VV device probe tools)...

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
    private func captureKeyWindow()->UIImage?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Invoked...")

        guard let windowScene = UIApplication.shared.connectedScenes
              .compactMap({ $0 as? UIWindowScene })
              .first(where:{ $0.activationState == .foregroundActive }),
              let window = windowScene.keyWindow
        else
        {
            appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> No foreground keyWindow found - Error!")
            return nil
        }

        let renderer:UIGraphicsImageRenderer = UIGraphicsImageRenderer(bounds:window.bounds)

        let image:UIImage = renderer.image
        { _ in

            // afterScreenUpdates:true ensures SwiftData-driven UI is fully rendered before capture
            window.drawHierarchy(in:window.bounds, afterScreenUpdates:true)

        }

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Exiting - captured [\(Int(window.bounds.width))x\(Int(window.bounds.height))] pts...")

        return image

    }   // End of private func captureKeyWindow().

    // MARK:- Save to Documents (Developer Probe Accessible via VV device tools)

    @discardableResult
    private func saveToDocuments(data:Data, filename:String)->String
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <CaptureScreenshot> Invoked - filename[\(filename)]...")

        let docsURL:URL        = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask)[0]
        let screenshotsURL:URL = docsURL.appendingPathComponent("VV_Screenshots", isDirectory:true)

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

    // MARK:- Timestamp Helper

    private func buildTimestamp() -> String
    {

        let formatter:ISO8601DateFormatter = ISO8601DateFormatter()
        formatter.formatOptions            = [.withFullDate, .withTime, .withColonSeparatorInTime]

        return formatter.string(from:Date()).replacingOccurrences(of:":", with:"-")

    }   // End of private func buildTimestamp().

}   // End of class JmAppScreenCapture:NSObject.

