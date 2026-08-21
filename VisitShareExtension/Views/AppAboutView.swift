//
//  AppAboutView.swift
//  <<< App 'dependent' >>>
//
//  Created by Daryl Cox on 08/24/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import Foundation
import SwiftUI
import MarkdownUI
#if INSTANTIATE_APP_SWIFTDATAMANAGER || INSTANTIATE_APP_JMSWIFTDATAMANAGER
import SwiftData
#endif

@JmEntityInfo(vers:"v1.2705")
@available(iOS 17.0, *)
struct AppAboutView:View
{
    
    // App Data field(s):

//  @Environment(\.dismiss)                 var dismiss
    @Environment(\.presentationMode)        var presentationMode
    @Environment(\.openURL)                 var openURL
    @Environment(\.appGlobalDeviceType)     var appGlobalDeviceType
    @Environment(\.supportsMultipleWindows) var supportsMultipleWindows

                    var appGlobalInfo:AppGlobalInfo               = AppGlobalInfo.appGlobalInfo
#if INSTANTIATE_APP_SWIFTDATAMANAGER
    @ObservedObject var appSwiftDataManager:AppSwiftDataManager   = AppSwiftDataManager.appSwiftDataManager
#endif
#if USE_APP_LOGGING_BY_VISITOR || INSTANTIATE_APP_JMSWIFTDATAMANAGER
                    var jmAppDelegateVisitor:JmAppDelegateVisitor = JmAppDelegateVisitor.appDelegateVisitor
#endif

                    let sAppBundlePath:String                     = Bundle.main.bundlePath

    // <<CHICKEN-TRACKS>> Added (v1.2601, 2026-08-07) — optional "Credits" section, sourced entirely
    // from an 'AppAboutCredits.md' file at the bundle root (checked via 'sAppBundlePath' above, per
    // Daryl's direction) rather than hardcoded in this View. Lives in NomadPack/Resources/ — a
    // PBXFileSystemSynchronizedRootGroup, so any file placed there lands at the bundle root
    // automatically (same mechanism 'HelpBasic.md' already uses via HelpBasicLoader.swift — no
    // .xcodeproj edits needed to add/change it). If the file is absent, 'sAppAboutCreditsMarkdown'
    // is empty and the body below simply omits the section — logged, not treated as an error, since
    // not every App in this family will necessarily ship one.

                    let sAppAboutCreditsMarkdown:String

#if os(macOS)
            private let pasteboard                                = NSPasteboard.general
#elseif os(iOS)
            private let pasteboard                                = UIPasteboard.general
#endif

    init()
    {
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Look for an optional 'AppAboutCredits.md' file at the bundle root...

        let sCreditsFilespec:String = Bundle.main.bundlePath + "/AppAboutCredits.md"

        if (FileManager.default.fileExists(atPath:sCreditsFilespec) == true)
        {
            do
            {
                let sLoadedCreditsMarkdown:String = try String(contentsOfFile:sCreditsFilespec, encoding:.utf8)
                self.sAppAboutCreditsMarkdown = sLoadedCreditsMarkdown
                appLogMsg("\(sCurrMethodDisp) Found and loaded 'AppAboutCredits.md' at [\(sCreditsFilespec)] - #(\(sLoadedCreditsMarkdown.count)) character(s)...")
            }
            catch
            {
                self.sAppAboutCreditsMarkdown = ""
                appLogMsg("\(sCurrMethodDisp) 'AppAboutCredits.md' exists at [\(sCreditsFilespec)] but failed to load - Error: [\(error.localizedDescription)] - Error!")
            }
        }
        else
        {
            self.sAppAboutCreditsMarkdown = ""
            appLogMsg("\(sCurrMethodDisp) No 'AppAboutCredits.md' file found at [\(sCreditsFilespec)] - skipping Credits section...")
        }

        appLogMsg("\(sCurrMethodDisp) Exiting...")
        return
    }

