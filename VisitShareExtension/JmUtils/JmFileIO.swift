//
//  JmFileIO.swift
//  JmUtils_Library
//
//  First version created by Daryl Cox on 04/18/2015 - renamed 12/22/2023.
//  Copyright (c) 2015-2026 JustMacApps. All rights reserved.
//

import Foundation

// Implementation class to handle File I/O (Input/Output).

public class JmFileIO
{

    struct ClassInfo
    {
        static let sClsId        = "JmFileIO"
        static let sClsVers      = "v1.0305"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2015-2026. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = false
    }

    class public func toString()->String
    {

        var asToString:[String] = Array()

        asToString.append("[")
        asToString.append("'sClsId': [\(ClassInfo.sClsId)],")
        asToString.append("'sClsVers': [\(ClassInfo.sClsVers)],")
        asToString.append("'sClsDisp': [\(ClassInfo.sClsDisp)],")
        asToString.append("'sClsCopyRight': [\(ClassInfo.sClsCopyRight)],")
        asToString.append("'bClsTrace': [\(ClassInfo.bClsTrace)],")
        asToString.append("'bClsFileLog': [\(ClassInfo.bClsFileLog)]")
        asToString.append("]")

        let sContents:String = "{"+(asToString.joined(separator: ""))+"}"

        return sContents

    }   // End of class public func toString().

    class public func fileExists(sFilespec:String)->Bool
    {

        if (sFilespec.count < 1)
        {
            return false
        }

        let sTestFilespec:String = JmFileIO.stripQuotesFromFile(sFilespec:sFilespec)

        return FileManager().fileExists(atPath:sTestFilespec)

    }   // End of class public func fileExists()->Bool.

    class public func stripQuotesFromFile(sFilespec:String)->String
    {

        if (sFilespec.count < 1)
        {
            return ""
        }

        var sTestFilespec:String = sFilespec

        if (sTestFilespec.first == "'" ||
            sTestFilespec.first == "\"")
        {
            sTestFilespec = String(sTestFilespec.dropFirst(1))
        }

        if (sTestFilespec.last == "'" ||
            sTestFilespec.last == "\"")
        {
            sTestFilespec = String(sTestFilespec.dropLast(1))
        }

        return sTestFilespec

    }   // End of class public func stripQuotesFromFile()->String.

    class public func readFile(sFilespec:String, nsEncoding:String.Encoding = String.Encoding.utf8)->String?
    {

        if (sFilespec.count < 1)
        {
            return nil
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec: sCurrFilespec)
        {
            return try? String(contentsOfFile:sCurrFilespec, encoding:nsEncoding)
        }

        return nil

    }   // End of class public func readFile()->String?.

    class public func readFileLines(sFilespec:String, nsEncoding:String.Encoding = String.Encoding.utf8)->[String]?
    {

        if (sFilespec.count < 1)
        {
            return nil
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            let sDataRead           = (try? String(contentsOfFile:sCurrFilespec, encoding:nsEncoding)) ?? ""
            let asDataRead:[String] = sDataRead.components(separatedBy:"\n")

            return asDataRead
        }

        return nil

    }   // End of class public func readFileLines()->[String]?.

    class public func writeFile(sFilespec:String, sContents:String, bAppendToFile:Bool = true, nsEncoding:String.Encoding = String.Encoding.utf8)->Bool
    {

        if (sFilespec.count < 1)
        {
            return false
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        let sCurrFilepath = (sCurrFilespec as NSString).deletingLastPathComponent

        do
        {
            try FileManager.default.createDirectory(atPath:sCurrFilepath, withIntermediateDirectories:true, attributes:nil)
        }
        catch
        {
            print("'[\(String(describing: ClassInfo.sClsId))].writeFile(...)' - Failed to create the 'path' of [\(sCurrFilepath)] - Error: \(error)...")
        }

        if (bAppendToFile == false)
        {
            do
            {
                try sContents.write(toFile:sCurrFilespec, atomically:true, encoding:nsEncoding)

                return true
            }
            catch _
            {
                return false
            }
        }

        let nsOutputStream = OutputStream(toFileAtPath:sCurrFilespec, append:bAppendToFile)

        if (nsOutputStream == nil)
        {
            return false
        }

        nsOutputStream?.open()

        nsOutputStream?.write(sContents, maxLength:sContents.lengthOfBytes(using:nsEncoding))

        nsOutputStream?.close()

        return true

    }   // End of class public func writeFile()->Bool.

    class public func writeFileLines(sFilespec:String, asContents:[String], bAppendToFile:Bool = true, nsEncoding:String.Encoding = String.Encoding.utf8)->Bool
    {

