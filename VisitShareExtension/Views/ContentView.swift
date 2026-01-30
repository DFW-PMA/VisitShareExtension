//
//  ContentView.swift
//  VisitShareExtension
//
//  Main view showing instructions and available target apps
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

struct ContentView:View
{
    
    struct ClassInfo
    {
        static let sClsId        = "ContentView"
        static let sClsVers      = "v1.0501"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // App Data field(s):

//  @Environment(\.dismiss)              var dismiss
    @Environment(\.presentationMode)     var presentationMode
    @Environment(\.openURL)              var openURL
    @Environment(\.appGlobalDeviceType)  var appGlobalDeviceType

                            var appGlobalInfo:AppGlobalInfo   = AppGlobalInfo.ClassSingleton.appGlobalInfo

    @State          private var cAppAboutButtonPresses:Int    = 0
    @State          private var cAppSettingsButtonPresses:Int = 0

    @State          private var isAppAboutViewModal:Bool      = false
    @State          private var showingSettingsView:Bool      = false

    var body:some View
    {
        
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - [\(String(describing:JmXcodeBuildSettings.jmAppVersionAndBuildNumber))]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'appGlobalDeviceType' is (\(String(describing:appGlobalDeviceType)))...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'AppGlobalInfo.bIsAppLoggingByVisitor' is [\(AppGlobalInfo.bIsAppLoggingByVisitor)] and 'AppGlobalInfo.sAppLoggingMethod' is [\(AppGlobalInfo.sAppLoggingMethod)]...")

        NavigationStack
        {
            ScrollView
            {
                VStack(spacing:24)
                {
                    headerSection
                    targetAppsSection
                    Divider()
                    instructionsSection
                    Spacer(minLength:40)
                }
                .padding()
            }
            .navigationTitle("VisitShareExtension")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement:.navigationBarLeading) 
                {
                    Button
                    {
                        self.cAppAboutButtonPresses += 1
                
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):ContentView.Button(Xcode).'App About'.#(\(self.cAppAboutButtonPresses))...")
                
                        self.isAppAboutViewModal.toggle()
                    }
                    label:
                    {
                        VStack(alignment:.center)
                        {
                            Label("", systemImage: "questionmark.diamond")
                                .help(Text("App About Information"))
                                .imageScale(.small)
                            Text("About")
                                .font(.caption2)
                        }
                    }
                    .fullScreenCover(isPresented:$isAppAboutViewModal)
                    {
                        AppAboutView()
                    }
                #if os(macOS)
                    .buttonStyle(.borderedProminent)
                //  .background(???.isPressed ? .blue : .gray)
                    .cornerRadius(10)
                    .foregroundColor(Color.primary)
                #endif
                    .padding()
                }

                ToolbarItem(placement:.navigationBarTrailing) 
                {
                    Button
                    {
                        self.cAppSettingsButtonPresses += 1

                        let _ = appLogMsg("\(ClassInfo.sClsDisp):ContentView.Button(Xcode).'Settings'.#(\(self.cAppSettingsButtonPresses))...")

                        self.showingSettingsView.toggle()
                    }
                    label:
                    {
                        Label("Settings", systemImage:"gear")
                    }
                #if os(macOS)
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(10)
                    .foregroundColor(Color.primary)
                #endif
                    .padding()
                }
            }
            .fullScreenCover(isPresented:$showingSettingsView)
            {
                SettingsSingleView()
            }
        }

    }
    
    // MARK:- Header...
    
    private var headerSection:some View
    {
        VStack(spacing:12)
        {
            Image(systemName:"square.and.arrow.up.on.square")
                .font(.system(size:50))
                .foregroundColor(.accentColor)
            Text("Share to DFWPMA Apps")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Quickly send text from Messages and other Apps to your DFWPMA products.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    // MARK:- Instructions...
    
    private var instructionsSection:some View
    {
        VStack(alignment:.leading, spacing:16)
        {
            Text("How to Use")
                .font(.headline)
            VStack(alignment:.leading, spacing:12)
            {
                InstructionRow(number:1, text:"Open Messages (or any App with text)")
                InstructionRow(number:2, text:"Long-press a message (text), on the Context menu, tap 'Select'")
                InstructionRow(number:3, text:"Highlight the text you want to 'Share'")
                InstructionRow(number:4, text:"Below the highlighted text, tap the '>'")
                InstructionRow(number:5, text:"Tap 'Share...'")
                InstructionRow(number:6, text:"Choose \"VisitShareExtension\" from the 2nd row on the 'Share' sheet (if not shown, scroll to the right and tap 'More...', select from the new screen)")
                InstructionRow(number:7, text:"Select your destination App by clicking on the 'round' checkbox next to the App")
                InstructionRow(number:8, text:"Tap on the new 'Action' Button (that appears on the bottom of the screen to) 'Share' the highlighted text to the destination App")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK:- Target Apps
    
    private var targetAppsSection:some View
    {
        VStack(alignment:.leading, spacing:16)
        {
            Text("Available Apps")
                .font(.headline)
            ForEach(VVSharedTargetApps.allCases) 
            { app in

                TargetAppRow(app:app)

            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

}   // End of struct HelperContentView:View.

// MARK:- Instruction Row...

struct InstructionRow:View
{

    let number:Int
    let text:String
    
    var body:some View
    {
        HStack(alignment:.top, spacing:12)
        {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width:24, height:24)
                .background(Color.accentColor)
                .clipShape(Circle())
            Text(text)
                .font(.subheadline)
        }
    }

}   // End of struct InstructionRow:View.

// MARK:- Target App Row...

struct TargetAppRow:View
{

                   let app:VVSharedTargetApps
    @State private var isInstalled:Bool        = false
    
    var body:some View
    {

        HStack(spacing:12)
        {
            Image(systemName:app.iconName)
                .font(.title2)
                .foregroundColor(app.brandColor)
                .frame(width:40, height:40)
                .background(app.brandColor.opacity(0.15))
                .cornerRadius(8)
            VStack(alignment:.leading, spacing:2)
            {
                Text(app.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(app.actionDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
        // Status indicator...

        if isInstalled 
        {
            Image(systemName:"checkmark.circle.fill")
                .foregroundColor(.green)
        } 
        else
        {
            Text("Not Installed")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        }
        .padding(.vertical, 4)
        .onAppear { checkInstalled() }

    }
    
    private func checkInstalled()
    {

        // Check if the app can be opened via URL scheme...

        if let url = URL(string:"\(app.urlScheme)://")
        {
            isInstalled = UIApplication.shared.canOpenURL(url)
        }

        return

    }   // End of private func checkInstalled().

}   // End of struct TargetAppRow:View.

// MARK:- Preview...

#Preview
{
    ContentView()
}

