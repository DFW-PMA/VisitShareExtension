//
//  VisitShareExtensionApp.swift
//  VisitShareExtension
//
//  The containing app for the VV Share Extension.
//  Provides instructions and shows status of target apps.
//  Listens for Darwin notifications from extension to open target apps.
//

import Foundation
import SwiftUI

@main
struct VisitShareExtensionApp:App
{
    
    struct ClassInfo
    {
        static let sClsId        = "VisitShareExtensionApp"
        static let sClsVers      = "v1.0703"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // AppDelegate:
    //     (NOTE: This causes the AppDelegate class to instantiate
    //            - use this ONLY once in an App or it will cause multiple instantiation(s) of AppDelegate...

#if os(macOS)
    @NSApplicationDelegateAdaptor(JmNSAppDelegate.self)
                                         var appDelegate
#elseif os(iOS)
    @UIApplicationDelegateAdaptor(JmUIAppDelegate.self)
                                         var appDelegate
#endif

    // App 'environmental' field(s):

//  @Environment(\.dismiss)              var dismiss
    @Environment(\.presentationMode)     var presentationMode
    @Environment(\.openWindow)           var openWindow
    @Environment(\.openURL)              var openURL
    @Environment(\.scenePhase)           var scenePhase

    // App 'global' field(s):

                    var appGlobalInfo:AppGlobalInfo             = AppGlobalInfo.ClassSingleton.appGlobalInfo

    // App Data field(s):

                    let sAppBundlePath:String                   = Bundle.main.bundlePath
    @State private  var appGlobalDeviceType:AppGlobalDeviceType = AppGlobalDeviceType.appGlobalDeviceUndefined

    init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        _appGlobalDeviceType       = State(initialValue:appGlobalInfo.iGlobalDeviceType)

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Configure for iPad...

    #if targetEnvironment(macCatalyst)
        appLogMsg("\(sCurrMethodDisp) Running on macOS via Catalyst...")
    #else
        appLogMsg("\(sCurrMethodDisp) Running on iOS/iPadOS...")
    #endif

        // Configure app appearance

        self.setupAppearance()

        // Dump App 'details'...

        appLogMsg("\n" + String(repeating:"=", count:60))
        appLogMsg("🚀 \(ClassInfo.sClsDisp) Starting...")
        appLogMsg("   Platform: iPadOS")
        appLogMsg("   Date: \(Date())")
        appLogMsg(String(repeating:"=", count:60) + "\n")

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of init().

    var body:some Scene
    {

        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some Scene) - 'sAppBundlePath' is [\(sAppBundlePath)]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some Scene) - [\(String(describing:JmXcodeBuildSettings.jmAppVersionAndBuildNumber))]...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some Scene) - 'appGlobalDeviceType' is (\(String(describing:appGlobalDeviceType)))...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some Scene) - 'AppGlobalInfo.bIsAppLoggingByVisitor' is [\(AppGlobalInfo.bIsAppLoggingByVisitor)] and 'AppGlobalInfo.sAppLoggingMethod' is [\(AppGlobalInfo.sAppLoggingMethod)]...")
        
        WindowGroup
        {
            ContentView()
                .onOpenURL 
                { url in

                    // Handle incoming URL that 'wakes-up' this App (normally from share extension)...

                    appLogMsg("\(ClassInfo.sClsDisp):body(some Scene).ContentView().onOpenURL - Received URL: [\(url)] - <PendingHandoffs> <URLPost> received - invoking 'self.processAnyPendingHandoffs(viaMethod:\".onOpenURL<URLPoat>\")' to pass the 'handoff' to the Target App...")

                    self.processAnyPendingHandoffs(viaMethod:".onOpenURL<URLPoat>")
                }
                .onAppear
                {
                    // Clean up any stale handoffs on launch...

                    VVSharedConfig.cleanupStaleHandoffs()

                    appLogMsg("\(ClassInfo.sClsDisp):body(some Scene).ContentView().onAppear - 'VVSharedConfig.cleanupStaleHandoffs()' was invoked...")

                    if let url = VVSharedConfig.sharedContainerURL
                    {
                        appLogMsg("\(ClassInfo.sClsDisp):body(some Scene).ContentView().onAppear - App Group container accessible: [\(url.path)]...")
                        
                        // Write a test file...

                        let testFile = url.appendingPathComponent("test.txt")
                        try? "Hello from \(Bundle.main.bundleIdentifier ?? "unknown")".write(to:testFile, atomically:true, encoding:.utf8)
                    }
                    else
                    {
                        appLogMsg("\(ClassInfo.sClsDisp):body(some Scene).ContentView().onAppear - ERROR: App Group container NOT accessible!")
                    }

                    // Start listening for Darwin notifications from extension...

                    self.startListeningForHandoffs()
                }
                .onChange(of:scenePhase)
                { newPhase in

                    if newPhase == .active
                    {
                        appLogMsg("\(ClassInfo.sClsDisp):body(some Scene).ContentView().onChange(scenePhase) - App became active, checking for pending handoffs...")

                        // Re-check for any pending handoffs when app becomes active...

                        self.processAnyPendingHandoffs(viaMethod:".onChange(of:scenePhase)")
                    }

                }
        }

    }   // End of var body:some Scene.

    private func setupAppearance() 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of private func setupAppearance().

    // MARK: - Darwin Notification Handling...

    private func startListeningForHandoffs()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Invoked...")

        VVDarwinNotification.startObserving
        {
            // Called when extension posts notification...

            appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Darwin notification received - dispatching to main queue...")

            DispatchQueue.main.async
            {
                self.processAnyPendingHandoffs(viaMethod:".startObserving<DarwinNotification>")
            }
        }

        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Exiting...")

        return

    }   // End of private func startListeningForHandoffs().

    private func processAnyPendingHandoffs(viaMethod:String="unknown")
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Invoked - checking for pending handoffs - 'viaMethod' is [\(viaMethod)]...")

        // Check all target apps for pending handoffs...

        for targetApp in VVSharedTargetApps.allCases
        {
            let pendingFiles = VVSharedConfig.pendingHandoffs(for:targetApp)

            appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Checking target [\(targetApp.displayName)] - found #(\(pendingFiles.count)) pending file(s)...")

            for fileURL in pendingFiles
            {
                do
                {
                    let handoff = try VVMessageHandoff.read(from:fileURL)

                    appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Found handoff for: [\(targetApp.displayName)] - requestID: [\(handoff.requestID)]...")

                    // Build URL and open target app...

                    if let url = targetApp.buildHandoffURL(requestID:handoff.requestID)
                    {
                        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Opening URL: [\(url)]...")

                        UIApplication.shared.open(url, options:[:])
                        { success in

                            if success
                            {
                                appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Successfully opened [\(targetApp.displayName)]...")
                            }
                            else
                            {
                                appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Failed to open [\(targetApp.displayName)] - Error!")
                            }

                        }

                        // Only process one at a time...

                        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Exiting after processing one handoff...")

                        return
                    }
                    else
                    {
                        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Failed to build handoff URL for [\(targetApp.displayName)] - Error!")
                    }
                }
                catch
                {
                    appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Failed to read handoff from [\(fileURL.lastPathComponent)]: [\(error)] - Error!")
                }
            }
        }

        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Exiting - ALL processed or NO pending handoffs found...")

        return

    }   // End of private func processAnyPendingHandoffs(viaMethod:String).

}   // End of @main struct VisitShareExtensionApp:App.
