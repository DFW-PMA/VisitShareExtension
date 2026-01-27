//
//  JmXcodeBuildSettings.swift
//  JmUtils_Library
//
//  Created by Daryl Cox on 08/22/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation

// Implementation class to handle access to Xcode (.xcodeproj) 'Build' Setting(s).

public class JmXcodeBuildSettings
{

    struct ClassInfo
    {
        static let sClsId        = "JmXcodeBuildSettings"
        static let sClsVers      = "v1.0901"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = false
    }

    // App Data field(s):

    static var jmAppCategory:String
    {
        return getAppInfoPlistString(for:"LSApplicationCategoryType")
    }

    static var jmAppDisplayName:String
    {
        return getAppInfoPlistString(for:"CFBundleDisplayName")
    }

    static var jmAppBundleIdentifier:String
    {
        return getAppInfoPlistString(for:"CFBundleIdentifier")
    }

    static var jmAppVersionAndBuildNumber:String
    {
        return "Version v\(getAppInfoPlistString(for: "CFBundleShortVersionString")) (\(getAppInfoPlistString(for: "CFBundleVersion")))"
    }

    static var jmAppCopyright:String
    {
        return getAppInfoPlistString(for:"NSHumanReadableCopyright")
    }

    static var jmAppUserDefaultsFileLocation:String
    {
        return getAppUserDefaultsFileLocation()
    }

    static var jmAppJmaUserSetting1:String
    {
        return getAppInfoPlistString(for:"JMA_USER_SETTING_1")
    }

    static var jmAppJmaUserSetting2:String
    {
        return getAppInfoPlistString(for:"JMA_USER_SETTING_2")
    }

    static var jmAppUseAppLoggingByVisitor:String
    {
        return getAppInfoPlistString(for:"USE_APP_LOGGING_BY_VISITOR")
    }

#if INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
    static var jmAppGoogleAdMobAppIdentifier:String
    {
        return getAppInfoPlistString(for:"GADApplicationIdentifier")
    }
#endif

    class public func toString()->String
    {

        var asToString:[String] = Array()

        asToString.append("[")
        asToString.append("[")
        asToString.append("'sClsId': [\(ClassInfo.sClsId)],")
        asToString.append("'sClsVers': [\(ClassInfo.sClsVers)],")
        asToString.append("'sClsDisp': [\(ClassInfo.sClsDisp)],")
        asToString.append("'sClsCopyRight': [\(ClassInfo.sClsCopyRight)],")
        asToString.append("'bClsTrace': [\(ClassInfo.bClsTrace)],")
        asToString.append("'bClsFileLog': [\(ClassInfo.bClsFileLog)]")
        asToString.append("],")
        asToString.append("[")
        asToString.append("'jmAppCategory': [\(self.jmAppCategory)],")
        asToString.append("'jmAppDisplayName': [\(self.jmAppDisplayName)],")
        asToString.append("'jmAppBundleIdentifier': [\(self.jmAppBundleIdentifier)],")
        asToString.append("'jmAppVersionAndBuildNumber': [\(self.jmAppVersionAndBuildNumber)],")
        asToString.append("'jmAppCopyright': [\(self.jmAppCopyright)],")
        asToString.append("'jmAppUserDefaultsFileLocation': [\(self.jmAppUserDefaultsFileLocation)],")
        asToString.append("'jmAppJmaUserSetting1': [\(self.jmAppJmaUserSetting1)],")
        asToString.append("'jmAppJmaUserSetting2': [\(self.jmAppJmaUserSetting2)],")
        asToString.append("'jmAppUseAppLoggingByVisitor': [\(self.jmAppUseAppLoggingByVisitor)],")
        asToString.append("],")
        asToString.append("]")

        let sContents:String = "{"+(asToString.joined(separator: ""))+"}"

        return sContents

    }   // End of class public func toString()->String.

