//
//  JmAppDelegateVisitor.swift
//  JmUtils_Library
//
//  Created by JustMacApps.net on 08/24/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import Combine
import XCGLogger

#if os(iOS)
import UIKit
#if INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
import GoogleMobileAds
#endif
#endif

//@available(macOS 15, *)
@available(iOS 14.0, *)
@objc(JmAppDelegateVisitor)
public class JmAppDelegateVisitor:NSObject, ObservableObject
{

    struct ClassInfo
    {
        static let sClsId        = "JmAppDelegateVisitor"
        static let sClsVers      = "v1.6601"
        static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    struct ClassSingleton
    {
        static 
        var appDelegateVisitor:JmAppDelegateVisitor                = JmAppDelegateVisitor()
    }

    // 'Internal' control struct(s):
    // - Alert Queue Management structures
    
    struct GlobalAlertRequest
    {

        let alertMessage:String
        let alertButtonText:String
        let requestTimestamp:Date
        let requestId:UUID
        
        init(alertMessage:String, alertButtonText:String)
        {

            self.alertMessage     = alertMessage
            self.alertButtonText  = alertButtonText
            self.requestTimestamp = Date()
            self.requestId        = UUID()

        }

    }
    
    struct CompletionAlertRequest
    {

        let alertMessage:String
        let alertButtonText1:String
        let alertButtonText2:String
        let completionHandler1:(()->())?
        let completionHandler2:(()->())?
        let requestTimestamp:Date
        let requestId:UUID
        
        init(alertMessage:String, 
             alertButtonText1:String, 
             alertButtonText2:String,
             completionHandler1:(()->())?,
             completionHandler2:(()->())?)
        {

            self.alertMessage       = alertMessage
            self.alertButtonText1   = alertButtonText1
            self.alertButtonText2   = alertButtonText2
            self.completionHandler1 = completionHandler1
            self.completionHandler2 = completionHandler2
            self.requestTimestamp   = Date()
            self.requestId          = UUID()

        }

    }

    // 'Internal' Trace flag:

    private 
    var bInternalTraceFlag:Bool                                    = false

    // App <global> Message(s) 'stack' cached before XCGLogger is available:

    let appGlobalInfo:AppGlobalInfo                                = AppGlobalInfo.ClassSingleton.appGlobalInfo

    // App <possible> Controls/Managers/Repos/Services:

#if ENABLE_APP_USER_AUTHENTICATION
    //  // App <global> 'Authentication' control(s):
  
    public
    var isUserAuthenticationAvailable:Bool                         = false
#endif
    
#if INSTANTIATE_APP_OBJCSWIFTBRIDGE
    // Swift/ObjC Bridge:

    @objc 
    var jmObjCSwiftEnvBridge:JmObjCSwiftEnvBridge?                 = nil
#endif

// ============================================================================
// SECTION 1: NEW PROPERTIES
// Add after line 119 (after INSTANTIATE_APP_OBJCSWIFTBRIDGE block)
// ============================================================================

#if INSTANTIATE_APP_VV_UIKIT_ALERTS
    // VisitVerify-specific: UIKit Alert Presentation Support
    // This enables direct UIAlertController presentation when in ObjC UIViewController hierarchy
    
    // Reference to VV-specific bridge (provides window access)...

    var vvObjCSwiftEnvBridge:VVObjCSwiftEnvBridge?                 = nil
    
    // UIKit-specific alert queues (independent from SwiftUI queues)...

    private var uiKitGlobalAlertQueue:[GlobalAlertRequest]         = [GlobalAlertRequest]()
    private var uiKitCompletionAlertQueue:[CompletionAlertRequest] = [CompletionAlertRequest]()
    
    // UIKit-specific processing flags...

    private var isProcessingUIKitGlobalAlert:Bool                  = false
    private var isProcessingUIKitCompletionAlert:Bool              = false
    
    // UIKit-specific current alert tracking...

    private var currentUIKitGlobalAlertId:UUID?                    = nil
    private var currentUIKitCompletionAlertId:UUID?                = nil
    
    // Delay for UIKit alerts (matches SwiftUI delay pattern)...

    private let uiKitAlertSignalDelaySeconds:Double                = 0.5
#endif

#if INSTANTIATE_APP_JMSWIFTDATAMANAGER
    // App <possible> JmAppSwiftData Manager instance:
  
    var jmAppSwiftDataManager:JmAppSwiftDataManager?               = nil
#endif

#if INSTANTIATE_APP_METRICKITMANAGER
    // App <possible> (Apple) MetricKitManager instance:

    var jmAppMetricKitManager:JmAppMetricKitManager?               = nil
#endif

#if INSTANTIATE_APP_USERNOTIFICATIONSMANAGER
    // App <possible> (Apple) UNUserNotificationCenter Manager instance:

    var jmAppUserNotificationManager:JmAppUserNotificationManager? = nil
//  var jmAppUserNotificationManager:JmAppUserNotificationManager? = JmAppUserNotificationManager()
#endif

#if INSTANTIATE_APP_PARSECOREMANAGER
    // App <possible> ParseCore (Client) framework Manager instance:

    var jmAppParseCoreManager:JmAppParseCoreManager?               = nil
#endif

#if INSTANTIATE_APP_PARSECOREBKGDDATAREPO
    // App <possible> ParseCore (Client) Background Data Repo instance:

    var jmAppParseCoreBkgdDataRepo:JmAppParseCoreBkgdDataRepo?     = nil
#endif

#if INSTANTIATE_APP_PARSECOREBKGDDATAREPO2
    // App <possible> ParseCore (Client) Background Data Repo #2 instance:

    var jmAppParseCoreBkgdDataRepo2:JmAppParseCoreBkgdDataRepo2?   = nil
#endif

#if INSTANTIATE_APP_PARSECOREBKGDDATAREPO3
    // App <possible> ParseCore (Client) Background Data Repo #3 instance:

    var jmAppParseCoreBkgdDataRepo3:JmAppParseCoreBkgdDataRepo3?   = nil
#endif

#if INSTANTIATE_APP_PARSECOREBKGDDATAREPO4
    // App <possible> ParseCore (Client) Background Data Repo #4 instance:

    var jmAppParseCoreBkgdDataRepo4:JmAppParseCoreBkgdDataRepo4?   = nil
#endif

#if INSTANTIATE_APP_CORELOCATIONSUPPORT
    // App <possible> CoreLocation service instance:

    var jmAppCLModelObservable2:CoreLocationModelObservable2?      = nil
#endif

#if INSTANTIATE_APP_NWSWEATHERMODELOBSERVABLE
    // App <possible> NWSWeatherModel observable instance:

    var nwsWeatherModelObservable:NWSWeatherModelObservable?       = nil
#endif

#if os(macOS)
#if INSTANTIATE_APP_MENUBARSTATUSBAR
    // App <possible> MenuBar NSStatusBar instance:

    var appStatusBar:JustAMenuBarApp2NSStatusBar                   = JustAMenuBarApp2NSStatusBar.ClassSingleton.appStatusBar
#endif
#endif

#if os(macOS)
#if INSTANTIATE_APP_WINDOWPOSITIONMANAGER

    // App <macOS> JmAppWindowPositionManager observable instance:

    @StateObject private
    var jmAppWindowPositionManager:JmAppWindowPositionManager      = JmAppWindowPositionManager()

    // App <macOS> JmAppWindowDelegate instance:

    var jmAppWindowDelegate:JmAppWindowDelegate                    = JmAppWindowDelegate()
    var bAppMainWindowDelegateHasBeenSet:Bool                      = false
#endif
#endif

#if INSTANTIATE_APP_BIGTESTTRACKING
    // App <possible> JmAppWindowPositionManager observable instance:

    var vvAppBigTestTracking:VisitVerifyAppBigTestTracking         = VisitVerifyAppBigTestTracking.vvAppBigTestTracking
#endif

    // App <global> Message(s) 'stack' cached before XCGLogger is available:

    var listPreXCGLoggerMessages:[String]                          = [String]()

    // App 'name' field:

    let sApplicationName:String                                    = AppGlobalInfo.sGlobalInfoAppId

    // Various App field(s):

    var cAppDelegateVisitorInitCalls:Int                           = 0

    var bAppTitleSetupRequired:Bool                                = true
    let bUseApplicationShortTitle:Bool                             = AppGlobalInfo.bUseApplicationShortTitle
    var sApplicationTitle:String                                   = AppGlobalInfo.sApplicationTitle
    let sApplicationShortTitle:String                              = AppGlobalInfo.sApplicationShortTitle

                                                                     // 'help' File extension: "md", "html", or "txt":
    let sHelpBasicFileExt:String                                   = AppGlobalInfo.sHelpBasicFileExt
    var sHelpBasicContents:String                                  = "-N/A-"

    @AppStorage("helpBasicMode") 
    var helpBasicMode                                              = HelpBasicMode.simpletext

    var helpBasicLoader:HelpBasicLoader?                           = nil

    // Misc:

    let bClsTraceInternal:Bool                                     = true
    var bAppDelegateVisitorTraceLogInitRequired:Bool               = true
    var sInitAppDelegateVisitorTraceLogTag:String                  = "-unknown-"
    var bAppDelegateVisitorLogFilespecIsUsable:Bool                = false
    var urlAppDelegateVisitorLogFilespec:URL?                      = nil
    var urlAppDelegateVisitorLogFilepath:URL?                      = nil
    var sAppDelegateVisitorLogFilespec:String!                     = nil
    var sAppDelegateVisitorLogFilepath:String!                     = nil
    var xcgLogger:XCGLogger?                                       = XCGLogger.default
    
    // App <global> SwiftUI View 'Refresh' control(s):

    @Published 
    var appDelegateVisitorSwiftViewsShouldRefresh:Bool             = false
    {
        didSet
        {
            objectWillChange.send()
        }
    }

    // App <global> 'Alert' control(s):

    @Published 
    var appDelegateVisitorSwiftViewsShouldChange:Bool              = false
    {
        didSet
        {
            objectWillChange.send()
        }
    }

    // App <global> 'Alert' control(s):

    @Published 
    var isAppDelegateVisitorShowingAlert:Bool                      = false
    {
        didSet
        {
            objectWillChange.send()
        }
    }

    var sAppDelegateVisitorGlobalAlertMessage:String?              = nil
    var sAppDelegateVisitorGlobalAlertButtonText:String?           = nil

    // App <global> 'Alert' control(s) with (optional) 'completion' closures:

    @Published 
    var isAppDelegateVisitorShowingCompletionAlert:Bool            = false
    {
        didSet
        {
            objectWillChange.send()
        }
    }

    @Published 
    var isAppDelegateVisitorShowingCompletionAlert2ndButton:Bool   = false
    {
        didSet
        {
            objectWillChange.send()
        }
    }

    var sAppDelegateVisitorCompletionAlertMessage:String           = ""
    var sAppDelegateVisitorCompletionAlertButtonText1:String       = ""
    var sAppDelegateVisitorCompletionAlertButtonText2:String       = ""
    var appDelegateVisitorCompletionClosure1:(()->())?             = nil
    var appDelegateVisitorCompletionClosure2:(()->())?             = nil

    // Alert Queue Management properties...
    
    private var globalAlertQueue:[GlobalAlertRequest]              = []
    private var completionAlertQueue:[CompletionAlertRequest]      = []
    private let alertQueueLock:NSLock                              = NSLock()
    
    // Track the currently displayed alert(s) to prevent premature reset...

    private var currentGlobalAlertId:UUID?                         = nil
    private var currentCompletionAlertId:UUID?                     = nil
    
    // Delay before signaling alert (in seconds) - adjust as needed...

    private let alertSignalDelaySeconds:Double                     = 0.50
    
    // Flag(s) to track if alert processing is active...

    private var isProcessingGlobalAlert:Bool                       = false
    private var isProcessingCompletionAlert:Bool                   = false

    // App <global> 'state' control(s):

    var bWasAppLogFilePresentAtStartup:Bool                        = false
    var bWasAppCrashFilePresentAtStartup:Bool                      = false
    var bAppDelegateVisitorCrashMarkerFilespecIsUsable:Bool        = false
    var bAppDelegateVisitorCrashMarkerFilespecIsCreated:Bool       = false
    var urlAppDelegateVisitorCrashMarkerFilespec:URL?              = nil
    var urlAppDelegateVisitorCrashMarkerFilepath:URL?              = nil
    var sAppDelegateVisitorCrashMarkerFilespec:String!             = nil
    var sAppDelegateVisitorCrashMarkerFilepath:String!             = nil
    var urlAppDelegateVisitorLogToSaveFilespec:URL?                = nil
    var sAppDelegateVisitorLogToSaveFilespec:String!               = nil

    // NOTE: <Critical>
    //     This MUST be here as AppGlobalInfo uses this until XCGLogger is available...

    @objc public func xcgLogMsg(_ sMessage:String)
    {
  
        if (self.bAppDelegateVisitorLogFilespecIsUsable == true)
        {
            self.xcgLogger?.info(sMessage)
        }
        else
        {
            print("\(sMessage)")
  
            self.listPreXCGLoggerMessages.append(sMessage)
        }
  
        // Exit:
  
        return
  
    }   // End of @objc public func xcgLogMsg().

    private override init()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        super.init()
        
        self.cAppDelegateVisitorInitCalls           += 1
        self.bAppDelegateVisitorLogFilespecIsUsable  = false

        appLogMsg("\(sCurrMethodDisp) Invoked - #(\(self.cAppDelegateVisitorInitCalls)) time(s) - 'self' is [\(self)]...")

        // NOTE: The method 'performAppDelegateVisitorStartupCrashLogic()' MUST be the first method called
        //       by this 'init()' method to properly handle startup if there was an App 'crash': 
 
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Intermediate - #(\(self.cAppDelegateVisitorInitCalls)) time(s) - Calling 'self.performAppDelegateVisitorStartupCrashLogic(true, bForegroundRestore:false)'...")
        self.performAppDelegateVisitorStartupCrashLogic(true, bForegroundRestore:false)
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Intermediate - #(\(self.cAppDelegateVisitorInitCalls)) time(s) - Called  'self.performAppDelegateVisitorStartupCrashLogic(true, bForegroundRestore:false)'...")

        // Setup the 'logging' output (console and file):

        self.initAppDelegateVisitorTraceLog(initappdelegatetracelogtag:"\(sCurrMethodDisp)<>\(self.cAppDelegateVisitorInitCalls)")

        appLogMsg("\(sCurrMethodDisp) Method Invoked - #(\(self.cAppDelegateVisitorInitCalls)) time(s) - 'sApplicationName' is [\(self.sApplicationName)]...")
        appLogMsg("\(sCurrMethodDisp) AppDelegateVisitor is starting - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' instance 'self.xcgLogger' is being used (default instance)...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - #(\(self.cAppDelegateVisitorInitCalls)) time(s) - 'sApplicationName' is [\(self.sApplicationName)]...")

        return

    }   // End of private override init().
        
    @objc public func runPostInitializationTasks()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")

        // Handle displaying the field(s) of the AppGlobalInfo class:

        self.displayAppGlobalInfoFields()

        // Dump the App 'Info.plist':

        let _ = self.dumpAppInfoPlistToLog()

    #if INSTANTIATE_APP_OBJCSWIFTBRIDGE
        // Setup the Objective-C/Swift Bridge:
  
        self.jmObjCSwiftEnvBridge = JmObjCSwiftEnvBridge.sharedObjCSwiftEnvBridge

        self.jmObjCSwiftEnvBridge?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
  
        appLogMsg("\(sCurrMethodDisp) 'self' is [\(self)] and 'self.jmObjCSwiftEnvBridge' is (\(String(describing: self.jmObjCSwiftEnvBridge))) and 'self.xcgLogger' is [\(String(describing: self.xcgLogger))]...")
  
        // Objective-C call(s) <maybe>:

        if (AppGlobalInfo.bPerformAppObjCSwiftBridgeTest == true)
        {
            // Initialize and call the class DefinesObjCOverrides...

            let definesObjCModule = DefinesObjCOverrides()
          
            appLogMsg("\(sCurrMethodDisp) Objective-C call #1 - calling 'definesObjCModule.initInstance()' with NO parameter(s)...")
          
            definesObjCModule.initInstance()
          
            appLogMsg("\(sCurrMethodDisp) Objective-C call #1 - called  'definesObjCModule.initInstance()' with NO parameter(s)...")

            appLogMsg("\(sCurrMethodDisp) Objective-C call #2 - calling 'definesObjCModule.customLoggerTest1()' with 1 parameter(s)...")
          
            let sHelloMessage1:String = "Message from 'JmAppDelegateVisitor' to 'definesObjCModule.customLoggerTest1(sHelloMessage1)'..."

            definesObjCModule.customLoggerTest1(sHelloMessage1)

            appLogMsg("\(sCurrMethodDisp) Objective-C call #2 - called  'definesObjCModule.customLoggerTest1()' with a parameter of [\(String(describing: sHelloMessage1))]...")

            // Initialize and call the class CalledObjCModule...

            let calledObjCModule = CalledObjCModule()

            appLogMsg("\(sCurrMethodDisp) Objective-C call #3 - calling 'calledObjCModule.initInstance()' with NO parameter(s)...")

            calledObjCModule.initInstance()

            appLogMsg("\(sCurrMethodDisp) Objective-C call #3 - called  'calledObjCModule.initInstance()' with NO parameter(s)...")

            appLogMsg("\(sCurrMethodDisp) Objective-C call #4 - calling 'calledObjCModule.getInternalVariable()' with 1 parameter(s)...")
          
            let sInternalVariable:String? = calledObjCModule.getInternalVariable()

            appLogMsg("\(sCurrMethodDisp) Objective-C call #4 - called  'calledObjCModule.getInternalVariable()' - returned parameter 'sInternalVariable' is [\(String(describing: sInternalVariable))]...")

            appLogMsg("\(sCurrMethodDisp) Objective-C call #5 - calling 'calledObjCModule.sayHello()' with 1 parameter(s)...")
          
            let sHelloMessage2:String = "Message from 'JmAppDelegateVisitor' to 'calledObjCModule.sayHello(sHelloMessage2)'..."

            calledObjCModule.sayHello(sHelloMessage2)

            appLogMsg("\(sCurrMethodDisp) Objective-C call #5 - called  'calledObjCModule.sayHello()' with a parameter of [\(String(describing: sHelloMessage2))]...")
        }
    #endif

    #if INSTANTIATE_APP_JMSWIFTDATAMANAGER
        // Instantiate the JmAppSwiftDataManager...
        
        appLogMsg("\(sCurrMethodDisp) Instantiating the 'self.jmAppSwiftDataManager' instance...")
        
        self.jmAppSwiftDataManager = JmAppSwiftDataManager.ClassSingleton.appSwiftDataManager
        
        self.jmAppSwiftDataManager?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
        
        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'self.jmAppSwiftDataManager' instance...")
    #endif

    #if INSTANTIATE_APP_METRICKITMANAGER
        // Instantiate the jmAppMetricKitManager...

        appLogMsg("\(sCurrMethodDisp) Instantiating the 'self.jmAppMetricKitManager' instance...")

        self.jmAppMetricKitManager = JmAppMetricKitManager()

        self.jmAppMetricKitManager?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
        
        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'self.jmAppMetricKitManager' instance...")
    #endif

    #if INSTANTIATE_APP_USERNOTIFICATIONSMANAGER
        // Instantiate the jmAppUserNotificationManager...

        appLogMsg("\(sCurrMethodDisp) Instantiating the 'self.jmAppUserNotificationManager' instance...")

    //  self.jmAppUserNotificationManager = JmAppUserNotificationManager()
        self.jmAppUserNotificationManager = JmAppUserNotificationManager.ClassSingleton.appUserNotificationManager

        self.jmAppUserNotificationManager?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
        
        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'self.jmAppUserNotificationManager' instance...")
    #endif

    #if INSTANTIATE_APP_PARSECOREMANAGER
        // Instantiate the JmAppParseCoreManager...

        appLogMsg("\(sCurrMethodDisp) Instantiating the 'self.jmAppParseCoreManager' instance...")

    //  self.jmAppParseCoreManager = JmAppParseCoreManager()
        self.jmAppParseCoreManager = JmAppParseCoreManager.ClassSingleton.appParseCoreManager

        self.jmAppParseCoreManager?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
      
        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'self.jmAppParseCoreManager' instance...")
    #endif

    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO
        // Instantiate the JmAppParseCoreBkgdDataRepo...

        appLogMsg("\(sCurrMethodDisp) Instantiating the 'self.jmAppParseCoreBkgdDataRepo' instance...")

        self.jmAppParseCoreBkgdDataRepo = JmAppParseCoreBkgdDataRepo.ClassSingleton.appParseCodeBkgdDataRepo

        self.jmAppParseCoreBkgdDataRepo?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
        
        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'self.jmAppParseCoreBkgdDataRepo' instance...")
    #endif

    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO2
        // Instantiate the JmAppParseCoreBkgdDataRepo2...

        appLogMsg("\(sCurrMethodDisp) Instantiating the 'self.jmAppParseCoreBkgdDataRepo2' instance...")

        self.jmAppParseCoreBkgdDataRepo2 = JmAppParseCoreBkgdDataRepo2.appParseCodeBkgdDataRepo2

        self.jmAppParseCoreBkgdDataRepo2?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
        
        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'self.jmAppParseCoreBkgdDataRepo2' instance...")
    #endif

    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO3
        // Instantiate the JmAppParseCoreBkgdDataRepo3...

        appLogMsg("\(sCurrMethodDisp) Instantiating the 'self.jmAppParseCoreBkgdDataRepo3' instance...")

