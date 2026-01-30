//
//  JmAppMetricKitManager.swift
//  JmUtils_Library
//
//  Created by Daryl Cox on 10/02/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import MetricKit

// Implementation class to handle access to the Apple MetricKit.

public class JmAppMetricKitManager: NSObject, MXMetricManagerSubscriber
{

    struct ClassInfo
    {

        static let sClsId        = "JmAppMetricKitManager"
        static let sClsVers      = "v1.0701"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = false

    }   // End of struct ClassInfo.

    // App Data field(s):

    private var jmMetricManager:MXMetricManager            = MXMetricManager.shared

            var jmAppDelegateVisitor:JmAppDelegateVisitor? = nil
                                                             // 'jmAppDelegateVisitor' MUST remain declared this way
                                                             // as having it reference the 'shared' instance of 
                                                             // JmAppDelegateVisitor causes a circular reference
                                                             // between the 'init()' methods of the 2 classes...

    // App <global> Message(s) 'stack' cached before XCGLogger is available:

            var listPreXCGLoggerMessages:[String]          = Array()

    override init()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        super.init()

        appLogMsg("\(sCurrMethodDisp) Invoked - 'jmMetricManager' is [\(jmMetricManager)] - 'jmAppDelegateVisitor' is [\(String(describing: self.jmAppDelegateVisitor))]...")

        // Add 'self' to the MXMetricManager as a 'subscriber'...

        self.jmMetricManager.add(self)

        appLogMsg("\(sCurrMethodDisp) Added 'self' to 'jmMetricManager' instance as a 'subscriber'...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'jmMetricManager' is [\(jmMetricManager)] - 'jmAppDelegateVisitor' is [\(String(describing: self.jmAppDelegateVisitor))]...")

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
        asToString.append("'bClsFileLog': [\(ClassInfo.bClsFileLog)]")
        asToString.append("],")
        asToString.append("[")
        asToString.append("'jmMetricManager': [\(self.jmMetricManager)],")
        asToString.append("],")
        asToString.append("]")

        let sContents:String = "{"+(asToString.joined(separator: ""))+"}"

