//
//  JmUIAppDelegate.swift
//  <<< App 'dependent' >>>
//
//  Created by JustMacApps.net on 07/19/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import XCGLogger

#if os(iOS)
//class JmUIAppDelegate:NSObject, UIApplicationDelegate, ObservableObject
class JmUIAppDelegate:NSObject, UIApplicationDelegate
{

    struct ClassInfo
    {
        static let sClsId        = "JmUIAppDelegate"
        static let sClsVers      = "v1.2101"
        static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    struct ClassSingleton
    {
        static var appDelegate:JmUIAppDelegate?               = nil
    }

    // Various App field(s):

               var appGlobalInfo:AppGlobalInfo                = AppGlobalInfo.ClassSingleton.appGlobalInfo
               var jmAppDelegateVisitor:JmAppDelegateVisitor  = JmAppDelegateVisitor.ClassSingleton.appDelegateVisitor

               var cAppDelegateInitCalls:Int                  = 0

    override init()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        super.init()
        
        ClassSingleton.appDelegate  = self
        self.cAppDelegateInitCalls += 1
        
        appLogMsg("\(sCurrMethodDisp) Invoked - #(\(self.cAppDelegateInitCalls)) time(s) - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)]...")

        // Run the AppDelegateVisitor 'post' initialization Task(s)...

        self.jmAppDelegateVisitor.runPostInitializationTasks()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - #(\(self.cAppDelegateInitCalls)) time(s) - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)]...")

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
        asToString.append("],")
        asToString.append("[")
        asToString.append("'jmAppDelegateVisitor': [\(self.jmAppDelegateVisitor)],")
        asToString.append("],")
        asToString.append("]")

        let sContents:String = "{"+(asToString.joined(separator:""))+"}"

        return sContents

    }   // End of public func toString().

//  func applicationWillFinishLaunching(_ aNotification:Notification) 
    func applicationWillFinishLaunchingWithOptions(_ uiApplication:UIApplication, willFinishLaunchingWithOptions:[UIApplication.LaunchOptionsKey:Any?])->Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

    //  appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(uiApplication)] - 'willFinishLaunchingWithOptions' is [\(willFinishLaunchingWithOptions)] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")

        let _ = self.jmAppDelegateVisitor.appDelegateVisitorWillFinishLaunchingWithOptions(uiApplication, willFinishLaunchingWithOptions:willFinishLaunchingWithOptions)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        return true

    }   // End of func applicationWillFinishLaunchingWithOptions(_ uiApplication:UIApplication, willFinishLaunchingWithOptions:[UIApplication.LaunchOptionsKey:Any?])->Bool.

//  func applicationDidFinishLaunching(_ aNotification:Notification) 
    func applicationDidFinishLaunchingWithOptions(_ uiApplication:UIApplication, didFinishLaunchingWithOptions:[UIApplication.LaunchOptionsKey:Any?])->Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

    //  appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(uiApplication)] - 'didFinishLaunchingWithOptions' is [\(didFinishLaunchingWithOptions)] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")

        let _ = self.jmAppDelegateVisitor.appDelegateVisitorWillFinishLaunchingWithOptions(uiApplication, willFinishLaunchingWithOptions:didFinishLaunchingWithOptions)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        return true

    }   // End of func applicationDidFinishLaunchingWithOptions(_ uiApplication:UIApplication, didFinishLaunchingWithOptions:[UIApplication.LaunchOptionsKey:Any?])->Bool.

    func applicationWillEnterForeground(_ uiApplication:UIApplication) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")

        let _ = self.jmAppDelegateVisitor.applicationWillEnterForeground(uiApplication)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of func applicationWillEnterForeground(_ application:UIApplication).

//  func applicationWillTerminate(_ aNotification:Notification) 
    func applicationWillTerminate(_ uiApplication:UIApplication)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

    //  appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(uiApplication)] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) AppDelegate is stopping...")

        self.jmAppDelegateVisitor.appDelegateVisitorWillTerminate(uiApplication)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        ClassSingleton.appDelegate = nil

        return

    }   // End of func applicationWillTerminate(_ uiApplication:UIApplication).

//  func application(_ application:NSApplication, open urls:[URL])
    func application(_ application:UIApplication, open urls:[URL])
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'application' is [\(application)] - 'urls' are [\(urls)]...")
        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) -> Unhandled url(s) -> \(urls)")

        self.jmAppDelegateVisitor.appDelegateVisitorApplication(application, open:urls)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        return

    }   // End of func application(_ application:UIApplication, open urls:[URL]).

}   // End of class JustAMultiplatformClock1NSAppDelegate:NSObject, NSApplicationDelegate, ObservableObject.
#endif