        self.jmAppParseCoreBkgdDataRepo3 = JmAppParseCoreBkgdDataRepo3.appParseCodeBkgdDataRepo3

        self.jmAppParseCoreBkgdDataRepo3?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
        
        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'self.jmAppParseCoreBkgdDataRepo3' instance...")
    #endif

    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO4
        // Instantiate the JmAppParseCoreBkgdDataRepo4...

        appLogMsg("\(sCurrMethodDisp) Instantiating the 'self.jmAppParseCoreBkgdDataRepo4' instance...")

        self.jmAppParseCoreBkgdDataRepo4 = JmAppParseCoreBkgdDataRepo4.appParseCodeBkgdDataRepo4

        self.jmAppParseCoreBkgdDataRepo4?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
        
        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'self.jmAppParseCoreBkgdDataRepo4' instance...")
    #endif

    #if INSTANTIATE_APP_CORELOCATIONSUPPORT
        // Instantiate the CoreLocationModelObservable()...

        appLogMsg("\(sCurrMethodDisp) Instantiating the 'self.jmAppCLModelObservable2' instance...")

    //  self.jmAppCLModelObservable2 = CoreLocationModelObservable2.ClassSingleton.appCoreLocationModel
        self.jmAppCLModelObservable2 = CoreLocationModelObservable2.appCoreLocationModel

    //  NOTE: No longer needed with 'appLogMsg()'...
    //  self.jmAppCLModelObservable2?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)

        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'self.jmAppCLModelObservable2' instance...")
    #endif

    #if INSTANTIATE_APP_NWSWEATHERMODELOBSERVABLE
        // Instantiate the NWSWeatherModelObservable()...
     
        appLogMsg("\(sCurrMethodDisp) Instantiating the 'self.nwsWeatherModelObservable' instance...")
     
        self.nwsWeatherModelObservable = NWSWeatherModelObservable.ClassSingleton.appNWSWeatherModelObservable
     
        self.nwsWeatherModelObservable?.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
      
        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'self.nwsWeatherModelObservable' instance...")
    #endif

    #if os(macOS)
    #if INSTANTIATE_APP_MENUBARSTATUSBAR
        // Setup the NSStatusBar MenuBar menu(s)...
    
    //  self.appStatusBar = JmObjCSwiftEnvBridge.sharedObjCSwiftEnvBridge
    