        return sContents

    }   // End of public func toString().

    // (Call-back) Method to set the jmAppDelegateVisitor instance...

    public func setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:JmAppDelegateVisitor)
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - supplied parameter 'jmAppDelegateVisitor' is [\(jmAppDelegateVisitor)]...")

        // Set the AppDelegateVisitor instance...

        self.jmAppDelegateVisitor = jmAppDelegateVisitor
    
        // Spool <any> pre-XDGLogger (via the AppDelegateVisitor) message(s) into the Log...

        if (self.listPreXCGLoggerMessages.count > 0)
        {

            appLogMsg("")
            appLogMsg("\(sCurrMethodDisp) <<< === Spooling the JmAppDelegateVisitor.XCGLogger 'pre' Message(s) from JmAppMetricKitManager === >>>")

            let sPreXCGLoggerMessages:String = self.listPreXCGLoggerMessages.joined(separator: "\n")

            appLogMsg(sPreXCGLoggerMessages)

            appLogMsg("\(sCurrMethodDisp) <<< === Spooled  the JmAppDelegateVisitor.XCGLogger 'pre' Message(s) from JmAppMetricKitManager === >>>")
            appLogMsg("")

        }
    
        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'self.jmAppDelegateVisitor' is [\(String(describing: self.jmAppDelegateVisitor))]...")
    
        return

    } // End of public func setJmAppDelegateVisitorInstance().

    // Method(s) to 'receive' and 'pause' Report(s)...

    public func receiveReports()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Add 'self' (again) to the MXMetricManager as a 'subscriber' to 'receive' Report(s)...

        self.jmMetricManager.add(self)

        appLogMsg("\(sCurrMethodDisp) Added 'self' to 'jmMetricManager' instance as a 'subscriber' (again) to 'receive' report(s)...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func receiveReports().

    public func pauseReports()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Remove 'self' from the MXMetricManager as a 'subscriber' to 'pause' Report(s)...

        self.jmMetricManager.remove(self)

        appLogMsg("\(sCurrMethodDisp) Removed 'self' from 'jmMetricManager' instance as a 'subscriber' to 'pause' report(s)...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func pauseReports().

    // Method(s) to 'receive' and handle MXMetricManager 'payload(s)'...

#if os(iOS)

    // MXMetricPayload is ONLY available under Mac Catalyst 13.1+ (not MacOS):

    public func didReceive(_ payloads: [MXMetricPayload])
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"<MXMetricPayload>':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Handle the payload list by looping to convert the item(s) into string(s) to be able to 'upload'...

        if (AppGlobalInfo.bAppMetricKitManagerSendMetrics == true)
        {
        
            var listPayloadAttachmentsJSON:[String]   = []
            var listPayloadAttachmentsBase64:[String] = []

            if (payloads.count > 0)
            {

                for payload in payloads
                {

                    let sPayloadAttachmentJSON:String   = String(decoding:payload.jsonRepresentation(), as:UTF8.self)
                    let sPayloadAttachmentBase64:String = payload.jsonRepresentation().base64EncodedString()

                    listPayloadAttachmentsJSON.append(sPayloadAttachmentJSON)
                    listPayloadAttachmentsBase64.append(sPayloadAttachmentBase64)

                }

                appLogMsg("\(sCurrMethodDisp) Supplied 'payload' list was converted to JSON 'data' string(s) as [\(listPayloadAttachmentsJSON)]...")
                appLogMsg("\(sCurrMethodDisp) Supplied 'payload' list was converted to Base64 'upload' string(s) as [\(listPayloadAttachmentsBase64)]...")

                // ...this is where we'd 'upload' this data and email it...

                self.sendMXPayloadViaEmail(listPayloadAttachments:listPayloadAttachmentsJSON, sPayloadTag:"MXMetricPayload")

            }
            else
            {

                appLogMsg("\(sCurrMethodDisp) Supplied 'payload' list was Empty - no action was taken...")

            }
        
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func didReceive(_ payloads: [MXMetricPayload]).

#endif

    public func didReceive(_ payloads: [MXDiagnosticPayload])
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"<MXDiagnosticPayload>':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Handle the payload list by looping to convert the item(s) into string(s) to be able to 'upload'...

        if (AppGlobalInfo.bAppMetricKitManagerSendDiagnostics == true)
        {
        
            var listPayloadAttachmentsJSON:[String]   = []
            var listPayloadAttachmentsBase64:[String] = []

            if (payloads.count > 0)
            {

                for payload in payloads
                {

                    let sPayloadAttachmentJSON:String   = String(decoding:payload.jsonRepresentation(), as:UTF8.self)
                    let sPayloadAttachmentBase64:String = payload.jsonRepresentation().base64EncodedString()

                    listPayloadAttachmentsJSON.append(sPayloadAttachmentJSON)
                    listPayloadAttachmentsBase64.append(sPayloadAttachmentBase64)

                }

                appLogMsg("\(sCurrMethodDisp) Supplied 'payload' list was converted to JSON 'data' string(s) as [\(listPayloadAttachmentsJSON)]...")
                appLogMsg("\(sCurrMethodDisp) Supplied 'payload' list was converted to Base64 'upload' string(s) as [\(listPayloadAttachmentsBase64)]...")

                // ...this is where we'd 'upload' this data and email it...

                self.sendMXPayloadViaEmail(listPayloadAttachments:listPayloadAttachmentsJSON, sPayloadTag:"MXDiagnosticPayload")

            }
            else
            {

                appLogMsg("\(sCurrMethodDisp) Supplied 'payload' list was Empty - no action was taken...")

            }
        
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func didReceive(_ payloads: [MXDiagnosticPayload]).

    private func sendMXPayloadViaEmail(listPayloadAttachments:[String], sPayloadTag:String)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'listPayloadAttachments' has (\(listPayloadAttachments.count)) element(s) with 'sPayloadTag' of [\(sPayloadTag)]...")

        // If there were supplied 'payload' String(s), convert to a single String and upload the data...

        if (listPayloadAttachments.count > 0)
        {

            let sPayloadAttachments:String = listPayloadAttachments.joined(separator: "")

            appLogMsg("\(sCurrMethodDisp) Supplied 'listPayloadAttachments' list was converted into an 'upload' string of (\(sPayloadAttachments.count)) byte(s)...")

            var sPayloadType:String = sPayloadTag

            if (sPayloadType.count < 1)
            {

                sPayloadType = "UnTaggedData"

            }

            let sPayloadFilenameExt:String = "MXPayload.\(sPayloadType).json"

            appLogMsg("\(sCurrMethodDisp) Sending an 'upload' string of (\(sPayloadAttachments.count)) byte(s) with a 'sPayloadFilenameExt' of [\(sPayloadFilenameExt)]...")

            self.jmAppDelegateVisitor?.appDelegateVisitorSendSilentUpload("dcox@justmacapps.net",
                                                                          emailAddressCc:"",  
                                                                          emailSourceFilespec:sPayloadFilenameExt,
                                                                          emailSourceFilename:sPayloadFilenameExt,
                                                                          emailZipFilename:"",
                                                                          emailSaveAsFilename:sPayloadFilenameExt,
                                                                          emailFileMimeType:"",
                                                                          emailFileData:Data(sPayloadAttachments.utf8) as NSData)

            appLogMsg("\(sCurrMethodDisp) Sent    an 'upload' string of (\(sPayloadAttachments.count)) byte(s) with a 'sPayloadFilenameExt' of [\(sPayloadFilenameExt)]...")

        }
        else
        {

            appLogMsg("\(sCurrMethodDisp) Supplied 'listPayloadAttachments' list was Empty - no action was taken...")

        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func sendMXPayloadViaEmail(listPayloadAttachments:[String]).

}   // End of public class JmAppMetricKitManager.