    var body:some View 
    {
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - [\(String(describing:JmXcodeBuildSettings.jmAppVersionAndBuildNumber))]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'sAppBundlePath' is [\(sAppBundlePath)]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'appGlobalDeviceType' is (\(String(describing:appGlobalDeviceType)))...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'AppGlobalInfo.bIsAppLoggingByVisitor' is [\(AppGlobalInfo.bIsAppLoggingByVisitor)] and 'AppGlobalInfo.sAppLoggingMethod' is [\(AppGlobalInfo.sAppLoggingMethod)]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'supportsMultipleWindows' is (\(String(describing:supportsMultipleWindows)))...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'appGlobalInfo.bGlobalProcessInfoIsiOSAppOnMac' is (\(String(describing:appGlobalInfo.bGlobalProcessInfoIsiOSAppOnMac)))...")

        VStack
        {
        #if os(iOS)
            HStack(alignment:.center)
            {
                Spacer()

                Button
                {
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):AppAboutView.Button(Xcode).'Dismiss' pressed...")
                    self.presentationMode.wrappedValue.dismiss()
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage:"xmark.circle")
                            .help(Text("Dismiss this Screen"))
                            .imageScale(.small)
                        Text("Dismiss")
                            .font(.caption2)
                    }
                }
            #if os(macOS)
                .buttonStyle(.borderedProminent)
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
                .padding(1.00)
            }
        #endif

            ZStack(alignment:.bottom)
            {
                ScrollView
                {
                    if #available(iOS 17.0, *)
                    {
                        Image(ImageResource(name:"Gfx/AppIcon", bundle:Bundle.main))
                            .resizable()
                            .scaledToFit()
                            .containerRelativeFrame(.horizontal)
                                { size, axis in
                                    size * 0.10
                                }
                    }
                    else
                    {
                        Image(ImageResource(name:"Gfx/AppIcon", bundle:Bundle.main))
                            .resizable()
                            .scaledToFit()
                            .frame(width:50, height:50, alignment:.center)
                    }

                        Text("")
                        Text("Display Name: \(JmXcodeBuildSettings.jmAppDisplayName)")
                            .bold()
                        Text("")

                        ScrollView
                        {
                        Text("Application Category:")
                            .bold()
                            .italic()
                            .font(.footnote)
                        Text("\(JmXcodeBuildSettings.jmAppCategory)")
                            .font(.footnote)
                        Text("")
                            .font(.footnote)
                        Text("\(JmXcodeBuildSettings.jmAppVersionAndBuildNumber)")     // <=== Version...
                            .italic()
                            .font(.footnote)
                        Text("")
                            .font(.caption2)
                        Text("- - - - - - - - - - - - - - -")
                            .font(.caption2)
                    #if USE_APP_LOGGING_BY_VISITOR
                        Text("Log file:")
                            .font(.caption2)
                        Text(self.jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec ?? "...empty...")
                            .font(.caption2)
                            .contextMenu
                            {
                                Button
                                {
                                    let _ = appLogMsg("...\(ClassInfo.sClsDisp):AppAboutView in Text.contextMenu.'copy' button #1...")
                                    self.copyLogFilespecToClipboard()
                                }
                                label:
                                {
                                    Text("Copy to Clipboard")
                                }
                            }
                        Text("Log file 'size' is: [\(self.getLogFilespecFileSizeDisplayableMB())]")
                            .font(.caption2)
                        Text("")
                            .font(.caption2)
                    #endif
                        Text("UserDefaults file:")
                            .font(.caption2)
                        Text("\(self.appGlobalInfo.sAppUserDefaultsFileLocation)")
                            .font(.caption2)
                            .contextMenu
                            {
                                Button
                                {
                                    let _ = appLogMsg("...\(ClassInfo.sClsDisp):AppAboutView in Text.contextMenu.'copy' button #2...")
                                    self.copyUserDefaultsFilespecToClipboard()
                                }
                                label:
                                {
                                    Text("Copy to Clipboard")
                                }
                            }
                    #if USE_APP_LOGGING_BY_VISITOR && INSTANTIATE_APP_JMSWIFTDATAMANAGER
                        Text("")
                            .font(.caption2)
                        Text("(Jm) SwiftData file(s) location:")
                            .font(.caption2)
                        Text("\(self.getJmSwiftDataFilesLocation())")
                            .font(.caption2)
                            .contextMenu
                            {
                                Button
                                {
                                    let _ = appLogMsg("...\(ClassInfo.sClsDisp):AppAboutView in Text.contextMenu.'copy' button #3...")
                                    self.copyJmSwiftDataFilesLocationToClipboard()
                                }
                                label:
                                {
                                    Text("Copy to Clipboard")
                                }
                            }
                    #endif
                    #if INSTANTIATE_APP_SWIFTDATAMANAGER
                        Text("")
                            .font(.caption2)
                        Text("(App) SwiftData file(s) location:")
                            .font(.caption2)
                        Text("\(self.getAppSwiftDataFilesLocation())")
                            .font(.caption2)
                            .contextMenu
                            {
                                Button
                                {
                                    let _ = appLogMsg("...\(ClassInfo.sClsDisp):AppAboutView in Text.contextMenu.'copy' button #4...")
                                    self.copyAppSwiftDataFilesLocationToClipboard()
                                }
                                label:
                                {
                                    Text("Copy to Clipboard")
                                }
                            }
                    #endif
                        Text("- - - - - - - - - - - - - - -")
                            .font(.caption2)
                        Text("")
                            .font(.caption2)

                        Text("\(JmXcodeBuildSettings.jmAppCopyright)")
                            .italic()
                            .font(.caption2)

                        // <<CHICKEN-TRACKS>> Added (v1.2601, 2026-08-07) — "Credits" section, below
                        // the copyright block per Daryl's placement instruction. Omitted entirely
                        // (no Divider, no empty space) when 'sAppAboutCreditsMarkdown' is empty —
                        // see the init()/property CHICKEN-TRACKS above for how it's loaded. The
                        // heading itself ("## Credits") lives IN the .md file, not hardcoded here,
                        // so the file fully owns its own content/structure.
                        if (!sAppAboutCreditsMarkdown.isEmpty)
                        {
                            Text("")
                                .font(.caption2)
                            Text("- - - - - - - - - - - - - - -")
                                .font(.caption2)
                            Text("")
                                .font(.caption2)
                            // <<CHICKEN-TRACKS>> Fixed (v1.2606, 2026-08-07) — plain SwiftUI '.font()'
                            // has no effect on a 'Markdown' view (confirmed against the swift-
                            // markdown-ui package source): it builds its own Font internally from a
                            // separate '\.textStyle'/'\.theme' environment pipeline (FontSize/
                            // FontWeight/etc., composed into an AttributeContainer), never reading
                            // SwiftUI's '\.font' environment key that plain Text consults. The
                            // correct modifier is '.markdownTextStyle { FontSize(...) }' — it sets
                            // the theme's BASE text size, and since '.basic' theme's headings are
                            // defined as relative em-multipliers of that base (heading2 = 1.5x, see
                            // Theme+Basic.swift), this scales the "## Credits" heading down
                            // proportionally too, not just the body text.
                            Markdown(sAppAboutCreditsMarkdown)
                                .markdownTheme(.basic)
                                .markdownTextStyle
                                {
                                    FontSize(11)
                                }
                                .textSelection(.enabled)
                            Text("")
                                .font(.caption2)
                            Text("- - - - - - - - - - - - - - -")
                                .font(.caption2)
                        }

                #if os(iOS) && INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
                    if (!appGlobalInfo.bGlobalProcessInfoIsiOSAppOnMac &&
                        (AppGlobalInfo.bEnableAppAdsPlaceholder  == true ||
                         AppGlobalInfo.bEnableAppAdsTesting      == true ||
                         AppGlobalInfo.bEnableAppAdsProduction   == true))
                    {
                        Text("")            
                            .hidden()
                            .frame(minWidth: 1, idealWidth: 2, maxWidth: 3,
                                   minHeight:1, idealHeight:2, maxHeight:3)
                            .padding(.bottom, 100)
                    }
                #endif
                    }
                #if os(macOS)
                    .frame(height:300)
                #elseif os(iOS)
                    .frame(minHeight:200)
                #endif

                    // <<CHICKEN-TRACKS>> Added (v1.2607, 2026-08-09) — reserve-space placeholder at
                    // the TRUE end of the outer ScrollView's content. Needed now that 'Divider()' and
                    // the Ad banner (below) have moved OUT of this ScrollView to become real
                    // ZStack(alignment:.bottom) siblings (see that CHICKEN-TRACKS) — without this,
                    // the last visible line of scrollable text would be hidden behind the now-pinned
                    // overlay. Same ~100pt value the pre-existing (and, it turns out, largely inert —
                    // see below) inner reserve-space block above already used for this same Ad
                    // banner's footprint.
                #if os(iOS) && INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
                    if (!appGlobalInfo.bGlobalProcessInfoIsiOSAppOnMac &&
                        (AppGlobalInfo.bEnableAppAdsPlaceholder  == true ||
                         AppGlobalInfo.bEnableAppAdsTesting      == true ||
                         AppGlobalInfo.bEnableAppAdsProduction   == true))
                    {
                        Text("")
                            .hidden()
                            .frame(minWidth: 1, idealWidth: 2, maxWidth: 3,
                                   minHeight:1, idealHeight:2, maxHeight:3)
                            .padding(.bottom, 100)
                    }
                #endif
                }

                Text("")
                    .hidden()
                    .onAppear(perform:{ let _ = self.finishAppInitialization() })
                    .frame(minWidth: 1, idealWidth: 2, maxWidth: 3,
                           minHeight:1, idealHeight:2, maxHeight:3)

                // <<CHICKEN-TRACKS>> Fixed (v1.2607, 2026-08-09) — 'Divider()' and the Ad banner used
                // to be siblings INSIDE the outer ScrollView above (scroll-flow content), not true
                // ZStack(alignment:.bottom) overlay children, despite the ZStack wrapper — the exact
                // same bug already found and fixed today in NWSNexRadRadarViews.swift/
                // AppCoreLocationMapView.swift: no visible scrollbar hint, so the Ad was easy to miss
                // entirely unless you happened to scroll all the way down. Moved here, as direct
                // ZStack children, so the Ad is now genuinely pinned/always-visible at the true
                // bottom of the screen, and the scrollable text area above it is what the user must
                // scroll through — matching Daryl's 2026-08-09 direction exactly.

                Divider()

            #if os(iOS) && INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
                if (!appGlobalInfo.bGlobalProcessInfoIsiOSAppOnMac &&
                    (AppGlobalInfo.bEnableAppAdsPlaceholder  == true ||
                     AppGlobalInfo.bEnableAppAdsTesting      == true ||
                     AppGlobalInfo.bEnableAppAdsProduction   == true))
                {
                    VStack
                    {
                    if (AppGlobalInfo.bEnableAppAdsTesting    == true ||
                        AppGlobalInfo.bEnableAppAdsProduction == true)
                    {
                        let _ = appLogMsg("AppAboutView.View: Invoking 'BannerContentView()'...")
                        BannerContentView(navigationTitle:"")
                        let _ = appLogMsg("AppAboutView.View: Invoked  'BannerContentView()'...")
                    }
                    else
                    {
                        if (AppGlobalInfo.bEnableAppAdsPlaceholder == true)
                        {
                            HStack
                            {
                            if #available(iOS 17.0, *)
                            {
                                GeometryReader
                                { geometry in
                                    Image(ImageResource(name:"Gfx/Placeholder-for-Ads", bundle:Bundle.main))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:geometry.size.width, height:50)
                                }
                                .frame(height:50)
                            }
                            else
                            {
                                Image(ImageResource(name:"Gfx/Placeholder-for-Ads", bundle:Bundle.main))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:320, height:50, alignment:.center)
                            }
                            }
                        }
                    }
                    }
                    .frame(minHeight:75)
                }
            #endif
            }
            .frame(minHeight:75)
        }
        
    }
    
    private func finishAppInitialization()
    {
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Finish the App 'initialization'...
  
    #if USE_APP_LOGGING_BY_VISITOR
        appLogMsg("\(ClassInfo.sClsDisp) Invoking the 'jmAppDelegateVisitor.checkAppDelegateVisitorTraceLogFileForSize()'...")
        self.jmAppDelegateVisitor.checkAppDelegateVisitorTraceLogFileForSize()
        appLogMsg("\(ClassInfo.sClsDisp) Invoked  the 'jmAppDelegateVisitor.checkAppDelegateVisitorTraceLogFileForSize()'...")
    #endif
        appLogMsg("\(sCurrMethodDisp) Exiting...")
        return
    }
    