        self.appStatusBar.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self.jmAppDelegateVisitor)
    
        appLogMsg("\(sCurrMethodDisp) 'self' is [\(self)] and 'self.appStatusBar' is (\(String(describing: self.appStatusBar)))...")
    #endif
    #endif

    #if INSTANTIATE_APP_BIGTESTTRACKING
        // Instantiate the 'shared' instance of App BigTest tracking...
        
        appLogMsg("------------------------------------------------------------")
        appLogMsg("\(sCurrMethodDisp) Instantiating the 'VisitVerifyAppBigTestTracking' instance...")
        
    //  let vvAppBigTestTracking:VisitVerifyAppBigTestTracking = VisitVerifyAppBigTestTracking.vvAppBigTestTracking
        
        self.vvAppBigTestTracking.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)
        
        appLogMsg("\(sCurrMethodDisp) Instantiated  the 'VisitVerifyAppBigTestTracking' instance...")
        appLogMsg("------------------------------------------------------------")
    #endif

    #if os(macOS)
    #if INSTANTIATE_APP_WINDOWPOSITIONMANAGER
        // Setup the App 'main' Window...

        appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Invoking 'self.setupAppMainWindow()'...")

        self.setupAppMainWindow()

        appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Invoked  'self.setupAppMainWindow()'...")

    //  // Wait a bit longer after launch to ensure system is fully ready...
    //
    //  DispatchQueue.main.asyncAfter(deadline:(.now() + 0.35))
    //  {
    //      appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Invoking 'self.setupAppMainWindow()'...")
    //
    //      self.setupAppMainWindow()
    //
    //      appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Invoked  'self.setupAppMainWindow()'...")
    //  }
    #endif
    #endif

    #if os(iOS)
    #if INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
        // Google AdMob shared instance 'start' <maybe>:

        if (AppGlobalInfo.bEnableAppAdsTesting    == true ||
            AppGlobalInfo.bEnableAppAdsProduction == true)
        {
            // Instantiate the Gooble AdMob Manager...
            // ----------------------------------------------------------------------------------------------
            // NOTE:
            //     *** Terminating app due to uncaught exception 'GADInvalidInitializationException',
            //     reason: 'The Google Mobile Ads SDK was initialized without an application ID.
            //              Google AdMob publishers, follow instructions at 
            //              https://goo.gle/admob-ios-update-plist to set a valid application ID.
            //              Google Ad Manager publishers, 
            //              follow instructions at https://goo.gle/ad-manager-ios-update-plist.'
            //
            //     *** First throw call stack:
            //         (0x18ff0b21c 0x18d3a9abc 0x18ff0d5fc 0x101e1189c 0x101e11a18 0x1013dc584
            //         0x1013f6064 0x101414e30 0x1013eff30 0x1013f08c8 0x21a4549d0 0x21a454aac)
            //         terminating due to uncaught exception of type NSException
            // ----------------------------------------------------------------------------------------------

            appLogMsg("\(sCurrMethodDisp) <GoogleMobileAds> Starting the 'MobileAds.shared.start()' shared instance...")

            MobileAds.shared.start(completionHandler:nil)

            appLogMsg("\(sCurrMethodDisp) <GoogleMobileAds> Started  the 'MobileAds.shared.start()' shared instance...")
        }
    #endif
    #endif

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func runPostInitializationTasks().

    // Method(s) to setup the file and console 'logging' output:

    @objc public func toString() -> String
    {

        var asToString:[String] = Array()

        asToString.append("[")
        asToString.append("[")
        asToString.append("sClsId': [\(ClassInfo.sClsId)],")
        asToString.append("sClsVers': [\(ClassInfo.sClsVers)],")
        asToString.append("sClsDisp': [\(ClassInfo.sClsDisp)],")
        asToString.append("sClsCopyRight': [\(ClassInfo.sClsCopyRight)],")
        asToString.append("bClsTrace': [\(ClassInfo.bClsTrace)],")
        asToString.append("bClsFileLog': [\(ClassInfo.bClsFileLog)],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("'bInternalTraceFlag': [\(String(describing: self.bInternalTraceFlag))],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("sApplicationName': [\(self.sApplicationName)],")
        asToString.append("cAppDelegateVisitorInitCalls': (\(self.cAppDelegateVisitorInitCalls)),")
        asToString.append("],")
        asToString.append("[")
        asToString.append("bAppTitleSetupRequired': [\(self.bAppTitleSetupRequired)],")
        asToString.append("bUseApplicationShortTitle': [\(self.bUseApplicationShortTitle)],")
        asToString.append("sApplicationTitle': [\(self.sApplicationTitle)],")
        asToString.append("sApplicationShortTitle': [\(self.sApplicationShortTitle)],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("sHelpBasicFileExt': [\(self.sHelpBasicFileExt)],")
        asToString.append("sHelpBasicContents': [\(self.sHelpBasicContents)],")
        asToString.append("helpBasicMode': [\(self.helpBasicMode)],")
        asToString.append("helpBasicLoader': [\(String(describing: self.helpBasicLoader?.toString()))],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("bClsTraceInternal': [\(self.bClsTraceInternal)],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("appGlobalInfo': [\(String(describing: self.appGlobalInfo))],")
    #if ENABLE_APP_USER_AUTHENTICATION
        asToString.append("isUserAuthenticationAvailable': [\(String(describing: self.isUserAuthenticationAvailable))],")
    #endif
    #if INSTANTIATE_APP_OBJCSWIFTBRIDGE
        asToString.append("jmObjCSwiftEnvBridge': [\(String(describing: self.jmObjCSwiftEnvBridge))],")
    #endif
    #if INSTANTIATE_APP_VV_UIKIT_ALERTS
        asToString.append("vvObjCSwiftEnvBridge': [\(String(describing: self.vvObjCSwiftEnvBridge))],")
        asToString.append("uiKitGlobalAlertQueue': [\(String(describing: self.uiKitGlobalAlertQueue))],")
        asToString.append("uiKitCompletionAlertQueue': [\(String(describing: self.uiKitCompletionAlertQueue))],")
        asToString.append("isProcessingUIKitGlobalAlert': [\(String(describing: self.isProcessingUIKitGlobalAlert))],")
        asToString.append("isProcessingUIKitCompletionAlert': [\(String(describing: self.isProcessingUIKitCompletionAlert))],")
        asToString.append("currentUIKitGlobalAlertId': [\(String(describing: self.currentUIKitGlobalAlertId))],")
        asToString.append("currentUIKitCompletionAlertId': [\(String(describing: self.currentUIKitCompletionAlertId))],")
        asToString.append("uiKitAlertSignalDelaySeconds': #(\(String(describing: self.uiKitAlertSignalDelaySeconds))),")
    #endif
    #if INSTANTIATE_APP_JMSWIFTDATAMANAGER
        asToString.append("jmAppSwiftDataManager': [\(String(describing: self.jmAppSwiftDataManager))],")
    #endif
    #if INSTANTIATE_APP_METRICKITMANAGER
        asToString.append("jmAppMetricKitManager': [\(String(describing: self.jmAppMetricKitManager))],")
    #endif
    #if INSTANTIATE_APP_USERNOTIFICATIONSMANAGER
        asToString.append("jmAppUserNotificationManager': [\(String(describing: self.jmAppUserNotificationManager))],")
    #endif
    #if INSTANTIATE_APP_PARSECOREMANAGER
        asToString.append("jmAppParseCoreManager': [\(String(describing: self.jmAppParseCoreManager))],")
    #endif
    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO
        asToString.append("jmAppParseCoreBkgdDataRepo': [\(String(describing: self.jmAppParseCoreBkgdDataRepo))],")
    #endif
    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO2
        asToString.append("jmAppParseCoreBkgdDataRepo2': [\(String(describing: self.jmAppParseCoreBkgdDataRepo2))],")
    #endif
    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO3
        asToString.append("jmAppParseCoreBkgdDataRepo3': [\(String(describing: self.jmAppParseCoreBkgdDataRepo3))],")
    #endif
    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO4
        asToString.append("jmAppParseCoreBkgdDataRepo4': [\(String(describing: self.jmAppParseCoreBkgdDataRepo4))],")
    #endif
    #if INSTANTIATE_APP_CORELOCATIONSUPPORT
        asToString.append("jmAppCLModelObservable2': [\(String(describing: self.jmAppCLModelObservable2))],")
    #endif
    #if INSTANTIATE_APP_NWSWEATHERMODELOBSERVABLE
        asToString.append("nwsWeatherModelObservable': [\(String(describing: self.nwsWeatherModelObservable))],")
    #endif
    #if os(macOS)
    #if INSTANTIATE_APP_MENUBARSTATUSBAR
        asToString.append("appStatusBar': [\(String(describing: self.appStatusBar))],")
    #endif
    #if INSTANTIATE_APP_WINDOWPOSITIONMANAGER
        asToString.append("jmAppWindowPositionManager': [\(String(describing: self.jmAppWindowPositionManager))],")
        asToString.append("jmAppWindowDelegate': [\(String(describing: self.jmAppWindowDelegate))],")
        asToString.append("bAppMainWindowDelegateHasBeenSet': [\(String(describing: self.bAppMainWindowDelegateHasBeenSet))],")
    #endif
    #endif
    #if INSTANTIATE_APP_BIGTESTTRACKING
        asToString.append("vvAppBigTestTracking': [\(String(describing: self.vvAppBigTestTracking))],")
    #endif        
        asToString.append("],")
        asToString.append("[")
        asToString.append("bAppDelegateVisitorTraceLogInitRequired': [\(self.bAppDelegateVisitorTraceLogInitRequired)],")
        asToString.append("sInitAppDelegateVisitorTraceLogTag': [\(self.sInitAppDelegateVisitorTraceLogTag)],")
        asToString.append("bAppDelegateVisitorLogFilespecIsUsable': [\(String(describing: self.bAppDelegateVisitorLogFilespecIsUsable))],")
        asToString.append("urlAppDelegateVisitorLogFilespec': [\(String(describing: self.urlAppDelegateVisitorLogFilespec))],")
        asToString.append("urlAppDelegateVisitorLogFilepath': [\(String(describing: self.urlAppDelegateVisitorLogFilepath))],")
        asToString.append("sAppDelegateVisitorLogFilespec': [\(String(describing: self.sAppDelegateVisitorLogFilespec))],")
        asToString.append("sAppDelegateVisitorLogFilepath': [\(String(describing: self.sAppDelegateVisitorLogFilepath))],")
        asToString.append("xcgLogger': [\(String(describing: self.xcgLogger))],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("appDelegateVisitorSwiftViewsShouldRefresh': [\(String(describing: self.appDelegateVisitorSwiftViewsShouldRefresh))],")
        asToString.append("appDelegateVisitorSwiftViewsShouldChange': [\(String(describing: self.appDelegateVisitorSwiftViewsShouldChange))],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("isAppDelegateVisitorShowingAlert': [\(self.isAppDelegateVisitorShowingAlert)],")
        asToString.append("sAppDelegateVisitorGlobalAlertMessage': [\(String(describing: self.sAppDelegateVisitorGlobalAlertMessage))],")
        asToString.append("sAppDelegateVisitorGlobalAlertButtonText': [\(String(describing: self.sAppDelegateVisitorGlobalAlertButtonText))],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("isAppDelegateVisitorShowingCompletionAlert': [\(self.isAppDelegateVisitorShowingCompletionAlert)],")
        asToString.append("isAppDelegateVisitorShowingCompletionAlert2ndButton': [\(self.isAppDelegateVisitorShowingCompletionAlert2ndButton)],")
        asToString.append("sAppDelegateVisitorCompletionAlertMessage': [\(String(describing: self.sAppDelegateVisitorCompletionAlertMessage))],")
        asToString.append("sAppDelegateVisitorCompletionAlertButtonText1': [\(String(describing: self.sAppDelegateVisitorCompletionAlertButtonText1))],")
        asToString.append("sAppDelegateVisitorCompletionAlertButtonText2': [\(String(describing: self.sAppDelegateVisitorCompletionAlertButtonText2))],")
        asToString.append("appDelegateVisitorCompletionClosure1': [\(String(describing: self.appDelegateVisitorCompletionClosure1))],")
        asToString.append("appDelegateVisitorCompletionClosure2': [\(String(describing: self.appDelegateVisitorCompletionClosure2))],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("globalAlertQueue': [\(String(describing: self.globalAlertQueue))],")
        asToString.append("completionAlertQueue': [\(String(describing: self.completionAlertQueue))],")
        asToString.append("alertQueueLock': [\(String(describing: self.alertQueueLock))],")
        asToString.append("currentGlobalAlertId': [\(String(describing: self.currentGlobalAlertId))],")
        asToString.append("currentCompletionAlertId': [\(String(describing: self.currentCompletionAlertId))],")
        asToString.append("alertSignalDelaySeconds': #(\(String(describing: self.alertSignalDelaySeconds))),")
        asToString.append("isProcessingGlobalAlert': [\(String(describing: self.isProcessingGlobalAlert))],")
        asToString.append("isProcessingCompletionAlert': [\(String(describing: self.isProcessingCompletionAlert))],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("bWasAppLogFilePresentAtStartup': [\(self.bWasAppLogFilePresentAtStartup)],")
        asToString.append("bWasAppCrashFilePresentAtStartup': [\(self.bWasAppCrashFilePresentAtStartup)],")
        asToString.append("bAppDelegateVisitorCrashMarkerFilespecIsUsable': [\(self.bAppDelegateVisitorCrashMarkerFilespecIsUsable)],")
        asToString.append("bAppDelegateVisitorCrashMarkerFilespecIsCreated': [\(self.bAppDelegateVisitorCrashMarkerFilespecIsCreated)],")
        asToString.append("urlAppDelegateVisitorCrashMarkerFilespec': [\(String(describing: self.urlAppDelegateVisitorCrashMarkerFilespec))],")
        asToString.append("urlAppDelegateVisitorCrashMarkerFilepath': [\(String(describing: self.urlAppDelegateVisitorCrashMarkerFilepath))],")
        asToString.append("sAppDelegateVisitorCrashMarkerFilespec': [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilespec))],")
        asToString.append("sAppDelegateVisitorCrashMarkerFilepath': [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilepath))],")
        asToString.append("urlAppDelegateVisitorLogToSaveFilespec': [\(String(describing: self.urlAppDelegateVisitorLogToSaveFilespec))],")
        asToString.append("sAppDelegateVisitorLogToSaveFilespec': [\(String(describing: self.sAppDelegateVisitorLogToSaveFilespec))],")
        asToString.append("],")
        asToString.append("]")

        let sContents:String = "{"+(asToString.joined(separator:""))+"}"

        return sContents

    }   // End of @objc public func toString().

    private func initAppDelegateVisitorTraceLog(initappdelegatetracelogtag:String = "-unknown-")
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        if (self.bAppDelegateVisitorTraceLogInitRequired == true)
        {
            self.setupAppDelegateVisitorTraceLogFile()
            self.setupAppDelegateVisitorXCGLogger()

            if (self.bAppDelegateVisitorLogFilespecIsUsable == true &&
                self.listPreXCGLoggerMessages.count          > 0)
            {
                appLogMsg("")
                appLogMsg("\(sCurrMethodDisp) <<< === Spooling the XCGLogger 'pre' Message(s) === >>>")
                appLogMsg(self.listPreXCGLoggerMessages.joined(separator:"\n"))
                appLogMsg("\(sCurrMethodDisp) <<< === Spooled  the XCGLogger 'pre' Message(s) === >>>")
                appLogMsg("")
            }

            appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'initappdelegatetracelogtag' is [\(initappdelegatetracelogtag)]...")

            self.sInitAppDelegateVisitorTraceLogTag = initappdelegatetracelogtag

            if (self.sInitAppDelegateVisitorTraceLogTag.count < 1)
            {
                self.sInitAppDelegateVisitorTraceLogTag = "-unknown-"

                let sSearchMessage:String = "Supplied 'init' AppDelegateVisitor Trace Log loader TAG string is an 'empty' string - defaulting it to [\(self.sInitAppDelegateVisitorTraceLogTag)] - Warning!"

                appLogMsg("\(sCurrMethodDisp) \(sSearchMessage)")
            }

            appLogMsg("\(sCurrMethodDisp) Exiting - AppDelegateVisitor TraceLog setup was called by [\(self.sInitAppDelegateVisitorTraceLogTag)]...")

            self.bAppDelegateVisitorTraceLogInitRequired = false
        }

        // Exit:

        return

    }   // End of private func initAppDelegateVisitorTraceLog().

    private func setupAppDelegateVisitorTraceLogFile()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Setup the AppDelegateVisitor (physical) 'log' file:

        do
        {
            self.urlAppDelegateVisitorLogFilepath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask ,appropriateFor: nil, create: true)
            self.urlAppDelegateVisitorLogFilespec = self.urlAppDelegateVisitorLogFilepath?.appendingPathComponent(AppGlobalInfo.sGlobalInfoAppLogFilespec)
            self.sAppDelegateVisitorLogFilespec   = self.urlAppDelegateVisitorLogFilespec?.path
            self.sAppDelegateVisitorLogFilepath   = self.urlAppDelegateVisitorLogFilepath?.path

            appLogMsg("\(sCurrMethodDisp) 'self.sAppDelegateVisitorLogFilespec' (computed) is [\(String(describing: self.sAppDelegateVisitorLogFilespec))]...")
            appLogMsg("\(sCurrMethodDisp) 'self.sAppDelegateVisitorLogFilepath' (resolved #2) is [\(String(describing: self.sAppDelegateVisitorLogFilepath))]...")

            let bIsAppLogFilePresent:Bool = JmFileIO.fileExists(sFilespec:self.sAppDelegateVisitorLogFilespec)

            if (bIsAppLogFilePresent == true)
            {
                self.bWasAppLogFilePresentAtStartup = true

                // The LOG file 'exists', calculate the 'target' Log file name:

                appLogMsg("\(sCurrMethodDisp) 'self.bWasAppCrashFilePresentAtStartup' is [\(self.bWasAppCrashFilePresentAtStartup)]...")

                if (self.bWasAppCrashFilePresentAtStartup == true)
                {
                    self.urlAppDelegateVisitorLogToSaveFilespec = self.urlAppDelegateVisitorLogFilepath?.appendingPathComponent("\(AppGlobalInfo.sGlobalInfoAppLastCrashLogFilespec)")

                    appLogMsg("\(sCurrMethodDisp) App appears to have been 'crashed'...")
                }
                else
                {
                    self.urlAppDelegateVisitorLogToSaveFilespec = self.urlAppDelegateVisitorLogFilepath?.appendingPathComponent("\(AppGlobalInfo.sGlobalInfoAppLastGoodLogFilespec)")

                    appLogMsg("\(sCurrMethodDisp) App appears to have been terminated 'successfully'...")
                }

                appLogMsg("\(sCurrMethodDisp) Saving the LOG Filespec of [\(String(describing: self.urlAppDelegateVisitorLogFilespec))] to the 'target' LOG Filespec of [\(String(describing: self.urlAppDelegateVisitorLogToSaveFilespec))]...")

                self.sAppDelegateVisitorLogToSaveFilespec = self.urlAppDelegateVisitorLogToSaveFilespec?.path

                // If the 'target' Log file (to be moved to) exists, then remove (delete) it first (or the 'move' will fail):

                let bIsAppLogToSaveFilePresent:Bool = JmFileIO.fileExists(sFilespec:self.sAppDelegateVisitorLogToSaveFilespec)

                if (bIsAppLogToSaveFilePresent == true)
                {
                    try FileManager.default.removeItem(at: self.urlAppDelegateVisitorLogToSaveFilespec!)

                    appLogMsg("\(sCurrMethodDisp) Successfully removed the 'target' LOG Filespec of [\(String(describing: self.urlAppDelegateVisitorLogToSaveFilespec))]...")
                }

                // Save the Log file to the 'target' Log file:

                try FileManager.default.moveItem(at: self.urlAppDelegateVisitorLogFilespec!,
                                                 to: self.urlAppDelegateVisitorLogToSaveFilespec!)

                appLogMsg("\(sCurrMethodDisp) Successfully 'saved' the Log Filespec of [\(String(describing: self.sAppDelegateVisitorLogFilespec))] to a 'target' Log Filespec of [\(String(describing: self.urlAppDelegateVisitorLogToSaveFilespec))]...")
            }
            else
            {
                self.bWasAppLogFilePresentAtStartup = false
            }

            try FileManager.default.createDirectory(atPath: self.sAppDelegateVisitorLogFilepath, withIntermediateDirectories: true, attributes: nil)

            let sContents = "\(sCurrMethodDisp) Invoked - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]..."

            try sContents.write(toFile: self.sAppDelegateVisitorLogFilespec, atomically:true, encoding:String.Encoding.utf8)

            self.bAppDelegateVisitorLogFilespecIsUsable = true

            appLogMsg("\(sCurrMethodDisp) Successfully created the 'path' of [.documentDirectory] and the Log Filespec of [\(String(describing: self.sAppDelegateVisitorLogFilespec))]...")
        }
        catch
        {
            self.bAppDelegateVisitorLogFilespecIsUsable = false

            appLogMsg("\(sCurrMethodDisp) Failed to create the 'path' of [.documentDirectory] - Error: \(error)...")
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'self.bAppDelegateVisitorLogFilespecIsUsable' is [\(self.bAppDelegateVisitorLogFilespecIsUsable)] - 'self.bWasAppLogFilePresentAtStartup' is [\(self.bWasAppLogFilePresentAtStartup)]...")

        return

    }   // End of private func setupAppDelegateVisitorTraceLogFile().

    private func setupAppDelegateVisitorXCGLogger()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) - Invoked...")

        // Setup the AppDelegateVisitor XCGLogger instance:

        self.xcgLogger?.setup(level:             .verbose,
                              showLogIdentifier: false,
                              showFunctionName:  false,
                              showThreadName:    false,
                              showLevel:         false,
                              showFileNames:     false,
                              showLineNumbers:   false,
                              showDate:          true,
                              writeToFile:       self.urlAppDelegateVisitorLogFilespec,
                              fileLevel:         .verbose)

        let listXCGLoggerDestinations = self.xcgLogger?.destinations
        
        appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' (default) instance has these destinations (\(listXCGLoggerDestinations!.count)): [\(String(describing: listXCGLoggerDestinations))]...")
        
        for index in 0 ..< (listXCGLoggerDestinations!.count) 
        {
            appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' (default) instance destination #(\(index)) TYPE is [\(String(describing: type(of: listXCGLoggerDestinations?[index])))]...")
            appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' (default) instance destination #(\(index)) 'is' FileDestination [\(String(describing: (listXCGLoggerDestinations?[index] is FileDestination)))]...")
            appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' (default) instance destination #(\(index)) Destination 'identifier' is [\(String(describing: listXCGLoggerDestinations?[index].identifier))]...")
            appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' (default) instance destination #(\(index)) is [\(String(describing: listXCGLoggerDestinations?[index]))]...")

            if ((listXCGLoggerDestinations?[index] is FileDestination) == true)
            {
                let xcgFileDestination = listXCGLoggerDestinations?[index] as! FileDestination

                appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' FileDestination with 'identifier' of [\(xcgFileDestination.identifier)] is writing to file [\(String(describing: xcgFileDestination.writeToFileURL))]...")
            }
        }
        
        // Add basic app info, version info etc, to the start of the logs:

        self.xcgLogger?.logAppDetails()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) - Exiting...")

        return

    }   // End of private func setupAppDelegateVisitorXCGLogger().

    @objc public func checkAppDelegateVisitorTraceLogFileForSize()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Check the 'default' xcgLogger? File size, clear if it's too large...

        let cTestFilespecSize:Int64 = JmFileIO.getFilespecSize(sFilespec:self.sAppDelegateVisitorLogFilespec)

        if (cTestFilespecSize > AppGlobalInfo.sGlobalInfoAppLogFilespecMaxSize)
        {
            appLogMsg("\(sCurrMethodDisp) Current Log file size of (\(cTestFilespecSize)) is greater then (\(AppGlobalInfo.sGlobalInfoAppLogFilespecMaxSize)) - clearing the file [\(String(describing: self.sAppDelegateVisitorLogFilespec))]...")
            self.clearAppDelegateVisitorTraceLogFile()
            appLogMsg("\(sCurrMethodDisp) Cleared the current Log file [\(String(describing: self.sAppDelegateVisitorLogFilespec))]...")
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func checkAppDelegateVisitorTraceLogFileForSize().

    @objc public func clearAppDelegateVisitorTraceLogFile()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Locate and remove the FileDestination from the 'default' xcgLogger?:

        let listXCGLoggerDestinations    = self.xcgLogger?.destinations
        var xcgFileDestinationIdentifier = XCGLogger.Constants.fileDestinationIdentifier
        
        appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' (default) instance has these destinations (\(listXCGLoggerDestinations!.count)): [\(String(describing: listXCGLoggerDestinations))]...")
        
        for index in 0 ..< (listXCGLoggerDestinations!.count) 
        {
            appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' (default) instance destination #(\(index)) TYPE is [\(String(describing: type(of: listXCGLoggerDestinations?[index])))]...")
            appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' (default) instance destination #(\(index)) 'is' FileDestination [\(String(describing: (listXCGLoggerDestinations?[index] is FileDestination)))]...")
            appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' (default) instance destination #(\(index)) Destination 'identifier' is [\(String(describing: listXCGLoggerDestinations?[index].identifier))]...")
            appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' (default) instance destination #(\(index)) is [\(String(describing: listXCGLoggerDestinations?[index]))]...")

            if ((listXCGLoggerDestinations?[index] is FileDestination) == true)
            {
                let xcgFileDestination = listXCGLoggerDestinations?[index] as! FileDestination

                xcgFileDestinationIdentifier = xcgFileDestination.identifier

                appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' FileDestination with 'identifier' of [\(xcgFileDestination.identifier)] is writing to file [\(String(describing: xcgFileDestination.writeToFileURL))]...")

                if (xcgFileDestinationIdentifier == XCGLogger.Constants.fileDestinationIdentifier)
                {
                    self.xcgLogger?.remove(destination: xcgFileDestination)
                }
            }
        }

        // Clear the AppDelegateVisitor (trace) 'Log' file:

        if (self.bAppDelegateVisitorLogFilespecIsUsable == false)
        {
            appLogMsg("\(sCurrMethodDisp) Exiting - 'self.bAppDelegateVisitorLogFilespecIsUsable' is [\(self.bAppDelegateVisitorLogFilespecIsUsable)]...")

            return
        }

        do 
        {
            let sContents = "\(sCurrMethodDisp) ...Clearing the AppDelegateVisitor (trace) 'Log' file [\(String(describing: self.sAppDelegateVisitorLogFilespec))]..."

            try sContents.write(toFile: self.sAppDelegateVisitorLogFilespec, atomically:true, encoding:String.Encoding.utf8)
        }
        catch _
        {
            appLogMsg("\(sCurrMethodDisp) Exiting - Exception in clearing the AppDelegateVisitor (trace) 'Log' file [\(String(describing: self.sAppDelegateVisitorLogFilespec))]...")

            return
        }

        // Construct and set-up a <new> 'default' FileDestination...

        let xcgFileDestination               = FileDestination(writeToFile: self.urlAppDelegateVisitorLogFilespec!, 
                                                               identifier:  XCGLogger.Constants.fileDestinationIdentifier)
        
        xcgFileDestination.outputLevel       = .verbose
        xcgFileDestination.showLogIdentifier = false
        xcgFileDestination.showFunctionName  = false
        xcgFileDestination.showThreadName    = false
        xcgFileDestination.showLevel         = false
        xcgFileDestination.showFileName      = false
        xcgFileDestination.showLineNumber    = false
        xcgFileDestination.showDate          = true
        
        // Process this destination in the background...
        
        xcgFileDestination.logQueue          = XCGLogger.logQueue
        
        // Re-add the 'default' FileDestination to xcgLogger?:

        self.xcgLogger?.add(destination:xcgFileDestination)
        
        appLogMsg("\(sCurrMethodDisp) XCGLogger 'log' FileDestination with 'identifier' of [\(xcgFileDestination.identifier)] is writing to [\(String(describing: xcgFileDestination.writeToFileURL))]...")

        // Re-add the AppGlobalInfo data 'dump' to the new log...

        self.displayAppGlobalInfoFields()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func clearAppDelegateVisitorTraceLogFile().

    // Method to display the field(s) of the AppGlobalInfo struct:

    private func displayAppGlobalInfoFields()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Get the 'shared' instance of the AppGlobalInfo struct and finish it's 'setup':

    //  let appGlobalInfo:AppGlobalInfo = AppGlobalInfo.ClassSingleton.appGlobalInfo

        self.appGlobalInfo.setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:self)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of private func displayAppGlobalInfoFields().

    // Method(s) that act as AppDelegate 'helpers':

    @objc public func dumpAppInfoPlistToLog() -> Bool
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let infoFileURL = Bundle.main.url(forResource: "Info", withExtension: "plist")

        if (infoFileURL == nil)
        {
            appLogMsg("\(sCurrMethodDisp) Locating the 'resource' URL for the 'Info.plist' (in Bundle.Resources) failed - Warning!")

            return false
        }

        var formatinfoplist                  = PropertyListSerialization.PropertyListFormat.xml
        var dictInfoPlist:[String:AnyObject] = [:]

        do 
        {
            let pListInfo = try Data(contentsOf: infoFileURL!)
          
            dictInfoPlist = try PropertyListSerialization.propertyList(from:    pListInfo,
                                                                       options: PropertyListSerialization.ReadOptions.mutableContainersAndLeaves,
                                                                       format:  &formatinfoplist) as! [String:AnyObject]
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Error reading plist: \(error), format: \(formatinfoplist)...")

            return false
        }

        appLogMsg("\(sCurrMethodDisp) Read the dictionary 'dictInfoPlist' with (\(dictInfoPlist.count)) element(s) of [\(dictInfoPlist)] from file [\(String(describing: infoFileURL))]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return true

    }   // End of @objc public func dumpAppInfoPlistToLog().

    @objc public func dumpAppCommandLineArgs()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let cArgs                  = Int(CommandLine.argc)

        appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")
        appLogMsg("\(sCurrMethodDisp) The Command line input #(\(cArgs)) parameters are:")
        
        for i in 0..<cArgs
        {
            let sArg  = String(cString: CommandLine.unsafeArgv[i]!)
            let sArgV = sArg
            
            appLogMsg("\(sCurrMethodDisp) Input parameter #(\(i)) is [\(sArgV)]...")
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func dumpAppCommandLineArgs().

    @objc public func getAppDelegateVisitorApplicationTitle() -> String
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        if (self.bAppTitleSetupRequired == true)
        {
            appLogMsg("\(sCurrMethodDisp) Setting up the Application 'title'...")

            if (self.bUseApplicationShortTitle == true)
            {
                self.sApplicationTitle = self.sApplicationShortTitle
            }
            else
            {
                self.sApplicationTitle = self.sApplicationName
            }

            appLogMsg("\(sCurrMethodDisp) Set up of the Application 'title' of [\(self.sApplicationTitle)] done...")

            self.bAppTitleSetupRequired = false
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'self.sApplicationTitle' is [\(self.sApplicationTitle)]...")

        return self.sApplicationTitle

    }   // End of @objc public func getAppDelegateVisitorApplicationTitle().

#if INSTANTIATE_APP_WINDOWPOSITIONMANAGER
    public func checkAppMainWindowSetup() 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Invoked - 'self.bAppMainWindowDelegateHasBeenSet' is [\(self.bAppMainWindowDelegateHasBeenSet)]...")

        // If the (app) main window 'delegate' has NOT been set, then do so...

        if (self.bAppMainWindowDelegateHasBeenSet == false)
        {
            appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Intermediate - Invoking 'self.setupAppMainWindow()'...")
            self.setupAppMainWindow()
            appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Intermediate - Invoked  'self.setupAppMainWindow()'...")
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Exiting - 'self.bAppMainWindowDelegateHasBeenSet' is [\(self.bAppMainWindowDelegateHasBeenSet)]...")

        return

    }   // End of public func checkAppMainWindowSetup().

    public func setupAppMainWindow() 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Invoked...")

        // Get the main window...

        if let window = NSApplication.shared.windows.first 
        {
            // Set up window delegate to save position when moved...

            self.jmAppWindowDelegate.setJmAppWindowPositionManager(jmAppWindowPositionManager:self.jmAppWindowPositionManager)

            window.delegate = self.jmAppWindowDelegate
        //  window.delegate = JmAppWindowDelegate(jmAppWindowPositionManager:self.jmAppWindowPositionManager)

            // Restore window position...

            self.jmAppWindowPositionManager.restoreWindowPosition(window)

            // Ensure window is key and front...

            window.makeKeyAndOrderFront(nil)

            self.bAppMainWindowDelegateHasBeenSet = true

            appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Intermediate - Setup the 'self.jmAppWindowDelegate' as a 'window' delegate and set the 'self.jmAppWindowPositionManager' of [\(self.jmAppWindowPositionManager))] for it...")
        }
        else
        {
            self.bAppMainWindowDelegateHasBeenSet = false

            appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Intermediate - Unable to setup the 'self.jmAppWindowDelegate' as a 'window' delegate because the main 'window' couldn't be obtained - Error!")
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) <AppWindowPosition> Exiting...")

        return

    }   // End of public func setupAppMainWindow().
#endif

    @objc public func getAppDelegateVisitorHelpBasicContents() -> String
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        if (self.bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) 'self.helpBasicLoader' is [\(String(describing: self.helpBasicLoader))]...")
        }

        if (self.helpBasicLoader == nil)
        {
            self.helpBasicLoader = HelpBasicLoader()
        }

        var bWasHelpSetupPerformed:Bool = false

        if (self.helpBasicLoader?.bHelpSetupRequired == true)
        {
            appLogMsg("\(sCurrMethodDisp) Setting up HELP 'basic' content(s) - 'self.helpBasicLoader?.bHelpSetupRequired' is [\(String(describing: self.helpBasicLoader?.bHelpSetupRequired))]...")

            self.sHelpBasicContents                  = self.helpBasicLoader?.loadHelpBasicContents(helpbasicfileext:self.sHelpBasicFileExt, helpbasicloadertag:"'get...()'") ?? "---Error: HELP was NOT loaded properly---"
            self.helpBasicLoader?.bHelpSetupRequired = false
            bWasHelpSetupPerformed                   = true

            if (self.bInternalTraceFlag == true)
            {
                appLogMsg("\(sCurrMethodDisp) 'self.helpBasicLoader?.bHelpSetupRequired' is [\(String(describing: self.helpBasicLoader?.bHelpSetupRequired))] - 'self.sHelpBasicContents' is [\(self.sHelpBasicContents)]...")
            }

            appLogMsg("\(sCurrMethodDisp) Set up the HELP 'basic' content(s)...")
        }

        // Exit:

        if (self.bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) 'bWasHelpSetupPerformed' is [\(bWasHelpSetupPerformed)] - 'self.helpBasicLoader?.bHelpSetupRequired' is [\(String(describing: self.helpBasicLoader?.bHelpSetupRequired))] - 'self.sHelpBasicContents' is [\(self.sHelpBasicContents)]...")
        }

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return self.sHelpBasicContents

    }   // End of @objc public func getAppDelegateVisitorHelpBasicContents().

    // Method(s) that act as AppDelegateVistor 'crash' logic:

    @objc public func performAppDelegateVisitorStartupCrashLogic(_ bAppFirstStartCall:Bool = false, bForegroundRestore:Bool = false)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Invoked - parameters 'bAppFirstStartCall' is [\(bAppFirstStartCall)] - 'bForegroundRestore' is [\(bForegroundRestore)]...")

        // Calculate the AppDelegateVisitor (physical) CRASH 'marker' filespec and filepath:

        do 
        {
            self.urlAppDelegateVisitorCrashMarkerFilepath = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
            self.urlAppDelegateVisitorCrashMarkerFilespec = self.urlAppDelegateVisitorCrashMarkerFilepath?.appendingPathComponent(AppGlobalInfo.sGlobalInfoAppCrashMarkerFilespec)
            self.sAppDelegateVisitorCrashMarkerFilespec   = self.urlAppDelegateVisitorCrashMarkerFilespec?.path
            self.sAppDelegateVisitorCrashMarkerFilepath   = self.urlAppDelegateVisitorCrashMarkerFilepath?.path

            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> 'self.sAppDelegateVisitorCrashMarkerFilespec' (computed)    is [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilespec))]...")
            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> 'self.sAppDelegateVisitorCrashMarkerFilepath' (resolved #2) is [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilepath))]...")

            try FileManager.default.createDirectory(atPath:sAppDelegateVisitorCrashMarkerFilepath, withIntermediateDirectories:true, attributes:nil)

            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Successfully created the 'path' of [.documentDirectory]...")
        }
        catch
        {
            self.bAppDelegateVisitorCrashMarkerFilespecIsCreated = false
            self.bAppDelegateVisitorCrashMarkerFilespecIsUsable  = false

            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Failed to create the 'path' of [.documentDirectory] - Detail(s):[\(error)] - Error!")
            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Exiting...")

            return
        }

        // If this is the actual 1st 'start' call, then determine if the AppDelegateVisitor (physical) CRASH 'marker' file is present...

        if (bAppFirstStartCall == true)
        {
            self.bWasAppCrashFilePresentAtStartup = JmFileIO.fileExists(sFilespec:self.sAppDelegateVisitorCrashMarkerFilespec)

            if (self.bWasAppCrashFilePresentAtStartup == false)
            {
                appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> <<< PREVIOUS App execution appears to have been SUCCESSFULL!!! >>>")
            }
            else
            {
                appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> <<< PREVIOUS App execution appears to have CRASHED!!! >>>")
            }
        }

        // (Possibly) Setup the AppDelegateVisitor (physical) CRASH 'marker' file:

        let bDoesAppCrashFileExist:Bool = JmFileIO.fileExists(sFilespec:self.sAppDelegateVisitorCrashMarkerFilespec)

        if (bDoesAppCrashFileExist == false)
        {
            do 
            {
                let dtFormatterDateStamp        = DateFormatter()
                dtFormatterDateStamp.locale     = Locale(identifier: "en_US")
                dtFormatterDateStamp.timeZone   = TimeZone.current
                dtFormatterDateStamp.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"

                let dateStampNow                = Date.now
                let sDateStamp                  = "\(dtFormatterDateStamp.string(from: dateStampNow)) >> "
                let sContents                   = "\(sCurrMethodDisp) <VisitorCrashLogic> Invoked (CRASH 'marker' detection file) - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)] - 'sDateStamp' is [\(sDateStamp)]...\n"

                try sContents.write(toFile:self.sAppDelegateVisitorCrashMarkerFilespec, atomically:true, encoding:String.Encoding.utf8)

                self.bAppDelegateVisitorCrashMarkerFilespecIsCreated = true
                self.bAppDelegateVisitorCrashMarkerFilespecIsUsable  = true

                appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Successfully created the CRASH Marker Filespec of [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilespec))]...")
            }
            catch
            {
                self.bAppDelegateVisitorCrashMarkerFilespecIsCreated = false
                self.bAppDelegateVisitorCrashMarkerFilespecIsUsable  = false

                appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> <VisitorCrashLogic> Failed to create the CRASH Marker Filespec of [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilespec))] - Detail(s):[\(error)] - Error!")
            }
        }
        else
        {
            self.bAppDelegateVisitorCrashMarkerFilespecIsCreated = false
            self.bAppDelegateVisitorCrashMarkerFilespecIsUsable  = true

            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Did NOT create the CRASH Marker Filespec (file already exists) of [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilespec))]...")

            if (bAppFirstStartCall == true)
            {
                let dtFormatterDateStamp        = DateFormatter()
                dtFormatterDateStamp.locale     = Locale(identifier: "en_US")
                dtFormatterDateStamp.timeZone   = TimeZone.current
                dtFormatterDateStamp.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"

                let dateStampNow                = Date.now
                let sDateStamp                  = "\(dtFormatterDateStamp.string(from: dateStampNow)) >> "
                let sNewContents                = "\(sCurrMethodDisp) <VisitorCrashLogic> Invoked (CRASH 'marker' detection file) <AlreadyExisting> - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)] - 'sDateStamp' is [\(sDateStamp)]...\n"
                let bWriteFile                  = JmFileIO.writeFile(sFilespec:self.sAppDelegateVisitorCrashMarkerFilespec, sContents:sNewContents, bAppendToFile:true)
            }

            let sCrashMarkerFileContents = JmFileIO.readFile(sFilespec:self.sAppDelegateVisitorCrashMarkerFilespec)

            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> <CrashMarkerContents> CRASH Marker Filespec (file already exists) of [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilespec))] - 'sCrashMarkerFileContents' is [\(String(describing: sCrashMarkerFileContents))]...")
        }
        
        // Exit:

        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> 'self.bAppDelegateVisitorCrashMarkerFilespecIsCreated' is [\(self.bAppDelegateVisitorCrashMarkerFilespecIsCreated)]...")
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> 'self.bAppDelegateVisitorCrashMarkerFilespecIsUsable' is [\(self.bAppDelegateVisitorCrashMarkerFilespecIsUsable)]...")
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> 'self.bWasAppCrashFilePresentAtStartup' is [\(self.bWasAppCrashFilePresentAtStartup)]...")
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Exiting - 'bDoesAppCrashFileExist' is [\(bDoesAppCrashFileExist)] - parameters were 'bAppFirstStartCall' is [\(bAppFirstStartCall)] - 'bForegroundRestore' is [\(bForegroundRestore)]...")

        return

    }   // End of @objc public func performAppDelegateVisitorStartupCrashLogic(_ bAppFirstStartCall:Bool, bForegroundRestore:Bool).

    @objc public func performAppDelegateVisitorTerminatingCrashLogic()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Invoked...")

        // (Possibly) remove the AppDelegateVisitor (physical) CRASH 'marker' file:

        do 
        {
            let bIsAppCrashMarkerFilePresent:Bool = JmFileIO.fileExists(sFilespec:self.sAppDelegateVisitorCrashMarkerFilespec)

            if (bIsAppCrashMarkerFilePresent == true)
            {
                try FileManager.default.removeItem(at:self.urlAppDelegateVisitorCrashMarkerFilespec!)

                appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> <1st Attempt> Successfully removed the CRASH 'marker' Filespec of [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilespec))]...")

                self.bAppDelegateVisitorCrashMarkerFilespecIsCreated = false
            }
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> <do/catch> <1st Attempt> Failed to remove the CRASH 'marker' Filespec of [\(String(describing:self.sAppDelegateVisitorCrashMarkerFilespec))] - Details:[\(error)] - Error!") 
        }

        self.bAppDelegateVisitorCrashMarkerFilespecIsCreated = false
        self.bAppDelegateVisitorCrashMarkerFilespecIsUsable  = false
        self.bWasAppCrashFilePresentAtStartup                = false

        let bDoesAppCrashFileExist:Bool = JmFileIO.fileExists(sFilespec:self.sAppDelegateVisitorCrashMarkerFilespec)

        if (bDoesAppCrashFileExist == true)
        {
            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> <PostCheck> Failed to remove the CRASH 'marker' Filespec of [\(String(describing:self.sAppDelegateVisitorCrashMarkerFilespec))] - file STILL exists - SEVERE Error!") 

            let dtFormatterDateStamp        = DateFormatter()
            dtFormatterDateStamp.locale     = Locale(identifier: "en_US")
            dtFormatterDateStamp.timeZone   = TimeZone.current
            dtFormatterDateStamp.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"

            let dateStampNow                = Date.now
            let sDateStamp                  = "\(dtFormatterDateStamp.string(from: dateStampNow)) >> "
            let sNewContents                = "\(sCurrMethodDisp) <VisitorCrashLogic> <PostCheck> Failed to remove the CRASH 'marker' Filespec <AlreadyExisting> - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)] - 'sDateStamp' is [\(sDateStamp)]...\n"
            let bWriteFile                  = JmFileIO.writeFile(sFilespec:self.sAppDelegateVisitorCrashMarkerFilespec, sContents:sNewContents, bAppendToFile:true)
            let sCrashMarkerFileContents    = JmFileIO.readFile(sFilespec:self.sAppDelegateVisitorCrashMarkerFilespec)

            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> <CrashMarkerContents> CRASH Marker Filespec (file already exists) of [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilespec))] - 'sCrashMarkerFileContents' is [\(String(describing: sCrashMarkerFileContents))]...")

            do 
            {
                try FileManager.default.removeItem(at:self.urlAppDelegateVisitorCrashMarkerFilespec!)

                appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> <2nd Attempt> Successfully removed the CRASH 'marker' Filespec of [\(String(describing: self.sAppDelegateVisitorCrashMarkerFilespec))]...")
            }
            catch
            {
                appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> <do/catch> <2nd Attempt> Failed to remove the CRASH 'marker' Filespec of [\(String(describing:self.sAppDelegateVisitorCrashMarkerFilespec))] - Details:[\(error)] - Error!") 
            }
        }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> 'self.bAppDelegateVisitorCrashMarkerFilespecIsCreated' is [\(self.bAppDelegateVisitorCrashMarkerFilespecIsCreated)]...")
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> 'self.bAppDelegateVisitorCrashMarkerFilespecIsUsable' is [\(self.bAppDelegateVisitorCrashMarkerFilespecIsUsable)]...")
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> 'self.bWasAppCrashFilePresentAtStartup' is [\(self.bWasAppCrashFilePresentAtStartup)]...")
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Exiting...")

        return

    }   // End of @objc public func performAppDelegateVisitorTerminatingCrashLogic().

