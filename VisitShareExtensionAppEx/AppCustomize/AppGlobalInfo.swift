//
//  AppGlobalInfo.swift
//  <<< App 'dependent' >>>
//
//  AppGlobalInfo.swift - v1.6001...
//  Updated by Daryl Cox on 02/23/2026.
//  Updated by Daryl Cox on 02/22/2026.
//  Updated by Daryl Cox on 02/18/2026.
//  Updated by Daryl Cox on 02/11/2026.
//  Created by Daryl Cox on 06/19/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

#if os(macOS)
import IOKit
#endif
#if os(iOS)
import UIKit
#endif

// MARK: Global functions at module level (outside the class)...

@inlinable
public func appLogMsg(_ sMessage:String) 
{

#if USE_APP_LOGGING_BY_VISITOR
    appLogMsgWithVisitor(sMessage)
#else
    appLogMsgWithoutVisitor(sMessage)
#endif

}   // End of @inlinable public func appLogMsg(_ sMessage:String).

// NOTE: Use this version if the 'jmAppDelegateVisitor' is NOT optional...

#if USE_APP_LOGGING_BY_VISITOR

    // App 'delegate' Visitor:

           public var jmAppGlobalInfoDelegateVisitor:JmAppDelegateVisitor? = nil
                                                                           // 'jmAppDelegateVisitor' MUST remain declared this way
                                                                           // as having it reference the 'shared' instance of 
                                                                           // JmAppDelegateVisitor causes a circular reference
                                                                           // between the 'init()' methods of the 2 classes...

    // App <global> Message(s) 'stack' cached before XCGLogger is available:

           public var listAppGlobalInfoPreXCGLoggerMessages:[String]       = [String]()

@inlinable
public func appLogMsgViaGlobalCache(_ sMessage:String) 
{

    listAppGlobalInfoPreXCGLoggerMessages.append(sMessage)

}   // End of @inlinable public func appLogMsg(_ sMessage:String).
#endif

//@inlinable - NOTE: This method can NOT be marked @inlinable - problems with 'jmAppDelegateVisitor'...
public func appLogMsgWithVisitor(_ sMessage:String)
{

#if USE_APP_LOGGING_BY_VISITOR
    if (jmAppGlobalInfoDelegateVisitor                                        != nil &&
        jmAppGlobalInfoDelegateVisitor?.bAppDelegateVisitorLogFilespecIsUsable == true)
    {
        jmAppGlobalInfoDelegateVisitor?.xcgLogMsg(sMessage)
    }
    else
    {
        appLogMsgWithoutVisitor(sMessage)

        listAppGlobalInfoPreXCGLoggerMessages.append(sMessage)
    }
#else
    appLogMsgWithoutVisitor(sMessage)
#endif
    
    // Exit:
    
    return
    
}   // End of @inlinable public func appLogMsgWithVisitor(_ sMessage:String).

@inlinable
public func appLogMsgWithoutVisitor(_ sMessage:String)
{

    let dtFormatterDateStamp        = DateFormatter()
    dtFormatterDateStamp.locale     = Locale(identifier: "en_US")
    dtFormatterDateStamp.timeZone   = TimeZone.current
    dtFormatterDateStamp.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"

    let dateStampNow                = Date.now
    let sDateStamp                  = "\(dtFormatterDateStamp.string(from: dateStampNow)) >> "

    print("\(sDateStamp)\(sMessage)")

    // Exit:
    
    return
    
}   // End of @inlinable public func appLogMsgWithoutVisitor(_ sMessage:String).

// MARK: Global enum(s) and environment value(s)...

// App 'global' Device TYPE:

enum AppGlobalDeviceType:Int, CaseIterable
{
    
    case appGlobalDeviceUndefined  = 0
    case appGlobalDeviceMac        = 1
    case appGlobalDeviceIPad       = 2
    case appGlobalDeviceIPhone     = 3
    case appGlobalDeviceAppleWatch = 4
    
}   // End of AppGlobalDeviceType:Int, CaseIterable.

// App 'global' Auth (Authentication) TYPE:

enum AppGlobalAuthType:Int, CaseIterable
{
    
    case appGlobalAuthTypeUndefined = 0
    case appGlobalAuthTypeUser      = 1
    case appGlobalAuthTypePatient   = 2
    case appGlobalAuthTypeTherapist = 3
    case appGlobalAuthTypeOffice    = 4
    case appGlobalAuthTypeDev       = 5
    
}   // End of AppGlobalAuthType:Int, CaseIterable.

// App 'global' Device TYPE Environment 'key':

struct AppGlobalDeviceTypeEnvironmentKey:EnvironmentKey
{

    static let defaultValue:AppGlobalDeviceType = AppGlobalDeviceType.appGlobalDeviceUndefined

}   // End of struct AppGlobalDeviceTypeEnvironmentKey:EnvironmentKey.

// Extend EnvironmentValues to include AppGlobalDeviceType:

extension EnvironmentValues 
{

    var appGlobalDeviceType:AppGlobalDeviceType 
    {
        get { self[AppGlobalDeviceTypeEnvironmentKey.self] }
        set { self[AppGlobalDeviceTypeEnvironmentKey.self] = newValue }
    }

}   // End of extension EnvironmentValues.

// App 'global' Auth(Authentication) TYPE Environment 'key':

struct AppGlobalAuthTypeEnvironmentKey:EnvironmentKey
{

    static let defaultValue:AppGlobalAuthType = AppGlobalAuthType.appGlobalAuthTypeUndefined

}   // End of struct AppGlobalAuthTypeEnvironmentKey:EnvironmentKey.

// Extend EnvironmentValues to include AppGlobalAuthType:

extension EnvironmentValues 
{

    var appGlobalAuthType:AppGlobalAuthType 
    {
        get { self[AppGlobalAuthTypeEnvironmentKey.self] }
        set { self[AppGlobalAuthTypeEnvironmentKey.self] = newValue }
    }

}   // End of extension EnvironmentValues.

// MARK: App 'global' information...

@objcMembers
@objc(AppGlobalInfo)
public class AppGlobalInfo:NSObject
{
    
    struct ClassSingleton
    {
        static var appGlobalInfo:AppGlobalInfo                           = AppGlobalInfo()
    }
    
    // Objective-C accessor for singleton (computed property):
    //     - Swift code continues to use: AppGlobalInfo.ClassSingleton.appGlobalInfo
    //     - Objective-C code uses:       [AppGlobalInfo shared] or AppGlobalInfo.shared...

    @objc public static var shared: AppGlobalInfo
    {
        return ClassSingleton.appGlobalInfo
    }

    static let sGlobalInfoAppId:String                                   = AppGlobalInfoConfig.sGlobalInfoAppId
    static let sGlobalInfoAppVers:String                                 = AppGlobalInfoConfig.sGlobalInfoAppVers
    static let sGlobalInfoAppDisp:String                                 = AppGlobalInfoConfig.sGlobalInfoAppDisp                 
    static let sGlobalInfoAppCopyRight:String                            = AppGlobalInfoConfig.sGlobalInfoAppCopyRight            
    static let sGlobalInfoAppLogFilespecMaxSize:Int64                    = AppGlobalInfoConfig.sGlobalInfoAppLogFilespecMaxSize
    static let bGlobalInfoAppAutoSendCrashLog:Bool                       = AppGlobalInfoConfig.bGlobalInfoAppAutoSendCrashLog       
    static let bGlobalInfoAppAutoSendCrashLogTesting:Bool                = AppGlobalInfoConfig.bGlobalInfoAppAutoSendCrashLogTesting
    static let sGlobalInfoAppLogFilespec:String                          = AppGlobalInfoConfig.sGlobalInfoAppLogFilespec          
    static let sGlobalInfoAppLastGoodLogFilespec:String                  = AppGlobalInfoConfig.sGlobalInfoAppLastGoodLogFilespec  
    static let sGlobalInfoAppLastCrashLogFilespec:String                 = AppGlobalInfoConfig.sGlobalInfoAppLastCrashLogFilespec 
    static let sGlobalInfoAppCrashMarkerFilespec:String                  = AppGlobalInfoConfig.sGlobalInfoAppCrashMarkerFilespec  
                                                                                                                                         
    static let bUseApplicationShortTitle:Bool                            = AppGlobalInfoConfig.bUseApplicationShortTitle            
    static let sApplicationTitle:String                                  = AppGlobalInfoConfig.sApplicationTitle                  
    static let sApplicationShortTitle:String                             = AppGlobalInfoConfig.sApplicationShortTitle             
    static let sHelpBasicFileExt:String                                  = AppGlobalInfoConfig.sHelpBasicFileExt                  

