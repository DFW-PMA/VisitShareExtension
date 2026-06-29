//
//  MultipartRequestDriver.swift
//  JustAMultipartRequestTest1
//
//  Created by JustMacApps.net on 09/10/2024.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import JmEntityInfo
import Foundation
import SwiftUI

@JmEntityInfo(vers:"v1.2007")
@available(iOS 14.0, *)
//class MultipartRequestDriver: NSObject
final class MultipartRequestDriver: Sendable
{

    //  struct ClassInfo
    //  {
//
        //  static let sClsId          = "MultipartRequestDriver"
        //  static let sClsVers        = "v1.1101"
        //  static let sClsDisp        = sClsId+"(.swift).("+sClsVers+"):"
        //  static let sClsCopyRight   = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        //  static let bClsTrace       = true
        //  static let bClsFileLog     = true
//
    //  }

    // App Data field(s):

    // <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — 'bInternalTest' and
    // 'multipartRequestInfo' were stored properties read/written throughout processMultipartRequest(),
    // which is a real shared-mutable-state hazard on a class declared 'Sendable' (the compiler caught
    // a genuine re-entrancy risk, not a false positive — see <<CHICKEN-TRACKS>> note inside
    // processMultipartRequest()). Commented out; replaced with method-local vars set fresh on each call.
    //  private var bInternalTest:Bool                         = false
    // <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — flagged SENDABLE
    // ("stored property is mutable" on a 'Sendable'-conforming class). Daryl confirmed these are
    // per-instance config (NOT singleton state) that can only ever be set once, from the (now
    // consolidated) init() — never from any method or call site afterward. Changed 'var' -> 'let'
    // with the inline defaults removed (a 'let' can't have both an inline default AND an init
    // assignment); the former 'convenience init' that overrode these after delegating to the
    // parameterless init() is merged into one designated init below, since 'let' properties cannot
    // be reassigned after delegation completes. See <<CHICKEN-TRACKS>> note at the init().
    private let bGenerateResponseLongMsg:Bool
    private let bAlertIsBypassed:Bool

                                                             // For 'test':
    // <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — flagged SENDABLE
    // ("stored property is mutable" on a 'Sendable'-conforming class). Daryl confirmed this is
    // read-only test data, never written to anywhere — confirmed via grep. Changed 'var' -> 'let'.
    private let dictUserData:[String:String]               = ["firstName": "John",
                                                              "lastName":  "Doe"
                                                             ]

    //  private var multipartRequestInfo:MultipartRequestInfo? = nil

    // <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — flagged SENDABLE
    // ("stored property is mutable" on a 'Sendable'-conforming class). These were pure duplicates —
    // MultipartRequestInfo (the 'localMultipartRequestInfo' local var in processMultipartRequest())
    // already has its own 'urlResponse'/'urlResponseData' properties, and the driver's copies were
    // just being mirrored into it right before use. Daryl confirmed nothing external reads these
    // (grep showed zero references outside this file). Commented out; processMultipartRequest() now
    // sets 'localMultipartRequestInfo?.urlResponse'/'.urlResponseData' directly, dropping 'self.'.
    //  public  var urlResponse:HTTPURLResponse?               = nil
    //  public  var urlResponseData:Data?                      = nil

    // <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — flagged SENDABLE
    // ("stored property is mutable" on a 'Sendable'-conforming class). Confirmed via grep this is
    // only ever read (self.jmAppDelegateVisitor.setAppDelegateVisitorSignalGlobalAlert(...)), never
    // reassigned after declaration. Changed 'var' -> 'let'.
    // <<CHICKEN-TRACKS>> Swift 6 migration follow-up — 'let' alone wasn't sufficient; the compiler
    // separately flags JmAppDelegateVisitor itself as non-Sendable (it's the shared app-wide
    // delegate-visitor singleton, ~5,917 lines, touches nearly every manager — making it Sendable
    // is far outside this file's scope). Added nonisolated(unsafe) — same reasoning as
    // AppGlobalInfo's singleton fix: trusted, read-only-after-construction reference.
            nonisolated(unsafe) let jmAppDelegateVisitor:JmAppDelegateVisitor  = JmAppDelegateVisitor.appDelegateVisitor

