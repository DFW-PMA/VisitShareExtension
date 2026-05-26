//
//  AppMarkdownViewerView.swift
//  DataGridPack
//
//  Created by JustMacApps.net on 04/27/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//
//  NOTE: Shared viewer used by both DataGridPack (ContentView) and
//        VMA (AppGeneralFileView).  When the SPM shared-module migration
//        lands this file moves there; until then a copy lives in each
//        project that uses it.
//

import Foundation
import SwiftUI
import MarkdownUI

// MARK: - MarkdownThemeOption Enum

enum MarkdownThemeOption:String, CaseIterable, Identifiable
{
    case gitHub = "GitHub"
    case docC   = "DocC"
    case basic  = "Basic"

    var id:String { self.rawValue }

    var displayName:String { self.rawValue }

    var theme:Theme
    {
        switch self
        {
        case .gitHub: return .gitHub
        case .docC:   return .docC
        case .basic:  return .basic
        }
    }

}   // End of enum MarkdownThemeOption.

// MARK: - AppMarkdownViewerView

struct AppMarkdownViewerView:View
{

    struct ClassInfo
    {
        static let sClsId        = "AppMarkdownViewerView"
        static let sClsVers      = "v1.0401"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // Caller-supplied field(s):

    let sMarkdownContent:String
    let sFileName:String
    let iFileSize:Int

    // Persisted theme selection (shared across all callers via UserDefaults)...

    @AppStorage("markdownThemeName") private var sMarkdownThemeName:String = MarkdownThemeOption.gitHub.rawValue

    // View mode toggle:
    //   false = rendered Markdown (default)
    //   true  = raw source in TextEditor (full drag-select, copy any block)

    @State private var bShowRawSource:Bool = false

    // Computed theme resolution...

    private var currentThemeOption:MarkdownThemeOption
    {
        MarkdownThemeOption(rawValue:sMarkdownThemeName) ?? .gitHub
    }