#if USE_APP_LOGGING_BY_VISITOR
    private func getLogFilespecFileSizeDisplayableMB()->String
    {
        let sCurrMethodDisp:String = #JmCurrentMethodInfo
          
        appLogMsg("\(sCurrMethodDisp) Invoked - 'sAppDelegateVisitorLogFilespec' is [\(jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec!)]...")

        // Get the size of the LogFilespec in a displayable MB string...

        let sLogFilespecSizeInMB:String = JmFileIO.getFilespecSizeAsDisplayableMB(sFilespec:self.jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec)
        appLogMsg("\(sCurrMethodDisp) Exiting - 'sLogFilespecSizeInMB' is [\(sLogFilespecSizeInMB)] for 'sAppDelegateVisitorLogFilespec' of [\(jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec!)]...")
        return sLogFilespecSizeInMB
    }
#endif

#if USE_APP_LOGGING_BY_VISITOR && INSTANTIATE_APP_JMSWIFTDATAMANAGER
    private func getJmSwiftDataFilesLocation()->String
    {
        let sCurrMethodDisp:String = #JmCurrentMethodInfo
          
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Get the location of the (Jm) SwiftData file(s)...

        var sJmSwiftDataFilesLocation:String = "-unknown-"

        if (self.jmAppDelegateVisitor.jmAppSwiftDataManager != nil)
        {
            if (self.jmAppDelegateVisitor.jmAppSwiftDataManager?.modelContext != nil)
            {
                if let urlSwiftDataLocation = self.jmAppDelegateVisitor.jmAppSwiftDataManager?.modelContext!.container.configurations.first?.url 
                {
                    sJmSwiftDataFilesLocation = String(describing:urlSwiftDataLocation).stripOptionalStringWrapper()
                    appLogMsg("\(sCurrMethodDisp) <JmSwiftData Location> 📱 The SwiftData 'location' is [\(String(describing:urlSwiftDataLocation).stripOptionalStringWrapper())]...")
                    appLogMsg("\(sCurrMethodDisp) <JmSwiftData Location> 📱 The SwiftData 'self.jmAppDelegateVisitor.jmAppSwiftDataManager?.modelContext!.container.configurations' is [\(String(describing: self.jmAppDelegateVisitor.jmAppSwiftDataManager?.modelContext!.container.configurations))]...")
                }
            }
        }

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sJmSwiftDataFilesLocation' is [\(sJmSwiftDataFilesLocation)]...")
        return sJmSwiftDataFilesLocation
    }