    // <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — 'bGenerateResponseLongMsg'
    // and 'bAlertIsBypassed' changed 'var' -> 'let' (see note at declaration). The former parameterless
    // 'init()' plus a separate 'convenience init(bGenerateResponseLongMsg:bAlertIsBypassed:)' that
    // delegated to it and then overrode the values is merged into this single designated init with
    // default parameter values — a 'convenience init' cannot reassign a 'let' property after
    // delegating via 'self.init()'. Every real call site already passes both arguments explicitly
    // (confirmed via grep — JmAppScreenCapture.swift, JmAppDelegateVisitor.swift), and the old
    // parameterless init() was never called directly from outside this class, so this preserves
    // identical call-site behavior with no API changes.
//  override init()
    init(bGenerateResponseLongMsg:Bool = false, bAlertIsBypassed:Bool = false)
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

    //  super.init()

        self.bGenerateResponseLongMsg = bGenerateResponseLongMsg
        self.bAlertIsBypassed         = bAlertIsBypassed

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'bGenerateResponseLongMsg' is [\(bGenerateResponseLongMsg)] and 'bAlertIsBypassed' is [\(bAlertIsBypassed)]...")

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting - 'self.bGenerateResponseLongMsg' is [\(self.bGenerateResponseLongMsg)] - 'self.bAlertIsBypassed' is [\(self.bAlertIsBypassed)]...")

        return

    }   // End of init(bGenerateResponseLongMsg:Bool = false, bAlertIsBypassed:Bool = false).