        if (sFilespec.count < 1)
        {
            return false
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        let sCurrFilepath = (sCurrFilespec as NSString).deletingLastPathComponent

        do
        {
            try FileManager.default.createDirectory(atPath:sCurrFilepath, withIntermediateDirectories:true, attributes:nil)
        }
        catch
        {
            print("'[\(String(describing: ClassInfo.sClsId))].writeFileLines(...)' - Failed to create the 'path' of [\(sCurrFilepath)] - Error: \(error)...")
        }

        let sContents:String = asContents.joined(separator:"\n")

        if (bAppendToFile == false)
        {
            do
            {
                try sContents.write(toFile:sCurrFilespec, atomically:true, encoding:nsEncoding)

                return true
            }
            catch _
            {
                return false
            }
        }

        let nsOutputStream = OutputStream(toFileAtPath:sCurrFilespec, append:bAppendToFile)

        if (nsOutputStream == nil)
        {
            return false
        }

        nsOutputStream?.open()

        nsOutputStream?.write(sContents, maxLength:sContents.lengthOfBytes(using:nsEncoding))

        nsOutputStream?.close()

        return true

    }   // End of class public func writeFileLines()->Bool.

    class public func deleteFile(sFilespec:String)->Bool
    {

        if (sFilespec.count < 1)
        {
            return true
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        var bWasFileDeleted:Bool = false

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            do
            {
                try FileManager.default.removeItem(atPath:sCurrFilespec)

                bWasFileDeleted = true
            }
            catch
            {
                print("'[\(String(describing: ClassInfo.sClsId))].deleteFile(...)' - Failed to delete the 'file' of [\(sCurrFilespec)] - Error: \(error)...")

                bWasFileDeleted = false
            }
        }

        return bWasFileDeleted

    }   // End of class public func deleteFile(sFilespec:String)->Bool.

    class public func deleteFile(urlFile:URL)->Bool
    {

        var bWasFileDeleted:Bool = false

        if FileManager.default.fileExists(atPath:urlFile.path)
        {
            do
            {
                try FileManager.default.removeItem(at:urlFile)

                bWasFileDeleted = true
            }
            catch
            {
                print("'[\(String(describing: ClassInfo.sClsId))].deleteFile(...)' - Failed to delete the 'file' of [\(urlFile)] - Error: \(error)...")

                bWasFileDeleted = false
            }
        }

        return bWasFileDeleted

    }   // End of class public func deleteFile(urlFile:URL)->Bool.

    class public func convertHFSFilespecToUnix(sHFSFilespec:String? = nil)->String?
    {

        if (sHFSFilespec        == nil ||
            sHFSFilespec!.count  < 1)
        {
            return nil
        }

        let sStdFilespec = sHFSFilespec!.replacingOccurrences(of:":", with:"/", options:String.CompareOptions.literal, range:nil)

        return ("/Volumes/\(sStdFilespec)")

    }   // End of public func convertHFSFilespecToUnix()->String?.

    class public func getFilespecComponents(sFilespec:String)->[String]?
    {

        if (sFilespec.count < 1)
        {
            return nil
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        return FileManager().componentsToDisplay(forPath:sCurrFilespec)

    }   // End of class public func fgetFilespecComponents(sFilespec:String)->[String]?.

    class public func getFilespecType(sFilespec:String)->String
    {

        if (sFilespec.count < 1)
        {
            return "unknown"
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            let nsDictItemAttributes:NSDictionary? = try? FileManager.default.attributesOfItem(atPath:sCurrFilespec) as NSDictionary

            if (nsDictItemAttributes        != nil &&
                nsDictItemAttributes!.count  > 0)
            {
                return (nsDictItemAttributes!.fileType() ?? "unknown")
            }
        }

        return "unknown"

    }   // End of class public func getFilespecType(sFilespec:String)->String.

    class public func getFilespecIsImmutable(sFilespec:String)->Bool
    {

        if (sFilespec.count < 1)
        {
            return false
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            let nsDictItemAttributes:NSDictionary? = try? FileManager.default.attributesOfItem(atPath:sCurrFilespec) as NSDictionary

            if (nsDictItemAttributes        != nil &&
                nsDictItemAttributes!.count  > 0)
            {
                return nsDictItemAttributes!.fileIsImmutable()
            }
        }

        return false

    }   // End of class public func getFilespecIsImmutable(sFilespec:String)->Bool.

    class public func getFilespecIsAppendOnly(sFilespec:String)->Bool
    {

        if (sFilespec.count < 1)
        {
            return false
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            let nsDictItemAttributes:NSDictionary? = try? FileManager.default.attributesOfItem(atPath:sCurrFilespec) as NSDictionary

            if (nsDictItemAttributes        != nil &&
                nsDictItemAttributes!.count  > 0)
            {
                return nsDictItemAttributes!.fileIsAppendOnly()
            }
        }