#endif
    
#if INSTANTIATE_APP_SWIFTDATAMANAGER
    private func getAppSwiftDataFilesLocation()->String
    {
        let sCurrMethodDisp:String = #JmCurrentMethodInfo
          
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Get the location of the (App) SwiftData file(s)...

        var sAppSwiftDataFilesLocation:String = "-unknown-"

        if (self.appSwiftDataManager.modelContext != nil)
        {
            if let urlSwiftDataLocation = self.appSwiftDataManager.modelContext!.container.configurations.first?.url 
            {
                sAppSwiftDataFilesLocation = String(describing:urlSwiftDataLocation).stripOptionalStringWrapper()
                appLogMsg("\(sCurrMethodDisp) <AppSwiftData Location> 📱 The SwiftData 'location' is [\(String(describing:urlSwiftDataLocation).stripOptionalStringWrapper())]...")
                appLogMsg("\(sCurrMethodDisp) <AppSwiftData Location> 📱 The SwiftData 'self.appSwiftDataManager.modelContext.container.configurations' is [\(self.appSwiftDataManager.modelContext!.container.configurations)]...")
            }
        }

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppSwiftDataFilesLocation' is [\(sAppSwiftDataFilesLocation)]...")
        return sAppSwiftDataFilesLocation
    }