    class public func getAppCategory()->String 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let sAppCategory:String = getAppInfoPlistString(for: "LSApplicationCategoryType")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppCategory' is [\(sAppCategory)]...")

        return sAppCategory

    }   // End of class public func getAppCategory()->String.

    class public func getAppDisplayName()->String 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let sAppDiaplayName:String = getAppInfoPlistString(for: "CFBundleDisplayName")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppDiaplayName' is [\(sAppDiaplayName)]...")

        return sAppDiaplayName

    }   // End of class public func getAppDisplayName()->String.

    class public func getAppBundleIdentifier()->String 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let sAppBundleIdentifier:String = getAppInfoPlistString(for: "CFBundleIdentifier")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppBundleIdentifier' is [\(sAppBundleIdentifier)]...")

        return sAppBundleIdentifier

    }   // End of class public func getAppBundleIdentifier()->String.

    class public func getAppVersionAndBuildNumber()->String 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let sAppVersionNumber:String         = getAppInfoPlistString(for: "CFBundleShortVersionString")
        let sAppBuildNumber:String           = getAppInfoPlistString(for: "CFBundleVersion")
        let sAppVersionAndBuildNumber:String = "Version v\(sAppVersionNumber) (\(sAppBuildNumber))"

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppVersionAndBuildNumber' is [\(sAppVersionAndBuildNumber)]...")

        return sAppVersionAndBuildNumber

    }   // End of class public func getAppVersionAndBuildNumber()->String.

    class public func getAppCopyright()->String 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let sAppCopyRight:String = getAppInfoPlistString(for: "NSHumanReadableCopyright")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppCopyRight' is [\(sAppCopyRight)]...")

        return sAppCopyRight

    }   // End of class public func getAppCopyright()->String.

    class public func getAppInfoPlistString(for key:String)->String
    {

        return (Bundle.main.infoDictionary?[key] as? String) ?? "-N/A-"

    }   // End of class public func getAppInfoPlistString(for key:)->String.

    class public func getAppUserDefaultsFileLocation(bIsBootstrapInit:Bool = false)->String 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        if (bIsBootstrapInit == false)
        {
            appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'bIsBootstrapInit' is [\(bIsBootstrapInit)]...")
        }

        var sAppUserDefaultsFileLocation:String   = ""
        var sAppBundleMainBundleIdentifier:String = ""

        // Get the Application's Bundle 'identifier'...

        guard let bundleIdentifier = Bundle.main.bundleIdentifier 
        else 
        {
            sAppUserDefaultsFileLocation = "Error: Could NOT retrieve the App's Bundle 'identifier' <pass #1>..."

            // Exit:

            if (bIsBootstrapInit == false)
            {
                appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppUserDefaultsFileLocation' is [\(sAppUserDefaultsFileLocation)]...")
            }

            return sAppUserDefaultsFileLocation
        }

        sAppBundleMainBundleIdentifier = bundleIdentifier

        if (sAppBundleMainBundleIdentifier.count < 1)
        {
            sAppBundleMainBundleIdentifier = jmAppBundleIdentifier
        }
        
        if (sAppBundleMainBundleIdentifier.count < 1)
        {
            sAppUserDefaultsFileLocation = "Error: Could NOT retrieve the App's Bundle 'identifier' <pass #2>..."

            // Exit:

            if (bIsBootstrapInit == false)
            {
                appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppUserDefaultsFileLocation' is [\(sAppUserDefaultsFileLocation)]...")
            }

            return sAppUserDefaultsFileLocation
        }

        // First approach: Search in Library/Preferences...

        if let preferencesDir = FileManager.default.urls(for:.libraryDirectory, in:.userDomainMask).first 
        {
            let preferencesPath   = preferencesDir.appendingPathComponent("Preferences")
            let defaultsPlistPath = preferencesPath.appendingPathComponent("\(sAppBundleMainBundleIdentifier).plist")

            if FileManager.default.fileExists(atPath:defaultsPlistPath.path) 
            {
                sAppUserDefaultsFileLocation = defaultsPlistPath.path

                // Exit:

                if (bIsBootstrapInit == false)
                {
                    appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppUserDefaultsFileLocation' is [\(sAppUserDefaultsFileLocation)]...")
                }

                return sAppUserDefaultsFileLocation
            }
        }

        // Second approach: Search in Application Support directory...

        if let appSupportDir = FileManager.default.urls(for:.applicationSupportDirectory, in:.userDomainMask).first 
        {
            let possiblePath = appSupportDir.appendingPathComponent("\(sAppBundleMainBundleIdentifier).plist")

            if FileManager.default.fileExists(atPath:possiblePath.path) 
            {
                sAppUserDefaultsFileLocation = possiblePath.path

                // Exit:

                if (bIsBootstrapInit == false)
                {
                    appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppUserDefaultsFileLocation' is [\(sAppUserDefaultsFileLocation)]...")
                }

                return sAppUserDefaultsFileLocation
            }
        }

        // Third approach: Search in the container directory (iOS)...

        if let containerDir = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first?.deletingLastPathComponent() 
        {
            let libPath   = containerDir.appendingPathComponent("Library")
            let prefsPath = libPath.appendingPathComponent("Preferences")
            let plistPath = prefsPath.appendingPathComponent("\(sAppBundleMainBundleIdentifier).plist")

            if FileManager.default.fileExists(atPath:plistPath.path) 
            {
                sAppUserDefaultsFileLocation = plistPath.path

                // Exit:

                if (bIsBootstrapInit == false)
                {
                    appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppUserDefaultsFileLocation' is [\(sAppUserDefaultsFileLocation)]...")
                }

                return sAppUserDefaultsFileLocation
            }
        }

        // Additional approach: List all files in Library/Preferences to aid debugging...

        do 
        {
            if let preferencesDir = FileManager.default.urls(for:.libraryDirectory, in:.userDomainMask).first?.appendingPathComponent("Preferences") 
            {
                let files         = try FileManager.default.contentsOfDirectory(atPath:preferencesDir.path)
                let relevantFiles = files.filter 
                {
                    $0.contains(sAppBundleMainBundleIdentifier) || $0.contains("UserDefaults")
                }

                if (!relevantFiles.isEmpty)
                {
                    let relevantPaths = relevantFiles.map 
                    {
                        preferencesDir.appendingPathComponent($0).path
                    }

                    sAppUserDefaultsFileLocation = "Found potential matches:\n"+relevantPaths.joined(separator:"\n")

                    // Exit:

                    if (bIsBootstrapInit == false)
                    {
                        appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppUserDefaultsFileLocation' is [\(sAppUserDefaultsFileLocation)]...")
                    }

                    return sAppUserDefaultsFileLocation
                }
            }
        }
        catch 
        {
            // Continue to the fallback if these approachs fail...
        }

        // Fallback: Provide information about common locations...

        sAppUserDefaultsFileLocation = 
            """
            Could not locate UserDefaults plist file.

            Common locations:
            - iOS: /Library/Preferences/\(sAppBundleMainBundleIdentifier).plist
            - macOS: ~/Library/Preferences/\(sAppBundleMainBundleIdentifier).plist
            - Simulator: ~/Library/Developer/CoreSimulator/Devices/<DEVICE_ID>/data/Containers/Data/Application/<APP_ID>/Library/Preferences/\(sAppBundleMainBundleIdentifier).plist

            Bundle identifier: \(sAppBundleMainBundleIdentifier)
            """

        // Exit:

        if (bIsBootstrapInit == false)
        {
            appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppUserDefaultsFileLocation' is [\(sAppUserDefaultsFileLocation)]...")
        }

        return sAppUserDefaultsFileLocation

    }   // End of class public func getAppUserDefaultsFileLocation(bIsBootstrapInit:Bool)->String.

}   // End of public class JmXcodeBuildSettings.