// ============================================================================
// SECTION 2: DETECTION METHOD
// Add near the beginning of the class methods section (after init)
// ============================================================================

#if INSTANTIATE_APP_VV_UIKIT_ALERTS
    // -------------------------------------------------------------------------
    // UIKit Detection and Helper Methods
    // FINAL: Uses _patientsVC as deterministic indicator of ObjC readiness
    // -------------------------------------------------------------------------

    private func shouldUseUIKitPresentation()->Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        // No VV bridge reference? → Use SwiftUI path...

        guard let vvBridge = vvObjCSwiftEnvBridge 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> No VV bridge available - using SwiftUI presentation...")

            return false
        }

        // Get AppDelegate...

        guard let appDelegate = vvBridge.objcAppDelegate
        else 
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> No AppDelegate available - using SwiftUI presentation...")

            return false
        }

        // =====================================================================
        // CRITICAL DETERMINISTIC CHECK:
        // _patientsVC is the definitive indicator of ObjC initialization
        // =====================================================================

        // Check if _patientsVC is set (indicates ObjC side fully initialized)...

        if let patientsVC = appDelegate.value(forKey: "_patientsVC") as? UIViewController
        {
            // ObjC side IS initialized → Use UIKit...

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> ObjC side initialized (_patientsVC exists) - routing to UIKit alert queue...")
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> _patientsVC type: [\(String(describing: type(of: patientsVC)))]...")

            return true
        } 
        else 
        {
            // ObjC side NOT initialized → Use SwiftUI...

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> ObjC side NOT initialized (_patientsVC is nil) - routing to SwiftUI alert queue...")
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> This is correct behavior - ObjC ViewControllers not yet ready...")

            return false
        }

    }   // End of private func shouldUseUIKitPresentation()->Bool.

    private func findTopViewController()->UIViewController?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Invoked...")
        
        // ===================================================================
        // Strategy 1: Try generic traversal FIRST (guaranteed in hierarchy)
        // ===================================================================
        
        if let topVC = findTopViewControllerViaTraversal()
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Found top ViewController via generic traversal: [\(String(describing: type(of: topVC)))]...")

            return topVC
        }
        
        // ===================================================================
        // Strategy 2: Fall back to AppDelegate (domain knowledge)
        // ===================================================================
        
        if let topVC = findTopViewControllerViaAppDelegate()
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Found top ViewController via AppDelegate: [\(String(describing: type(of: topVC)))]...")

            return topVC
        }
        
        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WARNING: Could not find top view controller via any method - Warning!")
        
        return nil

    }   // End of private func findTopViewController()->UIViewController?.

//  private func findTopViewController()->UIViewController?
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//      appLogMsg("\(sCurrMethodDisp) Invoked...")
//
//      // Strategy 1: Try AppDelegate's getTopViewControllers() method
//      // This has VisitVerify-specific domain knowledge about the hierarchy...
//
//      if let topVC = self.findTopViewControllerViaAppDelegate()
//      {
//          appLogMsg("\(sCurrMethodDisp) Found top ViewController via AppDelegate: [\(String(describing: type(of: topVC)))]...")
//
//          return topVC
//      }
//
//      // Strategy 2: Fall back to generic traversal
//      // This works for edge cases where _presentFromVC is NULL
//      // (but we should have already routed to SwiftUI if _patientsVC was nil)...
//
//      if let topVC = findTopViewControllerViaTraversal()
//      {
//          appLogMsg("\(sCurrMethodDisp) Found top ViewController via generic traversal: [\(String(describing: type(of: topVC)))]...")
//
//          return topVC
//      }
//
//      appLogMsg("\(sCurrMethodDisp) WARNING: Could not find top view controller via any method - Warning!")
//
//      return nil
//
//  }   // End of private func findTopViewController()->UIViewController?.

    private func findTopViewControllerViaAppDelegate()->UIViewController?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Attempting to use AppDelegate's getTopViewControllers() method...")
        
        // Get AppDelegate...

        guard let appDelegate = vvObjCSwiftEnvBridge?.objcAppDelegate
        else 
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> NO AppDelegate available...")

            return nil
        }
        
        // Call AppDelegate's method to populate _presentFromVC...

        appDelegate.getTopViewControllers()
        
        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Called AppDelegate.getTopViewControllers()...")
        
        // Access the _presentFromVC ivar that was populated...

        if let presentFromVC = appDelegate.value(forKey:"_presentFromVC") as? UIViewController
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> AppDelegate populated _presentFromVC: [\(String(describing: type(of: presentFromVC)))]...")
            
            // ===================================================================
            // CRITICAL: Validate the VC is actually in the window hierarchy
            // ===================================================================
            
            if presentFromVC.view.window != nil
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> _presentFromVC IS in window hierarchy - using it...")
                
                // Check if it has a presented view controller we should use instead...

                if let presented = presentFromVC.presentedViewController
                {
                    appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Found presented VC on top: [\(String(describing: type(of: presented)))]...")

                    return presented
                }
                
                return presentFromVC
            }
            else
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WARNING: _presentFromVC is NOT in window hierarchy - Warning!")
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Falling back to generic traversal for visible VC...")

                return nil
            }
        }
        else
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WARNING: _presentFromVC was NOT available in the AppDelegate by 'value(forKey:\"_presentFromVC\")' - Warning!")
        }
        
        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> AppDelegate's _presentFromVC is NULL - falling back to generic traversal...")
        
        return nil

    }   // End of private func findTopViewControllerViaAppDelegate()->UIViewController?.

//  private func findTopViewControllerViaAppDelegate()->UIViewController?
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//      appLogMsg("\(sCurrMethodDisp) Attempting to use AppDelegate's getTopViewControllers() method...")
//
//      // Get AppDelegate...
//
//      guard let appDelegate = vvObjCSwiftEnvBridge?.objcAppDelegate
//      else 
//      {
//          appLogMsg("\(sCurrMethodDisp) N0 AppDelegate available...")
//
//          return nil
//      }
//
//      // Call AppDelegate's method to populate _presentFromVC
//      // This method has VisitVerify-specific logic about:
//      // - requestSyncVC handling (syncing vs visible states)
//      // - notesVC modal handling (nested dismissals)
//      // - AddVisitViewController special cases
//      // - iPhone vs iPad differences...
//
//      appDelegate.getTopViewControllers()
//
//      appLogMsg("\(sCurrMethodDisp) Called AppDelegate.getTopViewControllers()...")
//
//      // Access the _presentFromVC ivar that was populated
//      // This is the VC that AppDelegate uses for login/sync alerts...
//
//      if let presentFromVC = appDelegate.value(forKey: "_presentFromVC") as? UIViewController
//      {
//          appLogMsg("\(sCurrMethodDisp) AppDelegate populated _presentFromVC: [\(String(describing: type(of: presentFromVC)))]...")
//
//          // Check if it has a presented view controller we should use instead...
//
//          if let presented = presentFromVC.presentedViewController
//          {
//              appLogMsg("\(sCurrMethodDisp) Found presented VC on top: [\(String(describing: type(of: presented)))]...")
//
//              return presented
//          }
//
//          return presentFromVC
//      }
//
//      appLogMsg("\(sCurrMethodDisp) AppDelegate's _presentFromVC is NULL - falling back to generic traversal...")
//
//      return nil
//
//  }   // End of private func findTopViewControllerViaAppDelegate()->UIViewController?.

    private func findTopViewControllerViaTraversal()->UIViewController?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Using generic view controller traversal...")

        guard let window = vvObjCSwiftEnvBridge?.objcAppDelegateWindow
        else 
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> NO window available...")

            return nil
        }

        guard let rootViewController = window.rootViewController
        else 
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> NO rootViewController available...")

            return nil
        }

        let topVC = findTopViewController(from:rootViewController)

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Generic traversal found: [\(String(describing: type(of: topVC)))]...")

        return topVC

    }   // End of private func findTopViewControllerViaTraversal()->UIViewController?.

    private func findTopViewController(from viewController:UIViewController)->UIViewController
    {

        // Recursive traversal for generic case:

        // Check for presented view controller (modals)...

        if let presented = viewController.presentedViewController
        {
            return findTopViewController(from:presented)
        }

        // Check for navigation controller...

        if let navigationController = viewController as? UINavigationController
        {
            if let visible = navigationController.visibleViewController
            {
                return findTopViewController(from:visible)
            }
        }

        // Check for tab bar controller...

        if let tabBarController = viewController as? UITabBarController
        {
            if let selected = tabBarController.selectedViewController
            {
                return findTopViewController(from: selected)
            }
        }

        // Check for split view controller (iPad)...

        if let splitViewController = viewController as? UISplitViewController
        {
            if let last = splitViewController.viewControllers.last
            {
                return findTopViewController(from:last)
            }
        }

        return viewController

    }   // End of private func findTopViewController(from viewController:UIViewController)->UIViewController.
#endif

//  #if INSTANTIATE_APP_VV_UIKIT_ALERTS
//      // -------------------------------------------------------------------------
//      // UIKit Detection and Helper Methods
//      // UPDATED: Uses AppDelegate's getTopViewControllers() for domain knowledge
//      // -------------------------------------------------------------------------
//
//      private func shouldUseUIKitPresentation()->Bool
//      {
//
//          let sCurrMethod:String     = #function
//          let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//          // No VV bridge reference? → Use SwiftUI path...
//
//          guard let vvBridge = vvObjCSwiftEnvBridge 
//          else 
//          {
//              appLogMsg("\(sCurrMethodDisp) NO VV bridge available - using SwiftUI presentation...")
//
//              return false
//          }
//
//          // No window available? → Use SwiftUI path...
//
//          guard let window = vvBridge.objcAppDelegateWindow
//          else 
//          {
//              appLogMsg("\(sCurrMethodDisp) NO window available from VV bridge - using SwiftUI presentation...")
//
//              return false
//          }
//
//          // Check if rootViewController is NOT a UIHostingController
//          // If it's ObjC ViewControllers → Use UIKit presentation...
//
//          let isUIKitHierarchy = !(window.rootViewController is UIHostingController<Any>)
//
//          if isUIKitHierarchy 
//          {
//              appLogMsg("\(sCurrMethodDisp) Detected UIKit view hierarchy - routing to UIKit alert queue...")
//              appLogMsg("\(sCurrMethodDisp) Root ViewController type: [\(String(describing: type(of: window.rootViewController)))]...")
//          } 
//          else
//          {
//              appLogMsg("\(sCurrMethodDisp) Detected SwiftUI view hierarchy - routing to SwiftUI alert queue...")
//          }
//
//          return isUIKitHierarchy
//
//      }   // End of private func shouldUseUIKitPresentation()->Bool.
//
//      private func findTopViewController()->UIViewController?
//      {
//
//          let sCurrMethod:String     = #function
//          let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//          appLogMsg("\(sCurrMethodDisp) Invoked...")
//
//          // Strategy 1: Try AppDelegate's getTopViewControllers() method
//          // This has VisitVerify-specific domain knowledge about the hierarchy...
//
//          if let topVC = findTopViewControllerViaAppDelegate() 
//          {
//              appLogMsg("\(sCurrMethodDisp) Found top ViewController via AppDelegate: [\(String(describing: type(of: topVC)))]...")
//
//              return topVC
//          }
//
//          // Strategy 2: Fall back to generic traversal
//          // This works for edge cases and during initialization...
//
//          if let topVC = findTopViewControllerViaTraversal() 
//          {
//              appLogMsg("\(sCurrMethodDisp) Found top ViewController via generic traversal: [\(String(describing: type(of: topVC)))]...")
//
//              return topVC
//          }
//
//          appLogMsg("\(sCurrMethodDisp) WARNING: Could not find top view controller via any method!")
//
//          return nil
//
//      }   // End of private func findTopViewController()->UIViewController?.
//
//      private func findTopViewControllerViaAppDelegate()->UIViewController?
//      {
//
//          let sCurrMethod:String     = #function
//          let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//          appLogMsg("\(sCurrMethodDisp) Attempting to use AppDelegate's getTopViewControllers() method...")
//
//          // Get AppDelegate...
//
//          guard let appDelegate = vvObjCSwiftEnvBridge?.objcAppDelegate
//          else 
//          {
//              appLogMsg("\(sCurrMethodDisp) NO AppDelegate available...")
//
//              return nil
//          }
//
//          // Call AppDelegate's method to populate _presentFromVC
//          // This method has VisitVerify-specific logic about:
//          // - requestSyncVC handling
//          // - notesVC modal handling  
//          // - AddVisitViewController special cases...
//
//          appDelegate.getTopViewControllers()
//
//          appLogMsg("\(sCurrMethodDisp) Called AppDelegate.getTopViewControllers()...")
//
//          // Access the _presentFromVC ivar that was populated
//          // This is the VC that AppDelegate uses for login/sync alerts...
//
//          if let presentFromVC = appDelegate.value(forKey:"_presentFromVC") as? UIViewController
//          {
//              appLogMsg("\(sCurrMethodDisp) AppDelegate populated _presentFromVC: [\(String(describing: type(of: presentFromVC)))]...")
//
//              // Check if it has a presented view controller we should use instead...
//
//              if let presented = presentFromVC.presentedViewController
//              {
//                  appLogMsg("\(sCurrMethodDisp) Found presented VC on top: [\(String(describing: type(of: presented)))]...")
//
//                  return presented
//              }
//
//              return presentFromVC
//          }
//
//          appLogMsg("\(sCurrMethodDisp) AppDelegate's _presentFromVC is NULL - falling back to generic traversal")
//
//          return nil
//
//      }   // End of private func findTopViewControllerViaAppDelegate()->UIViewController?.
//
//      private func findTopViewControllerViaTraversal()->UIViewController?
//      {
//
//          let sCurrMethod:String     = #function
//          let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//          appLogMsg("\(sCurrMethodDisp) Using generic view controller traversal...")
//
//          guard let window = vvObjCSwiftEnvBridge?.objcAppDelegateWindow
//          else 
//          {
//              appLogMsg("\(sCurrMethodDisp) NO window available...")
//
//              return nil
//          }
//
//          guard let rootViewController = window.rootViewController
//          else
//          {
//              appLogMsg("\(sCurrMethodDisp) NO rootViewController available...")
//
//              return nil
//          }
//
//          let topVC = findTopViewController(from:rootViewController)
//
//          appLogMsg("\(sCurrMethodDisp) Generic traversal found: [\(String(describing: type(of: topVC)))]...")
//
//          return topVC
//
//      }   // End of private func findTopViewControllerViaTraversal()->UIViewController?.
//
//      private func findTopViewController(from viewController:UIViewController)->UIViewController
//      {
//
//          // Recursive traversal for generic case:
//
//          // Check for presented view controller (modals)...
//
//          if let presented = viewController.presentedViewController
//          {
//              return findTopViewController(from: presented)
//          }
//
//          // Check for navigation controller...
//
//          if let navigationController = viewController as? UINavigationController
//          {
//              if let visible = navigationController.visibleViewController
//              {
//                  return findTopViewController(from:visible)
//              }
//          }
//
//          // Check for tab bar controller...
//
//          if let tabBarController = viewController as? UITabBarController
//          {
//              if let selected = tabBarController.selectedViewController
//              {
//                  return findTopViewController(from:selected)
//              }
//          }
//
//          // Check for split view controller (iPad)...
//
//          if let splitViewController = viewController as? UISplitViewController
//          {
//              if let last = splitViewController.viewControllers.last
//              {
//                  return findTopViewController(from:last)
//              }
//          }
//
//          return viewController
//
//      }   // End of private func findTopViewController(from viewController: UIViewController)->UIViewController.
//  #endif