    // ------------------------------------------------------------------------------------------------------
    // 
    // Control of the 'app' component options is by Xcode 'define(s)':
    //
    //     Xcode: -> Project -> Target -> 
    //                   Build Settings -> Swift Compiler - Custom Flags -> Other Swift Flags
    //                       Value: -Dxxx (where xxx is one of the defines below)
    //
    //                              USE_APP_LOGGING_BY_VISITOR
    //                              ENABLE_APP_USER_AUTHENTICATION
    //                              ENABLE_APP_USER_AUTH_TYPE
    //                              ENABLE_APP_PARSECORE_FOR_SWIFT
    //                              ENABLE_APP_IAP_CAPABILITY
    //                              INSTANTIATE_APP_VV
    //                              INSTANTIATE_APP_VV_UIKIT_ALERTS
    //                              INSTANTIATE_APP_VMA
    //                              INSTANTIATE_APP_OBJCSWIFTBRIDGE
    //                              INSTANTIATE_APP_JMSWIFTDATAMANAGER
    //                              INSTANTIATE_APP_SWIFTDATAMANAGER
    //                              INSTANTIATE_APP_METRICKITMANAGER
    //                              INSTANTIATE_APP_USERNOTIFICATIONSMANAGER
    //                              INSTANTIATE_APP_PARSECOREMANAGER
    //                              INSTANTIATE_APP_PARSECOREBKGDDATAREPO
    //                              INSTANTIATE_APP_PARSECOREBKGDDATAREPO2
    //                              INSTANTIATE_APP_PARSECOREBKGDDATAREPO3
    //                              INSTANTIATE_APP_PARSECOREBKGDDATAREPO4
    //                              INSTANTIATE_APP_CORELOCATIONSUPPORT
    //                              INSTANTIATE_APP_CORELOCATIONAUTOSYNCSUPPORT
    //                              INSTANTIATE_APP_NWSWEATHERMODELOBSERVABLE
    //                              INSTANTIATE_APP_MENUBARSTATUSBAR
    //                              INSTANTIATE_APP_WINDOWPOSITIONMANAGER
    //                              INSTANTIATE_APP_BIGTESTTRACKING
    //                              INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
    //
    // ------------------------------------------------------------------------------------------------------

    // Various 'app' component options:

    static let bIsAppLoggingByVisitor:Bool                               =
    {
    #if USE_APP_LOGGING_BY_VISITOR
        return true
    #else
        return false
    #endif
    }()

    static let sAppLoggingMethod:String                                  =
    {
    #if USE_APP_LOGGING_BY_VISITOR
        return "Visitor-based Logging (with XCGLogger)"
    #else
        return "Simple-Logging (Console 'print' with timestamps)"
    #endif
    }()

    static let isUserAuthenticationAvailable:Bool                        =
    {
    #if ENABLE_APP_USER_AUTHENTICATION
        return true
    #else
        return false
    #endif
    }()

    static let isUserAuthTypeAvailable:Bool                              =
    {
    #if ENABLE_APP_USER_AUTH_TYPE
        return true
    #else
        return false
    #endif
    }()

    static let isEnabledParseCoreForSwift:Bool                           =
    {
    #if ENABLE_APP_PARSECORE_FOR_SWIFT
        return true
    #else
        return false
    #endif
    }()

