//
//  AppDocumentImportContentTypes.swift
//  DataGridPack
//
//  Created by JustMacApps.net on 04/08/2026.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import JmEntityInfo
import Foundation
import SwiftUI
import UniformTypeIdentifiers

@JmEntityInfo(vers:"v1.0301")
public struct AppDocumentImportContentTypes
{
    
    //  struct ClassInfo
    //  {
        //  static let sClsId          = "AppDocumentImportContentTypes"
        //  static let sClsVers        = "v1.0201"
        //  static let sClsDisp        = sClsId+"(.swift).("+sClsVers+"):"
        //  static let sClsCopyRight   = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        //  static let bClsTrace       = false
        //  static let bClsFileLog     = true
    //  }

    // App Data field(s):

    // <<CHICKEN-TRACKS>> (2026-06-24) — 'var' -> 'let': nothing in the codebase mutates this list
    // (confirmed via grep - SpreadsheetXMLViewer.swift only reads it), so it was flagged under
    // Swift 6 as nonisolated global mutable state for no real reason. 'UTType' is Sendable, so a
    // 'static let' of an array of UTType is unconditionally concurrency-safe - no actor isolation needed.
    static let listAppDocumentImportContentTypes:[UTType] = [
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
                                                                 UTType(filenameExtension:"json")!,
                                                                // Markdown support (.md / .markdown)...
                                                                 UTType(filenameExtension:"md")!,
                                                                 UTType(filenameExtension:"markdown")!,
                                                                 UTType("net.daringfireball.markdown")!
                                                            ]

}   // End of public struct AppDocumentImportContentTypes.