//  #if INSTANTIATE_APP_VV_UIKIT_ALERTS
//      // -------------------------------------------------------------------------
//      // UIKit Detection and Helper Methods
//      // -------------------------------------------------------------------------
//
//      private func shouldUseUIKitPresentation()->Bool
//      {
//
//          let sCurrMethod:String     = #function
//          let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//          // No VV bridge reference? → Use SwiftUI path...
//
//          guard let vvBridge = vvObjCSwiftEnvBridge 
//          else 
//          {
//              appLogMsg("\(sCurrMethodDisp) No VV bridge available - using SwiftUI presentation")
//
//              return false
//          }
//
//          // No window available? → Use SwiftUI path...
//
//          guard let window = vvBridge.objcAppDelegateWindow 
//          else 
//          {
//              appLogMsg("\(sCurrMethodDisp) No window available from VV bridge - using SwiftUI presentation")
//
//              return false
//          }
//
//          // Check if rootViewController is NOT a UIHostingController
//          // If it's ObjC ViewControllers → Use UIKit presentation...
//
//          let isUIKitHierarchy = !(window.rootViewController is UIHostingController<Any>)
//
//          if (isUIKitHierarchy == true)
//          {
//              appLogMsg("\(sCurrMethodDisp) Detected UIKit view hierarchy - routing to UIKit alert queue...")
//              appLogMsg("\(sCurrMethodDisp) Root ViewController type: [\(String(describing: type(of: window.rootViewController)))]...")
//          } 
//          else 
//          {
//              appLogMsg("\(sCurrMethodDisp) Detected SwiftUI view hierarchy - routing to SwiftUI alert queue...")
//          }
//
//          return isUIKitHierarchy
//
//      }   // End of private func shouldUseUIKitPresentation()->Bool.
//
//      private func findTopViewController()->UIViewController?
//      {
//
//          let sCurrMethod:String     = #function
//          let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//          guard let window = vvObjCSwiftEnvBridge?.objcAppDelegateWindow 
//          else 
//          {
//              appLogMsg("\(sCurrMethodDisp) NO window available - Error!")
//
//              return nil
//          }
//
//          guard let rootViewController = window.rootViewController 
//          else 
//          {
//              appLogMsg("\(sCurrMethodDisp) NO rootViewController available - Warning!")
//
//              return nil
//          }
//
//          let topVC = findTopViewController(from:rootViewController)
//
//          appLogMsg("\(sCurrMethodDisp) Found top ViewController: [\(String(describing: type(of: topVC)))]...")
//
//          return topVC
//
//      }   // End of private func findTopViewController()->UIViewController?.
//
//      private func findTopViewController(from viewController:UIViewController)->UIViewController
//      {
//
//          // Check for presented view controller (modals)...
//
//          if let presented = viewController.presentedViewController 
//          {
//              return findTopViewController(from:presented)
//          }
//
//          // Check for navigation controller...
//
//          if let navigationController = viewController as? UINavigationController 
//          {
//              if let visible = navigationController.visibleViewController
//              {
//                  return findTopViewController(from: visible)
//              }
//          }
//
//          // Check for tab bar controller...
//
//          if let tabBarController = viewController as? UITabBarController 
//          {
//              if let selected = tabBarController.selectedViewController 
//              {
//                  return findTopViewController(from: selected)
//              }
//          }
//
//          // Check for split view controller (iPad)...
//
//          if let splitViewController = viewController as? UISplitViewController
//          {
//              if let last = splitViewController.viewControllers.last
//              {
//                  return findTopViewController(from: last)
//              }
//          }
//
//          return viewController
//
//      }   // End of private func findTopViewController(from viewController:UIViewController)->UIViewController.
//  #endif

// ============================================================================
// SECTION 3: UIKIT GLOBAL ALERT METHODS
// Add after the detection methods
// ============================================================================

#if INSTANTIATE_APP_VV_UIKIT_ALERTS
    // -------------------------------------------------------------------------
    // UIKit Global Alert Methods
    // -------------------------------------------------------------------------

    private func processNextUIKitGlobalAlert()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        // Check if already processing...

        self.alertQueueLock.lock()

        if (self.isProcessingUIKitGlobalAlert)
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Already processing a UIKit global alert, skipping...")

            return
        }

        // Check if queue is empty...

        guard self.uiKitGlobalAlertQueue.count > 0
        else
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> UIKit global alert queue is empty...")

            return
        }

        // Mark as processing and get next alert...

        isProcessingUIKitGlobalAlert = true
        let alertRequest             = uiKitGlobalAlertQueue[0]
        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Processing UIKit alert request [\(alertRequest.requestId)] after [\(self.uiKitAlertSignalDelaySeconds)] second delay...")

        // Delay before presenting to allow View re-rendering...

        DispatchQueue.main.asyncAfter(deadline:(.now() + self.uiKitAlertSignalDelaySeconds))
        {
            self.presentUIKitGlobalAlert(alertRequest)
        }

        return

    }   // End of private func processNextUIKitGlobalAlert().

// ============================================================================
// SECTION C: UIKIT ALERT METHODS WITH WINDOW VALIDATION + WATCHDOG
// Replace presentUIKitGlobalAlert around line 2293
// ============================================================================

#if INSTANTIATE_APP_VV_UIKIT_ALERTS
    private func presentUIKitGlobalAlert(_ alertRequest:GlobalAlertRequest)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Presenting UIKit alert [\(alertRequest.requestId)] - Message: [\(alertRequest.alertMessage)]...")

        // Set current alert ID (prevents premature reset)...

        self.alertQueueLock.lock()
        self.currentUIKitGlobalAlertId = alertRequest.requestId
        self.alertQueueLock.unlock()

        // Find top view controller...

        guard let topViewController = findTopViewController() 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> ERROR: Could not find top view controller for alert presentation!")

            // Mark as not processing and try next...

            self.alertQueueLock.lock()
            self.isProcessingUIKitGlobalAlert = false
            self.uiKitGlobalAlertQueue.removeFirst()
            let remainingCount                = self.uiKitGlobalAlertQueue.count
            self.alertQueueLock.unlock()

            if (remainingCount > 0)
            {
                self.processNextUIKitGlobalAlert()
            }

            return
        }

        // ========================================================================
        // CRITICAL: Validate VC is actually in window hierarchy
        // ========================================================================

        if (topViewController.view.window == nil)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> ERROR: Top ViewController view is NOT in window hierarchy!")
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> VC type: [\(String(describing: type(of: topViewController)))]...")

            // Mark as not processing and try next...

            self.alertQueueLock.lock()
            self.isProcessingUIKitGlobalAlert = false
            self.uiKitGlobalAlertQueue.removeFirst()
            let remainingCount                = self.uiKitGlobalAlertQueue.count
            self.alertQueueLock.unlock()

            if (remainingCount > 0)
            {
                self.processNextUIKitGlobalAlert()
            }

            return
        }

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Top ViewController IS in window hierarchy - proceeding...")

        // Create UIAlertController...

        let alertController = UIAlertController(title:         nil,
                                                message:       alertRequest.alertMessage,
                                                preferredStyle:.alert)

        // Add button with action that calls reset...

        let action = UIAlertAction(title:alertRequest.alertButtonText, style:.default)
        { [weak self] _ in

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> User dismissed UIKit alert [\(alertRequest.requestId)]...")

            self?.resetUIKitGlobalAlert()
        }

        alertController.addAction(action)

        // ========================================================================
        // WATCHDOG TIMER: Auto-reset if alert doesn't present within 'AppGlobalInfo.iAlertViaUIKitTimeout' seconds
        // ========================================================================

        var watchdogCancelled = false

        let watchdogTimer = DispatchWorkItem 
        { [weak self] in

            guard let self = self, !watchdogCancelled 
            else { return }

            self.alertQueueLock.lock()
            let stillProcessing = self.isProcessingUIKitGlobalAlert
            let currentId       = self.currentUIKitGlobalAlertId
            self.alertQueueLock.unlock()

            if (stillProcessing == true &&
                currentId       == alertRequest.requestId)
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WATCHDOG: Alert [\(alertRequest.requestId)] failed to present within #(\(AppGlobalInfo.iAlertViaUIKitTimeout)) second(s) - Warning!")
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WATCHDOG: Auto-resetting and advancing queue...")

                // Force reset...

                self.alertQueueLock.lock()
                self.isProcessingUIKitGlobalAlert = false
                self.currentUIKitGlobalAlertId    = nil

                if (self.uiKitGlobalAlertQueue.count         > 0 &&
                    self.uiKitGlobalAlertQueue[0].requestId == alertRequest.requestId)
                {
                    self.uiKitGlobalAlertQueue.removeFirst()
                }

                let remainingCount = self.uiKitGlobalAlertQueue.count
                self.alertQueueLock.unlock()

                if (remainingCount > 0)
                {
                    appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WATCHDOG: Processing next alert in queue...")

                    self.processNextUIKitGlobalAlert()
                }
            }

        }

        // Start watchdog ('AppGlobalInfo.iAlertViaUIKitTimeout' second timeout)...

        DispatchQueue.main.asyncAfter(deadline:(.now() + AppGlobalInfo.iAlertViaUIKitTimeout), execute:watchdogTimer)

        // Present on main thread...

        DispatchQueue.main.async
        {
            topViewController.present(alertController, animated:true)
            {
                // Cancel watchdog on successful presentation...

                watchdogCancelled = true
                watchdogTimer.cancel()

                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> UIKit alert [\(alertRequest.requestId)] presented successfully...")
            }
        }

        return

    }   // End of private func presentUIKitGlobalAlert(_ alertRequest:GlobalAlertRequest).
#endif

//  private func presentUIKitGlobalAlert(_ alertRequest:GlobalAlertRequest)
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//      appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Presenting UIKit alert [\(alertRequest.requestId)] - Message: [\(alertRequest.alertMessage)]...")
//
//      // Set current alert ID (prevents premature reset)...
//
//      self.alertQueueLock.lock()
//      self.currentUIKitGlobalAlertId = alertRequest.requestId
//      self.alertQueueLock.unlock()
//
//      // Find top view controller...
//
//      guard let topViewController = findTopViewController() 
//      else 
//      {
//          appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> ERROR: Could not find top view controller for alert presentation - Error!")
//
//          // Mark as not processing and try next...
//
//          self.alertQueueLock.lock()
//          self.isProcessingUIKitGlobalAlert = false
//          self.uiKitGlobalAlertQueue.removeFirst()
//          let remainingCount                = self.uiKitGlobalAlertQueue.count
//          self.alertQueueLock.unlock()
//
//          if (remainingCount > 0)
//          {
//              self.processNextUIKitGlobalAlert()
//          }
//
//          return
//      }
//
//      // Create UIAlertController...
//
//      let alertController = UIAlertController(title:         nil,
//                                              message:       alertRequest.alertMessage,
//                                              preferredStyle:.alert)
//
//      // Add button with action that calls reset...
//
//      let action = UIAlertAction(title:alertRequest.alertButtonText, style:.default) 
//      { [weak self] _ in
//
//          appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> User dismissed UIKit alert [\(alertRequest.requestId)]...")
//
//          self?.resetUIKitGlobalAlert()
//
//      }
//
//      alertController.addAction(action)
//
//      // Present on main thread...
//
//      DispatchQueue.main.async 
//      {
//          topViewController.present(alertController, animated:true)
//          {
//              appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> UIKit alert [\(alertRequest.requestId)] presented successfully...")
//          }
//      }
//
//      return
//
//  }   // End of private func presentUIKitGlobalAlert(_ alertRequest:GlobalAlertRequest).

    private func resetUIKitGlobalAlert()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Invoked...")

        self.alertQueueLock.lock()

        // Verify we have a currently displayed alert...

        guard let currentAlertId = self.currentUIKitGlobalAlertId 
        else
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WARNING: Reset called but no current UIKit alert ID tracked - Warning!")

            return
        }

        // Remove the completed alert from queue...

        if (self.uiKitGlobalAlertQueue.count         > 0 &&
            self.uiKitGlobalAlertQueue[0].requestId == currentAlertId)
        {
            let completedAlert = uiKitGlobalAlertQueue.removeFirst()

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Removed completed UIKit alert [\(completedAlert.requestId)] from queue...")
        }
        else
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WARNING: Current UIKit alert ID [\(currentAlertId)] not at front of queue - Warning!")
        }

        // Clear current alert tracking...

        self.currentUIKitGlobalAlertId = nil

        // Mark processing as complete...

        self.isProcessingUIKitGlobalAlert = false
        let remainingCount = self.uiKitGlobalAlertQueue.count
        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> UIKit alert reset complete. Remaining queue depth: #(\(remainingCount))...")

        // Process next alert if any...

        if (remainingCount > 0)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Processing 'next' queued UIKit alert - 'remainingCount' is #(\(remainingCount))...")

            self.processNextUIKitGlobalAlert()
        }

        // Exit...

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Exiting...")

        return

    }   // End of private func resetUIKitGlobalAlert().
#endif

    // Method(s) that signal interaction(s) with Swift View(s):

    @objc public func setAppDelegateVisitorSignalSwiftViewsShouldRefresh()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")

        // Signal Swift 'view(s)' that they should refresh (if watching this AppDelegateVisitor)...

        self.appDelegateVisitorSwiftViewsShouldRefresh = true

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func setAppDelegateVisitorSignalSwiftViewsShouldRefresh().

    @objc public func resetAppDelegateVisitorSignalSwiftViewsShouldRefresh()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")

        // Reset the signal Swift 'view(s)' that they should refresh (if watching this AppDelegateVisitor)...

        self.appDelegateVisitorSwiftViewsShouldRefresh = false

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func resetAppDelegateVisitorSignalSwiftViewsShouldRefresh().

    @objc public func setAppDelegateVisitorSignalSwiftViewsShouldChange()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")

        // Signal Swift 'view(s)' that they should change (if watching this AppDelegateVisitor)...

        self.appDelegateVisitorSwiftViewsShouldChange = true

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func setAppDelegateVisitorSignalSwiftViewsShouldChange().

    @objc public func resetAppDelegateVisitorSignalSwiftViewsShouldChange()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")

        // Reset the signal Swift 'view(s)' that they should change (if watching this AppDelegateVisitor)...

        self.appDelegateVisitorSwiftViewsShouldChange = false

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func resetAppDelegateVisitorSignalSwiftViewsShouldChange().

//  @objc public func setAppDelegateVisitorSignalGlobalAlert(_ alertMsg:String? = nil, alertButtonText:String? = nil)
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//      appLogMsg("\(sCurrMethodDisp) Invoked - parameter(s) 'alertMsg' is [\(String(describing: alertMsg))] - 'alertButtonText' is [\(String(describing: alertButtonText))] - 'self' is [\(self)]...")
//
//      // Set the Alert fields (Message and Button Text) and then signal the Global Alert...
//
//      if (alertMsg        == nil ||
//          alertMsg!.count  < 1)
//      {
//          self.sAppDelegateVisitorGlobalAlertMessage = "-N/A-"
//      }
//      else
//      {
//          self.sAppDelegateVisitorGlobalAlertMessage = alertMsg
//      }
//
//      if (alertButtonText        == nil ||
//          alertButtonText!.count  < 1)
//      {
//          self.sAppDelegateVisitorGlobalAlertButtonText = "-N/A-"
//      }
//      else
//      {
//          self.sAppDelegateVisitorGlobalAlertButtonText = alertButtonText
//      }
//
//      self.isAppDelegateVisitorShowingAlert = true
//
//      // Exit:
//
//      appLogMsg("\(sCurrMethodDisp) Exiting...")
//
//      return
//
//  }   // End of @objc public func setAppDelegateVisitorSignalGlobalAlert().
//
//  @objc public func resetAppDelegateVisitorSignalGlobalAlert()
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//      appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")
//
//      // Reset the signal of the Global Alert...
//
//      self.sAppDelegateVisitorGlobalAlertMessage    = "-N/A-"
//      self.sAppDelegateVisitorGlobalAlertButtonText = "-N/A-"
//      self.isAppDelegateVisitorShowingAlert         = false
//
//      // Exit:
//
//      appLogMsg("\(sCurrMethodDisp) Exiting...")
//
//      return
//
//  }   // End of @objc public func resetAppDelegateVisitorSignalGlobalAlert().
//
//  public func setAppDelegateVisitorSignalCompletionAlert(_ alertMsg:String? = nil, 
//                                                   alertButtonText1:String? = nil, 
//                                                   alertButtonText2:String? = nil,
//                                                   withCompletion1 completionHandler1:(()->())?,
//                                                   withCompletion2 completionHandler2:(()->())?)
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//      appLogMsg("\(sCurrMethodDisp) Invoked - parameter(s) 'alertMsg' is [\(String(describing: alertMsg))] - 'alertButtonText1' is [\(String(describing: alertButtonText1))] - 'alertButtonText2' is [\(String(describing: alertButtonText2))] - 'completionHandler1' is [\(String(describing: completionHandler1))] - 'completionHandler2' is [\(String(describing: completionHandler2))]...")
//
//      // Set the Alert fields (Message and Button Text) and then signal the Global Alert...
//
//      if (alertMsg        == nil ||
//          alertMsg!.count  < 1)
//      {
//          self.sAppDelegateVisitorCompletionAlertMessage = "-N/A-"
//      }
//      else
//      {
//          self.sAppDelegateVisitorCompletionAlertMessage = alertMsg ?? "-N/A-"
//      }
//
//      if (alertButtonText1        == nil ||
//          alertButtonText1!.count  < 1)
//      {
//          self.sAppDelegateVisitorCompletionAlertButtonText1 = "-N/A-"
//      }
//      else
//      {
//          self.sAppDelegateVisitorCompletionAlertButtonText1 = alertButtonText1 ?? "-N/A"
//      }
//      
//      if (alertButtonText1        == nil ||
//          alertButtonText1!.count  < 1)
//      {
//          self.sAppDelegateVisitorCompletionAlertButtonText2 = ""
//      }
//      else
//      {
//          self.sAppDelegateVisitorCompletionAlertButtonText2 = alertButtonText2 ?? ""
//      }
//      
//      if completionHandler1 != nil
//      {
//          self.appDelegateVisitorCompletionClosure1 = completionHandler1
//      }
//      else
//      {
//          self.appDelegateVisitorCompletionClosure1 = nil
//      }
//
//      if completionHandler2 != nil
//      {
//          self.appDelegateVisitorCompletionClosure2 = completionHandler2
//      }
//      else
//      {
//          self.appDelegateVisitorCompletionClosure2 = nil
//      }
//      
//      if (self.sAppDelegateVisitorCompletionAlertButtonText2.count < 1)
//      {
//          self.isAppDelegateVisitorShowingCompletionAlert2ndButton = false
//      }
//      else
//      {
//          self.isAppDelegateVisitorShowingCompletionAlert2ndButton = true
//      }
//      
//      self.isAppDelegateVisitorShowingCompletionAlert = true
//
//      // Exit:
//
//      appLogMsg("\(sCurrMethodDisp) Exiting...")
//
//      return
//
//  }   // End of @objc public func setAppDelegateVisitorSignalCompletionAlert(_ alertMsg:String? = nil, alertButtonText:String? = nil, withCompletion completionHandler:@escaping(Void)->(Void)?)
//
//  @objc public func resetAppDelegateVisitorSignalCompletionAlert(idButtonClicked:Int = 1)
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//      appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")
//
//      // (Optionally) call the 'completion' handler and reset the signal of the 'completion' Alert...
//
//      if (idButtonClicked == 1)
//      {
//          if self.appDelegateVisitorCompletionClosure1 != nil
//          {
//              appLogMsg("\(sCurrMethodDisp) Calling the 'completion' closure #1 - 'appDelegateVisitorCompletionClosure1' is [\(String(describing: self.appDelegateVisitorCompletionClosure1))]...")
//
//              self.appDelegateVisitorCompletionClosure1!()
//
//              appLogMsg("\(sCurrMethodDisp) Called  the 'completion' closure #1 - 'appDelegateVisitorCompletionClosure1' is [\(String(describing: self.appDelegateVisitorCompletionClosure1))]...")
//          }
//          else
//          {
//              appLogMsg("\(sCurrMethodDisp) Bypassing calling the 'completion' closure #1 - 'appDelegateVisitorCompletionClosure1' is nil...")
//          }
//      }
//      else
//      {
//          if self.appDelegateVisitorCompletionClosure2 != nil
//          {
//              appLogMsg("\(sCurrMethodDisp) Calling the 'completion' closure #2 - 'appDelegateVisitorCompletionClosure2' is [\(String(describing: self.appDelegateVisitorCompletionClosure2))]...")
//
//              self.appDelegateVisitorCompletionClosure2!()
//
//              appLogMsg("\(sCurrMethodDisp) Called  the 'completion' closure #2 - 'appDelegateVisitorCompletionClosure2' is [\(String(describing: self.appDelegateVisitorCompletionClosure2))]...")
//          }
//          else
//          {
//              appLogMsg("\(sCurrMethodDisp) Bypassing calling the 'completion' closure #2 - 'appDelegateVisitorCompletionClosure2' is nil...")
//          }
//
//      }
//
//      self.isAppDelegateVisitorShowingCompletionAlert = false
//
//      // Exit:
//
//      appLogMsg("\(sCurrMethodDisp) Exiting...")
//
//      return
//
//  }   // End of @objc public func resetAppDelegateVisitorSignalCompletionAlert().

// ============================================================================
// SECTION 4: UIKIT COMPLETION ALERT METHODS
// Add after UIKit global alert methods
// ============================================================================

#if INSTANTIATE_APP_VV_UIKIT_ALERTS
    // -------------------------------------------------------------------------
    // UIKit Completion Alert Methods
    // -------------------------------------------------------------------------

    private func processNextUIKitCompletionAlert()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        // Check if already processing...

        self.alertQueueLock.lock()

        if (self.isProcessingUIKitCompletionAlert)
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Already processing a UIKit completion alert, skipping...")

            return
        }

        // Check if queue is empty...

        guard uiKitCompletionAlertQueue.count > 0 
        else
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> UIKit completion alert queue is empty...")

            return
        }

        // Mark as processing and get next alert...

        self.isProcessingUIKitCompletionAlert = true
        let alertRequest                      = self.uiKitCompletionAlertQueue[0]
        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Processing UIKit completion alert request [\(alertRequest.requestId)] after #(\(self.uiKitAlertSignalDelaySeconds)) second delay...")

        // Delay before presenting...

        DispatchQueue.main.asyncAfter(deadline:(.now() + self.uiKitAlertSignalDelaySeconds))
        {
            self.presentUIKitCompletionAlert(alertRequest)
        }

        return

    }   // End of private func processNextUIKitCompletionAlert().

// ============================================================================
// SECTION D: UIKIT COMPLETION ALERT WITH WINDOW VALIDATION + WATCHDOG
// Replace presentUIKitCompletionAlert around line 2545
// ============================================================================