    static let isEnabledAppIAPCapability:Bool                            =
    {
    #if ENABLE_APP_IAP_CAPABILITY
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppVV:Bool                                    =
    {
    #if INSTANTIATE_APP_VV
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppVVUIKitAlerts:Bool                         =
    {
    #if INSTANTIATE_APP_VV_UIKIT_ALERTS
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppVMA:Bool                                   =
    {
    #if INSTANTIATE_APP_VMA
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppObjCSwiftBridge:Bool                       =
    {
    #if INSTANTIATE_APP_OBJCSWIFTBRIDGE
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppJmSwiftDataManager:Bool                    =
    {
    #if INSTANTIATE_APP_JMSWIFTDATAMANAGER
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppSwiftDataManager:Bool                      =
    {
    #if INSTANTIATE_APP_SWIFTDATAMANAGER
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppMetricKitManager:Bool                      =
    {
    #if INSTANTIATE_APP_METRICKITMANAGER
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppUserNotificationsManager:Bool              =
    {
    #if INSTANTIATE_APP_USERNOTIFICATIONSMANAGER
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppParseCoreManager:Bool                      =
    {
    #if INSTANTIATE_APP_PARSECOREMANAGER
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppParseCoreBkgdDataRepo:Bool                 =
    {
    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppParseCoreBkgdDataRepo2:Bool                =
    {
    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO2
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppParseCoreBkgdDataRepo3:Bool                =
    {
    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO3
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppParseCoreBkgdDataRepo4:Bool                =
    {
    #if INSTANTIATE_APP_PARSECOREBKGDDATAREPO4
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppCoreLocationSupport:Bool                   =
    {
    #if INSTANTIATE_APP_CORELOCATIONSUPPORT
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppCoreLocationAutoSyncSupport:Bool           =
    {
    #if INSTANTIATE_APP_CORELOCATIONAUTOSYNCSUPPORT
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppNWSWeatherModelObservable:Bool             =
    {
    #if INSTANTIATE_APP_NWSWEATHERMODELOBSERVABLE
        return true
    #else
        return false
    #endif
    }()
    
    static let bInstantiateAppMenuBarStatusBar:Bool                      =
    {
    #if INSTANTIATE_APP_MENUBARSTATUSBAR
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppWindowPositionManager:Bool                 =
    {
    #if INSTANTIATE_APP_WINDOWPOSITIONMANAGER
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppBigTestTracking:Bool                       =
    {
    #if INSTANTIATE_APP_BIGTESTTRACKING
        return true
    #else
        return false
    #endif
    }()

    static let bInstantiateAppGoogleAdMobMobileAds:Bool                  =
    {
    #if INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
        return true
    #else
        return false
    #endif
    }()

    // Various 'app' component controls:

    static let eUseLatitudeLongitudePrecision:CLLocationPrecision        = AppGlobalInfoConfig.eUseLatitudeLongitudePrecision
    static let bAppIsADrcBuildDistribution:Bool                          = AppGlobalInfoConfig.bAppIsADrcBuildDistribution
    static let bAppShouldShowLogFiles:Bool                               = AppGlobalInfoConfig.bAppShouldShowLogFiles
    static let bEnableAppDevSwiftDataRecovery:Bool                       = AppGlobalInfoConfig.bEnableAppDevSwiftDataRecovery               
    static let bPerformAppObjCSwiftBridgeTest:Bool                       = AppGlobalInfoConfig.bPerformAppObjCSwiftBridgeTest               
    static let bAppMetricKitManagerSendDiagnostics:Bool                  = AppGlobalInfoConfig.bAppMetricKitManagerSendDiagnostics          
    static let bAppMetricKitManagerSendMetrics:Bool                      = AppGlobalInfoConfig.bAppMetricKitManagerSendMetrics              
    static let bIssueTestAppUserNotifications:Bool                       = AppGlobalInfoConfig.bIssueTestAppUserNotifications               
    static let bIssueShortAppUserNotifications:Bool                      = AppGlobalInfoConfig.bIssueShortAppUserNotifications              
    static let bPerformAppCoreLocationTesting:Bool                       = AppGlobalInfoConfig.bPerformAppCoreLocationTesting               
    static let bPerformAppDevTesting:Bool                                = AppGlobalInfoConfig.bPerformAppDevTesting                        
    static let bEnableAppReleaseDownloads:Bool                           = AppGlobalInfoConfig.bEnableAppReleaseDownloads                   
    static let bEnableAppAdsPlaceholder:Bool                             = AppGlobalInfoConfig.bEnableAppAdsPlaceholder                     
    static let bEnableAppAdsTesting:Bool                                 = AppGlobalInfoConfig.bEnableAppAdsTesting                         
    static let sAdSenseAppAdsTesting:String                              = AppGlobalInfoConfig.sAdSenseAppAdsTesting                      
    static let bEnableAppAdsProduction:Bool                              = AppGlobalInfoConfig.bEnableAppAdsProduction                      
    static let sAdSenseAppAdsProduction:String                           = AppGlobalInfoConfig.sAdSenseAppAdsProduction                   
    static let bEnableAppRevenueCatTesting:Bool                          = AppGlobalInfoConfig.bEnableAppRevenueCatTesting                  
    static let bEnableAppRevenueCatProduction:Bool                       = AppGlobalInfoConfig.bEnableAppRevenueCatProduction               
    static let bTestStringManipulations:Bool                             = AppGlobalInfoConfig.bTestStringManipulations                     
    static let bTestAppBigTestTracking1:Bool                             = AppGlobalInfoConfig.bTestAppBigTestTracking1                     
    static let bTestAppBigTestTracking2:Bool                             = AppGlobalInfoConfig.bTestAppBigTestTracking2                     
    static let bTestAppDeepCopyUtility:Bool                              = AppGlobalInfoConfig.bTestAppDeepCopyUtility                      
    static let sAppUploadNotifyFrom:String                               = AppGlobalInfoConfig.sAppUploadNotifyFrom                       
    static let iAlertViaSwiftUITimeout:Double                            = AppGlobalInfoConfig.iAlertViaSwiftUITimeout                    
    static let iAlertViaUIKitTimeout:Double                              = AppGlobalInfoConfig.iAlertViaUIKitTimeout                      

    // Various 'App' (tracking) information:

           var tiGlobalAppStartTime:TimeInterval                         = ProcessInfo.processInfo.systemUptime

           var dblGlobalAppUptime:Double
           {
               let dblCurrentUptime:Double = ProcessInfo.processInfo.systemUptime
               
               return(dblCurrentUptime - tiGlobalAppStartTime)
           }

           var sGlobalAppUptime:String
           {
               let cAppUptimeDays:Int         = (Int(dblGlobalAppUptime) / 86400)
               let cAppUptimeHours:Int        = (Int(dblGlobalAppUptime) / 3600 % 24)
               let cAppUptimeMinutes:Int      = (Int(dblGlobalAppUptime) / 60   % 60)
               let cAppUptimeSeconds:Int      = (Int(dblGlobalAppUptime) % 60)

               return String(format:"%02d:%02d:%02d:%02d", cAppUptimeDays, cAppUptimeHours, cAppUptimeMinutes, cAppUptimeSeconds)
           }

           var sGlobalSystemUptime:String
           {
               let dblCurrentAppUptime:Double = self.tiGlobalAppStartTime
               let cAppUptimeDays:Int         = (Int(dblCurrentAppUptime) / 86400)
               let cAppUptimeHours:Int        = (Int(dblCurrentAppUptime) / 3600 % 24)
               let cAppUptimeMinutes:Int      = (Int(dblCurrentAppUptime) / 60   % 60)
               let cAppUptimeSeconds:Int      = (Int(dblCurrentAppUptime) % 60)

               return String(format:"%02d:%02d:%02d:%02d", cAppUptimeDays, cAppUptimeHours, cAppUptimeMinutes, cAppUptimeSeconds)
           }

    // Various 'ProcessInfo' information:

           var sGlobalProcessInfoSystemUptime:TimeInterval               = 0.0000
           var sGlobalProcessInfoOSVersion:OperatingSystemVersion        = OperatingSystemVersion()
           var sGlobalProcessInfoHostName:String                         = "-unknown-"
           var sGlobalProcessInfoSystemName:String                       = "-unknown-"
           var sGlobalProcessInfoSystemVersion:String                    = "-unknown-"
           var sGlobalProcessInfoProcessorCount:Int                      = 0
           var sGlobalProcessInfoProcessorCountActive:Int                = 0
           var sGlobalProcessInfoPhysicalMemory:UInt64                   = 0
           var sGlobalProcessInfoProcessIdentifier:Int32                 = 0
           var sGlobalProcessInfoProcessName:String                      = "-unknown-"

        #if os(macOS)
           var sGlobalProcessInfoMacOSUserName:String                    = "-unknown-"
           var sGlobalProcessInfoMacOSFullUserName:String                = "-unknown-"
        #endif

    // Various 'device' information:

           var sGlobalDeviceMachineIdentifier:String                     = "-unknown-"  // e.g. "iPad14,6" or "Mac15,3"
           var sGlobalDeviceCPUType:String                               = "-unknown-"  // e.g. "Apple M4"
           var sGlobalDeviceCPUArchitecture:String                       = "-unknown-"  // e.g. "ARM64"
           var sGlobalDeviceCPUSubtype:String                            = "-unknown-"  // e.g. "ARM64E"
           var iGlobalDeviceCPUPhysicalCores:Int                         = 0
           var iGlobalDeviceCPULogicalCores:Int                          = 0

  @nonobjc var iGlobalDeviceType:AppGlobalDeviceType                     = AppGlobalDeviceType.appGlobalDeviceUndefined
           var sGlobalDeviceType:String                                  = "-unknown-"   // Values: "Mac", "iPad", "iPhone, "AppleWatch"
           var bGlobalDeviceIsMac:Bool                                   = false
           var bGlobalDeviceIsIPad:Bool                                  = false
           var bGlobalDeviceIsIPhone:Bool                                = false
           var bGlobalDeviceIsAppleWatch:Bool                            = false
           var bGlobalDeviceIsXcodeSimulator:Bool                        = false
           var cgfGlobalDeviceImageSizeForQR:CGFloat                     = 64

           var sGlobalDeviceName:String                                  = "-unknown-"
           var sGlobalDeviceSystemName:String                            = "-unknown-"
           var sGlobalDeviceSystemVersion:String                         = "-unknown-"
           var sGlobalDeviceModel:String                                 = "-unknown-"
           var sGlobalDeviceLocalizedModel:String                        = "-unknown-"

       #if os(iOS)
  @nonobjc var idiomGlobalDeviceUserInterfaceIdiom:UIUserInterfaceIdiom? = nil
           var iGlobalDeviceUserInterfaceIdiom:Int                       = 0
  @nonobjc var uuidGlobalDeviceIdForVendor:UUID?                         = nil
           var fGlobalDeviceCurrentBatteryLevel:Float                    = 1.0
       #endif

           var fGlobalDeviceScreenSizeWidth:Float                        = 0.0
           var fGlobalDeviceScreenSizeHeight:Float                       = 0.0
           var iGlobalDeviceScreenSizeScale:Int                          = 0

       #if os(iOS)
           var sGlobalDeviceOrientation:String                           = "unknown"
                                                                           // Values: "unknown", "portrait", "portraitUpsideDown",
                                                                           //         "landscapeLeft", "landscapeRight",
                                                                           //         "faceUp", and "faceDown"...
           var bGlobalDeviceOrientationIsPortrait:Bool                   = false
           var bGlobalDeviceOrientationIsLandscape:Bool                  = false
           var bGlobalDeviceOrientationIsFlat:Bool                       = false
           var bGlobalDeviceOrientationIsInvalid:Bool                    = false
       #endif

   // Various 'auth' (authentication) information:

 @nonobjc var iGlobalAuthType:AppGlobalAuthType                          = AppGlobalAuthType.appGlobalAuthTypeUndefined
          var sGlobalAuthType:String                                     = "-unknown-"   // Values: "Undefined", "User", "Patient",
          var bGlobalAuthTypeIsUndefined:Bool                            = false
          var bGlobalAuthTypeIsUser:Bool                                 = false
          var bGlobalAuthTypeIsPatient:Bool                              = false
          var bGlobalAuthTypeIsTherapist:Bool                            = false
          var bGlobalAuthTypeIsOffice:Bool                               = false
          var bGlobalAuthTypeIsDev:Bool                                  = false

    // Various 'app' information:

           var sAppCategory:String                                       = "-unknown-"
           var sAppDisplayName:String                                    = "-unknown-"
           var sAppBundleIdentifier:String                               = "-unknown-"
           var sAppVersionAndBuildNumber:String                          = "-unknown-"
           var sAppCopyright:String                                      = "-unknown-"
           var sAppUserDefaultsFileLocation:String                       = "-unknown-"

           var bAppIsInTheBackground:Bool                                = false
                                                                           // false: App is NOT in the Background...
                                                                           // true:  App is NOW in the Background...

#if USE_APP_LOGGING_BY_VISITOR
    // App 'delegate' Visitor:

           var jmAppDelegateVisitor:JmAppDelegateVisitor?                = nil
                                                                           // 'jmAppDelegateVisitor' MUST remain declared this way
                                                                           // as having it reference the 'shared' instance of 
                                                                           // JmAppDelegateVisitor causes a circular reference
                                                                           // between the 'init()' methods of the 2 classes...

//  // App <global> Message(s) 'stack' cached before XCGLogger is available:
//
//         var listPreXCGLoggerMessages:[String]                         = [String]()
#endif

    // Private 'init()' to make this class a 'singleton':

    private override init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "AppGlobalInfo.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"

        super.init()

    #if USE_APP_LOGGING_BY_VISITOR
        appLogMsgViaGlobalCache("\(sCurrMethodDisp) Invoked...")
    #else
        appLogMsg("\(sCurrMethodDisp) Invoked...")
    #endif
        
        self.sGlobalProcessInfoSystemUptime         = ProcessInfo.processInfo.systemUptime
        self.sGlobalProcessInfoOSVersion            = ProcessInfo.processInfo.operatingSystemVersion
        self.sGlobalProcessInfoHostName             = ProcessInfo.processInfo.hostName
    //  self.sGlobalProcessInfoSystemName           = "MacOS v\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        self.sGlobalProcessInfoSystemVersion        = ProcessInfo.processInfo.operatingSystemVersionString
        self.sGlobalProcessInfoProcessorCount       = ProcessInfo.processInfo.processorCount
        self.sGlobalProcessInfoProcessorCountActive = ProcessInfo.processInfo.activeProcessorCount
        self.sGlobalProcessInfoPhysicalMemory       = ProcessInfo.processInfo.physicalMemory
        self.sGlobalProcessInfoProcessIdentifier    = ProcessInfo.processInfo.processIdentifier
        self.sGlobalProcessInfoProcessName          = ProcessInfo.processInfo.processName         

    #if os(macOS)
        self.sGlobalProcessInfoSystemName           = "MacOS v\(self.sGlobalProcessInfoOSVersion.majorVersion).\(self.sGlobalProcessInfoOSVersion.minorVersion).\(self.sGlobalProcessInfoOSVersion.patchVersion)"
        self.sGlobalProcessInfoMacOSUserName        = ProcessInfo.processInfo.userName
        self.sGlobalProcessInfoMacOSFullUserName    = ProcessInfo.processInfo.fullUserName

        self.iGlobalDeviceType                      = AppGlobalDeviceType.appGlobalDeviceMac
        self.sGlobalDeviceType                      = "Mac"   // Values: "Mac", "iPad", "iPhone, "AppleWatch"
        self.bGlobalDeviceIsMac                     = true
        self.bGlobalDeviceIsIPad                    = false
        self.bGlobalDeviceIsIPhone                  = false
        self.bGlobalDeviceIsAppleWatch              = false
        self.bGlobalDeviceIsXcodeSimulator          = false
        self.cgfGlobalDeviceImageSizeForQR          = 64

        let osVersion:OperatingSystemVersion        = ProcessInfo.processInfo.operatingSystemVersion 

        self.sGlobalDeviceName                      = ProcessInfo.processInfo.hostName
        self.sGlobalDeviceSystemName                = "MacOS v\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        self.sGlobalDeviceSystemVersion             = ProcessInfo.processInfo.operatingSystemVersionString
        self.sGlobalDeviceModel                     = "-unknown-"
        self.sGlobalDeviceLocalizedModel            = "-unknown-"

        let ioServiceExpertDevice                   = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        var sModelIdentifier:String?                = nil

        if let ioModelData:Data = IORegistryEntryCreateCFProperty(ioServiceExpertDevice, ("model" as CFString), kCFAllocatorDefault, 0).takeRetainedValue() as? Data
        {
            if let ioModelIdentifierCString = String(data:ioModelData, encoding:.utf8)?.cString(using:.utf8) 
            {
                sModelIdentifier = String(cString:ioModelIdentifierCString)
            }
        }

        IOObjectRelease(ioServiceExpertDevice)

        self.sGlobalDeviceModel                     = sModelIdentifier ?? "-unknown-"
        self.sGlobalDeviceLocalizedModel            = sModelIdentifier ?? "-unknown-"

        if let screenSize = NSScreen.main?.frame as CGRect?
        {
            self.fGlobalDeviceScreenSizeWidth       = Float(screenSize.width)
            self.fGlobalDeviceScreenSizeHeight      = Float(screenSize.height)
            self.iGlobalDeviceScreenSizeScale       = 1
        }

        // Get detailed CPU/chip information (macOS):
        
        self.sGlobalDeviceMachineIdentifier         = self.getDeviceMachineIdentifier()
        self.sGlobalDeviceCPUArchitecture           = self.getCPUArchitecture()
        self.sGlobalDeviceCPUSubtype                = self.getCPUSubtype()
        self.sGlobalDeviceCPUType                   = self.mapMachineIdentifierToCPUType(sMachineId:self.sGlobalDeviceMachineIdentifier)
        
        let cpuCoresMac                             = self.getCPUCoreCount()
        self.iGlobalDeviceCPUPhysicalCores          = cpuCoresMac.physical
        self.iGlobalDeviceCPULogicalCores           = cpuCoresMac.logical
    #elseif os(iOS)
        // Get various 'device' setting(s):
        // (Alternate test: if UIDevice.current.userInterfaceIdiom == .pad { ... } ).

        self.iGlobalDeviceType                      = AppGlobalDeviceType.appGlobalDeviceUndefined
        self.sGlobalDeviceType                      = "-unknown-"

        if UIDevice.current.localizedModel == "Mac" 
        {
            self.iGlobalDeviceType                  = AppGlobalDeviceType.appGlobalDeviceMac
            self.sGlobalDeviceType                  = "Mac"
            self.bGlobalDeviceIsMac                 = true
        } 
        else if UIDevice.current.localizedModel == "iPad" 
        {
            self.iGlobalDeviceType                  = AppGlobalDeviceType.appGlobalDeviceIPad
            self.sGlobalDeviceType                  = "iPad"
            self.bGlobalDeviceIsIPad                = true
        }
        else if UIDevice.current.localizedModel == "iPhone" 
        {
            self.iGlobalDeviceType                  = AppGlobalDeviceType.appGlobalDeviceIPhone
            self.sGlobalDeviceType                  = "iPhone"
            self.bGlobalDeviceIsIPhone              = true
        }
        else if UIDevice.current.localizedModel == "AppleWatch" 
        {
            self.iGlobalDeviceType                  = AppGlobalDeviceType.appGlobalDeviceAppleWatch
            self.sGlobalDeviceType                  = "AppleWatch"
            self.bGlobalDeviceIsAppleWatch          = true
        }

        if (self.iGlobalDeviceType == AppGlobalDeviceType.appGlobalDeviceIPhone)
        {
            self.cgfGlobalDeviceImageSizeForQR      = 128
        }
        else
        {
            self.cgfGlobalDeviceImageSizeForQR      = 196
        }

        self.sGlobalProcessInfoSystemName           = "\(self.sGlobalDeviceType) v\(self.sGlobalProcessInfoOSVersion.majorVersion).\(self.sGlobalProcessInfoOSVersion.minorVersion).\(self.sGlobalProcessInfoOSVersion.patchVersion)"

        self.sGlobalDeviceName                      = UIDevice.current.name
        self.sGlobalDeviceSystemName                = UIDevice.current.systemName
        self.sGlobalDeviceSystemVersion             = UIDevice.current.systemVersion
        self.sGlobalDeviceModel                     = UIDevice.current.model
        self.sGlobalDeviceLocalizedModel            = UIDevice.current.localizedModel

        self.idiomGlobalDeviceUserInterfaceIdiom    = UIDevice.current.userInterfaceIdiom
        self.iGlobalDeviceUserInterfaceIdiom        = ((idiomGlobalDeviceUserInterfaceIdiom?.rawValue ?? 0) as Int)
        self.uuidGlobalDeviceIdForVendor            = UIDevice.current.identifierForVendor
        self.fGlobalDeviceCurrentBatteryLevel       = UIDevice.current.batteryLevel

        if let screenSize = UIScreen.main.bounds as CGRect?
        {
            self.fGlobalDeviceScreenSizeWidth       = Float(screenSize.width)
            self.fGlobalDeviceScreenSizeHeight      = Float(screenSize.height)
            self.iGlobalDeviceScreenSizeScale       = Int(UIScreen.main.scale)
        }

        // Get detailed CPU/chip information (iOS):
        
        self.sGlobalDeviceMachineIdentifier         = self.getDeviceMachineIdentifier()
        self.sGlobalDeviceCPUArchitecture           = self.getCPUArchitecture()
        self.sGlobalDeviceCPUSubtype                = self.getCPUSubtype()
        self.sGlobalDeviceCPUType                   = self.mapMachineIdentifierToCPUType(sMachineId:self.sGlobalDeviceMachineIdentifier)
        
        let cpuCoresiOS                             = self.getCPUCoreCount()
        self.iGlobalDeviceCPUPhysicalCores          = cpuCoresiOS.physical
        self.iGlobalDeviceCPULogicalCores           = cpuCoresiOS.logical
    #endif

    #if targetEnvironment(simulator)
        self.self.bGlobalDeviceIsXcodeSimulator = true
    #endif

        self.sAppCategory                           = JmXcodeBuildSettings.jmAppCategory   
        self.sAppDisplayName                        = JmXcodeBuildSettings.jmAppDisplayName
        self.sAppBundleIdentifier                   = JmXcodeBuildSettings.jmAppBundleIdentifier
        self.sAppVersionAndBuildNumber              = JmXcodeBuildSettings.jmAppVersionAndBuildNumber
        self.sAppCopyright                          = JmXcodeBuildSettings.jmAppCopyright      
        self.sAppUserDefaultsFileLocation           = JmXcodeBuildSettings.getAppUserDefaultsFileLocation(bIsBootstrapInit:true)

        self.bAppIsInTheBackground                  = false

        self.updateUIDeviceOrientation()

    #if !USE_APP_LOGGING_BY_VISITOR
        // Finish any 'initialization' work:

        appLogMsg("\(sCurrMethodDisp) AppGlobalInfo Invoking 'self.runPostInitializationTasks()'...")
    
        self.runPostInitializationTasks()

        appLogMsg("\(sCurrMethodDisp) AppGlobalInfo Invoked  'self.runPostInitializationTasks()'...")
    #endif
    
        // Exit:

    #if USE_APP_LOGGING_BY_VISITOR
        appLogMsgViaGlobalCache("\(sCurrMethodDisp) Exiting...")
    #else
        appLogMsg("\(sCurrMethodDisp) Exiting...")
    #endif

        return

    }   // End of private override init().

#if USE_APP_LOGGING_BY_VISITOR
    public func setJmAppDelegateVisitorInstance(jmAppDelegateVisitor:JmAppDelegateVisitor)
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "AppGlobalInfo.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"
        
    #if USE_APP_LOGGING_BY_VISITOR
        appLogMsgViaGlobalCache("\(sCurrMethodDisp) Invoked - supplied parameter 'jmAppDelegateVisitor' is [\(jmAppDelegateVisitor)]...")
    #else
        appLogMsg("\(sCurrMethodDisp) Invoked - supplied parameter 'jmAppDelegateVisitor' is [\(jmAppDelegateVisitor)]...")
    #endif

        // Set the AppDelegateVisitor instance(s)...

        jmAppGlobalInfoDelegateVisitor = jmAppDelegateVisitor
        self.jmAppDelegateVisitor      = jmAppDelegateVisitor

        // Spool <any> pre-XDGLogger (via the AppDelegateVisitor) message(s) into the Log...

        if (listAppGlobalInfoPreXCGLoggerMessages.count > 0)
        {
            appLogMsg("")
            appLogMsg("\(sCurrMethodDisp) <<< === Spooling the JmAppDelegateVisitor.XCGLogger 'pre' Message(s) === >>>")
            appLogMsg(listAppGlobalInfoPreXCGLoggerMessages.joined(separator:"\n"))
            appLogMsg("\(sCurrMethodDisp) <<< === Spooled  the JmAppDelegateVisitor.XCGLogger 'pre' Message(s) === >>>")
            appLogMsg("")
        }

        // Finish any 'initialization' work:

        appLogMsg("\(sCurrMethodDisp) AppGlobalInfo Invoking 'self.runPostInitializationTasks()'...")
    
        self.runPostInitializationTasks()

        appLogMsg("\(sCurrMethodDisp) AppGlobalInfo Invoked  'self.runPostInitializationTasks()'...")
    
        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'self.jmAppDelegateVisitor' is [\(String(describing: self.jmAppDelegateVisitor))]...")
    
        return

    } // End of public func setJmAppDelegateVisitorInstance().
#endif

    private func runPostInitializationTasks()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"

        appLogMsg("AppGlobalInfo.\(sCurrMethodDisp) Invoked - 'self' is [\(self)]...")

        // Run 'post' Initialization task(s)...

        self.updateUIDeviceOrientation()
        self.displayUIDeviceInformation()

        // Detail how the App is 'logging'...

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bIsAppLoggingByVisitor' is [\(String(describing: AppGlobalInfo.bIsAppLoggingByVisitor))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAppLoggingMethod' is [\(String(describing: AppGlobalInfo.sAppLoggingMethod))]...")

        // If we're flagged to 'test' String manipulation(s), then do so...

        if (AppGlobalInfo.bTestStringManipulations == true)
        {
            let listCharactersToRemove:[StringCleaning] = [
                                                           StringCleaning.removeAll,
                                                           StringCleaning.removeControl,
                                                           StringCleaning.removeDecomposables,
                                                           StringCleaning.removeIllegal,
                                                           StringCleaning.removeNewlines,
                                                           StringCleaning.removeNonBase,
                                                           StringCleaning.removePunctuation,
                                                           StringCleaning.removeSymbols,
                                                           StringCleaning.removeWhitespaces,
                                                           StringCleaning.removeWhitespacesAndNewlines,
                                                          ]

            appLogMsg("------------------------------------------------------------")
            appLogMsg("'listCharactersToRemove' is [\(listCharactersToRemove)]...")
            appLogMsg("------------------------------------------------------------")

            let sTest4:String  = "<LastName>, FirstName MiddleName, Jr. \r\n"
            let sTest5:String  = sTest4.removeUnwantedCharacters(charsetToRemove:listCharactersToRemove, bResultIsLowerCased:false)
            let sTest6:String  = sTest4.removeUnwantedCharacters(charsetToRemove:listCharactersToRemove, bResultIsLowerCased:true)
            let sTest7:String  = sTest4.removeUnwantedCharacters(charsetToRemove:listCharactersToRemove, sJoinCharacters:",", bResultIsLowerCased:true)
            let sTest8:String  = sTest4.removeUnwantedCharacters(charsetToRemove:listCharactersToRemove, sExtraCharacters:"<>amp", bResultIsLowerCased:true)
            let sTest9:String  = sTest4.removeUnwantedCharacters(charsetToRemove:listCharactersToRemove, sExtraCharacters:"<>amp", bResultIsLowerCased:false)
            let sTest10:String = sTest4.removeUnwantedCharacters(charsetToRemove:[StringCleaning.removeAll], bResultIsLowerCased:true)
            let sTest11:String = sTest4.removeUnwantedCharacters(charsetToRemove:[StringCleaning.removeNone], bResultIsLowerCased:false)
            let sTest12:String = sTest4.removeUnwantedCharacters(charsetToRemove:[StringCleaning.removeNone], bResultIsLowerCased:true)

            let sTest21:String = "Optional(096243EE-809D-4514-B6A6-464D6CD652CD)"
            let sTest22:String = sTest21.stripOptionalStringWrapper()
            let bTest22:Bool   = (sTest22 == "096243EE-809D-4514-B6A6-464D6CD652CD")

            appLogMsg("------------------------------------------------------------")
            appLogMsg("'sTest4'  is [\(sTest4)]...")
            appLogMsg("'sTest5'  is [\(sTest5)]  -> 'sTest4' cleaned (case-sensitive)...")
            appLogMsg("'sTest6'  is [\(sTest6)]  -> 'sTest4' cleaned (lowercased)...")
            appLogMsg("'sTest7'  is [\(sTest7)]  -> 'sTest4' cleaned (lowercased separated by ',')...")
            appLogMsg("'sTest8'  is [\(sTest8)]  -> 'sTest4' cleaned (lowercased without '<>amp')...")
            appLogMsg("'sTest9'  is [\(sTest9)]  -> 'sTest4' cleaned (case-sensitive without '<>amp')...")
            appLogMsg("'sTest10' is [\(sTest10)] -> 'sTest4' cleaned (.removeAll, lowercased)...")
            appLogMsg("'sTest11' is [\(sTest11)] -> 'sTest4' cleaned (.removeNone, case-sensitive)...")
            appLogMsg("'sTest12' is [\(sTest12)] -> 'sTest4' cleaned (.removeNone, lowercased)...")
            appLogMsg("------------------------------------------------------------")
            appLogMsg("'sTest21' is [\(sTest21)]...")
            appLogMsg("'sTest22' is [\(sTest22)] -> should be a string of '096243EE-809D-4514-B6A6-464D6CD652CD'...")
            appLogMsg("'bTest22' is [\(bTest22)] -> should be 'true'...")
            appLogMsg("------------------------------------------------------------")
        }

        // If we're flagged to 'test' Deep Copy utility, then do so...

        if (AppGlobalInfo.bTestAppDeepCopyUtility == true)
        {
            appLogMsg("------------------------------------------------------------")
            appLogMsg("Issuing the 'deep' Copy utility test(s)...")
            appLogMsg("------------------------------------------------------------")

            JmAppDeepCopyExamples.runExamples()

            appLogMsg("------------------------------------------------------------")
            appLogMsg("Issued  the 'deep' Copy utility test(s)...")
            appLogMsg("------------------------------------------------------------")
        }

    #if os(iOS)
        // For iOS, add Foreground/Background 'notification(s)' observer(s)...

        appLogMsg("\(sCurrMethodDisp) Intermediate - Adding Foreground/Background 'notification(s)' observer(s)...")

        NotificationCenter.default.addObserver(self,
                                               selector:#selector(appMovedToForeground),
                                               name:    UIApplication.willEnterForegroundNotification,
                                               object:  nil)

        NotificationCenter.default.addObserver(self,
                                               selector:#selector(appMovedToBackground),
                                               name:    UIApplication.didEnterBackgroundNotification,
                                               object:  nil)

        appLogMsg("\(sCurrMethodDisp) Intermediate - Added  Foreground/Background 'notification(s)' observer(s)...")
    #endif

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of private func runPostInitializationTasks().

    // Method(s) to 'update' and 'display' Device setting(s):

    public func updateUIDeviceOrientation()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "AppGlobalInfo.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"

    #if USE_APP_LOGGING_BY_VISITOR
        appLogMsgViaGlobalCache("\(sCurrMethodDisp) Invoked...")
    #else
        appLogMsg("\(sCurrMethodDisp) Invoked...")
    #endif

    #if os(iOS)
        // Update the 'device' orientation:

        self.sGlobalDeviceOrientation            = "unknown"
        self.bGlobalDeviceOrientationIsPortrait  = false
        self.bGlobalDeviceOrientationIsLandscape = false
        self.bGlobalDeviceOrientationIsFlat      = false
        self.bGlobalDeviceOrientationIsInvalid   = false

        switch(UIDevice.current.orientation)
        {
        case UIDeviceOrientation.portrait:
            self.sGlobalDeviceOrientation            = "portrait"
            self.bGlobalDeviceOrientationIsPortrait  = true
        case UIDeviceOrientation.portraitUpsideDown:
            self.sGlobalDeviceOrientation            = "portraitUpsideDown"
            self.bGlobalDeviceOrientationIsPortrait  = true
        case UIDeviceOrientation.landscapeLeft:
            self.sGlobalDeviceOrientation            = "landscapeLeft"
            self.bGlobalDeviceOrientationIsLandscape = true
        case UIDeviceOrientation.landscapeRight:
            self.sGlobalDeviceOrientation            = "landscapeLeft"
            self.bGlobalDeviceOrientationIsLandscape = true
        case UIDeviceOrientation.faceUp:
            self.sGlobalDeviceOrientation            = "faceUp"
            self.bGlobalDeviceOrientationIsFlat      = true
        case UIDeviceOrientation.faceDown:
            self.sGlobalDeviceOrientation            = "faceDown"
            self.bGlobalDeviceOrientationIsFlat      = true
        case UIDeviceOrientation.unknown:
            self.sGlobalDeviceOrientation            = "unknown"
            self.bGlobalDeviceOrientationIsInvalid   = true
        default:
            self.sGlobalDeviceOrientation            = "unknown"
            self.bGlobalDeviceOrientationIsInvalid   = true
        }
    #endif

        // Exit:

    #if USE_APP_LOGGING_BY_VISITOR
        appLogMsgViaGlobalCache("\(sCurrMethodDisp) Exiting...")
    #else
        appLogMsg("\(sCurrMethodDisp) Exiting...")
    #endif

        return

    }   // End of public func updateUIDeviceOrientation().

    public func displayUIDeviceInformation()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "AppGlobalInfo.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Display the various AppGlobalInfoConfig 'settings'...

        appLogMsg("\(sCurrMethodDisp) ========== AppGlobalInfoConfig 'settings' ==========")

        AppGlobalInfoConfig.displayAppGlobalInfoConfigSettings()

        // Display the various AppGlobalInfo 'settings'...

        appLogMsg("\(sCurrMethodDisp) ========== AppGlobalInfo 'settings' ================")

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.self' is [\(String(describing: self))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalInfoAppId' is [\(String(describing: AppGlobalInfo.sGlobalInfoAppId))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalInfoAppVers' is [\(String(describing: AppGlobalInfo.sGlobalInfoAppVers))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalInfoAppDisp' is [\(String(describing: AppGlobalInfo.sGlobalInfoAppDisp))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalInfoAppCopyRight' is [\(String(describing: AppGlobalInfo.sGlobalInfoAppCopyRight))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalInfoAppLogFilespecMaxSize' is [\(String(describing: AppGlobalInfo.sGlobalInfoAppLogFilespecMaxSize))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalInfoAppAutoSendCrashLog' is [\(String(describing: AppGlobalInfo.bGlobalInfoAppAutoSendCrashLog))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalInfoAppAutoSendCrashLogTesting' is [\(String(describing: AppGlobalInfo.bGlobalInfoAppAutoSendCrashLogTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalInfoAppLogFilespec' is [\(String(describing: AppGlobalInfo.sGlobalInfoAppLogFilespec))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalInfoAppLastGoodLogFilespec' is [\(String(describing: AppGlobalInfo.sGlobalInfoAppLastGoodLogFilespec))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalInfoAppLastCrashLogFilespec' is [\(String(describing: AppGlobalInfo.sGlobalInfoAppLastCrashLogFilespec))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalInfoAppCrashMarkerFilespec' is [\(String(describing: AppGlobalInfo.sGlobalInfoAppCrashMarkerFilespec))]...")
                                                                                                                                                                       
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bUseApplicationShortTitle' is [\(String(describing: AppGlobalInfo.bUseApplicationShortTitle))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sApplicationTitle' is [\(String(describing: AppGlobalInfo.sApplicationTitle))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sApplicationShortTitle' is [\(String(describing: AppGlobalInfo.sApplicationShortTitle))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sHelpBasicFileExt' is [\(String(describing: AppGlobalInfo.sHelpBasicFileExt))]...")
                                                                                                                                                                       
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bIsAppLoggingByVisitor' is [\(String(describing: AppGlobalInfo.bIsAppLoggingByVisitor))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAppLoggingMethod' is [\(String(describing: AppGlobalInfo.sAppLoggingMethod))]...")

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.isUserAuthenticationAvailable' is [\(String(describing: AppGlobalInfo.isUserAuthenticationAvailable))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.isUserAuthTypeAvailable' is [\(String(describing: AppGlobalInfo.isUserAuthTypeAvailable))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.isEnabledParseCoreForSwift' is [\(String(describing: AppGlobalInfo.isEnabledParseCoreForSwift))]...")

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppVV' is [\(String(describing: AppGlobalInfo.bInstantiateAppVV))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppVVUIKitAlerts' is [\(String(describing: AppGlobalInfo.bInstantiateAppVVUIKitAlerts))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppVMA' is [\(String(describing: AppGlobalInfo.bInstantiateAppVMA))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppObjCSwiftBridge' is [\(String(describing: AppGlobalInfo.bInstantiateAppObjCSwiftBridge))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppJmSwiftDataManager' is [\(String(describing: AppGlobalInfo.bInstantiateAppJmSwiftDataManager))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppSwiftDataManager' is [\(String(describing: AppGlobalInfo.bInstantiateAppSwiftDataManager))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppMetricKitManager' is [\(String(describing: AppGlobalInfo.bInstantiateAppMetricKitManager))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppUserNotificationsManager' is [\(String(describing: AppGlobalInfo.bInstantiateAppUserNotificationsManager))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppParseCoreManager' is [\(String(describing: AppGlobalInfo.bInstantiateAppParseCoreManager))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppParseCoreBkgdDataRepo' is [\(String(describing: AppGlobalInfo.bInstantiateAppParseCoreBkgdDataRepo))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppParseCoreBkgdDataRepo2' is [\(String(describing: AppGlobalInfo.bInstantiateAppParseCoreBkgdDataRepo2))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppParseCoreBkgdDataRepo3' is [\(String(describing: AppGlobalInfo.bInstantiateAppParseCoreBkgdDataRepo3))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppParseCoreBkgdDataRepo4' is [\(String(describing: AppGlobalInfo.bInstantiateAppParseCoreBkgdDataRepo4))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppCoreLocationSupport' is [\(String(describing: AppGlobalInfo.bInstantiateAppCoreLocationSupport))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppCoreLocationAutoSyncSupport' is [\(String(describing: AppGlobalInfo.bInstantiateAppCoreLocationAutoSyncSupport))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppNWSWeatherModelObservable' is [\(String(describing: AppGlobalInfo.bInstantiateAppNWSWeatherModelObservable))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppMenuBarStatusBar' is [\(String(describing: AppGlobalInfo.bInstantiateAppMenuBarStatusBar))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppWindowPositionManager' is [\(String(describing: AppGlobalInfo.bInstantiateAppWindowPositionManager))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppBigTestTracking' is [\(String(describing: AppGlobalInfo.bInstantiateAppBigTestTracking))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bInstantiateAppGoogleAdMobMobileAds' is [\(String(describing: AppGlobalInfo.bInstantiateAppGoogleAdMobMobileAds))]...")

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.eUseLatitudeLongitudePrecision' is [\(String(describing: AppGlobalInfo.eUseLatitudeLongitudePrecision))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bAppIsADrcBuildDistribution' is [\(String(describing: AppGlobalInfo.bAppIsADrcBuildDistribution))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bAppShouldShowLogFiles' is [\(String(describing: AppGlobalInfo.bAppShouldShowLogFiles))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bEnableAppDevSwiftDataRecovery' is [\(String(describing: AppGlobalInfo.bEnableAppDevSwiftDataRecovery))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bPerformAppObjCSwiftBridgeTest' is [\(String(describing: AppGlobalInfo.bPerformAppObjCSwiftBridgeTest))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bAppMetricKitManagerSendDiagnostics' is [\(String(describing: AppGlobalInfo.bAppMetricKitManagerSendDiagnostics))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bAppMetricKitManagerSendMetrics' is [\(String(describing: AppGlobalInfo.bAppMetricKitManagerSendMetrics))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bIssueTestAppUserNotifications' is [\(String(describing: AppGlobalInfo.bIssueTestAppUserNotifications))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bIssueShortAppUserNotifications' is [\(String(describing: AppGlobalInfo.bIssueShortAppUserNotifications))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bPerformAppCoreLocationTesting' is [\(String(describing: AppGlobalInfo.bPerformAppCoreLocationTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bPerformAppDevTesting' is [\(String(describing: AppGlobalInfo.bPerformAppDevTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bEnableAppReleaseDownloads' is [\(String(describing: AppGlobalInfo.bEnableAppReleaseDownloads))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bEnableAppAdsPlaceholder' is [\(String(describing: AppGlobalInfo.bEnableAppAdsPlaceholder))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bEnableAppAdsTesting' is [\(String(describing: AppGlobalInfo.bEnableAppAdsTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bEnableAppAdsProduction' is [\(String(describing: AppGlobalInfo.bEnableAppAdsProduction))]...")

    #if INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.jmAppGoogleAdMobAppIdentifier' is [\(String(describing: JmXcodeBuildSettings.jmAppGoogleAdMobAppIdentifier))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAdSenseAppAdsTesting' is [\(String(describing: AppGlobalInfo.sAdSenseAppAdsTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAdSenseAppAdsProduction' is [\(String(describing: AppGlobalInfo.sAdSenseAppAdsProduction))]...")
    #endif

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bEnableAppRevenueCatTesting' is [\(String(describing: AppGlobalInfo.bEnableAppRevenueCatTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bEnableAppRevenueCatProduction' is [\(String(describing: AppGlobalInfo.bEnableAppRevenueCatProduction))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bTestStringManipulations' is [\(String(describing: AppGlobalInfo.bTestStringManipulations))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bTestAppBigTestTracking1' is [\(String(describing: AppGlobalInfo.bTestAppBigTestTracking1))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bTestAppBigTestTracking2' is [\(String(describing: AppGlobalInfo.bTestAppBigTestTracking2))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAppUploadNotifyFrom' is [\(String(describing: AppGlobalInfo.sAppUploadNotifyFrom))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.iAlertViaSwiftUITimeout' is #(\(String(describing: AppGlobalInfo.iAlertViaSwiftUITimeout)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.iAlertViaUIKitTimeout' is #(\(String(describing: AppGlobalInfo.iAlertViaUIKitTimeout)))...")

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.tiGlobalAppStartTime' is (\(String(describing: self.tiGlobalAppStartTime)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.dblGlobalAppUptime' is (\(String(describing: self.dblGlobalAppUptime)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalAppUptime' is [\(String(describing: self.sGlobalAppUptime))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalSystemUptime' is [\(String(describing: self.sGlobalSystemUptime))]...")

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoSystemUptime' is [\(String(describing: self.sGlobalProcessInfoSystemUptime))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoOSVersion' is [\(String(describing: self.sGlobalProcessInfoOSVersion))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoHostName' is [\(String(describing: self.sGlobalProcessInfoHostName))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoSystemName' is [\(String(describing: self.sGlobalProcessInfoSystemName))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoSystemVersion' is [\(String(describing: self.sGlobalProcessInfoSystemVersion))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoProcessorCount' is [\(String(describing: self.sGlobalProcessInfoProcessorCount))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoProcessorCountActive' is [\(String(describing: self.sGlobalProcessInfoProcessorCountActive))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoPhysicalMemory' is [\(String(describing: self.sGlobalProcessInfoPhysicalMemory))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoProcessIdentifier' is [\(String(describing: self.sGlobalProcessInfoProcessIdentifier))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoProcessName' is [\(String(describing: self.sGlobalProcessInfoProcessName))]...")

    #if os(macOS)
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoMacOSUserName' is [\(String(describing: self.sGlobalProcessInfoMacOSUserName))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalProcessInfoMacOSFullUserName' is [\(String(describing: self.sGlobalProcessInfoMacOSFullUserName))]...")
    #endif

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.iGlobalDeviceType' is (\(String(describing: self.iGlobalDeviceType)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceType' is [\(String(describing: self.sGlobalDeviceType))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalDeviceIsMac' is [\(String(describing: self.bGlobalDeviceIsMac))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalDeviceIsIPad' is [\(String(describing: self.bGlobalDeviceIsIPad))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalDeviceIsIPhone' is [\(String(describing: self.bGlobalDeviceIsIPhone))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalDeviceIsAppleWatch' is [\(String(describing: self.bGlobalDeviceIsAppleWatch))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalDeviceIsXcodeSimulator' is [\(String(describing: self.bGlobalDeviceIsXcodeSimulator))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.cgfGlobalDeviceImageSizeForQR' is (\(String(describing: self.cgfGlobalDeviceImageSizeForQR)))...")
        
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceName' is [\(String(describing: self.sGlobalDeviceName))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceSystemName' is [\(String(describing: self.sGlobalDeviceSystemName))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceSystemVersion' is [\(String(describing: self.sGlobalDeviceSystemVersion))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceModel' is [\(String(describing: self.sGlobalDeviceModel))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceLocalizedModel' is [\(String(describing: self.sGlobalDeviceLocalizedModel))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceModel' is [\(String(describing: self.sGlobalDeviceModel))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceLocalizedModel' is [\(String(describing: self.sGlobalDeviceLocalizedModel))]...")
        
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceMachineIdentifier' is [\(String(describing: self.sGlobalDeviceMachineIdentifier))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceCPUType' is [\(String(describing: self.sGlobalDeviceCPUType))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceCPUArchitecture' is [\(String(describing: self.sGlobalDeviceCPUArchitecture))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceCPUSubtype' is [\(String(describing: self.sGlobalDeviceCPUSubtype))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.iGlobalDeviceCPUPhysicalCores' is (\(String(describing: self.iGlobalDeviceCPUPhysicalCores)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.iGlobalDeviceCPULogicalCores' is (\(String(describing: self.iGlobalDeviceCPULogicalCores)))...")
        
    #if os(iOS)
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.idiomGlobalDeviceUserInterfaceIdiom' is (\(String(describing: self.idiomGlobalDeviceUserInterfaceIdiom)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.iGlobalDeviceUserInterfaceIdiom' is (\(String(describing: self.iGlobalDeviceUserInterfaceIdiom)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.uuidGlobalDeviceIdForVendor' is [\(String(describing: self.uuidGlobalDeviceIdForVendor))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.fGlobalDeviceCurrentBatteryLevel' is (\(String(describing: self.fGlobalDeviceCurrentBatteryLevel)))...")
    #endif
        
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.fGlobalDeviceScreenSizeWidth' is (\(String(describing: self.fGlobalDeviceScreenSizeWidth)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.fGlobalDeviceScreenSizeHeight' is (\(String(describing: self.fGlobalDeviceScreenSizeHeight)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.iGlobalDeviceScreenSizeScale' is (\(String(describing: self.iGlobalDeviceScreenSizeScale)))...")

    #if os(iOS)
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalDeviceOrientation' is [\(String(describing: self.sGlobalDeviceOrientation))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalDeviceOrientationIsPortrait' is [\(String(describing: self.bGlobalDeviceOrientationIsPortrait))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalDeviceOrientationIsLandscape' is [\(String(describing: self.bGlobalDeviceOrientationIsLandscape))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalDeviceOrientationIsFlat' is [\(String(describing: self.bGlobalDeviceOrientationIsFlat))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalDeviceOrientationIsInvalid' is [\(String(describing: self.bGlobalDeviceOrientationIsInvalid))]...")
    #endif

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.iGlobalAuthType' is (\(String(describing: self.iGlobalAuthType)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sGlobalAuthType' is [\(String(describing: self.sGlobalAuthType))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalAuthTypeIsUndefined' is [\(String(describing: self.bGlobalAuthTypeIsUndefined))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalAuthTypeIsUser' is [\(String(describing: self.bGlobalAuthTypeIsUser))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalAuthTypeIsPatient' is [\(String(describing: self.bGlobalAuthTypeIsPatient))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalAuthTypeIsTherapist' is [\(String(describing: self.bGlobalAuthTypeIsTherapist))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalAuthTypeIsOffice' is [\(String(describing: self.bGlobalAuthTypeIsOffice))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bGlobalAuthTypeIsDev' is [\(String(describing: self.bGlobalAuthTypeIsDev))]...")

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAppCategory' is [\(String(describing: self.sAppCategory))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAppDisplayName' is [\(String(describing: self.sAppDisplayName))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAppBundleIdentifier' is [\(String(describing: self.sAppBundleIdentifier))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAppVersionAndBuildNumber' is [\(String(describing: self.sAppVersionAndBuildNumber))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAppCopyright' is [\(String(describing: self.sAppCopyright))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.sAppUserDefaultsFileLocation' is [\(String(describing: self.sAppUserDefaultsFileLocation))]...")

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.bAppIsInTheBackground' is [\(String(describing: self.bAppIsInTheBackground))]...")

    #if USE_APP_LOGGING_BY_VISITOR
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfo.listAppGlobalInfoPreXCGLoggerMessages' has (\(listAppGlobalInfoPreXCGLoggerMessages.count)) message(s)...")
    #endif

    #if ENABLE_APP_IAP_CAPABILITY
        // Display the various AppGlobalInfoConfigIAP 'settings'...

        appLogMsg("\(sCurrMethodDisp) ========== AppGlobalInfoConfigIAP 'settings' ==========")

        let appGlobalInfoConfigIAP:AppGlobalInfoConfigIAP = AppGlobalInfoConfigIAP.ClassSingleton.appGlobalInfoConfigIAP

        appGlobalInfoConfigIAP.displayAppGlobalInfoConfigIAPSettings()
    #endif

        appLogMsg("\(sCurrMethodDisp) =======================================================")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func displayUIDeviceInformation().

    // MARK: Authentication...

    func setAppAuthType(iGlobalAuthType:AppGlobalAuthType = AppGlobalAuthType.appGlobalAuthTypeUndefined)
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "AppGlobalInfo.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")
        
        // Finish the App 'auth' (authentication) setup...
        
        self.iGlobalAuthType            = iGlobalAuthType
        self.sGlobalAuthType            = "-unknown-"
        self.bGlobalAuthTypeIsUndefined = false
        self.bGlobalAuthTypeIsUser      = false
        self.bGlobalAuthTypeIsPatient   = false
        self.bGlobalAuthTypeIsTherapist = false
        self.bGlobalAuthTypeIsOffice    = false
        self.bGlobalAuthTypeIsDev       = false

        switch (iGlobalAuthType)
        {
        case AppGlobalAuthType.appGlobalAuthTypeUndefined:
            self.sGlobalAuthType            = "Undefined"
            self.bGlobalAuthTypeIsUndefined = true
        case AppGlobalAuthType.appGlobalAuthTypeUser:
            self.sGlobalAuthType            = "User"
            self.bGlobalAuthTypeIsUser      = true
        case AppGlobalAuthType.appGlobalAuthTypePatient:
            self.sGlobalAuthType            = "Patient"
            self.bGlobalAuthTypeIsPatient   = true
        case AppGlobalAuthType.appGlobalAuthTypeTherapist:
            self.sGlobalAuthType            = "Therapist"
            self.bGlobalAuthTypeIsTherapist = true
        case AppGlobalAuthType.appGlobalAuthTypeOffice:
            self.sGlobalAuthType            = "Office"
            self.bGlobalAuthTypeIsOffice    = true
        case AppGlobalAuthType.appGlobalAuthTypeDev:
            self.sGlobalAuthType            = "Dev"
            self.bGlobalAuthTypeIsDev       = true
        }

        // Exit...
        
        appLogMsg("\(sCurrMethodDisp) Exiting...")
        
        return

    }   // End of func setAppAuthType(iGlobalAuthType:AppGlobalAuthType = AppGlobalAuthType.appGlobalAuthTypeUndefined).

    // MARK: Foreground/Background 'state' setting...

#if os(iOS)
    @objc func appMovedToForeground()
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "AppGlobalInfo.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        self.setAppInForeground()

        // Exit...
        
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Exiting...")
        
        return
        
    }   // End of func appMovedToForeground().

    @objc func appMovedToBackground()
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "AppGlobalInfo.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Invoked...")

        self.setAppInBackground()

        // Exit...
        
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Exiting...")
        
        return
        
    }   // End of func appMovedToBackground().
#endif

    func setAppInForeground()
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "AppGlobalInfo.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Invoked...")
        
        // Finish setting the App in the Foreground 'state'...

        self.bAppIsInTheBackground = false

    #if USE_APP_LOGGING_BY_VISITOR
        if (jmAppGlobalInfoDelegateVisitor != nil)
        {
            // When we go into the Foreground, we make sure the CRASH Marker File is in place...

            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Intermediate - Calling 'self.performAppDelegateVisitorStartupCrashLogic(false, bForegroundRestore:true)'...")
            jmAppGlobalInfoDelegateVisitor?.performAppDelegateVisitorStartupCrashLogic(false, bForegroundRestore:true)
            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Intermediate - Called  'self.performAppDelegateVisitorStartupCrashLogic(false, bForegroundRestore:true)'...")
        }
    #endif

        // Exit...
        
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Exiting...")
        
        return
        
    }   // End of func setAppInForeground().

    func setAppInBackground()
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "AppGlobalInfo.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Invoked...")
        
        // Finish setting the App in the Background 'state'...

        self.bAppIsInTheBackground = true

    #if USE_APP_LOGGING_BY_VISITOR
        if (jmAppGlobalInfoDelegateVisitor != nil)
        {
            // When we go into the Background, we make sure the CRASH Marker File is NOT in place (we can be removed without warning)...

            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Intermediate - Calling 'self.performAppDelegateVisitorTerminatingCrashLogic()'...")
            jmAppGlobalInfoDelegateVisitor?.performAppDelegateVisitorTerminatingCrashLogic()
            appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Intermediate - Called  'self.performAppDelegateVisitorTerminatingCrashLogic()'...")
        }
    #endif

        // Exit...
        
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Exiting...")
        
        return
        
    }   // End of func setAppInBackground().

    @objc func checkAppInForegroundOrBackground()->Bool
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "AppGlobalInfo.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Invoked...")
        
        // Set the App in the Foreground/Background 'state'...
        
#if os(macOS)
        // Main app code

        let stateForegroundBackground = true
        self.setAppInForeground()
#endif
#if os(iOS)
    #if APP_EXTENSION
        // Extension code - UIApplication.shared is unavailable

        let stateForegroundBackground = UIApplication.State.active
    #else
        // Main app code

        let stateForegroundBackground = UIApplication.shared.applicationState
    #endif

        switch stateForegroundBackground 
        {
        case .active:
            self.setAppInForeground()
        case .inactive:
            self.setAppInBackground()
        case .background:
            self.setAppInBackground()
        @unknown default:
            break
        }
#endif

        // Exit...
        
        appLogMsg("\(sCurrMethodDisp) <VisitorCrashLogic> Exiting - 'self.bAppIsInTheBackground' is [\(self.bAppIsInTheBackground)]...")
        
        return self.bAppIsInTheBackground
        
    }   // End of @objc func checkAppInForegroundOrBackground()->Bool.

    // ------------------------------------------------------------------------------------------------------
    // MARK: CPU/Device Detection Methods (cross-platform)
    // ------------------------------------------------------------------------------------------------------

    private func getDeviceMachineIdentifier()->String
    {

        var size:Int = 0

        sysctlbyname("hw.machine", nil, &size, nil, 0)

        var machine = [CChar](repeating:0, count:size)
        let result  = sysctlbyname("hw.machine", &machine, &size, nil, 0)
        
        if (result == 0)
        {
            return String(cString:machine)
        }
        
        return "-unknown-"
        
    }   // End of private func getDeviceMachineIdentifier()->String.

    private func getCPUArchitecture()->String
    {

        var size:Int           = 0
        var cputype:cpu_type_t = 0
        size                   = MemoryLayout<cpu_type_t>.size
        let result             = sysctlbyname("hw.cputype", &cputype, &size, nil, 0)
        
        if (result == 0)
        {
            switch cputype
            {
            case CPU_TYPE_ARM64:
                return "ARM64"
            case CPU_TYPE_X86_64:
                return "X86_64"
            default:
                return "Type-\(cputype)"
            }
        }
        
        return "-unknown-"
        
    }   // End of private func getCPUArchitecture()->String.

    private func getCPUSubtype()->String
    {

        var size:Int                 = 0
        var cpusubtype:cpu_subtype_t = 0
        size                         = MemoryLayout<cpu_subtype_t>.size
        let result                   = sysctlbyname("hw.cpusubtype", &cpusubtype, &size, nil, 0)
        
        if (result == 0)
        {
            // ARM64E is subtype 2, ARM64 is subtype 0...

            if (cpusubtype == 2)
            {
                return "ARM64E"
            }
            else
            {
                return "Subtype-\(cpusubtype)"
            }
        }
        
        return "-unknown-"
        
    }   // End of private func getCPUSubtype()->String.

    private func getCPUCoreCount()->(physical:Int, logical:Int)
    {

        var physicalCores:Int = 0
        var logicalCores:Int  = 0
        var size:Int          = MemoryLayout<Int>.size
        
        // Get physical cores (performance cores)...

        let result1 = sysctlbyname("hw.perflevel0.physicalcpu", &physicalCores, &size, nil, 0)
        
        // Get logical cores (total processing units)...

        let result2 = sysctlbyname("hw.ncpu", &logicalCores, &size, nil, 0)
        
        // Fallback: if physical core query fails, use processor count from ProcessInfo...

        if (result1 != 0)
        {
            physicalCores = ProcessInfo.processInfo.processorCount
        }
        
        if (result2 != 0)
        {
            logicalCores = ProcessInfo.processInfo.activeProcessorCount
        }
        
        return (physical:physicalCores, logical:logicalCores)
        
    }   // End of private func getCPUCoreCount()->(physical:Int, logical:Int).

    private func mapMachineIdentifierToCPUType(sMachineId:String)->String
    {

        // Comprehensive mapping of device identifiers to CPU types
        // Works for both iOS devices and Macs:
        
        // iPad Pro models with M-series chips...

        let ipadProM4Models = ["iPad14,5", "iPad14,6", "iPad14,7", "iPad14,8",          // 11" & 13" M4 (2024)
                               "iPad16,3", "iPad16,4", "iPad16,5", "iPad16,6"]          // M4 variants
        let ipadProM2Models = ["iPad14,3", "iPad14,4"]                                  // 11" & 12.9" M2 (2022)
        let ipadProM1Models = ["iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7",          // 11" & 12.9" M1 (2021)
                               "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11"]
        
        // iPad Air with M-series chips...

        let ipadAirM2Models = ["iPad14,8", "iPad14,9", "iPad14,10", "iPad14,11"]        // Air M2 (2024)
        let ipadAirM1Models = ["iPad13,16", "iPad13,17"]                                // Air M1 (2022)
        
        // iPhone models (A-series chips)...

        let iphone16Models = ["iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4"]   // A18 series (2024)
        let iphone15ProModels = ["iPhone16,1", "iPhone16,2"]                            // A17 Pro (2023)
        let iphone15Models = ["iPhone15,4", "iPhone15,5"]                               // A16 (2023)
        let iphone14ProModels = ["iPhone15,2", "iPhone15,3"]                            // A16 (2022)
        let iphone14Models = ["iPhone14,7", "iPhone14,8"]                               // A15 (2022)
        let iphone13Models = ["iPhone14,2", "iPhone14,3", "iPhone14,4", "iPhone14,5"]   // A15 (2021)
        
        // Check against each group...

        if (ipadProM4Models.contains(sMachineId))   { return "Apple M4" }
        if (ipadProM2Models.contains(sMachineId))   { return "Apple M2" }
        if (ipadProM1Models.contains(sMachineId))   { return "Apple M1" }
        if (ipadAirM2Models.contains(sMachineId))   { return "Apple M2" }
        if (ipadAirM1Models.contains(sMachineId))   { return "Apple M1" }
        
        if (iphone16Models.contains(sMachineId))    { return "Apple A18" }
        if (iphone15ProModels.contains(sMachineId)) { return "Apple A17 Pro" }
        if (iphone15Models.contains(sMachineId))    { return "Apple A16" }
        if (iphone14ProModels.contains(sMachineId)) { return "Apple A16" }
        if (iphone14Models.contains(sMachineId))    { return "Apple A15" }
        if (iphone13Models.contains(sMachineId))    { return "Apple A15" }
        
        // Mac detection (for both macOS apps and Catalyst apps)...

        if (sMachineId.hasPrefix("Mac"))
        {
            // M5 Macs (2025)
            if (sMachineId.contains("Mac16"))       { return "Apple M5" }
            // M4 Macs (2024)
            if (sMachineId.contains("Mac15"))       { return "Apple M4" }
            // M3 Macs (2023)
            if (sMachineId.contains("Mac14"))       { return "Apple M3" }
            // M2 Macs (2022)
            if (sMachineId.contains("Mac13"))       { return "Apple M2" }
            // M1 Macs (2020-2021)
            if (sMachineId.contains("Mac12"))       { return "Apple M1" }
            // Intel Macs
            if (sMachineId.contains("Mac11") || 
                sMachineId.contains("Mac10") ||
                sMachineId.contains("MacBook"))     { return "Intel" }
        }
        
        // If no match found, return generic info...

        return "Unknown (\(sMachineId))"
        
    }   // End of private func mapMachineIdentifierToCPUType(sMachineId:String)->String.

}   // End of public class AppGlobalInfo:NSObject.

