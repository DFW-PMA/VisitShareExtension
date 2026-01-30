//
//  HelpBasicView.swift
//  JustAMultiplatformClock1
//
//  Created by JustMacApps.net on 05/07/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import MarkdownUI

struct HelpBasicView:View 
{
    
    struct ClassInfo
    {
        static let sClsId          = "HelpBasicView"
        static let sClsVers        = "v1.1210"
        static let sClsDisp        = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight   = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace       = true
        static let bClsFileLog     = true
    }

    // App Data field(s):

    @Environment(\.presentationMode) var presentationMode

    @AppStorage("helpBasicMode") var helpBasicMode             = HelpBasicMode.hypertext
    @State                       var sHelpBasicContents:String = "----NOT-Loaded-(View)----"

// --------------------------------------------------------------------------------------------------------------------
// NOTE: ANSWER: see below - must access the variable name with a leading '_' and
//                     >>>   wrap the inbound parameter with a 'State()' method ('wrapper').
// --------------------------------------------------------------------------------------------------------------------
  
    init(sHelpBasicContents:String)
    {
    
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'sHelpBasicContents' is [\(sHelpBasicContents)]...")
  
        self._sHelpBasicContents = State(initialValue: sHelpBasicContents)
    
        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting 'self.sHelpBasicContents' is [\(self.sHelpBasicContents)] - parameter 'sHelpBasicContents' was [\(sHelpBasicContents)]...")
    
        return
    
    }   // End of init().

    var body:some View 
    {
        
        VStack
        {
        #if os(iOS)
            HStack(alignment:.center)
            {
                Spacer()

                Button
                {
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):HelpBasicView.Button(Xcode).'Dismiss' pressed...")

                    self.presentationMode.wrappedValue.dismiss()
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage: "xmark.circle")
                            .help(Text("Dismiss this Screen"))
                            .imageScale(.large)
                        Text("Dismiss")
                            .font(.caption)
                    }
                }
                .padding()
            }

            Spacer(minLength:5)
        #endif

            HStack
            {
                ScrollView(.vertical)
                {
                    renderHELPContentsInTextView()
                }
            }
            .padding()
        }
        
    }
    
    @ViewBuilder
    func renderHELPContentsInTextView()->some View
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        let _ = appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> Invoked...")

        switch helpBasicMode
        {
        case .hypertext:
        #if os(macOS)
            if let nsAttributedString = try? NSAttributedString(data:               Data(sHelpBasicContents.utf8), 
                                                                options:            [.documentType: NSAttributedString.DocumentType.html], 
                                                                documentAttributes: nil),
               let attributedString   = try? AttributedString(nsAttributedString, including: \.appKit) 
            {
                let _ = appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> - rendering Text() as '.hypertext' (from an 'attributedString') on macOS...")

                Text(attributedString)
            }
            else
            {
                let _ = appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> - rendering Text() as '.simpletext' (from '.hypertext') on macOS (attribution failed)...")

                Text(sHelpBasicContents)
            }
        #elseif os(iOS)
            let _ = appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> - rendering Text() as '.simpletext' (from '.hypertext') on iOS...")

            Text(sHelpBasicContents)
        #endif
            
        case .simpletext:
            let _ = appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> - rendering Text() as '.simpletext'...")

            Text(sHelpBasicContents)
            
        case .markdown:
            let _ = appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> - rendering with MarkdownUI as '.markdown'...")

            VStack(alignment:.leading, spacing:0) 
            {
                Markdown(sHelpBasicContents)
                    .markdownTextStyle 
                    {
                        FontFamilyVariant(.normal)
                        FontSize(.em(0.75))
                    }
                    .markdownBlockStyle(\.heading1) 
                    { configuration in

                        configuration.label
                            .relativePadding(.bottom, length:.em(0.5))
                            .relativeLineSpacing(.em(0.125))
                            .markdownTextStyle 
                            {
                                FontWeight(.semibold)
                                FontSize(.em(0.75))
                            }
                    }
                    .markdownBlockStyle(\.heading2) 
                    { configuration in

                        configuration.label
                            .relativePadding(.bottom, length:.em(0.3))
                            .relativeLineSpacing(.em(0.125))
                            .markdownTextStyle 
                            {
                                FontWeight(.semibold)
                                FontSize(.em(0.75))
                            }
                    }
                    .markdownBlockStyle(\.paragraph) 
                    { configuration in

                        configuration.label
                            .relativeLineSpacing(.em(0.25))
                            .relativePadding(.bottom, length:.em(1))
                    }
                    .markdownBlockStyle(\.listItem) 
                    { configuration in

                        configuration.label
                            .markdownTextStyle 
                            {
                                FontSize(.em(0.75))
                            }
                    }
                    .markdownInlineImageProvider(.asset)
            }
        }
        
        // Note: Exit logging handled by @ViewBuilder automatically
    
    }   // End of func renderHELPContentsInTextView()->Text.

//  func renderHELPContentsInTextView()->some View
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//      
//      appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> Invoked...")
//      
//      var tfHELPContents:Text
//
//      switch helpBasicMode
//      {
//      case .hypertext:
//          do 
//          {
//          #if os(macOS)
//              if let nsAttributedString = try? NSAttributedString(data:               Data(sHelpBasicContents.utf8), 
//                                                                  options:            [.documentType: NSAttributedString.DocumentType.html], 
//                                                                  documentAttributes: nil),
//                 let attributedString   = try? AttributedString(nsAttributedString, including: \.appKit) 
//              {
//                  appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> - rendering Text() as '.hypertext' (from an 'attributedString') on macOS...")
//
//                  tfHELPContents = Text(attributedString)
//              }
//              else
//              {
//                  appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> - rendering Text() as '.simpletext' (from '.hypertext') on macOS (attribution failed)...")
//
//                  tfHELPContents = Text(sHelpBasicContents)
//              }
//          #elseif os(iOS)
//              appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> - rendering Text() as '.simpletext' (from '.hypertext') on iOS...")
//
//              tfHELPContents = Text(sHelpBasicContents)
//          #endif
//          }
//      case .simpletext:
//          do
//          {
//              appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> - rendering Text() as '.simpletext'...")
//
//              tfHELPContents = Text(sHelpBasicContents)
//          }
//      case .markdown:
//          do {
//              let attributedString = try AttributedString(markdown:sHelpBasicContents)
//              
//              tfHELPContents = Text(attributedString)
//          } catch {
//              tfHELPContents = Text(sHelpBasicContents) // Fallback to plain text
//          }
//          
//      //  do
//      //  {
//      //      appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> - rendering Text() as '.markdown' - returning Markdown().padding(sHelpBasicContents)...")
//      //
//      //      return Markdown(sHelpBasicContents)
//      //                 .padding()
//      //
//      //  //  tfHELPContents = Text(try! AttributedString(markdown: sHelpBasicContents))
//      //  }
//      }
//
//      // Exit...
//
//      appLogMsg("\(sCurrMethodDisp) <HelpBasic Render> Exiting - 'tfHELPContents' is [\(tfHELPContents)]...")
//      
//      return tfHELPContents
//
//  }   // End of func renderHELPContentsInTextView()->Text.

}

#Preview 
{
    HelpBasicView(sHelpBasicContents: "---HELP 'Basic' Preview---")
}