        return false

    }   // End of class public func getFilespecIsImmutable(sFilespec:String)->Bool.

    class public func getFilespecCreatedAtDate(sFilespec:String)->Date?
    {

        if (sFilespec.count < 1)
        {
            return nil
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            let nsDictItemAttributes:NSDictionary? = try? FileManager.default.attributesOfItem(atPath:sCurrFilespec) as NSDictionary

            if (nsDictItemAttributes        != nil &&
                nsDictItemAttributes!.count  > 0)
            {
                return (nsDictItemAttributes!.fileCreationDate() ?? Date())
            }
        }

        return nil

    }   // End of class public func getFilespecCreatedAtDate(sFilespec:String)->Date?.

    class public func getFilespecCreatedAtDateAsLocalizedString(sFilespec:String)->String?
    {

        if (sFilespec.count < 1)
        {
            return nil
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            let dateCurrFilespecCreated:Date   = JmFileIO.getFilespecCreatedAtDate(sFilespec:sCurrFilespec) ?? Date()
            let dtFormatterDate:DateFormatter  = DateFormatter()

            dtFormatterDate.locale             = Locale(identifier: "en_US")
            dtFormatterDate.timeZone           = TimeZone.current
            dtFormatterDate.dateFormat         = "EEEE MMMM dd, yyyy hh:mm:ss a zzz"

            return (dtFormatterDate.string(from:dateCurrFilespecCreated))
        }

        return nil

    }   // End of class public func getFilespecCreatedAtDateAsLocalizedString(sFilespec:String)->String?.

    class public func getFilespecModifiedOnDate(sFilespec:String)->Date?
    {

        if (sFilespec.count < 1)
        {
            return nil
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            let nsDictItemAttributes:NSDictionary? = try? FileManager.default.attributesOfItem(atPath:sCurrFilespec) as NSDictionary

            if (nsDictItemAttributes        != nil &&
                nsDictItemAttributes!.count  > 0)
            {
                return (nsDictItemAttributes!.fileModificationDate() ?? Date())
            }
        }

        return nil

    }   // End of class public func getFilespecModifiedOnDate(sFilespec:String)->Date?.

    class public func getFilespecModifiedOnDateAsLocalizedString(sFilespec:String)->String?
    {

        if (sFilespec.count < 1)
        {
            return nil
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            let dateCurrFilespecModified:Date  = JmFileIO.getFilespecModifiedOnDate(sFilespec:sCurrFilespec) ?? Date()
            let dtFormatterDate:DateFormatter  = DateFormatter()

            dtFormatterDate.locale             = Locale(identifier: "en_US")
            dtFormatterDate.timeZone           = TimeZone.current
            dtFormatterDate.dateFormat         = "EEEE MMMM dd, yyyy hh:mm:ss a zzz"

            return (dtFormatterDate.string(from:dateCurrFilespecModified))
        }

        return nil

    }   // End of class public func getFilespecModifiedOnDateAsLocalizedString(sFilespec:String)->String?.

    class public func getFilespecSize(sFilespec:String)->Int64
    {

        if (sFilespec.count < 1)
        {
            return 0
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            let nsDictItemAttributes:NSDictionary? = try? FileManager.default.attributesOfItem(atPath:sCurrFilespec) as NSDictionary

            if (nsDictItemAttributes        != nil &&
                nsDictItemAttributes!.count  > 0)
            {
                return Int64(nsDictItemAttributes!.fileSize())
            }
        }

        return 0

    }   // End of class public func getFilespecSize(sFilespec:String)->Int64.

    class public func getFilespecSizeAsDisplayableMB(sFilespec:String)->String
    {

        if (sFilespec.count < 1)
        {
            return "0 MB"
        }

        var sCurrFilespec:String = sFilespec

        if (sCurrFilespec.hasPrefix("~/") == true)
        {
            sCurrFilespec = NSString(string:sCurrFilespec).expandingTildeInPath as String
        }

        if JmFileIO.fileExists(sFilespec:sCurrFilespec)
        {
            let cTestFilespecSize:Int64               = JmFileIO.getFilespecSize(sFilespec:sCurrFilespec)
            let byteCountFormatter:ByteCountFormatter = ByteCountFormatter()

            byteCountFormatter.allowedUnits = [.useMB]
            byteCountFormatter.countStyle   = .file

            return (byteCountFormatter.string(fromByteCount:Int64(cTestFilespecSize)))
        }

        return "0 MB"

    }   // End of class public func getFilespecSizeAsDisplayableMB(sFilespec:String)->String.

}   // End of public class JmFileIO.

