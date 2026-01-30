//
//  MultipartZipFileService.swift
//  JustAMultipartRequestTest1
//
//  Created by JustMacApps.net on 11/06/2024.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import Foundation

// Enum(s):

enum ZipServiceError:Swift.Error 
{
    case urlNotADirectory(URL)
    case failedToCreateZIP(Swift.Error)
    case failedToGetDataFromZipURL
}

enum ZipFileDetails 
{
    case data(Data, filename:String)
    case existingFile(URL)
    case renamedFile(URL, toFilename:String)
}

// Extension(s):

extension URL 
{

    var isDirectory:Bool 
    {
       (try? resourceValues(forKeys:[.isDirectoryKey]))?.isDirectory == true
    }

}   // End of extension URL.

extension ZipFileDetails 
{

    static func text(_ text:String, filename:String)->ZipFileDetails 
    {

        .data(text.data(using: .utf8) ?? Data(), filename: filename)

    }   // End of static func text(_ text:String, filename:String)->ZipFileDetails

}   // End of extension ZipFileDetails.

extension ZipFileDetails 
{

    func prepareInDirectory(directoryURL:URL) throws 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "Extension<ZipFileDetails>.'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'directoryURL' is [\(directoryURL)]...")

        switch self 
        {
        case .data(let data, filename:let filename):

            let fileURL = directoryURL.appendingPathComponent(filename)

            appLogMsg("\(sCurrMethodDisp) <case .data> Writing .data to 'fileURL' is [\(fileURL)]...")

            try data.write(to:fileURL)
        case .existingFile(let existingFileURL):
            let filename                      = existingFileURL.lastPathComponent
            let newFileURL                    = directoryURL.appendingPathComponent(filename)
            let sTargetFilespec:String        = newFileURL.path
            let bIsTargetFilespecPresent:Bool = JmFileIO.fileExists(sFilespec:sTargetFilespec)

            if (bIsTargetFilespecPresent == true)
            {
                appLogMsg("\(sCurrMethodDisp) <case .existingFile> 'target' file [\(String(describing: sTargetFilespec))] exists - deleting it...")

                try FileManager.default.removeItem(at:newFileURL)

                appLogMsg("\(sCurrMethodDisp) <case .existingFile> Successfully removed the 'target' URL of [\(String(describing: newFileURL))]...")
            }

            appLogMsg("\(sCurrMethodDisp) <case .existingFile> Copying 'existingFileURL' of [\(existingFileURL)] to 'newFileURL' of [\(newFileURL)]...")

            try FileManager.default.copyItem(at:existingFileURL, to:newFileURL)
        case .renamedFile(let existingFileURL, toFilename:let filename):
            let newFileURL = directoryURL.appendingPathComponent(filename)

            appLogMsg("\(sCurrMethodDisp) <case .renamedFile> Copying 'existingFileURL' of [\(existingFileURL)] to 'newFileURL' of [\(newFileURL)]...")

            try FileManager.default.copyItem(at:existingFileURL, to:newFileURL)
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of func prepareInDirectory(directoryURL:URL) throws.

}   // End of extension ZipFileDetails.

// Method(s) - ZIP 'service':

class MultipartZipFileService:NSObject 
{

    struct ClassInfo
    {
        static let sClsId          = "MultipartZipFileService"
        static let sClsVers        = "v1.0401"
        static let sClsDisp        = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight   = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace       = true
        static let bClsFileLog     = true
    }

    // App Data field(s):

            var bShouldOverwriteZipIfNecessary:Bool       = true

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

    public func createZip(zipFinalURL:URL, fromDirectory directoryURL:URL)throws->URL 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'zipFinalURL' is [\(zipFinalURL)] - 'directoryURL' is [\(directoryURL)]...")

        // See URL extension below...

        guard directoryURL.isDirectory 
        else { throw ZipServiceError.urlNotADirectory(directoryURL) }
        
        var fileManagerError:Swift.Error?
        var coordinatorError:NSError?

        let coordinator = NSFileCoordinator()

        coordinator.coordinate(readingItemAt:directoryURL, options:.forUploading, error:&coordinatorError) 
        { zipAccessURL in

            do 
            {
                if (self.bShouldOverwriteZipIfNecessary)
                {
                    let _ = try FileManager.default.replaceItemAt(zipFinalURL, withItemAt:zipAccessURL)
                } 
                else 
                {
                    try FileManager.default.moveItem(at:zipAccessURL, to:zipFinalURL)
                }
            } 
            catch 
            {
                fileManagerError = error

                appLogMsg("\(sCurrMethodDisp) <do/catch> Failed to create the 'target' Zip file [\(zipFinalURL)] - Details: [\(error)] - Error!")
            }
        }

        if let zipServiceError = (coordinatorError ?? fileManagerError)
        {
            throw ZipServiceError.failedToCreateZIP(zipServiceError)
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'zipFinalURL' is [\(String(describing: zipFinalURL))]...")

        return zipFinalURL

    }   // End of public func createZip(zipFinalURL:URL, fromDirectory directoryURL:URL)throws->URL.