#if INSTANTIATE_APP_VV_UIKIT_ALERTS
    private func presentUIKitCompletionAlert(_ alertRequest:CompletionAlertRequest)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Presenting UIKit completion alert [\(alertRequest.requestId)] - Message: [\(alertRequest.alertMessage)]...")

        // Set current alert ID...

        self.alertQueueLock.lock()
        self.currentUIKitCompletionAlertId        = alertRequest.requestId

        // Store completion handlers for later execution...

        self.appDelegateVisitorCompletionClosure1 = alertRequest.completionHandler1
        self.appDelegateVisitorCompletionClosure2 = alertRequest.completionHandler2
        self.alertQueueLock.unlock()

        // Find top view controller...

        guard let topViewController = findTopViewController()
        else 
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> ERROR: Could not find top view controller for alert presentation - Error!")

            // Mark as not processing and try next...

            self.alertQueueLock.lock()
            self.isProcessingUIKitCompletionAlert = false
            self.uiKitCompletionAlertQueue.removeFirst()
            let remainingCount                    = self.uiKitCompletionAlertQueue.count
            self.alertQueueLock.unlock()

            if (remainingCount > 0)
            {
                self.processNextUIKitCompletionAlert()
            }

            return
        }

        // ========================================================================
        // CRITICAL: Validate VC is actually in window hierarchy
        // ========================================================================

        if (topViewController.view.window == nil)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> ERROR: Top ViewController view is NOT in window hierarchy - Error!")
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> VC type: [\(String(describing: type(of: topViewController)))]...")

            // Mark as not processing and try next...

            self.alertQueueLock.lock()
            self.isProcessingUIKitCompletionAlert = false
            self.uiKitCompletionAlertQueue.removeFirst()
            let remainingCount                    = self.uiKitCompletionAlertQueue.count
            self.alertQueueLock.unlock()

            if (remainingCount > 0)
            {
                self.processNextUIKitCompletionAlert()
            }

            return
        }

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Top ViewController IS in window hierarchy - proceeding...")

        // Create UIAlertController...

        let alertController = UIAlertController(title:         nil,
                                                message:       alertRequest.alertMessage,
                                                preferredStyle:.alert)

        // Add button 1...

        let action1 = UIAlertAction(title:alertRequest.alertButtonText1, style:.default) 
        { [weak self] _ in

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> User tapped button 1 in UIKit completion alert [\(alertRequest.requestId)]...")

            self?.resetUIKitCompletionAlert(idButtonClicked:1)

        }

        alertController.addAction(action1)

        // Add button 2 if present...

        if (alertRequest.alertButtonText2.count > 0)
        {
            let action2 = UIAlertAction(title:alertRequest.alertButtonText2, style:.default) 
            { [weak self] _ in

                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> User tapped button 2 in UIKit completion alert [\(alertRequest.requestId)]...")

                self?.resetUIKitCompletionAlert(idButtonClicked: 2)

            }

            alertController.addAction(action2)
        }

        // ========================================================================
        // WATCHDOG TIMER: Auto-reset if alert doesn't present within 'AppGlobalInfo.iAlertViaUIKitTimeout' seconds
        // ========================================================================

        var watchdogCancelled = false

        let watchdogTimer = DispatchWorkItem 
        { [weak self] in

            guard let self = self, !watchdogCancelled 
            else { return }

            self.alertQueueLock.lock()
            let stillProcessing = self.isProcessingUIKitCompletionAlert
            let currentId       = self.currentUIKitCompletionAlertId
            self.alertQueueLock.unlock()

            if (stillProcessing == true &&
                currentId       == alertRequest.requestId)
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WATCHDOG: Completion alert [\(alertRequest.requestId)] failed to present within #(\(AppGlobalInfo.iAlertViaUIKitTimeout)) second(s) - Error!")
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WATCHDOG: Auto-resetting and advancing queue...")

                // Force reset...

                self.alertQueueLock.lock()
                self.isProcessingUIKitCompletionAlert     = false
                self.currentUIKitCompletionAlertId        = nil
                self.appDelegateVisitorCompletionClosure1 = nil
                self.appDelegateVisitorCompletionClosure2 = nil

                if (self.uiKitCompletionAlertQueue.count         > 0 &&
                    self.uiKitCompletionAlertQueue[0].requestId == alertRequest.requestId)
                {
                    self.uiKitCompletionAlertQueue.removeFirst()
                }

                let remainingCount = self.uiKitCompletionAlertQueue.count
                self.alertQueueLock.unlock()

                if (remainingCount > 0)
                {
                    appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WATCHDOG: Processing next completion alert in queue...")

                    self.processNextUIKitCompletionAlert()
                }
            }

        }

        // Start watchdog ('AppGlobalInfo.iAlertViaUIKitTimeout' second timeout)...

        DispatchQueue.main.asyncAfter(deadline:(.now() + AppGlobalInfo.iAlertViaUIKitTimeout), execute:watchdogTimer)

        // Present on main thread...

        DispatchQueue.main.async
        {
            topViewController.present(alertController, animated:true)
            {
                // Cancel watchdog on successful presentation...

                watchdogCancelled = true
                watchdogTimer.cancel()

                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> UIKit completion alert [\(alertRequest.requestId)] presented successfully...")
            }
        }

        return

    }   // End of private func presentUIKitCompletionAlert(_ alertRequest:CompletionAlertRequest).
#endif

//  private func presentUIKitCompletionAlert(_ alertRequest:CompletionAlertRequest)
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//      appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Presenting UIKit completion alert [\(alertRequest.requestId)] - Message: [\(alertRequest.alertMessage)]...")
//
//      // Set current alert ID...
//
//      self.alertQueueLock.lock()
//      self.currentUIKitCompletionAlertId = alertRequest.requestId
//
//      // Store completion handlers for later execution...
//
//      self.appDelegateVisitorCompletionClosure1 = alertRequest.completionHandler1
//      self.appDelegateVisitorCompletionClosure2 = alertRequest.completionHandler2
//      self.alertQueueLock.unlock()
//
//      // Find top view controller...
//
//      guard let topViewController = findTopViewController() 
//      else 
//      {
//          appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> ERROR: Could not find top view controller for alert presentation - Error!")
//
//          // Mark as not processing and try next...
//
//          self.alertQueueLock.lock()
//          self.isProcessingUIKitCompletionAlert = false
//          self.uiKitCompletionAlertQueue.removeFirst()
//          let remainingCount                    = self.uiKitCompletionAlertQueue.count
//          self.alertQueueLock.unlock()
//
//          if (remainingCount > 0)
//          {
//              self.processNextUIKitCompletionAlert()
//          }
//
//          return
//      }
//
//      // Create UIAlertController...
//
//      let alertController = UIAlertController(title:         nil,
//                                              message:       alertRequest.alertMessage,
//                                              preferredStyle:.alert)
//
//      // Add button 1...
//
//      let action1 = UIAlertAction(title:alertRequest.alertButtonText1, style:.default) 
//      { [weak self] _ in
//
//          appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> User tapped button 1 in UIKit completion alert [\(alertRequest.requestId)]...")
//
//          self?.resetUIKitCompletionAlert(idButtonClicked:1)
//
//      }
//
//      alertController.addAction(action1)
//
//      // Add button 2 if present...
//
//      if (alertRequest.alertButtonText2.count > 0)
//      {
//          let action2 = UIAlertAction(title:alertRequest.alertButtonText2, style:.default)
//          { [weak self] _ in
//
//              appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> User tapped button 2 in UIKit completion alert [\(alertRequest.requestId)]...")
//
//              self?.resetUIKitCompletionAlert(idButtonClicked:2)
//
//          }
//
//          alertController.addAction(action2)
//      }
//
//      // Present on main thread...
//
//      DispatchQueue.main.async 
//      {
//          topViewController.present(alertController, animated:true)
//          {
//              appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> UIKit completion alert [\(alertRequest.requestId)] presented successfully...")
//          }
//      }
//
//      return
//
//  }   // End of private func presentUIKitCompletionAlert(_ alertRequest:CompletionAlertRequest).

    private func resetUIKitCompletionAlert(idButtonClicked:Int)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Invoked - 'idButtonClicked' is [\(idButtonClicked)]...")

        // Execute completion handler if present (BEFORE clearing)...

        if (idButtonClicked == 1)
        {
            if self.appDelegateVisitorCompletionClosure1 != nil
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Calling the UIKit 'completion' closure #1...")
                self.appDelegateVisitorCompletionClosure1!()
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Called  the UIKit 'completion' closure #1...")
            }
            else
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Bypassing calling the UIKit 'completion' closure #1 - closure is nil...")
            }
        }
        else
        {
            if self.appDelegateVisitorCompletionClosure2 != nil
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Calling the UIKit 'completion' closure #2...")
                self.appDelegateVisitorCompletionClosure2!()
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Called  the UIKit 'completion' closure #2...")
            }
            else
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Bypassing calling the UIKit 'completion' closure #2 - closure is nil...")
            }
        }

        self.alertQueueLock.lock()

        // Verify we have a currently displayed alert...

        guard let currentAlertId = self.currentUIKitCompletionAlertId
        else
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WARNING: Reset called but no current UIKit completion alert ID tracked - Warning!")

            return
        }

        // Remove the completed alert from queue...

        if (self.uiKitCompletionAlertQueue.count         > 0 &&
            self.uiKitCompletionAlertQueue[0].requestId == currentAlertId)
        {
            let completedAlert = uiKitCompletionAlertQueue.removeFirst()

            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Removed completed UIKit completion alert [\(completedAlert.requestId)] from queue...")
        }
        else
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> WARNING: Current UIKit completion alert ID [\(currentAlertId)] not at front of queue - Warning!")
        }

        // Clear current alert tracking and completion handlers...

        self.currentUIKitCompletionAlertId        = nil
        self.appDelegateVisitorCompletionClosure1 = nil
        self.appDelegateVisitorCompletionClosure2 = nil

        // Mark processing as complete...

        self.isProcessingUIKitCompletionAlert     = false
        let remainingCount                        = self.uiKitCompletionAlertQueue.count
        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> UIKit completion alert reset complete. Remaining queue depth: #(\(remainingCount))...")

        // Process next alert if any...

        if (remainingCount > 0)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Processing 'next' queued UIKit completion alert - 'remainingCount' is #(\(remainingCount))...")

            self.processNextUIKitCompletionAlert()
        }

        // Exit...

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Exiting...")

        return

    }   // End of private func resetUIKitCompletionAlert(idButtonClicked:Int).
#endif

    // -------------------------------------------------------------------------
    // GLOBAL ALERT METHODS (Refactored)
    // -------------------------------------------------------------------------
    
//  @objc public func setAppDelegateVisitorSignalGlobalAlert(_ alertMsg:String? = nil, alertButtonText:String? = nil)
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//      
//      appLogMsg("\(sCurrMethodDisp) Invoked - parameter(s) 'alertMsg' is [\(String(describing: alertMsg))] - 'alertButtonText' is [\(String(describing: alertButtonText))]...")
//      
//      // Validate and prepare alert message...
//
//      let finalAlertMessage:String
//
//      if (alertMsg        == nil || 
//          alertMsg!.count  < 1)
//      {
//          finalAlertMessage = "-N/A-"
//      }
//      else
//      {
//          finalAlertMessage = alertMsg!
//      }
//      
//      // Validate and prepare alert button text...
//
//      let finalAlertButtonText:String
//
//      if (alertButtonText        == nil || 
//          alertButtonText!.count  < 1)
//      {
//          finalAlertButtonText = "-N/A-"
//      }
//      else
//      {
//          finalAlertButtonText = alertButtonText!
//      }
//      
//      // Create alert request...
//
//      let alertRequest = GlobalAlertRequest(alertMessage:   finalAlertMessage, 
//                                            alertButtonText:finalAlertButtonText)
//      
//      // Add to queue with thread safety...
//
//      alertQueueLock.lock()
//      globalAlertQueue.append(alertRequest)
//      let queueCount = globalAlertQueue.count
//      alertQueueLock.unlock()
//      
//      appLogMsg("\(sCurrMethodDisp) Alert request [\(alertRequest.requestId)] added to queue - queue depth: #(\(queueCount))...")
//      
//      // Process the queue (if not already processing)...
//
//      self.processNextGlobalAlert()
//      
//      // Exit...
//
//      appLogMsg("\(sCurrMethodDisp) Exiting...")
//      
//      return
//
//  }   // End of @objc public func setAppDelegateVisitorSignalGlobalAlert(_ alertMsg:String?, alertButtonText:String?).

// ============================================================================
// SECTION 5: MODIFIED setAppDelegateVisitorSignalGlobalAlert METHOD
// Replace the existing method (around line 1792) with this version
// ============================================================================

    @objc public func setAppDelegateVisitorSignalGlobalAlert(_ alertMsg:String? = nil, alertButtonText:String? = nil)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Invoked - parameter(s) 'alertMsg' is [\(String(describing: alertMsg))] - 'alertButtonText' is [\(String(describing: alertButtonText))]...")
        
        // Validate and prepare alert message...

        let finalAlertMessage:String

        if (alertMsg        == nil ||
            alertMsg!.count  < 1)
        {
            finalAlertMessage = "-N/A-"
        }
        else
        {
            finalAlertMessage = alertMsg!
        }
        
        // Validate and prepare alert button text...

        let finalAlertButtonText:String

        if (alertButtonText        == nil ||
            alertButtonText!.count  < 1)
        {
            finalAlertButtonText = "-N/A-"
        }
        else
        {
            finalAlertButtonText = alertButtonText!
        }
        
    #if INSTANTIATE_APP_VV_UIKIT_ALERTS
        // Check if we should route to UIKit presentation...

        if (shouldUseUIKitPresentation() == true)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Routing to UIKit alert queue...")
            
            // Create alert request...

            let alertRequest = GlobalAlertRequest(alertMessage:   finalAlertMessage, 
                                                  alertButtonText:finalAlertButtonText)
            
            // Add to UIKit queue with thread safety...

            self.alertQueueLock.lock()
            self.uiKitGlobalAlertQueue.append(alertRequest)
            let queueCount = self.uiKitGlobalAlertQueue.count
            self.alertQueueLock.unlock()
            
            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> UIKit alert request [\(alertRequest.requestId)] added to queue. Queue depth: #(\(queueCount))...")
            
            // Process the UIKit queue...

            self.processNextUIKitGlobalAlert()
            
            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting via UIKit path...")

            return
        }
    #endif
        
        // Fall through to SwiftUI queue path...

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Routing to SwiftUI alert queue...")
        
        // Create alert request...

        let alertRequest = GlobalAlertRequest(alertMessage:   finalAlertMessage, 
                                              alertButtonText:finalAlertButtonText)
        
        // Add to queue with thread safety...

        self.alertQueueLock.lock()
        globalAlertQueue.append(alertRequest)
        let queueCount = self.globalAlertQueue.count
        self.alertQueueLock.unlock()
        
        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Alert request [\(alertRequest.requestId)] added to queue. Queue depth: #(\(queueCount))...")
        
        // Process the queue (if not already processing)...

        self.processNextGlobalAlert()
        
        // Exit...

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting...")
        
        return

    }   // End of @objc public func setAppDelegateVisitorSignalGlobalAlert(_ alertMsg:String?, alertButtonText:String?).

// ============================================================================
// SECTION A: SWIFTUI ALERT METHODS WITH WATCHDOG TIMERS
// Replace existing methods around lines 3122-3430
// ============================================================================

    private func processNextGlobalAlert()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        // Check if already processing...

        self.alertQueueLock.lock()

        if (self.isProcessingGlobalAlert == true)
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Already processing a global alert, skipping...")

            return
        }

        // Check if queue is empty...

        guard globalAlertQueue.count > 0
        else
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Global alert queue is empty...")

            return
        }

        // Mark as processing and get next alert...

        self.isProcessingGlobalAlert = true
        let alertRequest             = self.globalAlertQueue[0]
        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Processing alert request [\(alertRequest.requestId)] after #(\(self.alertSignalDelaySeconds)) second delay...")

        // Delay before signaling to allow View re-rendering...

        DispatchQueue.main.asyncAfter(deadline:(.now() + self.alertSignalDelaySeconds))
        {
            self.signalGlobalAlert(alertRequest)
        }

        return

    }   // End of private func processNextGlobalAlert().

    private func signalGlobalAlert(_ alertRequest:GlobalAlertRequest)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Signaling alert [\(alertRequest.requestId)] - Message: [\(alertRequest.alertMessage)]...")

        // Set the current alert ID (prevents premature reset)...

        self.alertQueueLock.lock()
        self.currentGlobalAlertId = alertRequest.requestId
        self.alertQueueLock.unlock()

        // Set the alert fields...

        self.sAppDelegateVisitorGlobalAlertMessage    = alertRequest.alertMessage
        self.sAppDelegateVisitorGlobalAlertButtonText = alertRequest.alertButtonText

        // Signal the alert to Views...

        self.isAppDelegateVisitorShowingAlert = true

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Alert [\(alertRequest.requestId)] signaled to View(s)...")

        // ========================================================================
        // WATCHDOG TIMER: Auto-reset if alert doesn't get dismissed within 'AppGlobalInfo.iAlertViaSwiftUITimeout' seconds
        // ========================================================================

        let watchdogTimer = DispatchWorkItem 
        { [weak self] in

            guard let self = self 
            else { return }

            self.alertQueueLock.lock()
            let stillProcessing = self.isProcessingGlobalAlert
            let currentId       = self.currentGlobalAlertId
            let stillShowing    = self.isAppDelegateVisitorShowingAlert
            self.alertQueueLock.unlock()

            if (stillProcessing == true                   &&
                currentId       == alertRequest.requestId &&
                stillShowing    == true)
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WATCHDOG: Alert [\(alertRequest.requestId)] NOT dismissed within #(\(AppGlobalInfo.iAlertViaSwiftUITimeout)) second(s)!")
                appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WATCHDOG: Auto-resetting and advancing queue...")

                // Force reset...

                self.alertQueueLock.lock()
                self.isProcessingGlobalAlert                  = false
                self.currentGlobalAlertId                     = nil
                self.isAppDelegateVisitorShowingAlert         = false
                self.sAppDelegateVisitorGlobalAlertMessage    = "-N/A-"
                self.sAppDelegateVisitorGlobalAlertButtonText = "-N/A-"

                if (self.globalAlertQueue.count         > 0 &&
                    self.globalAlertQueue[0].requestId == alertRequest.requestId)
                {
                    self.globalAlertQueue.removeFirst()
                }

                let remainingCount = self.globalAlertQueue.count
                self.alertQueueLock.unlock()

                if remainingCount > 0 
                {
                    appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WATCHDOG: Processing next alert in queue...")

                    self.processNextGlobalAlert()
                }
            }
        }

        // Start watchdog ('AppGlobalInfo.iAlertViaSwiftUITimeout' second timeout for SwiftUI - user might be away from device)...

        DispatchQueue.main.asyncAfter(deadline:(.now() + AppGlobalInfo.iAlertViaSwiftUITimeout), execute:watchdogTimer)

        return

    }   // End of private func signalGlobalAlert(_ alertRequest:GlobalAlertRequest).

    @objc public func resetAppDelegateVisitorSignalGlobalAlert()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Invoked...")

        self.alertQueueLock.lock()

        // Verify we have a currently displayed alert...

        guard let currentAlertId = self.currentGlobalAlertId 
        else
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WARNING: Reset called but no current alert ID tracked. Performing reset anyway...")

            // Reset anyway for defensive programming...

            self.sAppDelegateVisitorGlobalAlertMessage    = "-N/A-"
            self.sAppDelegateVisitorGlobalAlertButtonText = "-N/A-"
            self.isAppDelegateVisitorShowingAlert         = false

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting after defensive reset...")

            return
        }

        // Remove the completed alert from queue...

        if (self.globalAlertQueue.count         > 0 &&
            self.globalAlertQueue[0].requestId == currentAlertId)
        {
            let completedAlert = self.globalAlertQueue.removeFirst()

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Removed completed alert [\(completedAlert.requestId)] from queue...")
        }
        else
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WARNING: Current alert ID [\(currentAlertId)] NOT at front of queue - Warning!")
        }

        // Clear current alert tracking...

        self.currentGlobalAlertId                     = nil

        // Clear alert fields...

        self.sAppDelegateVisitorGlobalAlertMessage    = "-N/A-"
        self.sAppDelegateVisitorGlobalAlertButtonText = "-N/A-"

        // Hide the alert...

        self.isAppDelegateVisitorShowingAlert         = false

        // Mark processing as complete...

        self.isProcessingGlobalAlert                  = false
        let remainingCount                            = self.globalAlertQueue.count
        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Alert reset complete. Remaining queue depth: #(\(remainingCount))...")

        // Process next alert if any...

        if (remainingCount > 0)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Processing next queued alert...")

            self.processNextGlobalAlert()
        }

        // Exit...

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting...")

        return

    }   // End of @objc public func resetAppDelegateVisitorSignalGlobalAlert().

