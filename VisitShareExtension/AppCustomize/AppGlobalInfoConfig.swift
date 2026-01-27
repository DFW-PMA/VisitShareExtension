//
//  AppGlobalInfoConfig.swift
//  <<< App 'dependent' >>>
//
//  Created by Daryl Cox on 01/27/2026.
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

struct AppGlobalInfoConfig
{
    
    static let sGlobalInfoAppId:String                                   = "VisitShareExtension"
    static let sGlobalInfoAppVers:String                                 = "v1.5601"
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
    static let bPerformAppDevTesting:Bool                                = false
    static let bEnableAppReleaseDownloads:Bool                           = false
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
    static let bTestAppDeepCopyUtility:Bool                              = false
    static let sAppUploadNotifyFrom:String                               = "dcox@justmacapps.net"
    static let iAlertViaSwiftUITimeout:Double                            = 20.00
    static let iAlertViaUIKitTimeout:Double                              = 5.00

}   // End of struct AppGlobalInfoConfig.

