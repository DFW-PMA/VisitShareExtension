//
//  AppDocumentImportContentTypes.swift
//  AnyPack
//
//  Created by JustMacApps.net on 04/08/2026.
//  Copyright © 2023-2026 JustMacApps. All rights reserved.
//

import JmEntityInfo
import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

@JmEntityInfo(vers:"v1.0402")
public struct AppDocumentImportContentTypes
{
    
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
                                                                 UTType("net.daringfireball.markdown")!,
                                                                // <<CHICKEN-TRACKS>> (2026-09-10) - .propertyList added explicitly for the
                                                                // Import picker/NSOpenPanel. Already implicitly allowed via 'public.data'
                                                                // above (com.apple.property-list conforms to it), but listing it directly
                                                                // documents .plist as an intentionally-supported type, not an accident of
                                                                // the broad public.data catch-all. See Info.plist's new
                                                                // CFBundleDocumentTypes/LSItemContentTypes entry for the matching
                                                                // LaunchServices-side fix (Dock icon drop / Finder Open With).
                                                                 .propertyList
                                                            ]

}   // End of public struct AppDocumentImportContentTypes.
