//
//  MultipartZipFileCreator.swift
//  JustAMultipartRequestTest1
//
//  Created by JustMacApps.net on 09/10/2024.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import Foundation
import SwiftUI

class MultipartZipFileCreator:NSObject
{

    struct ClassInfo
    {
        
        static let sClsId          = "MultipartZipFileCreator"
        static let sClsVers        = "v1.0301"
        static let sClsDisp        = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight   = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace       = true
        static let bClsFileLog     = true
        
    }

    // App Data field(s):

    private var bInternalTest:Bool                        = false
    private var bInternalZipTest:Bool                     = true
    private let bGenerateInternalTextFiles:Bool           = true

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

    public func createTargetZipFileFromSource(multipartRequestInfo:MultipartRequestInfo)->URL?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'multipartRequestInfo' is [\(multipartRequestInfo.toString())]...")

        var urlCreatedZipFile:URL?                    = nil     // URL of the Zip file (created)...
    //  let urlForZipOperationsSource:URL             = URL(string:multipartRequestInfo.sAppSourceFilespec)!
    //  let urlForZipOperationsTarget:URL             = URL(string:multipartRequestInfo.sAppZipFilename)!
        let urlForZipOperationsSource:URL             = URL(fileURLWithPath:multipartRequestInfo.sAppSourceFilespec)
        let urlForZipOperationsTarget:URL             = URL(fileURLWithPath:multipartRequestInfo.sAppZipFilename)
        var sForZipOperationsSourceFilespec:String    = urlForZipOperationsSource.path
        let sForZipOperationsTargetFilename:String    = urlForZipOperationsTarget.path

        // Check that we have a 'target' file (string) that is NOT nil...

        if (sForZipOperationsTargetFilename.count < 1)
        {
            appLogMsg("\(sCurrMethodDisp) Unable to Zip the 'source' filespec of [\(String(describing: sForZipOperationsSourceFilespec))] - the 'target' Zip filename is 'nil' - Error!")

            // Exit:

            urlCreatedZipFile = nil

            appLogMsg("\(sCurrMethodDisp) Exiting - 'urlCreatedZipFile' is [\(String(describing: urlCreatedZipFile))]...")

            return urlCreatedZipFile
        }

        // Check that we have a 'source' file to zip (or if 'testing' make sure we have one)...

        let bIsForZipOperationsSourceFilePresent:Bool = JmFileIO.fileExists(sFilespec:sForZipOperationsSourceFilespec)