//  private func processNextGlobalAlert()
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//      
//      // Check if already processing...
//
//      self.alertQueueLock.lock()
//      
//      if (self.isProcessingGlobalAlert == true)
//      {
//          self.alertQueueLock.unlock()
//
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Already processing a global alert, skipping...")
//
//          return
//      }
//      
//      // Check if queue is empty...
//
//      guard globalAlertQueue.count > 0
//      else
//      {
//          self.alertQueueLock.unlock()
//
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Global alert queue is empty...")
//
//          return
//      }
//      
//      // Mark as processing and get next alert...
//
//      self.isProcessingGlobalAlert = true
//      let alertRequest             = self.globalAlertQueue[0]
//      self.alertQueueLock.unlock()
//      
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Processing alert request [\(alertRequest.requestId)] after #(\(self.alertSignalDelaySeconds)) second delay...")
//      
//      // Delay before signaling to allow View re-rendering...
//
//      DispatchQueue.main.asyncAfter(deadline:(.now() + self.alertSignalDelaySeconds))
//      {
//          self.signalGlobalAlert(alertRequest)
//      }
//
//      return
//
//  }   // End of private func processNextGlobalAlert().
//  
//  private func signalGlobalAlert(_ alertRequest:GlobalAlertRequest)
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//      
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Signaling alert [\(alertRequest.requestId)] - Message: [\(alertRequest.alertMessage)]...")
//      
//      // Set the current alert ID (prevents premature reset)...
//
//      self.alertQueueLock.lock()
//      self.currentGlobalAlertId = alertRequest.requestId
//      self.alertQueueLock.unlock()
//      
//      // Set the alert fields...
//
//      self.sAppDelegateVisitorGlobalAlertMessage    = alertRequest.alertMessage
//      self.sAppDelegateVisitorGlobalAlertButtonText = alertRequest.alertButtonText
//      
//      // Signal the alert to Views...
//
//      self.isAppDelegateVisitorShowingAlert = true
//      
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Alert [\(alertRequest.requestId)] signaled to View(s)...")
//
//      return
//
//  }   // End of private func signalGlobalAlert(_ alertRequest:GlobalAlertRequest).
//  
//  @objc public func resetAppDelegateVisitorSignalGlobalAlert()
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//      
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Invoked...")
//      
//      self.alertQueueLock.lock()
//      
//      // Verify we have a currently displayed alert...
//
//      guard let currentAlertId = self.currentGlobalAlertId 
//      else
//      {
//          alertQueueLock.unlock()
//
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WARNING: Reset called but no current alert ID tracked. Performing reset anyway...")
//          
//          // Reset anyway for defensive programming...
//
//          self.sAppDelegateVisitorGlobalAlertMessage    = "-N/A-"
//          self.sAppDelegateVisitorGlobalAlertButtonText = "-N/A-"
//          self.isAppDelegateVisitorShowingAlert         = false
//          
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting after defensive reset...")
//
//          return
//      }
//      
//      // Remove the completed alert from queue...
//
//      if (globalAlertQueue.count         > 0 &&
//          globalAlertQueue[0].requestId == currentAlertId)
//      {
//          let completedAlert = globalAlertQueue.removeFirst()
//
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Removed completed alert [\(completedAlert.requestId)] from queue...")
//      }
//      else
//      {
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WARNING: Current alert ID [\(currentAlertId)] not at front of queue!")
//      }
//      
//      // Clear current alert tracking...
//
//      self.currentGlobalAlertId = nil
//      
//      // Mark processing as complete...
//
//      self.isProcessingGlobalAlert = false
//      let remainingCount           = self.globalAlertQueue.count
//      self.alertQueueLock.unlock()
//      
//      // Reset the alert fields...
//
//      self.sAppDelegateVisitorGlobalAlertMessage    = "-N/A-"
//      self.sAppDelegateVisitorGlobalAlertButtonText = "-N/A-"
//      self.isAppDelegateVisitorShowingAlert         = false
//      
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Alert reset complete. Remaining queue depth: #(\(remainingCount))...")
//      
//      // Process next alert if any...
//
//      if (remainingCount > 0)
//      {
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Processing next queued alert...")
//
//          self.processNextGlobalAlert()
//      }
//      
//      // Exit...
//
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting...")
//      
//      return
//
//  }   // End of @objc public func resetAppDelegateVisitorSignalGlobalAlert().

    // -------------------------------------------------------------------------
    // COMPLETION ALERT METHODS (Refactored)
    // -------------------------------------------------------------------------
    
//  public func setAppDelegateVisitorSignalCompletionAlert(_ alertMsg:String? = nil, 
//                                                         alertButtonText1:String? = nil, 
//                                                         alertButtonText2:String? = nil,
//                                                         withCompletion1 completionHandler1:(()->())?,
//                                                         withCompletion2 completionHandler2:(()->())?)
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//      
//      appLogMsg("\(sCurrMethodDisp) Invoked - parameter(s) 'alertMsg' is [\(String(describing: alertMsg))] - 'alertButtonText1' is [\(String(describing: alertButtonText1))] - 'alertButtonText2' is [\(String(describing: alertButtonText2))]...")
//      
//      // Validate and prepare alert message...
//
//      let finalAlertMessage:String
//
//      if (alertMsg        == nil ||
//          alertMsg!.count  < 1)
//      {
//          finalAlertMessage = "-N/A-"
//      }
//      else
//      {
//          finalAlertMessage = alertMsg!
//      }
//      
//      // Validate and prepare button text 1...
//
//      let finalAlertButtonText1:String
//
//      if (alertButtonText1        == nil ||
//          alertButtonText1!.count  < 1)
//      {
//          finalAlertButtonText1 = "-N/A-"
//      }
//      else
//      {
//          finalAlertButtonText1 = alertButtonText1!
//      }
//      
//      // Validate and prepare button text 2...
//
//      let finalAlertButtonText2:String
//
//      if (alertButtonText2        == nil || 
//          alertButtonText2!.count  < 1)
//      {
//          finalAlertButtonText2 = ""
//      }
//      else
//      {
//          finalAlertButtonText2 = alertButtonText2!
//      }
//      
//      // Create alert request...
//
//      let alertRequest = CompletionAlertRequest(alertMessage:      finalAlertMessage,
//                                                alertButtonText1:  finalAlertButtonText1,
//                                                alertButtonText2:  finalAlertButtonText2,
//                                                completionHandler1:completionHandler1,
//                                                completionHandler2:completionHandler2)
//      
//      // Add to queue with thread safety...
//
//      alertQueueLock.lock()
//      completionAlertQueue.append(alertRequest)
//      let queueCount = completionAlertQueue.count
//      alertQueueLock.unlock()
//      
//      appLogMsg("\(sCurrMethodDisp) Alert request [\(alertRequest.requestId)] added to queue - queue depth: #(\(queueCount))...")
//      
//      // Process the queue (if not already processing)...
//
//      self.processNextCompletionAlert()
//      
//      // Exit...
//
//      appLogMsg("\(sCurrMethodDisp) Exiting...")
//      
//      return
//
//  }   // End of public func setAppDelegateVisitorSignalCompletionAlert(...).

// ============================================================================
// SECTION 6: MODIFIED setAppDelegateVisitorSignalCompletionAlert METHOD
// Replace the existing method (around line 2016) with this version
// ============================================================================

    @objc public func setAppDelegateVisitorSignalCompletionAlert(_ alertMsg:String? = nil, 
                                                                 alertButtonText1:String? = nil, 
                                                                 alertButtonText2:String? = nil,
                                                                 withCompletion1 completionHandler1:(()->())?,
                                                                 withCompletion2 completionHandler2:(()->())?)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Invoked - parameter(s) 'alertMsg' is [\(String(describing: alertMsg))] - 'alertButtonText1' is [\(String(describing: alertButtonText1))] - 'alertButtonText2' is [\(String(describing: alertButtonText2))]...")

        // Validate and prepare alert message...

        let finalAlertMessage:String

        if (alertMsg        == nil || 
            alertMsg!.count  < 1)
        {
            finalAlertMessage = "-N/A-"
        }
        else
        {
            finalAlertMessage = alertMsg!
        }

        // Validate and prepare button text 1...

        let finalAlertButtonText1:String

        if (alertButtonText1        == nil ||
            alertButtonText1!.count  < 1)
        {
            finalAlertButtonText1 = "-N/A-"
        }
        else
        {
            finalAlertButtonText1 = alertButtonText1!
        }

        // Validate and prepare button text 2...

        let finalAlertButtonText2:String

        if (alertButtonText2        == nil ||
            alertButtonText2!.count  < 1)
        {
            finalAlertButtonText2 = ""
        }
        else
        {
            finalAlertButtonText2 = alertButtonText2!
        }

    #if INSTANTIATE_APP_VV_UIKIT_ALERTS
        // Check if we should route to UIKit presentation...

        if (self.shouldUseUIKitPresentation() == true)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Routing to UIKit completion alert queue...")

            // Create alert request
            let alertRequest = CompletionAlertRequest(alertMessage:      finalAlertMessage,
                                                      alertButtonText1:  finalAlertButtonText1,
                                                      alertButtonText2:  finalAlertButtonText2,
                                                      completionHandler1:completionHandler1,
                                                      completionHandler2:completionHandler2)

            // Add to UIKit queue with thread safety...

            self.alertQueueLock.lock()
            self.uiKitCompletionAlertQueue.append(alertRequest)
            let queueCount = self.uiKitCompletionAlertQueue.count
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> UIKit completion alert request [\(alertRequest.requestId)] added to queue. Queue depth: #(\(queueCount))...")

            // Process the UIKit queue...

            self.processNextUIKitCompletionAlert()

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting via UIKit path...")

            return
        }
    #endif

        // Fall through to SwiftUI queue path...

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Routing to SwiftUI completion alert queue...")

        // Create alert request...

        let alertRequest = CompletionAlertRequest(alertMessage:      finalAlertMessage,
                                                  alertButtonText1:  finalAlertButtonText1,
                                                  alertButtonText2:  finalAlertButtonText2,
                                                  completionHandler1:completionHandler1,
                                                  completionHandler2:completionHandler2)

        // Add to queue with thread safety...

        self.alertQueueLock.lock()
        self.completionAlertQueue.append(alertRequest)
        let queueCount = self.completionAlertQueue.count
        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Alert request [\(alertRequest.requestId)] added to queue. Queue depth: #(\(queueCount))...")

        // Process the queue (if not already processing)...

        self.processNextCompletionAlert()

        // Exit...

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting...")

        return

    }   // End of public func setAppDelegateVisitorSignalCompletionAlert(...).

// ============================================================================
// SECTION B: SWIFTUI COMPLETION ALERT METHODS WITH WATCHDOG
// Replace existing methods around lines 3430-3730
// ============================================================================

    private func processNextCompletionAlert()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        // Check if already processing...

        self.alertQueueLock.lock()

        if (self.isProcessingCompletionAlert == true)
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Already processing a completion alert, skipping...")

            return
        }

        // Check if queue is empty...

        guard completionAlertQueue.count > 0
        else
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Completion alert queue is empty...")

            return
        }

        // Mark as processing and get next alert...

        self.isProcessingCompletionAlert = true
        let alertRequest                 = self.completionAlertQueue[0]
        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Processing completion alert request [\(alertRequest.requestId)] after #(\(self.alertSignalDelaySeconds)) second delay...")

        // Delay before signaling...

        DispatchQueue.main.asyncAfter(deadline:(.now() + self.alertSignalDelaySeconds))
        {
            self.signalCompletionAlert(alertRequest)
        }

        return

    }   // End of private func processNextCompletionAlert().

    private func signalCompletionAlert(_ alertRequest:CompletionAlertRequest)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Signaling completion alert [\(alertRequest.requestId)] - Message: [\(alertRequest.alertMessage)]...")

        // Set the current alert ID...

        self.alertQueueLock.lock()
        self.currentCompletionAlertId                      = alertRequest.requestId

        // Store completion handlers for execution...

        self.appDelegateVisitorCompletionClosure1          = alertRequest.completionHandler1
        self.appDelegateVisitorCompletionClosure2          = alertRequest.completionHandler2
        self.alertQueueLock.unlock()

        // Set the alert fields...

        self.sAppDelegateVisitorCompletionAlertMessage     = alertRequest.alertMessage
        self.sAppDelegateVisitorCompletionAlertButtonText1 = alertRequest.alertButtonText1
        self.sAppDelegateVisitorCompletionAlertButtonText2 = alertRequest.alertButtonText2

        // Signal the alert...

        self.isAppDelegateVisitorShowingCompletionAlert    = true

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Completion alert [\(alertRequest.requestId)] signaled to View(s)...")

        // ========================================================================
        // WATCHDOG TIMER: Auto-reset if not dismissed within 'AppGlobalInfo.iAlertViaSwiftUITimeout' seconds
        // ========================================================================

        let watchdogTimer = DispatchWorkItem 
        { [weak self] in

            guard let self = self 
            else { return }

            self.alertQueueLock.lock()
            let stillProcessing = self.isProcessingCompletionAlert
            let currentId       = self.currentCompletionAlertId
            let stillShowing    = self.isAppDelegateVisitorShowingCompletionAlert
            self.alertQueueLock.unlock()

            if (stillProcessing == true                   &&
                currentId       == alertRequest.requestId &&
                stillShowing    == true)
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WATCHDOG: Completion alert [\(alertRequest.requestId)] not dismissed within #(\(AppGlobalInfo.iAlertViaSwiftUITimeout)) second(s)!")
                appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WATCHDOG: Auto-resetting and advancing queue...")

                // Force reset...

                self.alertQueueLock.lock()
                self.isProcessingCompletionAlert                   = false
                self.currentCompletionAlertId                      = nil
                self.isAppDelegateVisitorShowingCompletionAlert    = false
                self.sAppDelegateVisitorCompletionAlertMessage     = "-N/A-"
                self.sAppDelegateVisitorCompletionAlertButtonText1 = "-N/A-"
                self.sAppDelegateVisitorCompletionAlertButtonText2 = ""
                self.appDelegateVisitorCompletionClosure1          = nil
                self.appDelegateVisitorCompletionClosure2          = nil

                if (self.completionAlertQueue.count         > 0 &&
                    self.completionAlertQueue[0].requestId == alertRequest.requestId)
                {
                    self.completionAlertQueue.removeFirst()
                }

                let remainingCount = self.completionAlertQueue.count
                self.alertQueueLock.unlock()

                if (remainingCount > 0)
                {
                    appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WATCHDOG: Processing next completion alert in queue...")

                    self.processNextCompletionAlert()
                }
            }
        }

        // Start watchdog ('AppGlobalInfo.iAlertViaSwiftUITimeout' second timeout)...

        DispatchQueue.main.asyncAfter(deadline:(.now() + AppGlobalInfo.iAlertViaSwiftUITimeout), execute:watchdogTimer)

        return

    }   // End of private func signalCompletionAlert(_ alertRequest:CompletionAlertRequest).

    @objc public func resetAppDelegateVisitorSignalCompletionAlert(_ idButtonClicked:Int)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Invoked - 'idButtonClicked' is #(\(idButtonClicked))...")

        // Execute completion handler if present (BEFORE clearing)...

        if (idButtonClicked == 1)
        {
            if self.appDelegateVisitorCompletionClosure1 != nil
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Calling the 'completion' closure #1...")
                self.appDelegateVisitorCompletionClosure1!()
                appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Called  the 'completion' closure #1...")
            }
            else
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Bypassing calling the 'completion' closure #1 - closure is nil...")
            }
        }
        else
        {
            if self.appDelegateVisitorCompletionClosure2 != nil
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Calling the 'completion' closure #2...")
                self.appDelegateVisitorCompletionClosure2!()
                appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Called  the 'completion' closure #2...")
            }
            else
            {
                appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Bypassing calling the 'completion' closure #2 - closure is nil...")
            }
        }

        self.alertQueueLock.lock()

        // Verify we have a currently displayed alert...

        guard let currentAlertId = self.currentCompletionAlertId 
        else
        {
            self.alertQueueLock.unlock()

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WARNING: Reset called but no current completion alert ID tracked")

            return
        }

        // Remove the completed alert from queue...

        if (self.completionAlertQueue.count         > 0 &&
            self.completionAlertQueue[0].requestId == currentAlertId)
        {
            let completedAlert = self.completionAlertQueue.removeFirst()

            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Removed completed completion alert [\(completedAlert.requestId)] from queue...")
        }
        else
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WARNING: Current completion alert ID [\(currentAlertId)] not at front of queue!")
        }

        // Clear current alert tracking and completion handlers...

        self.currentCompletionAlertId                      = nil
        self.appDelegateVisitorCompletionClosure1          = nil
        self.appDelegateVisitorCompletionClosure2          = nil

        // Clear alert fields...

        self.sAppDelegateVisitorCompletionAlertMessage     = "-N/A-"
        self.sAppDelegateVisitorCompletionAlertButtonText1 = "-N/A-"
        self.sAppDelegateVisitorCompletionAlertButtonText2 = ""

        // Hide the alert...

        self.isAppDelegateVisitorShowingCompletionAlert    = false

        // Mark processing as complete...

        self.isProcessingCompletionAlert                   = false
        let remainingCount                                 = self.completionAlertQueue.count
        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Completion alert reset complete. Remaining queue depth: #(\(remainingCount))...")

        // Process next alert if any...

        if (remainingCount > 0)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Processing next queued completion alert...")

            self.processNextCompletionAlert()
        }

        // Exit...

        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting...")

        return

    }   // End of @objc public func resetAppDelegateVisitorSignalCompletionAlert(idButtonClicked:Int).
    
//  private func processNextCompletionAlert()
//  {
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//      
//      // Check if already processing...
//
//      self.alertQueueLock.lock()
//      
//      if (isProcessingCompletionAlert)
//      {
//          self.alertQueueLock.unlock()
//
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Already processing a completion alert, skipping...")
//
//          return
//      }
//      
//      // Check if queue is empty...
//
//      guard completionAlertQueue.count > 0 else
//      {
//          self.alertQueueLock.unlock()
//
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Completion alert queue is empty...")
//
//          return
//      }
//      
//      // Mark as processing and get next alert...
//
//      isProcessingCompletionAlert = true
//      let alertRequest            = completionAlertQueue[0]
//      self.alertQueueLock.unlock()
//      
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Processing alert request [\(alertRequest.requestId)] after #(\(self.alertSignalDelaySeconds)) second delay...")
//      
//      // Delay before signaling to allow View re-rendering...
//
//      DispatchQueue.main.asyncAfter(deadline:(.now() + self.alertSignalDelaySeconds))
//      {
//          self.signalCompletionAlert(alertRequest)
//      }
//
//      // Exit...
//
//      return
//
//  }   // End of private func processNextCompletionAlert().
//  
//  private func signalCompletionAlert(_ alertRequest:CompletionAlertRequest)
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//      
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Signaling alert [\(alertRequest.requestId)] - Message: [\(alertRequest.alertMessage)]...")
//      
//      // Set the current alert ID (prevents premature reset)...
//
//      self.alertQueueLock.lock()
//      self.currentCompletionAlertId = alertRequest.requestId
//      self.alertQueueLock.unlock()
//      
//      // Set the alert fields...
//
//      self.sAppDelegateVisitorCompletionAlertMessage      = alertRequest.alertMessage
//      self.sAppDelegateVisitorCompletionAlertButtonText1  = alertRequest.alertButtonText1
//      self.sAppDelegateVisitorCompletionAlertButtonText2  = alertRequest.alertButtonText2
//      self.appDelegateVisitorCompletionClosure1           = alertRequest.completionHandler1
//      self.appDelegateVisitorCompletionClosure2           = alertRequest.completionHandler2
//      
//      // Set button 2 visibility...
//
//      if (alertRequest.alertButtonText2.count < 1)
//      {
//          self.isAppDelegateVisitorShowingCompletionAlert2ndButton = false
//      }
//      else
//      {
//          self.isAppDelegateVisitorShowingCompletionAlert2ndButton = true
//      }
//      
//      // Signal the alert to Views...
//
//      self.isAppDelegateVisitorShowingCompletionAlert = true
//      
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Alert [\(alertRequest.requestId)] signaled to View(s)...")
//
//      return
//
//  }   // End of private func signalCompletionAlert(_ alertRequest:CompletionAlertRequest).
//  
//  @objc public func resetAppDelegateVisitorSignalCompletionAlert(idButtonClicked:Int = 1)
//  {
//
//      let sCurrMethod:String     = #function
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//      
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Invoked - 'idButtonClicked' is [\(idButtonClicked)]...")
//      
//      // Execute completion handler if present...
//
//      if (idButtonClicked == 1)
//      {
//          if self.appDelegateVisitorCompletionClosure1 != nil
//          {
//              appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Calling the 'completion' closure #1...")
//              self.appDelegateVisitorCompletionClosure1!()
//              appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Called  the 'completion' closure #1...")
//          }
//          else
//          {
//              appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Bypassing calling the 'completion' closure #1 - closure is nil...")
//          }
//      }
//      else
//      {
//          if self.appDelegateVisitorCompletionClosure2 != nil
//          {
//              appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Calling the 'completion' closure #2...")
//              self.appDelegateVisitorCompletionClosure2!()
//              appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Called  the 'completion' closure #2...")
//          }
//          else
//          {
//              appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Bypassing calling the 'completion' closure #2 - closure is nil...")
//          }
//      }
//      
//      self.alertQueueLock.lock()
//      
//      // Verify we have a currently displayed alert...
//
//      guard let currentAlertId = self.currentCompletionAlertId else
//      {
//          self.alertQueueLock.unlock()
//
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WARNING: Reset called but no current alert ID tracked. Performing reset anyway...")
//          
//          // Reset anyway for defensive programming...
//
//          self.sAppDelegateVisitorCompletionAlertMessage           = ""
//          self.sAppDelegateVisitorCompletionAlertButtonText1       = ""
//          self.sAppDelegateVisitorCompletionAlertButtonText2       = ""
//          self.appDelegateVisitorCompletionClosure1                = nil
//          self.appDelegateVisitorCompletionClosure2                = nil
//          self.isAppDelegateVisitorShowingCompletionAlert          = false
//          self.isAppDelegateVisitorShowingCompletionAlert2ndButton = false
//          
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting after defensive reset...")
//
//          return
//      }
//      
//      // Remove the completed alert from queue...
//
//      if (completionAlertQueue.count         > 0 &&
//          completionAlertQueue[0].requestId == currentAlertId)
//      {
//          let completedAlert = completionAlertQueue.removeFirst()
//
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Removed completed alert [\(completedAlert.requestId)] from queue...")
//      }
//      else
//      {
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> WARNING: Current alert ID [\(currentAlertId)] not at front of queue!")
//      }
//      
//      // Clear current alert tracking...
//
//      self.currentCompletionAlertId = nil
//      
//      // Mark processing as complete...
//
//      self.isProcessingCompletionAlert = false
//      let remainingCount               = completionAlertQueue.count
//      self.alertQueueLock.unlock()
//      
//      // Reset the alert fields...
//
//      self.sAppDelegateVisitorCompletionAlertMessage           = ""
//      self.sAppDelegateVisitorCompletionAlertButtonText1       = ""
//      self.sAppDelegateVisitorCompletionAlertButtonText2       = ""
//      self.appDelegateVisitorCompletionClosure1                = nil
//      self.appDelegateVisitorCompletionClosure2                = nil
//      self.isAppDelegateVisitorShowingCompletionAlert          = false
//      self.isAppDelegateVisitorShowingCompletionAlert2ndButton = false
//      
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Alert reset complete. Remaining queue depth: #(\(remainingCount))...")
//      
//      // Process next alert if any...
//
//      if (remainingCount > 0)
//      {
//          appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Processing next queued alert...")
//
//          self.processNextCompletionAlert()
//      }
//      
//      // Exit...
//
//      appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting...")
//      
//      return
//
//  }   // End of @objc public func resetAppDelegateVisitorSignalCompletionAlert(idButtonClicked:Int = 1).

    // -------------------------------------------------------------------------
    // OPTIONAL: Queue Management Utilities
    // -------------------------------------------------------------------------
    
    @objc public func clearAllAlertQueues()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Invoked - clearing ALL alert queues...")
        
        self.alertQueueLock.lock()
        
        let globalCount                  = self.globalAlertQueue.count
        let completionCount              = self.completionAlertQueue.count
        
        self.globalAlertQueue.removeAll()
        self.completionAlertQueue.removeAll()
        
        self.currentGlobalAlertId        = nil
        self.currentCompletionAlertId    = nil
        self.isProcessingGlobalAlert     = false
        self.isProcessingCompletionAlert = false
        
        self.alertQueueLock.unlock()
        
        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Cleared #(\(globalCount)) global alert(s) and #(\(completionCount)) completion alert(s)...")
        appLogMsg("\(sCurrMethodDisp) <AlertViaSwiftUI> Exiting...")
        
        return

    }   // End of @objc public func clearAllAlertQueues().
    
    @objc public func getGlobalAlertQueueDepth()->Int
    {

        self.alertQueueLock.lock()
        let depth = self.globalAlertQueue.count
        self.alertQueueLock.unlock()
        
        return depth

    }   // End of @objc public func getGlobalAlertQueueDepth()->Int.
    
    @objc public func getCompletionAlertQueueDepth()->Int
    {

        self.alertQueueLock.lock()
        let depth = self.completionAlertQueue.count
        self.alertQueueLock.unlock()
        
        return depth

    }   // End of @objc public func getCompletionAlertQueueDepth()->Int.