    public func createZipAtTmp(zipFilename:String, zipExtension:String="zip", fromDirectory directoryURL:URL)throws->URL 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'zipFilename' is [\(zipFilename)] - 'zipExtension' is [\(zipExtension)] - 'directoryURL' is [\(directoryURL)]...")

        appLogMsg("\(sCurrMethodDisp) Creating the Final 'finalDirectoryToZipURL'...")

        let finalDirectoryToZipURL = FileManager.default.temporaryDirectory.appending(path:zipFilename).appendingPathExtension(zipExtension)

        appLogMsg("\(sCurrMethodDisp) Created  the Final 'finalDirectoryToZipURL' of [\(String(describing: finalDirectoryToZipURL))]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'finalDirectoryToZipURL' is [\(String(describing: finalDirectoryToZipURL))]...")

        return try createZip(zipFinalURL:finalDirectoryToZipURL, fromDirectory:directoryURL)

    }   // End of public func createZipAtTmp(zipFilename:String, zipExtension:String, fromDirectory directoryURL:URL)throws->URL.

    public func createZipAtTmp(zipFilename:String, zipExtension:String="zip", filesToZip:[ZipFileDetails])throws->URL 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'zipFilename' is [\(zipFilename)] - 'zipExtension' is [\(zipExtension)] - 'filesToZip' is [\(filesToZip)]...")

        let directoryToZipURL = FileManager.default.temporaryDirectory.appending(path:UUID().uuidString).appending(path:zipFilename)

        appLogMsg("\(sCurrMethodDisp) Calculated that the Temporary 'directoryToZipURL' is [\(String(describing: directoryToZipURL))]...")

        try FileManager.default.createDirectory(at:directoryToZipURL, withIntermediateDirectories:true, attributes:[:])

        appLogMsg("\(sCurrMethodDisp) Created the Temporary 'directoryToZipURL' of [\(String(describing: directoryToZipURL))]...")

        for zipFileDetails in filesToZip 
        {
            appLogMsg("\(sCurrMethodDisp) Adding the file 'zipFileDetails' of [\(zipFileDetails)] to the Temporary 'directoryToZipURL' of [\(String(describing: directoryToZipURL))]...")

            try zipFileDetails.prepareInDirectory(directoryURL:directoryToZipURL)

            appLogMsg("\(sCurrMethodDisp) Added  the file 'zipFileDetails' of [\(zipFileDetails)] to the Temporary 'directoryToZipURL' of [\(String(describing: directoryToZipURL))]...")
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'directoryToZipURL' is [\(String(describing: directoryToZipURL))]...")

        return try createZipAtTmp(zipFilename:zipFilename, zipExtension:zipExtension, fromDirectory:directoryToZipURL)

    }   // End of public func createZipAtTmp(zipFilename:String, zipExtension:String, filesToZip:[ZipFileDetails])throws->URL.
    
    public func getZipData(zipFilename:String=UUID().uuidString, fromDirectory directoryURL:URL)throws->Data 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'zipFilename' is [\(zipFilename)] - 'directoryURL' is [\(directoryURL)]...")

        let tmpZipURL = try self.createZipAtTmp(zipFilename:zipFilename, fromDirectory:directoryURL)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'tmpZipURL' is [\(tmpZipURL)]...")

        return try self.getZipData(zipFileURL:tmpZipURL)

    }   // End of public func getZipData(zipFilename:String=UUID().uuidString, fromDirectory directoryURL:URL)throws->Data.
    
    public func getZipData(zipFilename:String=UUID().uuidString, filesToZip:[ZipFileDetails])throws->Data 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'zipFilename' is [\(zipFilename)] - 'filesToZip' is [\(filesToZip)]...")

        let tmpZipURL = try self.createZipAtTmp(zipFilename:zipFilename, filesToZip:filesToZip)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'tmpZipURL' is [\(tmpZipURL)]...")

        return try self.getZipData(zipFileURL:tmpZipURL)

    }   // End of func public getZipData(zipFilename:String=UUID().uuidString, filesToZip:[ZipFileDetails])throws->Data.

    private func getZipData(zipFileURL:URL)throws->Data 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'zipFileURL' is [\(zipFileURL)]...")

        if let data = FileManager.default.contents(atPath:zipFileURL.path)
        {
            appLogMsg("\(sCurrMethodDisp) FileManager read the contents of the ZIP file 'zipFileURL' is [\(String(describing: zipFileURL))]...")
            
            // Exit:

            appLogMsg("\(sCurrMethodDisp) Exiting...")

            return data
        } 
        else 
        {
            // Exit:

            appLogMsg("\(sCurrMethodDisp) Exiting - via 'throw' of 'ZipServiceError.failedToGetDataFromZipURL' - Error!")

            throw ZipServiceError.failedToGetDataFromZipURL
        }

    }   // End of private func getZipData(zipFileURL:URL)throws->Data.

}   // End of final class MultipartZipFileService:NSObject.