#endif
    
#if USE_APP_LOGGING_BY_VISITOR
    private func copyLogFilespecToClipboard()
    {
        let sCurrMethodDisp:String = #JmCurrentMethodInfo
          
        appLogMsg("\(sCurrMethodDisp) Invoked - for text of [\(self.jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec!)]...")
        
    #if os(macOS)
        pasteboard.prepareForNewContents()
        pasteboard.setString(self.jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec!, forType:.string)
    #elseif os(iOS)
        pasteboard.string = self.jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec!
    #endif

        appLogMsg("\(sCurrMethodDisp) Exiting...")
        return
    }
#endif
    
    private func copyUserDefaultsFilespecToClipboard()
    {
        let sCurrMethodDisp:String = #JmCurrentMethodInfo
          
        appLogMsg("\(sCurrMethodDisp) Invoked - for text of [\(self.appGlobalInfo.sAppUserDefaultsFileLocation)]...")
        
    #if os(macOS)
        pasteboard.prepareForNewContents()
        pasteboard.setString(self.appGlobalInfo.sAppUserDefaultsFileLocation, forType:.string)
    #elseif os(iOS)
        pasteboard.string = self.appGlobalInfo.sAppUserDefaultsFileLocation
    #endif

        appLogMsg("\(sCurrMethodDisp) Exiting...")
        return
    }
    