    var body:some View
    {

        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'sFileName' is [\(sFileName)]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'iFileSize' is #(\(iFileSize)) byte(s)...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'sMarkdownThemeName' is [\(sMarkdownThemeName)]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'bShowRawSource' is [\(bShowRawSource)]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'sMarkdownContent' character count is #(\(sMarkdownContent.count))...")

        VStack(spacing:0)
        {
            // Header bar...

            HStack(spacing:8)
            {
                Image(systemName:bShowRawSource ? "doc.plaintext" : "text.badge.checkmark")
                    .foregroundColor(.blue)

                Text(bShowRawSource ? "Raw Source" : "Markdown Viewer")
                    .font(.headline)

                Spacer()

                // Option 1: Copy All — copies entire raw markdown to clipboard in one tap.
                // Works in both rendered and raw modes.
                // On iPad this is the fastest way to get a large block of text out.

                Button
                {
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):Button.'Copy All' - Copying #(\(sMarkdownContent.count)) character(s) to clipboard...")
                #if os(iOS)
                    UIPasteboard.general.string = sMarkdownContent
                #elseif os(macOS)
                    NSPasteboard.general.prepareForNewContents()
                    NSPasteboard.general.setString(sMarkdownContent, forType:.string)
                #endif
                    appLogMsg("\(ClassInfo.sClsDisp):Button.'Copy All' - Copied to clipboard...")
                }
                label:
                {
                    HStack(spacing:4)
                    {
                        Image(systemName:"doc.on.doc")
                            .imageScale(.small)

                        Text("Copy All")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.12))
                    .cornerRadius(6)
                }
                .help(Text("Copy entire file contents to clipboard"))

                // Option 2: Raw/Rendered toggle — switches between rendered Markdown
                // (per-element .textSelection copy) and a raw TextEditor that supports
                // full drag-to-select across any block of text.

                Button
                {
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):Button.'Raw/Rendered' - Toggling 'bShowRawSource' from [\(bShowRawSource)] to [\(!bShowRawSource)]...")

                    bShowRawSource.toggle()

                    appLogMsg("\(ClassInfo.sClsDisp):Button.'Raw/Rendered' - 'bShowRawSource' is now [\(bShowRawSource)]...")
                }
                label:
                {
                    HStack(spacing:4)
                    {
                        Image(systemName:bShowRawSource ? "text.badge.checkmark" : "curlybraces")
                            .imageScale(.small)

                        Text(bShowRawSource ? "Rendered" : "Raw")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(6)
                }
                .help(Text(bShowRawSource ? "Switch to rendered Markdown view" : "Switch to raw source for full text selection"))

                // Theme picker menu — only relevant in rendered mode...

                Menu
                {
                    ForEach(MarkdownThemeOption.allCases)
                    { themeOption in

                        Button
                        {
                            let _ = appLogMsg("\(ClassInfo.sClsDisp):themeMenu.Button - Selecting theme: [\(themeOption.rawValue)]...")

                            sMarkdownThemeName = themeOption.rawValue

                            appLogMsg("\(ClassInfo.sClsDisp):themeMenu.Button - Selected  theme: [\(sMarkdownThemeName)]...")
                        }
                        label:
                        {
                            HStack
                            {
                                Text(themeOption.displayName)

                                if (themeOption == currentThemeOption)
                                {
                                    Image(systemName:"checkmark")
                                }
                            }
                        }

                    }   // End of ForEach(MarkdownThemeOption.allCases).
                }
                label:
                {
                    HStack(spacing:4)
                    {
                        Image(systemName:"paintpalette")
                            .imageScale(.small)

                        Text(currentThemeOption.displayName)
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                }
                .disabled(bShowRawSource)
                .opacity(bShowRawSource ? 0.4 : 1.0)
                .help(Text("Select Markdown display theme"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        #if os(macOS)
            .background(Color(NSColor.controlBackgroundColor))
        #endif
        #if os(iOS)
            .background(Color(UIColor.secondarySystemBackground))
        #endif
            .border(Color.gray.opacity(0.2), width:0.5)

            // Content area — switches between rendered and raw modes...

            if bShowRawSource
            {
                // Option 2 - Raw source view:
                // TextEditor gives full platform drag-to-select across any span of text.
                // .constant() makes it read-only — user can select and copy freely
                // but cannot modify the content.

                TextEditor(text:.constant(sMarkdownContent))
                    .font(.system(.body, design:.monospaced))
                    .padding()
            }
            else
            {
                // Default - Rendered Markdown view:
                // .textSelection(.enabled) gives per-element long-press copy.
                // NOTE: swift-markdown-ui renders each paragraph/heading/block as a
                // separate Text view, so selection is limited to one element at a time.
                // Use Raw mode or Copy All for multi-element selection needs.
                // swift-markdown-ui renders the full document in one pass (non-lazy).

                ScrollView
                {
                    Markdown(sMarkdownContent)
                        .markdownTheme(currentThemeOption.theme)
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth:.infinity, alignment:.leading)
                }
            }

            // Status bar...

            HStack
            {
                Image(systemName:bShowRawSource ? "doc.plaintext" : "doc.richtext")
                    .foregroundColor(.secondary)
                    .imageScale(.small)

                Text(sFileName)
                    .font(.system(size:12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Divider()
                    .frame(height:12)

                let sFileSize = ByteCountFormatter.string(fromByteCount:Int64(iFileSize), countStyle:.file)

                Text("Size: \(sFileSize)")
                    .font(.system(size:12))
                    .foregroundColor(.secondary)

                Spacer()

                Text(bShowRawSource ? "Raw Source" : "Theme: \(currentThemeOption.displayName)")
                    .font(.system(size:12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        #if os(macOS)
            .background(Color(NSColor.controlBackgroundColor))
        #endif
        #if os(iOS)
            .background(Color(UIColor.secondarySystemBackground))
        #endif
            .border(Color.gray.opacity(0.2), width:0.5)

        }   // End of VStack(spacing:0).

    }   // End of var body:some View.

}   // End of struct AppMarkdownViewerView:View.

#Preview
{
    AppMarkdownViewerView(
        sMarkdownContent:"""
                         # Markdown Preview

                         This is **bold**, _italic_, and `code`.

                         ## Section Two

                         - Item 1
                         - Item 2
                         - Item 3

                         > A blockquote for good measure.

                         ```swift
                         let x = 42
                         print("Hello, Markdown!")
                         ```
                         """,
        sFileName:       "preview.md",
        iFileSize:       1024
    )
}
