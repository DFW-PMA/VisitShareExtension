//
//  VVDarwinNotification.swift
//  Shared between Helper App and Extension
//
//  Darwin notifications for cross-process communication.
//  Add this file to: VisitShareExtension, VisitShareExtensionAppEx
//

import Foundation

enum VVDarwinNotification
{

    struct ClassInfo
    {
        static let sClsId        = "VVDarwinNotification"
        static let sClsVers      = "v1.0401"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    static let notificationName = "com.PreferredMobileApplications.sharedExtensionPack.newHandoff" as CFString
    
    // MARK: - Post (called from Extension)
    
    static func postNewHandoff()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Invoked...")

        let notifyCenter = CFNotificationCenterGetDarwinNotifyCenter()
        
        CFNotificationCenterPostNotification(notifyCenter,
                                             CFNotificationName(notificationName),
                                             nil,
                                             nil,
                                             true)
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Posted 'newHandoff' Darwin notification...")

        return

    }   // End of static func postNewHandoff().
    
    // MARK: - Observe (called from Helper App)
    
    static func startObserving(callback:@escaping()->Void)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Invoked...")

        let notifyCenter = CFNotificationCenterGetDarwinNotifyCenter()
        
        // Store callback for use in static function...

        VVDarwinHandoffCallback.shared.callback = callback
        
        CFNotificationCenterAddObserver(notifyCenter,
                                        nil,
                                        darwinNotificationCallback,
                                        notificationName,
                                        nil,
                                        .deliverImmediately)
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Started observing for Darwin notifications...")

        return

    }   // End of static func startObserving(callback: @escaping () -> Void).
    
    static func stopObserving()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Invoked...")

        let notifyCenter = CFNotificationCenterGetDarwinNotifyCenter()
        
        CFNotificationCenterRemoveObserver(notifyCenter,
                                           nil,
                                           CFNotificationName(notificationName),
                                           nil)
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Stopped observing for Darwin notifications...")

        return

    }   // End of static func stopObserving().

}   // End of enum VVDarwinNotification.

// MARK: - Static Callback Function (C-compatible)

private func darwinNotificationCallback(center:CFNotificationCenter?,
                                        observer:UnsafeMutableRawPointer?,
                                        name:CFNotificationName?,
                                        object:UnsafeRawPointer?,
                                        userInfo:CFDictionary?)->Void
{

    appLogMsg("VVDarwinNotification.darwinNotificationCallback() - <PendingHandoffs> <DarwinNotification> Received Darwin notification, invoking callback...")

    VVDarwinHandoffCallback.shared.callback?()

}   // End of private func darwinNotificationCallback(...).

// MARK: - Helper class to store callback...

private class VVDarwinHandoffCallback
{

    static let shared               = VVDarwinHandoffCallback()
           var callback:(()->Void)?

}   // End of private class VVDarwinHandoffCallback.

