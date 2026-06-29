//
//  JmUIAppDelegate.swift
//  <<< App 'dependent' >>>
//
//  Created by JustMacApps.net on 07/19/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import Foundation
import SwiftUI
import Combine
import XCGLogger

#if os(iOS)
@JmEntityInfo(vers:"v1.2501")
class JmUIAppDelegate:NSObject, UIApplicationDelegate, ObservableObject
{

    //  struct ClassInfo
    //  {
        //  static let sClsId        = "JmUIAppDelegate"
        //  static let sClsVers      = "v1.2403"
        //  static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        //  static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    // <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — flagged SENDABLE
    // ("nonisolated global shared mutable state"). Unlike the write-once singletons fixed elsewhere
    // this session, this one is genuinely reassigned twice — set in init(), cleared to nil in
    // applicationWillTerminate(_:) — so 'let' isn't an option. Both writes happen from
    // UIApplicationDelegate lifecycle callbacks, which UIKit guarantees run on the main thread.
    // Confirmed via grep this has zero readers anywhere in the codebase today. nonisolated(unsafe).
    struct ClassSingleton
    {
        nonisolated(unsafe) static var appDelegate:JmUIAppDelegate?               = nil
    }

    // Various App field(s):

               var appGlobalInfo:AppGlobalInfo                = AppGlobalInfo.appGlobalInfo
    #if USE_APP_LOGGING_BY_VISITOR
               var jmAppDelegateVisitor:JmAppDelegateVisitor  = JmAppDelegateVisitor.appDelegateVisitor
    #endif

               var cAppDelegateInitCalls:Int                  = 0

    override init()
    {
        
        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        super.init()
        
        ClassSingleton.appDelegate  = self
        self.cAppDelegateInitCalls += 1
        
        appLogMsg("\(sCurrMethodDisp) Invoked - #(\(self.cAppDelegateInitCalls)) time(s)...")

    #if USE_APP_LOGGING_BY_VISITOR
        // Run the AppDelegateVisitor 'post' initialization Task(s)...

        self.jmAppDelegateVisitor.runPostInitializationTasks()
    #endif

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - #(\(self.cAppDelegateInitCalls)) time(s)...")

        return

    }   // End of override init().
        
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
        asToString.append("],")
        asToString.append("[")
        asToString.append("'cAppDelegateInitCalls': (\(self.cAppDelegateInitCalls)),")
    #if USE_APP_LOGGING_BY_VISITOR
        asToString.append("],")
        asToString.append("[")
        asToString.append("'jmAppDelegateVisitor': [\(self.jmAppDelegateVisitor)],")
    #endif
        asToString.append("],")
        asToString.append("]")

        let sContents:String = "{"+(asToString.joined(separator:""))+"}"

        return sContents

    }   // End of public func toString().

//  func applicationWillFinishLaunching(_ aNotification:Notification) 
    func applicationWillFinishLaunchingWithOptions(_ uiApplication:UIApplication, willFinishLaunchingWithOptions:[UIApplication.LaunchOptionsKey:Any?])->Bool
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

    //  appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(uiApplication)] - 'willFinishLaunchingWithOptions' is [\(willFinishLaunchingWithOptions)] - 'self' is [\(self)]...")

    #if USE_APP_LOGGING_BY_VISITOR
        let _ = self.jmAppDelegateVisitor.appDelegateVisitorWillFinishLaunchingWithOptions(uiApplication, willFinishLaunchingWithOptions:willFinishLaunchingWithOptions)
    #endif

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        return true

    }   // End of func applicationWillFinishLaunchingWithOptions(_ uiApplication:UIApplication, willFinishLaunchingWithOptions:[UIApplication.LaunchOptionsKey:Any?])->Bool.

