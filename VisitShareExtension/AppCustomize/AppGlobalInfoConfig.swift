//
//  AppGlobalInfoConfig.swift
//  <<< App 'dependent' >>>
//
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

// MARK: App 'global' information 'config'...

@objcMembers
@objc(AppGlobalInfoConfig)
final class AppGlobalInfoConfig:NSObject
{
    
    static let sGlobalInfoAppId:String                                   = "VisitShareExtension"
    static let sGlobalInfoAppVers:String                                 = "v1.5801"
    static let sGlobalInfoAppDisp:String                                 = sGlobalInfoAppId+".("+sGlobalInfoAppVers+"): "
    static let sGlobalInfoAppCopyRight:String                            = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
    static let sGlobalInfoAppLogFilespecMaxSize:Int64                    = 10000000
    static let bGlobalInfoAppAutoSendCrashLog:Bool                       = true
    static let bGlobalInfoAppAutoSendCrashLogTesting:Bool                = true
    static let sGlobalInfoAppLogFilespec:String                          = "VisitShareExtension.log"
    static let sGlobalInfoAppLastGoodLogFilespec:String                  = "VisitShareExtension.last_good.log"
    static let sGlobalInfoAppLastCrashLogFilespec:String                 = "VisitShareExtension.crashed_last.log"
    static let sGlobalInfoAppCrashMarkerFilespec:String                  = "VisitShareExtension.crash_marker.txt"

    static let bUseApplicationShortTitle:Bool                            = true
    static let sApplicationTitle:String                                  = sGlobalInfoAppId
    static let sApplicationShortTitle:String                             = "VSX"

#if os(macOS)
//  static let sHelpBasicFileExt:String                                  = "html"        // 'help' File extension: "md", "html", or "txt"
    static let sHelpBasicFileExt:String                                  = "md"          // 'help' File extension: "md", "html", or "txt"
#elseif os(iOS)
    static let sHelpBasicFileExt:String                                  = "md"          // 'help' File extension: "md", "html", or "txt"
#endif

    // Various 'app' component controls:

    static let eUseLatitudeLongitudePrecision:CLLocationPrecision        = CLLocationPrecision.useLatLong4  // or .useLatLong5
    static let bAppIsADrcBuildDistribution:Bool                          = false
    static let bAppShouldShowLogFiles:Bool                               = true
    static let bEnableAppDevSwiftDataRecovery:Bool                       = false
    static let bPerformAppObjCSwiftBridgeTest:Bool                       = false
    static let bAppMetricKitManagerSendDiagnostics:Bool                  = false
    static let bAppMetricKitManagerSendMetrics:Bool                      = false
    static let bIssueTestAppUserNotifications:Bool                       = false
    static let bIssueShortAppUserNotifications:Bool                      = true
    static let bPerformAppCoreLocationTesting:Bool                       = false
    static let bPerformAppDevTesting:Bool                                = true
    static let bEnableAppReleaseDownloads:Bool                           = true
    static let bEnableAppAdsPlaceholder:Bool                             = false
    static let bEnableAppAdsTesting:Bool                                 = false
    static let sAdSenseAppAdsTesting:String                              = "ca-app-pub-3940256099942544/2435281174"     // Google AdMod 'test' Ads...
    static let bEnableAppAdsProduction:Bool                              = false
    static let sAdSenseAppAdsProduction:String                           = "ca-app-pub-3654761817947063/5081828834"     // Google AdMod 'prod' Ad Unit ID...
    static let bEnableAppRevenueCatTesting:Bool                          = false
    static let bEnableAppRevenueCatProduction:Bool                       = false
    static let bTestStringManipulations:Bool                             = false
    static let bTestAppBigTestTracking1:Bool                             = false
    static let bTestAppBigTestTracking2:Bool                             = false
    static let bTestAppDeepCopyUtility:Bool                              = true
    static let sAppUploadNotifyFrom:String                               = "dcox@justmacapps.net"
    static let iAlertViaSwiftUITimeout:Double                            = 20.00
    static let iAlertViaUIKitTimeout:Double                              = 5.00

