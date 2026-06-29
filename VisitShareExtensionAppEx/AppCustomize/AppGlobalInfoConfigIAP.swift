//
//  AppGlobalInfoConfigIAP.swift            // IAP (In-App Purchases).
//  <<< App 'dependent' >>>
//
//  Created by Daryl Cox on 02/22/2026.
//  Modified by Daryl Cox on 06/19/2026. (Swift 6 migration, Section 12 — ClassSingleton.appGlobalInfoConfigIAP
//                                         changed 'var' -> 'let', then 'nonisolated(unsafe)' added after the
//                                         compiler separately flagged the class as non-Sendable; see
//                                         <<CHICKEN-TRACKS>> notes at declaration).
//  Modified by Daryl Cox on 04/04/2026.
//  Modified by Daryl Cox on 02/23/2026.
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

//  extension AppGlobalInfo
final class AppGlobalInfoConfigIAP:NSObject
{
    
    // <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — flagged SENDABLE
    // ("nonisolated global shared mutable state"). Changed 'var' -> 'let': confirmed via grep that
    // this is never reassigned anywhere in the codebase (classic lazy-singleton write-once pattern).
    // <<CHICKEN-TRACKS>> Swift 6 migration follow-up — 'let' alone wasn't sufficient; the compiler
    // separately flags AppGlobalInfoConfigIAP itself as non-Sendable. Added nonisolated(unsafe)
    // rather than @MainActor — same reasoning as AppGlobalInfo's singleton fix.
//  struct ClassSingleton
//  {
//      nonisolated(unsafe) static let appGlobalInfoConfigIAP:AppGlobalInfoConfigIAP = AppGlobalInfoConfigIAP()
//  }
        nonisolated(unsafe) static let appGlobalInfoConfigIAP:AppGlobalInfoConfigIAP = AppGlobalInfoConfigIAP()
    
    var bAppIAPEnabledAnySettings:Bool                           = true
    var bAppIAPEnabledSubscriptionToRemoveAds:Bool               = false

    // Private 'init()' to make this class a 'singleton':

    private override init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "AppGlobalInfoConfigIAP.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"

        super.init()

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Exit...
        
        appLogMsg("\(sCurrMethodDisp) Exiting...")
        
        return

    }   // End of private override init().
        
    public func displayAppGlobalInfoConfigIAPSettings()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "AppGlobalInfoConfigIAP.\(AppGlobalInfo.sGlobalInfoAppDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Display the various AppGlobalInfoConfig 'settings'...

        appLogMsg("\(sCurrMethodDisp) 'self.bAppIAPEnabledAnySettings' is [\(String(describing: self.bAppIAPEnabledAnySettings))]...")
        appLogMsg("\(sCurrMethodDisp) 'self.bAppIAPEnabledSubscriptionToRemoveAds' is [\(String(describing: self.bAppIAPEnabledSubscriptionToRemoveAds))]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func displayAppGlobalInfoConfigIAPSettings().

}   // End of final class AppGlobalInfoConfigIAP:NSObject.

