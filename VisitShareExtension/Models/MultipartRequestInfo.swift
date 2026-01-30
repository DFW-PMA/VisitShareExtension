//
//  MultipartRequestInfo.swift
//  JustAMultipartRequest
//
//  Created by JustMacApps.net on 09/10/2024.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import Foundation

@available(iOS 14.0, *)
class MultipartRequestInfo:NSObject
{

    struct ClassInfo
    {
        static let sClsId          = "MultipartRequestInfo"
        static let sClsVers        = "v1.0301"
        static let sClsDisp        = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight   = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace       = true
        static let bClsFileLog     = true
    }

    // App Data field(s):

    public var bAppZipSourceToUpload:Bool         = false     // This is a 'flag' to indicate to Zip the Data or not...
    public var sAppUploadURL:String               = ""        // This is an 'override' Upload URL...
                                                              // Email address may be a list - string(s) separated by ';'...
    public var sAppUploadNotifyFrom:String        = ""        // This should be an email address - 'From:' field...
    public var sAppUploadNotifyTo:String          = ""        // This should be an email address - 'To:' field...
    public var sAppUploadNotifyCc:String          = ""        // This should be an email address - 'Cc:' field...

    public var sAppSourceFilespec:String          = ""        // This is the fully-qualified filespec...
    public var sAppSourceFilename:String          = ""        // This is 'just' the filename...
    public var sAppZipFilename:String             = ""        // This is 'just' the filename of the Zip (if zipped)...
    public var sAppSaveAsFilename:String          = ""        // This is 'just' the filename to save the upload file as...

    public var sAppFileMimeType:String            = ""        // This required for successfull upload...
    public var dataAppFile:Data?                  = nil       // This is the Data (object) of the upload...

    public var urlResponse:HTTPURLResponse?       = nil       // This is the 'response' URL...
    public var urlResponseData:Data?              = nil       // This is the 'response' Data...

    var jmAppDelegateVisitor:JmAppDelegateVisitor = JmAppDelegateVisitor.ClassSingleton.appDelegateVisitor

    override init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        super.init()
        
        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of override init().

    public func toString()->String
    {

        var asToString:[String] = Array()

        asToString.append("[")
        asToString.append("[")
        asToString.append("'sClsId': [\(ClassInfo.sClsId)],")
        asToString.append("'sClsVers': [\(ClassInfo.sClsVers)],")
        asToString.append("'sClsDisp': [\(ClassInfo.sClsDisp)],")
        asToString.append("'sClsCopyRight': [\(ClassInfo.sClsCopyRight)],")
        asToString.append("'bClsTrace': [\(ClassInfo.bClsTrace)],")
        asToString.append("'bClsFileLog': [\(ClassInfo.bClsFileLog)],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("'self.bAppZipSourceToUpload': (\(self.bAppZipSourceToUpload)),")
        asToString.append("'self.sAppUploadURL': (\(self.sAppUploadURL)),")
        asToString.append("'self.sAppUploadNotifyFrom': (\(self.sAppUploadNotifyFrom)),")
        asToString.append("'self.sAppUploadNotifyTo': (\(self.sAppUploadNotifyTo)),")
        asToString.append("'self.sAppUploadNotifyCc': (\(self.sAppUploadNotifyCc)),")
        asToString.append("'self.sAppSourceFilespec': (\(self.sAppSourceFilespec)),")
        asToString.append("'self.sAppSourceFilename': (\(self.sAppSourceFilename)),")
        asToString.append("'self.sAppZipFilename': (\(self.sAppZipFilename)),")
        asToString.append("'self.sAppSaveAsFilename': (\(self.sAppSaveAsFilename)),")
        asToString.append("'self.sAppFileMimeType': (\(self.sAppFileMimeType)),")
        asToString.append("'self.dataAppFile': (\(String(describing: self.dataAppFile))),")
        asToString.append("],")
        asToString.append("[")
        asToString.append("'urlResponse': (\(String(describing: self.urlResponse))),")
        asToString.append("'urlResponseData': (\(String(describing: self.urlResponseData))),")
        asToString.append("],")
        asToString.append("]")

        let sContents:String = "{"+(asToString.joined(separator:""))+"}"

        return sContents

    }   // End of public func toString().

}   // End of class MultipartRequestInfo:NSObject.