//  convenience init(bGenerateResponseLongMsg:Bool, bAlertIsBypassed:Bool = false)
//  {
//
//      let sCurrMethodDisp:String = #JmCurrentMethodInfo
//
//      self.init()
//
//      appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'bGenerateResponseLongMsg' is [\(bGenerateResponseLongMsg)] and 'bAlertIsBypassed' is [\(bAlertIsBypassed)]...")
//
//      self.bGenerateResponseLongMsg = bGenerateResponseLongMsg
//      self.bAlertIsBypassed         = bAlertIsBypassed
//
//      // Exit...
//
//      appLogMsg("\(sCurrMethodDisp) Exiting - 'self.bGenerateResponseLongMsg' is [\(self.bGenerateResponseLongMsg)] - 'self.bAlertIsBypassed' is [\(self.bAlertIsBypassed)]...")
//
//      return
//
//  }   // End of (convenience) init().

    public func executeMultipartRequest(multipartRequestInfo:MultipartRequestInfo? = nil)
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — the prior
        // DispatchGroup/DispatchQueue.async/nested-Task wrapping below was vestigial: 'dispatchGroup'
        // was never wait()'d or notify()'d anywhere, and .leave() fired immediately after starting
        // the async work rather than after it completed, so it gated nothing. The custom
        // DispatchQueue.async hop was also unnecessary — Task { ... } alone already runs without
        // blocking the caller. Flagged by the compiler as "passing closure as a 'sending' parameter
        // risks causing data races" (Task's closure capturing the non-Sendable 'multipartRequestInfo'
        // across two nested non-Sendable closure boundaries instead of one). Simplified to a single
        // Task — resolved as a side effect of removing the redundant wrapping, combined with marking
        // MultipartRequestInfo '@unchecked Sendable' (see MultipartRequestInfo.swift).
        //  let dispatchGroup = DispatchGroup()
        //
        //  do
        //  {
        //
        //      dispatchGroup.enter()
        //
        //      let dispatchQueue = DispatchQueue(label: "MultipartRequestBackgroundThread", qos: .userInitiated)
        //
        //      dispatchQueue.async
        //      {
        //
        //          appLogMsg("\(sCurrMethodDisp) Calling 'processMultipartRequest()' with a 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo))]...")
        //
        //          Task
        //          {
        //
        //              await self.processMultipartRequest(multipartRequestInfo:multipartRequestInfo)
        //
        //          }
        //
        //          appLogMsg("\(sCurrMethodDisp) Called  'processMultipartRequest()' with a 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo))]...")
        //
        //      }
        //
        //      dispatchGroup.leave()
        //
        //  }

        appLogMsg("\(sCurrMethodDisp) Calling 'processMultipartRequest()' with a 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo))]...")

        Task
        {

            await self.processMultipartRequest(multipartRequestInfo:multipartRequestInfo)

        }

        appLogMsg("\(sCurrMethodDisp) Called  'processMultipartRequest()' with a 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo))]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func executeMultipartRequest().

    public func processMultipartRequest(multipartRequestInfo:MultipartRequestInfo? = nil) async
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — 'localBInternalTest' and
        // 'localMultipartRequestInfo' replace the former 'self.bInternalTest'/'self.multipartRequestInfo'
        // stored properties. This class is declared 'Sendable', so mutable shared state read/written
        // across this async method's body is a genuine re-entrancy hazard (two overlapping calls would
        // race on 'self'), not a checker false positive. Scoping this state to the call's stack frame
        // instead removes the hazard at the root. Nothing outside this method ever read the old
        // properties (both were 'private'), so this is a behavior-preserving refactor. All references
        // below — including the ones that previously bypassed 'self.' and read the parameter directly
        // (an inconsistency in the original code) — now consistently use the one local var.

        // Determine if this is a 'test' or not:

        var localBInternalTest:Bool                          = (multipartRequestInfo == nil)
        var localMultipartRequestInfo:MultipartRequestInfo?  = multipartRequestInfo

        // Create the Multipart 'request' (Phase 1):

        var multipart = MultipartRequest()

        if (localMultipartRequestInfo == nil)
        {

            localBInternalTest                               = true
            localMultipartRequestInfo                        = MultipartRequestInfo()

            localMultipartRequestInfo?.bAppZipSourceToUpload = false
            localMultipartRequestInfo?.sAppUploadURL         = ""                       // "" takes the Upload URL 'default'...
            localMultipartRequestInfo?.sAppUploadNotifyFrom  = "dcox@justmacapps.net"
            localMultipartRequestInfo?.sAppUploadNotifyTo    = "dcox@justmacapps.org"
            localMultipartRequestInfo?.sAppUploadNotifyCc    = "dcox@justmacapps.net"
            localMultipartRequestInfo?.sAppSourceFilespec    = "test1.txt"
            localMultipartRequestInfo?.sAppSourceFilename    = "test1.txt"
            localMultipartRequestInfo?.sAppZipFilename       = "test1.zip"
            localMultipartRequestInfo?.sAppSaveAsFilename    = "test1.data"
            localMultipartRequestInfo?.sAppFileMimeType      = "text/plain"
            localMultipartRequestInfo?.dataAppFile           = "test1-text-data".data(using:.utf8)

        }

        if (localMultipartRequestInfo?.sAppUploadURL == nil ||
            (localMultipartRequestInfo?.sAppUploadURL.count)! < 1)
        {

        //  localMultipartRequestInfo?.sAppUploadURL = "http://localhost/dfwpma/file_uploads"
        //  localMultipartRequestInfo?.sAppUploadURL = "http://justmacapps.net/dfwpma/file_uploads"
            localMultipartRequestInfo?.sAppUploadURL = "https://justmacapps.net/dfwpma/file_uploads"

        }

        // Check that we have a 'target' file (string) that is NOT nil, an Mime 'type' that is NOT zip, then zip...

        var sCheckAppZipFilename:String = localMultipartRequestInfo?.sAppZipFilename ?? ""

        if (localMultipartRequestInfo?.sAppZipFilename == "-N/A-")
        {

            sCheckAppZipFilename = ""

        }

        if (sCheckAppZipFilename.count < 1)
        {

            appLogMsg("\(sCurrMethodDisp) Unable to Zip the 'source' filespec of [\(String(describing: localMultipartRequestInfo?.sAppSourceFilespec))] - the 'check' Zip filename is 'nil' - Warning!")

        }
        else
        {

            if (localMultipartRequestInfo?.sAppFileMimeType == "application/zip")
            {

                appLogMsg("\(sCurrMethodDisp) Bypassing the Zip of the 'source' filespec of [\(String(describing: localMultipartRequestInfo?.sAppSourceFilespec))] - the MIME 'type' indicates the payload is already zipped...")

            }
            else
            {

                appLogMsg("\(sCurrMethodDisp) The 'upload' is using 'multipartRequestInfo' of [\(String(describing: localMultipartRequestInfo?.toString()))]...")

                // Attempting to 'zip' the file (content(s))...

                let multipartZipFileCreator:MultipartZipFileCreator = MultipartZipFileCreator()

            //  localMultipartRequestInfo.sAppZipFilename = localMultipartRequestInfo.sAppSourceFilename

                var urlCreatedZipFile:URL? = multipartZipFileCreator.createTargetZipFileFromSource(multipartRequestInfo:localMultipartRequestInfo ?? MultipartRequestInfo())

                // Check if we actually got the 'target' Zip file created...

                if let urlCreatedZipFile = urlCreatedZipFile 
                {

                    appLogMsg("\(sCurrMethodDisp) Produced a Zip file 'urlCreatedZipFile' of [\(urlCreatedZipFile)]...")

                    localMultipartRequestInfo!.sAppZipFilename  = "\(localMultipartRequestInfo?.sAppZipFilename ?? "-undefined-").zip"

                }
                else
                {

                    appLogMsg("\(sCurrMethodDisp) Failed to produce a Zip file - the 'target' Zip filename was [\(localMultipartRequestInfo?.sAppZipFilename ?? "-undefined-")] - Error!")

                    localMultipartRequestInfo?.sAppZipFilename  = "-N/A-"
                    localMultipartRequestInfo?.sAppFileMimeType = "text/plain"
                    localMultipartRequestInfo?.dataAppFile      = FileManager.default.contents(atPath: localMultipartRequestInfo?.sAppSourceFilespec ?? "-undefined-")

                    appLogMsg("\(sCurrMethodDisp) Reset the 'multipartRequestInfo' to upload the <raw> file without 'zipping'...")

                    urlCreatedZipFile = nil

                }

            }

        }

        // Create the Multipart 'request' (Phase 2):

        if (localBInternalTest == true)
        {

            for userItem in self.dictUserData
            {

                multipart.add(key:userItem.key, value:userItem.value)

            }

        }

        multipart.add(key:          "file",
                      fileName:     localMultipartRequestInfo!.sAppSourceFilename,
                      fileMimeType: localMultipartRequestInfo!.sAppFileMimeType,
                      fileData:     (localMultipartRequestInfo?.dataAppFile)!)

        // Create a regular HTTP URL request & use multipart components:

        let url     = URL(string:localMultipartRequestInfo!.sAppUploadURL)!
        var request = URLRequest(url:url)

        request.httpMethod     = "POST"
        request.httpBody       = multipart.httpBody

        let listRequestHeaders =
        [
        //  "Content-Type":        "multipart/form-data; boundary=\(sFormBoundary)",
            "appOrigin":           "\(AppGlobalInfo.sGlobalInfoAppId)",
            "appUploadNotifyFrom": localMultipartRequestInfo!.sAppUploadNotifyFrom,
            "appUploadNotifyTo":   localMultipartRequestInfo!.sAppUploadNotifyTo,
            "appUploadNotifyCc":   localMultipartRequestInfo!.sAppUploadNotifyCc,
            "appSourceFilespec":   localMultipartRequestInfo!.sAppSourceFilespec,
            "appSourceFilename":   localMultipartRequestInfo!.sAppSourceFilename,
            "appZipFilename":      localMultipartRequestInfo!.sAppZipFilename,
            "appSaveAsFilename":   localMultipartRequestInfo!.sAppSaveAsFilename,
            "appFileMimeType":     localMultipartRequestInfo!.sAppFileMimeType,
            "Accept":              "*/*",
        //  "accept-encoding":     "gzip, deflate",
            "cache-control":       "no-cache"
        ]

        request.allHTTPHeaderFields = listRequestHeaders

        request.setValue(multipart.httpContentTypeHeaderValue, forHTTPHeaderField:"Content-Type")

        // Call URLSession with the 'request':

        var sMultipartHttpBodyData:String = String(data:multipart.httpBody, encoding:.utf8) ?? "-N/A-"

        if (sMultipartHttpBodyData.count < 1)
        {

            sMultipartHttpBodyData = "-empty-"

        }
        else
        {

            if (sMultipartHttpBodyData.count > 2000)
            {

                sMultipartHttpBodyData = sMultipartHttpBodyData.subString(startIndex: 0, length: 2000)

            }

        }

        appLogMsg("\(sCurrMethodDisp) Using 'localMultipartRequestInfo' of [\(String(describing: localMultipartRequestInfo?.toString()))]...")
        appLogMsg("\(sCurrMethodDisp) Using 'url'                       of [\(url)]...")
        appLogMsg("\(sCurrMethodDisp) Using 'multipart'                 of [\(multipart)]...")
        appLogMsg("\(sCurrMethodDisp) Using 'multipart.httpBody'        of [\(String(describing: sMultipartHttpBodyData))]...")
        appLogMsg("\(sCurrMethodDisp) Using 'request.httpMethod'        of [\(String(describing: request.httpMethod))]...")
        appLogMsg("\(sCurrMethodDisp) Using 'request.headers'           of [\(String(describing: request.allHTTPHeaderFields))]...")
        appLogMsg("\(sCurrMethodDisp) Using 'request.httpBody'          of [\(String(describing: request.httpBody))]...")

        localMultipartRequestInfo?.urlResponse     = nil
        localMultipartRequestInfo?.urlResponseData = nil

        do
        {

            let (urlResponseData, urlResponse) = try await URLSession.shared.data(for:request)

            localMultipartRequestInfo!.urlResponse     = urlResponse as? HTTPURLResponse
            localMultipartRequestInfo!.urlResponseData = urlResponseData

            appLogMsg("\(sCurrMethodDisp) Returned HTTP 'url' StatusCode is (\(localMultipartRequestInfo!.urlResponse!.statusCode))...")
            appLogMsg("\(sCurrMethodDisp) Returned 'url' Response DATA was [\(String(data:localMultipartRequestInfo!.urlResponseData!, encoding:.utf8)!)]...")

            var iUrlStatusCode:Int = 0

            if ((localMultipartRequestInfo!.urlResponse?.statusCode) != nil)
            {

                // If we have a 'statusCode', flatten it to an Int to avoid using String(describing:)...

                iUrlStatusCode = localMultipartRequestInfo!.urlResponse!.statusCode

            }
            else
            {

                iUrlStatusCode = -1

            }

            var sUploadAlertDetails:String = "Status [\(iUrlStatusCode)]"

            if (self.bGenerateResponseLongMsg == true)
            {

                sUploadAlertDetails = "Status [\(iUrlStatusCode)] Response [\(String(data:localMultipartRequestInfo!.urlResponseData!, encoding:.utf8)!)]"

            }

            let sAppUploadedSaveAsFilename:String = localMultipartRequestInfo?.sAppSaveAsFilename ?? "-unknown-"

            if (self.bAlertIsBypassed == false)
            {

                DispatchQueue.main.async
                {

                    self.jmAppDelegateVisitor.setAppDelegateVisitorSignalGlobalAlert("Alert::App file [\(sAppUploadedSaveAsFilename)] has been 'uploaded' - [\(sUploadAlertDetails)]...",
                                                                                     alertButtonText:"Ok")

                }

                appLogMsg("\(sCurrMethodDisp) Triggered an upload completed 'Alert' - Details: [\(sUploadAlertDetails)]...")

            }
            else
            {

                appLogMsg("\(sCurrMethodDisp) Bypassed an upload completed 'Alert' - But these are the Details: [\(sUploadAlertDetails)]...")

            }

        }
        catch
        {

            appLogMsg("\(sCurrMethodDisp) URLSession invocation threw a try/catch 'Error' - Severe Error!")

        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func processMultipartRequest().

}   // End of class MultipartRequestDriver(NSObject).