// ============================================================================
// SECTION 7: UTILITY METHODS
// Add these queue management utilities (optional)
// ============================================================================

#if INSTANTIATE_APP_VV_UIKIT_ALERTS
    // -------------------------------------------------------------------------
    // UIKit Queue Management Utilities
    // -------------------------------------------------------------------------

    @objc public func clearAllUIKitAlertQueues()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Invoked - clearing ALL UIKit alert queues...")

        self.alertQueueLock.lock()
        let uiKitGlobalCount                  = self.uiKitGlobalAlertQueue.count
        let uiKitCompletionCount              = self.uiKitCompletionAlertQueue.count
        self.uiKitGlobalAlertQueue.removeAll()
        self.uiKitCompletionAlertQueue.removeAll()
        self.currentUIKitGlobalAlertId        = nil
        self.currentUIKitCompletionAlertId    = nil
        self.isProcessingUIKitGlobalAlert     = false
        self.isProcessingUIKitCompletionAlert = false
        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Cleared #(\(uiKitGlobalCount)) UIKit global alerts and #(\(uiKitCompletionCount)) UIKit completion alerts...")
        appLogMsg("\(sCurrMethodDisp) <AlertViaUIKit> Exiting...")

        return

    }   // End of @objc public func clearAllUIKitAlertQueues().

    @objc public func getUIKitGlobalAlertQueueDepth()->Int
    {

        self.alertQueueLock.lock()
        let depth = self.uiKitGlobalAlertQueue.count
        self.alertQueueLock.unlock()

        return depth

    }   // End of @objc public func getUIKitGlobalAlertQueueDepth()->Int.

    @objc public func getUIKitCompletionAlertQueueDepth()->Int
    {

        self.alertQueueLock.lock()
        let depth = self.uiKitCompletionAlertQueue.count
        self.alertQueueLock.unlock()

        return depth

    }   // End of @objc public func getUIKitCompletionAlertQueueDepth()->Int.
#endif

    // Method(s) to assist with sending Email with a File upload (and 'optional' Alert message)...

    @objc public func appDelegateVisitorSendEmailUpload(_ emailAddressTo:String,
                                                          emailAddressCc:String,  
                                                          emailSourceFilespec:String,
                                                          emailSourceFilename:String,
                                                          emailZipFilename:String,
                                                          emailSaveAsFilename:String,
                                                          emailFileMimeType:String,
                                                          emailFileData:NSData)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")

        // Pass the request on to the 'core' method...

        self.appDelegateVisitorSendUploadCore(alertIsBypassed:false,
                                              emailAddressTo:emailAddressTo,
                                              emailAddressCc:emailAddressCc,  
                                              emailSourceFilespec:emailSourceFilespec,
                                              emailSourceFilename:emailSourceFilename,
                                              emailZipFilename:emailZipFilename,
                                              emailSaveAsFilename:emailSaveAsFilename,
                                              emailFileMimeType:emailFileMimeType,
                                              emailFileData:emailFileData)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func appDelegateVisitorSendEmailUpload().

    @objc public func appDelegateVisitorSendSilentUpload(_ emailAddressTo:String,
                                                           emailAddressCc:String,  
                                                           emailSourceFilespec:String,
                                                           emailSourceFilename:String,
                                                           emailZipFilename:String,
                                                           emailSaveAsFilename:String,
                                                           emailFileMimeType:String,
                                                           emailFileData:NSData)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")

        // Pass the request on to the 'core' method...

        self.appDelegateVisitorSendUploadCore(alertIsBypassed:true,
                                              emailAddressTo:emailAddressTo,
                                              emailAddressCc:emailAddressCc,  
                                              emailSourceFilespec:emailSourceFilespec,
                                              emailSourceFilename:emailSourceFilename,
                                              emailZipFilename:emailZipFilename,
                                              emailSaveAsFilename:emailSaveAsFilename,
                                              emailFileMimeType:emailFileMimeType,
                                              emailFileData:emailFileData)

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func appDelegateVisitorSendEmailUpload().

    private func appDelegateVisitorSendUploadCore(alertIsBypassed:Bool,
                                                  emailAddressTo:String,
                                                  emailAddressCc:String,  
                                                  emailSourceFilespec:String,
                                                  emailSourceFilename:String,
                                                  emailZipFilename:String,
                                                  emailSaveAsFilename:String,
                                                  emailFileMimeType:String,
                                                  emailFileData:NSData)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'self' is [\(self)] - 'alertIsBypassed' is [\(alertIsBypassed)]...")

        // Remap the inbound parameter(s) into a MultipartRequestInfo object...

        let multipartRequestInfo:MultipartRequestInfo     = MultipartRequestInfo()

        multipartRequestInfo.bAppZipSourceToUpload        = false
        multipartRequestInfo.sAppUploadURL                = ""          // "" takes the Upload URL 'default'...
        multipartRequestInfo.sAppUploadNotifyFrom         = AppGlobalInfo.sAppUploadNotifyFrom
        multipartRequestInfo.sAppUploadNotifyTo           = emailAddressTo
        multipartRequestInfo.sAppUploadNotifyCc           = emailAddressCc
        multipartRequestInfo.sAppSourceFilespec           = emailSourceFilespec
        multipartRequestInfo.sAppSourceFilename           = emailSourceFilename
        multipartRequestInfo.sAppZipFilename              = emailZipFilename
        multipartRequestInfo.sAppSaveAsFilename           = emailSourceFilename
        multipartRequestInfo.sAppFileMimeType             = emailFileMimeType
        multipartRequestInfo.dataAppFile                  = Data(referencing:emailFileData)

        appLogMsg("\(sCurrMethodDisp) The 'upload' is using 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo.toString()))]...")

        // Send the 'upload' to the Server...

        let multipartRequestDriver:MultipartRequestDriver = MultipartRequestDriver(bGenerateResponseLongMsg:false, 
                                                                                   bAlertIsBypassed:alertIsBypassed)

        appLogMsg("\(sCurrMethodDisp) Calling 'multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:)' - 'alertIsBypassed' is [\(alertIsBypassed)]...")

        multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:multipartRequestInfo)
        
        appLogMsg("\(sCurrMethodDisp) Called  'multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:)' - 'alertIsBypassed' is [\(alertIsBypassed)]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of private func appDelegateVisitorSendUploadCore().

// ============================================================================
// SECTION E: EMERGENCY FORCE RESET METHOD (Both Sides)
// Add near end of class, before closing brace
// ============================================================================

    @objc public func forceResetAllAlertProcessing()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <AlertViaBoth> FORCE RESET: Manually clearing ALL stuck processing flags...")

        self.alertQueueLock.lock()

        // SwiftUI side...

        let wasProcessingSwiftUIGlobal                  = self.isProcessingGlobalAlert
        let wasProcessingSwiftUICompletion              = self.isProcessingCompletionAlert
        let swiftUIGlobalDepth                          = self.globalAlertQueue.count
        let swiftUICompletionDepth                      = self.completionAlertQueue.count

        self.isProcessingGlobalAlert                    = false
        self.isProcessingCompletionAlert                = false
        self.currentGlobalAlertId                       = nil
        self.currentCompletionAlertId                   = nil
        self.isAppDelegateVisitorShowingAlert           = false
        self.isAppDelegateVisitorShowingCompletionAlert = false
        self.appDelegateVisitorCompletionClosure1       = nil
        self.appDelegateVisitorCompletionClosure2       = nil

    #if INSTANTIATE_APP_VV_UIKIT_ALERTS
        // UIKit side...

        let wasProcessingUIKitGlobal                    = self.isProcessingUIKitGlobalAlert
        let wasProcessingUIKitCompletion                = self.isProcessingUIKitCompletionAlert
        let uiKitGlobalDepth                            = self.uiKitGlobalAlertQueue.count
        let uiKitCompletionDepth                        = self.uiKitCompletionAlertQueue.count

        self.isProcessingUIKitGlobalAlert               = false
        self.isProcessingUIKitCompletionAlert           = false
        self.currentUIKitGlobalAlertId                  = nil
        self.currentUIKitCompletionAlertId              = nil
    #endif

        self.alertQueueLock.unlock()

        appLogMsg("\(sCurrMethodDisp) <AlertViaBoth> SwiftUI: Was processing global: [\(wasProcessingSwiftUIGlobal)], completion: [\(wasProcessingSwiftUICompletion)]...")
        appLogMsg("\(sCurrMethodDisp) <AlertViaBoth> SwiftUI: Queue depths - global: [\(swiftUIGlobalDepth)], completion: [\(swiftUICompletionDepth)]...")

    #if INSTANTIATE_APP_VV_UIKIT_ALERTS
        appLogMsg("\(sCurrMethodDisp) <AlertViaBoth> UIKit: Was processing global: [\(wasProcessingUIKitGlobal)], completion: [\(wasProcessingUIKitCompletion)]...")
        appLogMsg("\(sCurrMethodDisp) <AlertViaBoth> UIKit: Queue depths - global: [\(uiKitGlobalDepth)], completion: [\(uiKitCompletionDepth)]...")
    #endif

        // Try to restart processing
        if (swiftUIGlobalDepth > 0)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaBoth> Restarting SwiftUI global alert queue...")

            self.processNextGlobalAlert()
        }

        if (swiftUICompletionDepth > 0)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaBoth> Restarting SwiftUI completion alert queue...")

            self.processNextCompletionAlert()
        }

    #if INSTANTIATE_APP_VV_UIKIT_ALERTS
        if (uiKitGlobalDepth > 0)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaBoth> Restarting UIKit global alert queue...")

            self.processNextUIKitGlobalAlert()
        }

        if (uiKitCompletionDepth > 0)
        {
            appLogMsg("\(sCurrMethodDisp) <AlertViaBoth> Restarting UIKit completion alert queue...")

            self.processNextUIKitCompletionAlert()
        }
    #endif

        appLogMsg("\(sCurrMethodDisp) <AlertViaBoth> Force reset complete...")

        return

    }   // End of @objc public func forceResetAllAlertProcessing().

#if os(macOS)
    // NSApplicationDelegate method(s):

    @objc public func appDelegateVisitorWillFinishLaunching(_ aNotification:Notification) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func appDelegateVisitorWillFinishLaunching(aNotification:).

    @objc public func appDelegateVisitorDidFinishLaunching(_ aNotification:Notification) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")

        self.dumpAppCommandLineArgs()

        // Tell the 'shared' instance of the AppGlobalInfo struct that we're in the Foreground...

        self.appGlobalInfo.setAppInForeground()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func appDelegateVisitorDidFinishLaunching(aNotification:).

    @objc public func appDelegateVisitorDidBecomeActive(_ aNotification:Notification) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")

        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) AppDelegateVisitor did become active...")

        // Additional safety check when App becomes active...

        if let window = NSApplication.shared.windows.first 
        {
            let screenFrame = window.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero
            let windowFrame = window.frame

            // If window is completely off-screen, reposition it...

            if (!screenFrame.intersects(windowFrame))
            {
                appLogMsg("\(sCurrMethodDisp) Window detected off-screen, repositioning...")

                window.center()
            }

        }

    #if INSTANTIATE_APP_CORELOCATIONSUPPORT && INSTANTIATE_APP_CORELOCATIONAUTOSYNCSUPPORT
        // Checking for a stale 'auto-sync' CLLocs...

        appLogMsg("\(sCurrMethodDisp) <AppBGTasks> App entering foreground - checking for stale sync...")

        Task.detached(priority:.background) 
        {
            await JmAppAutoSyncCLLocModels.jmAppAutoSyncCLLocModels.checkAndTriggerForegroundSyncIfNeeded(
                thresholdHours:JmAppAutoSyncCLLocModels.jmAppAutoSyncCLLocModels.dForegroundSyncThresholdHours,
                triggerSource: "ForegroundEntry")
        }
    #endif

        // Tell the 'shared' instance of the AppGlobalInfo struct that we're in the Foreground...

        self.appGlobalInfo.setAppInForeground()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of appDelegateVisitorDidBecomeActive(_ aNotification:Notification).

    @objc public func appDelegateVisitorDidResignActive(_ aNotification:Notification) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")

        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) AppDelegateVisitor did resign active...")

        // Tell the 'shared' instance of the AppGlobalInfo struct that we're in the Background...

        self.appGlobalInfo.setAppInBackground()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of appDelegateVisitorDidResignActive(_ aNotification:Notification).

    @objc public func appDelegateVisitorWillTerminate(_ aNotification:Notification) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'aNotification' is [\(aNotification)] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")

        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) AppDelegateVisitor is stopping...")

    #if INSTANTIATE_APP_WINDOWPOSITIONMANAGER
        // Save window position when the App terminates...

        if let window = NSApplication.shared.windows.first 
        {
            self.jmAppWindowPositionManager.saveWindowPosition(window)
        }
    #endif

        // Tell the 'shared' instance of the AppGlobalInfo struct that we're in the Background...

        self.appGlobalInfo.setAppInBackground()
    //  self.performAppDelegateVisitorTerminatingCrashLogic()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func appDelegateVisitorWillTerminate(aNotification:).

    @objc public func appDelegateVisitorApplication(_ application:NSApplication, open urls:[URL])
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'application' is [\(application)] - 'urls' are [\(urls)]...")

        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) -> Unhandled url(s) -> \(urls)")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func appDelegateVisitorApplication(application:, urls:).

#elseif os(iOS)

    // UIApplicationDelegate method(s):

    // NOTE: This method can NOT be marked @objc because 'willFinishLaunchingWithOptions' is a Swift struct...
    
    public func appDelegateVisitorWillFinishLaunchingWithOptions(_ uiApplication:UIApplication, willFinishLaunchingWithOptions:[UIApplication.LaunchOptionsKey:Any?]) -> Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'willFinishLaunchingWithOptions' is [\(String(describing: willFinishLaunchingWithOptions))] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return true

    }   // End of public func appDelegateVisitorWillFinishLaunchingWithOptions(uiApplication:, willFinishLaunchingWithOptions:).
    
    @objc public func appDelegateVisitorWillFinishLaunchingWithOptions(_ uiApplication:UIApplication) -> Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return true

    }   // End of public func @objc appDelegateVisitorWillFinishLaunchingWithOptions(uiApplication:).
    
    // NOTE: This method can NOT be marked @objc because 'willFinishLaunchingWithOptions' is a Swift struct...
    
    public func appDelegateVisitorDidFinishLaunchingWithOptions(_ uiApplication:UIApplication, didFinishLaunchingWithOptions:[UIApplication.LaunchOptionsKey:Any?]) -> Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'didFinishLaunchingWithOptions' is [\(String(describing: didFinishLaunchingWithOptions))] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")

        self.dumpAppCommandLineArgs()

        // Tell the 'shared' instance of the AppGlobalInfo struct that we're in the Foreground...

        self.appGlobalInfo.setAppInForeground()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return true

    }   // End of public func appDelegateVisitorDidFinishLaunchingWithOptions(uiApplication:, didFinishLaunchingWithOptions:).

    @objc public func appDelegateVisitorDidFinishLaunchingWithOptions(_ uiApplication:UIApplication) -> Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")

        self.dumpAppCommandLineArgs()

        // Tell the 'shared' instance of the AppGlobalInfo struct that we're in the Foreground...

        self.appGlobalInfo.setAppInForeground()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return true

    }   // End of public func @objc appDelegateVisitorDidFinishLaunchingWithOptions(uiApplication:).

    @objc public func applicationWillEnterForeground(_ uiApplication:UIApplication) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")
        
        // Tell the 'shared' instance of the AppGlobalInfo struct that we're in the Foreground...

        self.appGlobalInfo.setAppInForeground()

    #if INSTANTIATE_APP_CORELOCATIONSUPPORT && INSTANTIATE_APP_CORELOCATIONAUTOSYNCSUPPORT
        appLogMsg("\(sCurrMethodDisp) <AppBGTasks> App entering foreground - checking for stale sync...")

        Task.detached(priority:.background) 
        {
            await JmAppAutoSyncCLLocModels.jmAppAutoSyncCLLocModels.checkAndTriggerForegroundSyncIfNeeded(
                thresholdHours:JmAppAutoSyncCLLocModels.jmAppAutoSyncCLLocModels.dForegroundSyncThresholdHours,
                triggerSource: "ForegroundEntry")
        }
    #endif

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func applicationWillEnterForeground(_ application:UIApplication).

    @objc public func applicationWillResignActive(_ uiApplication:UIApplication) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")
        
        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func applicationWillResignActive(_ application:UIApplication).

    @objc public func applicationDidEnterBackground(_ uiApplication:UIApplication) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(String(describing: uiApplication))] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")
        
        // Tell the 'shared' instance of the AppGlobalInfo struct that we're in the Background...

        self.appGlobalInfo.setAppInBackground()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func applicationDidEnterBackground(_ application:UIApplication).

    @objc public func appDelegateVisitorWillTerminate(_ uiApplication:UIApplication)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'uiApplication' is [\(uiApplication)] - 'sApplicationName' is [\(self.sApplicationName)] - 'self' is [\(self)]...")
        
    #if INSTANTIATE_APP_USERNOTIFICATIONSMANAGER
        // Terminate the jmAppUserNotificationManager...

        appLogMsg("\(sCurrMethodDisp) Terminating the 'self.jmAppUserNotificationManager' instance...")

        self.jmAppUserNotificationManager?.terminateAppUserNotifications()
          
        appLogMsg("\(sCurrMethodDisp) Terminated  the 'self.jmAppUserNotificationManager' instance...")
    #endif

        // Finish the 'terminate' of the AppDelegateVisitor instance...

        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) AppDelegateVisitor is stopping...")

        // Tell the 'shared' instance of the AppGlobalInfo struct that we're in the Background...

        self.appGlobalInfo.setAppInBackground()
    //  self.performAppDelegateVisitorTerminatingCrashLogic()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func appDelegateVisitorWillTerminate(uiApplication:).

    @objc public func appDelegateVisitorApplication(_ application:UIApplication, open urls:[URL])
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'application' is [\(application)] - 'urls' are [\(urls)]...")

        appLogMsg("\(sCurrMethodDisp) Current '\(ClassInfo.sClsId)' is [\(self.toString())]...")
        appLogMsg("\(sCurrMethodDisp) -> Unhandled url(s) -> \(urls)")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of @objc public func appDelegateVisitorApplication(application:, urls:).
#endif

}   // End of class JmAppDelegateVisitor:NSObject, ObservableObject.

