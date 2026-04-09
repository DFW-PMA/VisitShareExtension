//
//  AppDocumentImportContentTypes.swift
//  DataGridPack
//
//  Created by JustMacApps.net on 04/08/2026.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

public struct AppDocumentImportContentTypes
{
    
    struct ClassInfo
    {
        static let sClsId          = "AppDocumentImportContentTypes"
        static let sClsVers        = "v1.0103"
        static let sClsDisp        = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight   = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace       = false
        static let bClsFileLog     = true
    }

    // App Data field(s):

    static var listAppDocumentImportContentTypes:[UTType] = [
                                                                .xml,
                                                                 UTType(filenameExtension:"xml")!,
                                                                 UTType(filenameExtension:"xls")!,
                                                                 .delimitedText,
                                                                 .commaSeparatedText,
                                                                 .tabSeparatedText,
                                                                 .utf8TabSeparatedText,
                                                                 UTType(filenameExtension:"csv")!,
                                                                 .text,
                                                                 UTType(filenameExtension:"txt")!,
                                                                 UTType("public.utf8-plain-text")!,
                                                                 UTType("public.utf16-plain-text")!,
                                                                 UTType("public.utf16-external-plain-text")!,
                                                                 UTType("com.apple.traditional-mac-plain-text")!,
                                                                 UTType("public.data")!,
                                                                 .yaml,
                                                                 UTType(filenameExtension:"yaml")!,
                                                                 .json,
                                                                 UTType(filenameExtension:"json")!
                                                            ]

}   // End of public struct AppDocumentImportContentTypes.

