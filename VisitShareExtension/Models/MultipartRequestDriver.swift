//
//  MultipartRequestDriver.swift
//  JustAMultipartRequest
//
//  Created by JustMacApps.net on 09/10/2024.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
class MultipartRequestDriver:NSObject
{

    struct ClassInfo
    {
        static let sClsId          = "MultipartRequestDriver"
        static let sClsVers        = "v1.0901"
        static let sClsDisp        = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight   = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace       = true
        static let bClsFileLog     = true
    }

    // App Data field(s):

    private var bInternalTest:Bool                         = false
    private var bGenerateResponseLongMsg:Bool              = false
    private var bAlertIsBypassed                           = false

                                                             // For 'test':
    private var dictUserData:[String:String]               = ["firstName": "John",
                                                              "lastName":  "Doe"
                                                             ]

    private var multipartRequestInfo:MultipartRequestInfo? = nil

    public  var urlResponse:HTTPURLResponse?               = nil
    public  var urlResponseData:Data?                      = nil

            var jmAppDelegateVisitor:JmAppDelegateVisitor  = JmAppDelegateVisitor.ClassSingleton.appDelegateVisitor

    override init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        super.init()
        
        self.bGenerateResponseLongMsg = false
        self.bAlertIsBypassed         = false

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of override init().

    convenience init(bGenerateResponseLongMsg:Bool, bAlertIsBypassed:Bool = false)
    {
    
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'bGenerateResponseLongMsg' is [\(bGenerateResponseLongMsg)] and 'bAlertIsBypassed' is [\(bAlertIsBypassed)]...")

        self.init()
        
        self.bGenerateResponseLongMsg = bGenerateResponseLongMsg
        self.bAlertIsBypassed         = bAlertIsBypassed

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting - 'self.bGenerateResponseLongMsg' is [\(self.bGenerateResponseLongMsg)] - 'self.bAlertIsBypassed' is [\(self.bAlertIsBypassed)]...")

        return
    
    }   // End of convenience init(bGenerateResponseLongMsg:Bool, bAlertIsBypassed:Bool).

    public func executeMultipartRequest(multipartRequestInfo:MultipartRequestInfo? = nil)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Process the Multipart Request on a background thread:

        let dispatchGroup = DispatchGroup()

