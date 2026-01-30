//
//  JmNSAppDelegate.swift
//  <<< App 'dependent' >>>
//
//  Created by JustMacApps.net on 07/19/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import XCGLogger

#if os(macOS)
//class JmNSAppDelegate:NSObject, NSApplicationDelegate, ObservableObject
class JmNSAppDelegate:NSObject, NSApplicationDelegate
{

    struct ClassInfo
    {
        static let sClsId        = "JmNSAppDelegate"
        static let sClsVers      = "v1.2101"
        static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    struct ClassSingleton
    {
        static var appDelegate:JmNSAppDelegate?              = nil
    }

    // Various App field(s):

               var appGlobalInfo:AppGlobalInfo               = AppGlobalInfo.ClassSingleton.appGlobalInfo
               var jmAppDelegateVisitor:JmAppDelegateVisitor = JmAppDelegateVisitor.ClassSingleton.appDelegateVisitor

               var cAppDelegateInitCalls:Int                 = 0

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
        asToString.append("'appGlobalInfo': [\(self.appGlobalInfo)],")
        asToString.append("'jmAppDelegateVisitor': [\(self.jmAppDelegateVisitor)],")
        asToString.append("],")
        asToString.append("]")

        let sContents:String = "{"+(asToString.joined(separator:""))+"}"

        return sContents

    }   // End of public func toString().

    func applicationWillFinishLaunching(_ aNotification:Notification) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")

        // Pass Notification on the the AppDelegate 'visitor'...

        self.jmAppDelegateVisitor.appDelegateVisitorWillFinishLaunching(aNotification)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        return

    }   // End of func applicationWillFinishLaunching(_ aNotification:Notification).

    func applicationDidFinishLaunching(_ aNotification:Notification) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")

        self.jmAppDelegateVisitor.appDelegateVisitorDidFinishLaunching(aNotification)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        return

    }   // End of func applicationDidFinishLaunching(_ aNotification:Notification).

    func applicationDidBecomeActive(_ aNotification:Notification) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")

        self.jmAppDelegateVisitor.appDelegateVisitorDidBecomeActive(aNotification)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        return

    }   // End of func applicationDidBecomeActive(_ aNotification:Notification).

    func applicationWillTerminate(_ aNotification:Notification) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.jmAppDelegateVisitor.sApplicationName)] - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) AppDelegate is stopping...")

        self.jmAppDelegateVisitor.appDelegateVisitorWillTerminate(aNotification)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Method Exiting...")

        ClassSingleton.appDelegate = nil

        return

    }   // End of func applicationWillTerminate(_ aNotification:Notification).

    func application(_ application:NSApplication, open urls:[URL])
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

    }   // End of func application(_ application:NSApplication, open urls:[URL]).

}   // End of class JmNSAppDelegate:NSObject, NSApplicationDelegate, ObservableObject.
#endif