//  func applicationDidFinishLaunching(_ aNotification:Notification) 
    func applicationDidFinishLaunchingWithOptions(_ uiApplication:UIApplication, didFinishLaunchingWithOptions:[UIApplication.LaunchOptionsKey:Any?])->Bool
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

    //  appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(uiApplication)] - 'didFinishLaunchingWithOptions' is [\(didFinishLaunchingWithOptions)] - 'self' is [\(self)]...")

    #if USE_APP_LOGGING_BY_VISITOR
        let _ = self.jmAppDelegateVisitor.appDelegateVisitorWillFinishLaunchingWithOptions(uiApplication, willFinishLaunchingWithOptions:didFinishLaunchingWithOptions)
    #endif

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        return true

    }   // End of func applicationDidFinishLaunchingWithOptions(_ uiApplication:UIApplication, didFinishLaunchingWithOptions:[UIApplication.LaunchOptionsKey:Any?])->Bool.

    func applicationWillEnterForeground(_ uiApplication:UIApplication) 
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'self' is [\(self)]...")

    #if USE_APP_LOGGING_BY_VISITOR
        let _ = self.jmAppDelegateVisitor.applicationWillEnterForeground(uiApplication)
    #endif

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of func applicationWillEnterForeground(_ application:UIApplication).

    @objc public func applicationWillResignActive(_ uiApplication:UIApplication) 
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'self' is [\(self)]...")

    #if USE_APP_LOGGING_BY_VISITOR
        let _ = self.jmAppDelegateVisitor.applicationWillResignActive(uiApplication)
    #endif
        
        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func applicationWillResignActive(_ application:UIApplication).

    @objc public func applicationDidEnterBackground(_ uiApplication:UIApplication) 
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'self' is [\(self)]...")

    #if USE_APP_LOGGING_BY_VISITOR
        let _ = self.jmAppDelegateVisitor.applicationDidEnterBackground(uiApplication)
    #endif
        
        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func applicationDidEnterBackground(_ application:UIApplication).

//  func applicationWillTerminate(_ aNotification:Notification) 
    func applicationWillTerminate(_ uiApplication:UIApplication)
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

    //  appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(uiApplication)] - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) AppDelegate is stopping...")

    #if USE_APP_LOGGING_BY_VISITOR
        self.jmAppDelegateVisitor.appDelegateVisitorWillTerminate(uiApplication)
    #endif

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        ClassSingleton.appDelegate = nil

        return

    }   // End of func applicationWillTerminate(_ uiApplication:UIApplication).

//  func application(_ application:NSApplication, open urls:[URL])
    func application(_ application:UIApplication, open urls:[URL])
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked - 'application' is [\(application)] - 'urls' are [\(urls)]...")
        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) -> Unhandled url(s) -> \(urls)")

    #if USE_APP_LOGGING_BY_VISITOR
        self.jmAppDelegateVisitor.appDelegateVisitorApplication(application, open:urls)
    #endif

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        return

    }   // End of func application(_ application:UIApplication, open urls:[URL]).

    // Called by iOS when the user discards scene sessions (e.g., swipes away a window
    // in the iPad multitasking switcher).  Passed through to JmAppDelegateVisitor for
    // centralised handling consistent with the delegate visitor pattern.

    func application(_ application:UIApplication, didDiscardSceneSessions sceneSessions:Set<UISceneSession>)
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked - 'sceneSessions' has [\(sceneSessions.count)] session(s)...")

        for (iIdx, session) in sceneSessions.enumerated()
        {
            appLogMsg("\(sCurrMethodDisp) Discarded session #(\(iIdx)): 'persistentIdentifier' is [\(session.persistentIdentifier)] - 'configuration.name' is [\(session.configuration.name)]...")
        }

    #if USE_APP_LOGGING_BY_VISITOR
        self.jmAppDelegateVisitor.appDelegateVisitorDidDiscardSceneSessions(application,
                                                                            didDiscardSceneSessions:sceneSessions)
    #endif

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of func application(_ application:UIApplication, didDiscardSceneSessions:Set<UISceneSession>).

    // <<CHICKEN-TRACKS>> application(_:configurationForConnecting:options:) shell WITHDRAWN (v1.2403).
    // This delegate hook caused the App to terminate on every launch because
    // requestSceneSessionDestruction was called against the primary window's session
    // (the session-count guard misfired for both the first and second window).
    // See JmAppDelegateVisitor.swift for the full post-mortem.
    // The fix is in AppWindow2GateView.destroyOwnSceneSession() — the gate view
    // destroys its own scene session from onAppear when bIsUserLoggedIn == false.

}   // End of class JmUIAppDelegate:NSObject, UIApplicationDelegate, ObservableObject.
#endif