#if USE_APP_LOGGING_BY_VISITOR && INSTANTIATE_APP_JMSWIFTDATAMANAGER
    private func copyJmSwiftDataFilesLocationToClipboard()
    {
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        let sJmSwiftDataFilesLocation:String = self.getJmSwiftDataFilesLocation()
          
        appLogMsg("\(sCurrMethodDisp) Invoked - for text of [\(sJmSwiftDataFilesLocation)]...")
        
    #if os(macOS)
        pasteboard.prepareForNewContents()
        pasteboard.setString(sJmSwiftDataFilesLocation, forType:.string)
    #elseif os(iOS)
        pasteboard.string = sJmSwiftDataFilesLocation
    #endif

        appLogMsg("\(sCurrMethodDisp) Exiting...")
        return
    }
#endif
    
#if INSTANTIATE_APP_SWIFTDATAMANAGER
    private func copyAppSwiftDataFilesLocationToClipboard()
    {
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        let sAppSwiftDataFilesLocation:String = self.getAppSwiftDataFilesLocation()
          
        appLogMsg("\(sCurrMethodDisp) Invoked - for text of [\(sAppSwiftDataFilesLocation)]...")
        
    #if os(macOS)
        pasteboard.prepareForNewContents()
        pasteboard.setString(sAppSwiftDataFilesLocation, forType:.string)
    #elseif os(iOS)
        pasteboard.string = sAppSwiftDataFilesLocation
    #endif

        appLogMsg("\(sCurrMethodDisp) Exiting...")
        return
    }
#endif
    
}   // End of struct AppAboutView:View.

@available(iOS 17.0, *)
#Preview
{
    AppAboutView()
}