        if (bIsForZipOperationsSourceFilePresent == true)
        {
            appLogMsg("\(sCurrMethodDisp) Preparing to Zip the 'source' filespec of [\(String(describing: sForZipOperationsSourceFilespec))]...")
        }
        else
        {
            if (self.bGenerateInternalTextFiles == false)
            {
                appLogMsg("\(sCurrMethodDisp) Unable to Zip the 'source' filespec of [\(String(describing: sForZipOperationsSourceFilespec))] - the file does NOT Exist - Error!")

                // Exit:

                urlCreatedZipFile = nil

                appLogMsg("\(sCurrMethodDisp) Exiting - 'urlCreatedZipFile' is [\(String(describing: urlCreatedZipFile))]...")

                return urlCreatedZipFile
            } 
            else
            {
                do 
                {
                    let urlForZipOperationsFilepath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask ,appropriateFor: nil, create: true)
                    let urlForZipOperationsFilespec = urlForZipOperationsFilepath.appendingPathComponent("Test-for-Zip_1.txt")
                    let sForZipOperationsFilespec   = urlForZipOperationsFilespec.path
                    let sForZipOperationsFilepath   = urlForZipOperationsFilepath.path

                    appLogMsg("\(sCurrMethodDisp) 'sForZipOperationsFilespec' (computed) is [\(String(describing: sForZipOperationsFilespec))]...")
                    appLogMsg("\(sCurrMethodDisp) 'sForZipOperationsFilepath' (resolved #1) is [\(String(describing: sForZipOperationsFilepath))]...")

                    let bIsForZipOperationsFilePresent:Bool = JmFileIO.fileExists(sFilespec:sForZipOperationsFilespec)

                    if (bIsForZipOperationsFilePresent == true)
                    {
                        appLogMsg("\(sCurrMethodDisp) Zipping the 'source' Filespec of [\(String(describing: sForZipOperationsFilespec))]...")

                        sForZipOperationsSourceFilespec = sForZipOperationsFilespec
                    }
                    else
                    {
                        try FileManager.default.createDirectory(atPath: sForZipOperationsFilepath, withIntermediateDirectories: true, attributes: nil)

                        let sGeneratedFileContents:String = "\(sCurrMethodDisp) Invoked - 'sApplicationName' is [\(AppGlobalInfo.sGlobalInfoAppId)] - 'self' is [\(self)]...\r\nThis is an 'auto' generated file used for 'testing'..."

                        try sGeneratedFileContents.write(toFile: sForZipOperationsFilespec, atomically:true, encoding:String.Encoding.utf8)

                        appLogMsg("\(sCurrMethodDisp) Successfully created the 'path' of [.documentDirectory] and the 'source' filespec of [\(String(describing: sForZipOperationsFilespec))]...")

                        sForZipOperationsSourceFilespec = sForZipOperationsFilespec
                    }
                }
                catch
                {
                    appLogMsg("\(sCurrMethodDisp) Failed to create the 'path' of [.documentDirectory] - Details: \(error) - Error!")

                    // Exit:

                    urlCreatedZipFile = nil

                    appLogMsg("\(sCurrMethodDisp) Exiting - 'urlCreatedZipFile' is [\(String(describing: urlCreatedZipFile))]...")

                    return urlCreatedZipFile
                }
            }
        }

        // Zip the 'source' file to the 'target' Zip file...

        appLogMsg("\(sCurrMethodDisp) Zipping the 'source' filespec of [\(String(describing: sForZipOperationsSourceFilespec))] as a URL 'urlForZipOperationsSource' of [\(urlForZipOperationsSource)] to the 'target' Zip filename of [\(sForZipOperationsTargetFilename)]...")

        do
        {
            let urlForSourceFilespec:URL?                       = urlForZipOperationsSource
        //  let urlForTargetZipFile:URL?                        = FileManager.default.temporaryDirectory
        //                                                            .appendingPathComponent(sForZipOperationsTargetFilename)
            let multipartZipFileService:MultipartZipFileService = MultipartZipFileService()

            let urlForTmpZipFile:URL = 
                try multipartZipFileService.createZipAtTmp(zipFilename: sForZipOperationsTargetFilename, 
                                                           zipExtension:"zip", 
                                                           filesToZip:  [ZipFileDetails.existingFile(urlForSourceFilespec!)])

            multipartRequestInfo.dataAppFile      = try Data(contentsOf:urlForTmpZipFile)
            multipartRequestInfo.sAppFileMimeType = "application/zip"

            urlCreatedZipFile                     = urlForTmpZipFile
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) <do/catch> Failed to create the 'target' Zip file [\(sForZipOperationsTargetFilename)] - Details: [\(error)] - Error!")

            // Exit:

            urlCreatedZipFile = nil

            appLogMsg("\(sCurrMethodDisp) Exiting - 'urlCreatedZipFile' is [\(String(describing: urlCreatedZipFile))]...")

            return urlCreatedZipFile
        }

        // Check if we actually got the 'target' Zip file created...

        if let urlCreatedZipFile = urlCreatedZipFile 
        {
            appLogMsg("\(sCurrMethodDisp) Produced a Zip file 'urlCreatedZipFile' of [\(urlCreatedZipFile)]...")
        } 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) Failed to produce a Zip file - the 'target' Zip filename was [\(sForZipOperationsTargetFilename)] - Error!")

            urlCreatedZipFile = nil
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'urlCreatedZipFile' is [\(String(describing: urlCreatedZipFile))]...")

        return urlCreatedZipFile

    }   // End of func createTargetZipFileFromSource().

}   // End of class MultipartZipFileCreator:NSObject.