        do
        {
            dispatchGroup.enter()

            let dispatchQueue = DispatchQueue(label: "MultipartRequestBackgroundThread", qos: .userInitiated)

            dispatchQueue.async
            {
                appLogMsg("\(sCurrMethodDisp) Calling 'processMultipartRequest()' with a 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo))]...")
                
                Task
                {
                    await self.processMultipartRequest(multipartRequestInfo:multipartRequestInfo)
                }

                appLogMsg("\(sCurrMethodDisp) Called  'processMultipartRequest()' with a 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo))]...")
            }

            dispatchGroup.leave()
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func executeMultipartRequest(multipartRequestInfo:MultipartRequestInfo?).

    public func processMultipartRequest(multipartRequestInfo:MultipartRequestInfo? = nil) async
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Determine if this is a 'test' or not:

        self.bInternalTest = false

        if (multipartRequestInfo == nil)
        {
            self.bInternalTest        = true
            self.multipartRequestInfo = nil
        }
        else
        {
            self.bInternalTest        = false
            self.multipartRequestInfo = multipartRequestInfo
        }

        // Create the Multipart 'request':

        var multipart = MultipartRequest()

        if (self.multipartRequestInfo == nil)
        {
            self.bInternalTest                               = true
            self.multipartRequestInfo                        = MultipartRequestInfo()

            self.multipartRequestInfo?.bAppZipSourceToUpload = false
            self.multipartRequestInfo?.sAppUploadURL         = ""                       // "" takes the Upload URL 'default'...
            self.multipartRequestInfo?.sAppUploadNotifyFrom  = "dcox@justmacapps.net"
            self.multipartRequestInfo?.sAppUploadNotifyTo    = "dcox@justmacapps.org"
            self.multipartRequestInfo?.sAppUploadNotifyCc    = "dcox@justmacapps.net"
            self.multipartRequestInfo?.sAppSourceFilespec    = "test1.txt"
            self.multipartRequestInfo?.sAppSourceFilename    = "test1.txt"
            self.multipartRequestInfo?.sAppZipFilename       = "test1.zip"
            self.multipartRequestInfo?.sAppSaveAsFilename    = "test1.data"
            self.multipartRequestInfo?.sAppFileMimeType      = "text/plain"
            self.multipartRequestInfo?.dataAppFile           = "test1-text-data".data(using:.utf8)
        }

        if (self.multipartRequestInfo?.sAppUploadURL == nil ||
            (self.multipartRequestInfo?.sAppUploadURL.count)! < 1)
        {
        //  self.multipartRequestInfo?.sAppUploadURL = "http://localhost/dfwpma/file_uploads"
            self.multipartRequestInfo?.sAppUploadURL = "http://justmacapps.net/dfwpma/file_uploads"
        }

        if (self.bInternalTest == true)
        {
            for userItem in self.dictUserData
            {
                multipart.add(key:userItem.key, value:userItem.value)
            }
        }

        multipart.add(key:          "file",
                      fileName:     self.multipartRequestInfo!.sAppSourceFilename,
                      fileMimeType: self.multipartRequestInfo!.sAppFileMimeType,
                      fileData:     (self.multipartRequestInfo?.dataAppFile)!)

        // Create a regular HTTP URL request & use multipart components:

        let url     = URL(string:self.multipartRequestInfo!.sAppUploadURL)!
        var request = URLRequest(url:url)

        request.httpMethod     = "POST"
        request.httpBody       = multipart.httpBody

        let listRequestHeaders =
        [
        //  "Content-Type":        "multipart/form-data; boundary=\(sFormBoundary)",
            "appOrigin":           "\(AppGlobalInfo.sGlobalInfoAppId)",
            "appUploadNotifyFrom": self.multipartRequestInfo!.sAppUploadNotifyFrom,
            "appUploadNotifyTo":   self.multipartRequestInfo!.sAppUploadNotifyTo,
            "appUploadNotifyCc":   self.multipartRequestInfo!.sAppUploadNotifyCc,
            "appSourceFilespec":   self.multipartRequestInfo!.sAppSourceFilespec,
            "appSourceFilename":   self.multipartRequestInfo!.sAppSourceFilename,
            "appZipFilename":      self.multipartRequestInfo!.sAppZipFilename,
            "appSaveAsFilename":   self.multipartRequestInfo!.sAppSaveAsFilename,
            "appFileMimeType":     self.multipartRequestInfo!.sAppFileMimeType,
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

        appLogMsg("\(sCurrMethodDisp) Using 'self.multipartRequestInfo' of [\(String(describing: self.multipartRequestInfo?.toString()))]...")
        appLogMsg("\(sCurrMethodDisp) Using 'url'                       of [\(url)]...")
        appLogMsg("\(sCurrMethodDisp) Using 'multipart'                 of [\(multipart)]...")
        appLogMsg("\(sCurrMethodDisp) Using 'multipart.httpBody'        of [\(String(describing: sMultipartHttpBodyData))]...")
        appLogMsg("\(sCurrMethodDisp) Using 'request.httpMethod'        of [\(String(describing: request.httpMethod))]...")
        appLogMsg("\(sCurrMethodDisp) Using 'request.headers'           of [\(String(describing: request.allHTTPHeaderFields))]...")
        appLogMsg("\(sCurrMethodDisp) Using 'request.httpBody'          of [\(String(describing: request.httpBody))]...")

        self.urlResponse                           = nil
        self.urlResponseData                       = nil

        self.multipartRequestInfo?.urlResponse     = nil
        self.multipartRequestInfo?.urlResponseData = nil

        do
        {
            let (urlResponseData, urlResponse) = try await URLSession.shared.data(for:request)

            self.urlResponse     = urlResponse as? HTTPURLResponse
            self.urlResponseData = urlResponseData

            appLogMsg("\(sCurrMethodDisp) Returned HTTP 'url' StatusCode is (\(self.urlResponse!.statusCode))...")
            appLogMsg("\(sCurrMethodDisp) Returned 'url' Response DATA was [\(String(data:self.urlResponseData!, encoding:.utf8)!)]...")

            self.multipartRequestInfo!.urlResponse     = self.urlResponse
            self.multipartRequestInfo!.urlResponseData = self.urlResponseData

            var iUrlStatusCode:Int = 0

            if ((self.multipartRequestInfo!.urlResponse?.statusCode) != nil)
            {
                // If we have a 'statusCode', flatten it to an Int to avoid using String(describing:)...

                iUrlStatusCode = self.multipartRequestInfo!.urlResponse!.statusCode
            }
            else
            {
                iUrlStatusCode = -1
            }

            var sUploadAlertDetails:String = "Status [\(iUrlStatusCode)]"

            if (self.bGenerateResponseLongMsg == true)
            {
                sUploadAlertDetails = "Status [\(iUrlStatusCode)] Response [\(String(data:self.multipartRequestInfo!.urlResponseData!, encoding:.utf8)!)]"
            }

            let sAppUploadedSaveAsFilename:String = self.multipartRequestInfo?.sAppSaveAsFilename ?? "-unknown-"

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

    }   // End of public func processMultipartRequest(multipartRequestInfo:MultipartRequestInfo?) async.

}   // End of class MultipartRequestDriver:NSObject.

