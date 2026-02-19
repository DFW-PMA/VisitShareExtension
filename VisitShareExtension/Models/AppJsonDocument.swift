//
//  AppJsonDocument.swift
//  JmUtils_Library
//
//  Created by Daryl Cox on 08/05/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - App JSON Document for Export...

struct AppJsonDocument:FileDocument 
{

    struct ClassInfo
    {
        static let sClsId        = "AppJsonDocument"
        static let sClsVers      = "v1.0401"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // App Data field(s):

    static var readableContentTypes:[UTType] 
    {
        [.json]
    }

    var jsonString:String

    var appGlobalInfo:AppGlobalInfo = AppGlobalInfo.ClassSingleton.appGlobalInfo

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
        asToString.append("'jsonString': [\(self.jsonString)],")
        asToString.append("]")

        let sContents:String = "{"+(asToString.joined(separator: ""))+"}"

        return sContents

    } // End of public func toString().

    init(jsonString:String) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        self.jsonString = jsonString
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of init(jsonString:String).

    init(configuration:ReadConfiguration)throws 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        guard let data   = configuration.file.regularFileContents,
              let string = String(data:data, encoding:.utf8)
        else 
        {
            throw CocoaError(.fileReadCorruptFile)
        }

        jsonString = string
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of init(configuration:ReadConfiguration)throws.

    func fileWrapper(configuration:WriteConfiguration)throws->FileWrapper 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let data = jsonString.data(using:.utf8)!

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return .init(regularFileWithContents:data)

    }   // End of func fileWrapper(configuration:WriteConfiguration)throws->FileWrapper.

}   // End of struct AppJsonDocument:FileDocument.