    // Various 'app' VisitVerify (VV) 'color' component controls:

    static let vvColorVisitScheduled:Color                               = Color.blue       // Visit 'scheduled'...
    static let vvColorVisitActual:Color                                  = Color.orange     // Visit 'actual'...
    static let vvColorVisitMissed:Color                                  = Color.red        // Visit 'missed'...
    static let vvColorVisitTeleP:Color                                   = Color.red        // Visit 'TelePractice'...
    static let vvColorVisitGood:Color                                    = Color.green      // Visit 'Good'...
    static let vvColorVisitDatePast:Color                                = Color.yellow     // Visit Date (In) 'Past'...
    static let vvColorVisitDateError:Color                               = Color.purple     // Visit Date 'Error'...
    static let vvColorVisitUndefined:Color                               = Color.primary    // Visit 'Undefined'...

    static public func displayAppGlobalInfoConfigSettings()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "AppGlobalInfoConfig.\(AppGlobalInfoConfig.sGlobalInfoAppDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Display the various AppGlobalInfoConfig 'settings'...

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sGlobalInfoAppId' is [\(String(describing: AppGlobalInfoConfig.sGlobalInfoAppId))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sGlobalInfoAppVers' is [\(String(describing: AppGlobalInfoConfig.sGlobalInfoAppVers))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sGlobalInfoAppDisp' is [\(String(describing: AppGlobalInfoConfig.sGlobalInfoAppDisp))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sGlobalInfoAppCopyRight' is [\(String(describing: AppGlobalInfoConfig.sGlobalInfoAppCopyRight))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sGlobalInfoAppLogFilespecMaxSize' is [\(String(describing: AppGlobalInfoConfig.sGlobalInfoAppLogFilespecMaxSize))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bGlobalInfoAppAutoSendCrashLog' is [\(String(describing: AppGlobalInfoConfig.bGlobalInfoAppAutoSendCrashLog))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bGlobalInfoAppAutoSendCrashLogTesting' is [\(String(describing: AppGlobalInfoConfig.bGlobalInfoAppAutoSendCrashLogTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sGlobalInfoAppLogFilespec' is [\(String(describing: AppGlobalInfoConfig.sGlobalInfoAppLogFilespec))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sGlobalInfoAppLastGoodLogFilespec' is [\(String(describing: AppGlobalInfoConfig.sGlobalInfoAppLastGoodLogFilespec))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sGlobalInfoAppLastCrashLogFilespec' is [\(String(describing: AppGlobalInfoConfig.sGlobalInfoAppLastCrashLogFilespec))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sGlobalInfoAppCrashMarkerFilespec' is [\(String(describing: AppGlobalInfoConfig.sGlobalInfoAppCrashMarkerFilespec))]...")
                                                                                                                                                                       
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bUseApplicationShortTitle' is [\(String(describing: AppGlobalInfoConfig.bUseApplicationShortTitle))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sApplicationTitle' is [\(String(describing: AppGlobalInfoConfig.sApplicationTitle))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sApplicationShortTitle' is [\(String(describing: AppGlobalInfoConfig.sApplicationShortTitle))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sHelpBasicFileExt' is [\(String(describing: AppGlobalInfoConfig.sHelpBasicFileExt))]...")
                                                                                                                                                                       
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.eUseLatitudeLongitudePrecision' is [\(String(describing: AppGlobalInfoConfig.eUseLatitudeLongitudePrecision))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bAppIsADrcBuildDistribution' is [\(String(describing: AppGlobalInfoConfig.bAppIsADrcBuildDistribution))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bAppShouldShowLogFiles' is [\(String(describing: AppGlobalInfoConfig.bAppShouldShowLogFiles))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bEnableAppDevSwiftDataRecovery' is [\(String(describing: AppGlobalInfoConfig.bEnableAppDevSwiftDataRecovery))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bPerformAppObjCSwiftBridgeTest' is [\(String(describing: AppGlobalInfoConfig.bPerformAppObjCSwiftBridgeTest))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bAppMetricKitManagerSendDiagnostics' is [\(String(describing: AppGlobalInfoConfig.bAppMetricKitManagerSendDiagnostics))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bAppMetricKitManagerSendMetrics' is [\(String(describing: AppGlobalInfoConfig.bAppMetricKitManagerSendMetrics))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bIssueTestAppUserNotifications' is [\(String(describing: AppGlobalInfoConfig.bIssueTestAppUserNotifications))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bIssueShortAppUserNotifications' is [\(String(describing: AppGlobalInfoConfig.bIssueShortAppUserNotifications))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bPerformAppCoreLocationTesting' is [\(String(describing: AppGlobalInfoConfig.bPerformAppCoreLocationTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bPerformAppDevTesting' is [\(String(describing: AppGlobalInfoConfig.bPerformAppDevTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bEnableAppReleaseDownloads' is [\(String(describing: AppGlobalInfoConfig.bEnableAppReleaseDownloads))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bEnableAppAdsPlaceholder' is [\(String(describing: AppGlobalInfoConfig.bEnableAppAdsPlaceholder))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bEnableAppAdsTesting' is [\(String(describing: AppGlobalInfoConfig.bEnableAppAdsTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bEnableAppAdsProduction' is [\(String(describing: AppGlobalInfoConfig.bEnableAppAdsProduction))]...")

    #if INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.jmAppGoogleAdMobAppIdentifier' is [\(String(describing: JmXcodeBuildSettings.jmAppGoogleAdMobAppIdentifier))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sAdSenseAppAdsTesting' is [\(String(describing: AppGlobalInfoConfig.sAdSenseAppAdsTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sAdSenseAppAdsProduction' is [\(String(describing: AppGlobalInfoConfig.sAdSenseAppAdsProduction))]...")
    #endif

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bEnableAppRevenueCatTesting' is [\(String(describing: AppGlobalInfoConfig.bEnableAppRevenueCatTesting))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bEnableAppRevenueCatProduction' is [\(String(describing: AppGlobalInfoConfig.bEnableAppRevenueCatProduction))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bTestStringManipulations' is [\(String(describing: AppGlobalInfoConfig.bTestStringManipulations))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bTestAppBigTestTracking1' is [\(String(describing: AppGlobalInfoConfig.bTestAppBigTestTracking1))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.bTestAppBigTestTracking2' is [\(String(describing: AppGlobalInfoConfig.bTestAppBigTestTracking2))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.sAppUploadNotifyFrom' is [\(String(describing: AppGlobalInfoConfig.sAppUploadNotifyFrom))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.iAlertViaSwiftUITimeout' is #(\(String(describing: AppGlobalInfoConfig.iAlertViaSwiftUITimeout)))...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.iAlertViaUIKitTimeout' is #(\(String(describing: AppGlobalInfoConfig.iAlertViaUIKitTimeout)))...")

        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.vvColorVisitScheduled' is [\(String(describing: AppGlobalInfoConfig.vvColorVisitScheduled))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.vvColorVisitActual' is [\(String(describing: AppGlobalInfoConfig.vvColorVisitActual))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.vvColorVisitMissed' is [\(String(describing: AppGlobalInfoConfig.vvColorVisitMissed))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.vvColorVisitTeleP' is [\(String(describing: AppGlobalInfoConfig.vvColorVisitTeleP))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.vvColorVisitGood' is [\(String(describing: AppGlobalInfoConfig.vvColorVisitGood))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.vvColorVisitDatePast' is [\(String(describing: AppGlobalInfoConfig.vvColorVisitDatePast))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.vvColorVisitDateError' is [\(String(describing: AppGlobalInfoConfig.vvColorVisitDateError))]...")
        appLogMsg("\(sCurrMethodDisp) 'AppGlobalInfoConfig.vvColorVisitUndefined' is [\(String(describing: AppGlobalInfoConfig.vvColorVisitUndefined))]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of static public func displayAppGlobalInfoConfigSettings().

}   // End of final class AppGlobalInfoConfig.

