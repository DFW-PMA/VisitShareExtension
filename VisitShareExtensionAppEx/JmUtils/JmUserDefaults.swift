//
//  JmUserDefaults.swift
//  JmUtils_Library
//
//  Created by JustMacApps.net on 06/11/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

#if canImport(Cocoa)
import Cocoa
#else
import UIKit
#endif

@available(iOS 14.0, *)
@objc(JmUserDefaults)
class JmUserDefaults: NSObject
{

    struct ClassInfo
    {
        static let sClsId        = "JmUserDefaults"
        static let sClsVers      = "v1.1101"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // Standard UserDefaults object:

    let userDefaults                              = UserDefaults.standard

    // App Data field(s):

    let bClsTraceInternal:Bool                    = false

    override init()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        super.init()

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of override init().

    @objc public func toString()->String
    {

        var asToString:[String] = Array()

        asToString.append("[")
        asToString.append("[")
        asToString.append("'sClsId': [\(ClassInfo.sClsId)],")
        asToString.append("'sClsVers': [\(ClassInfo.sClsVers)],")
        asToString.append("'sClsDisp': [\(ClassInfo.sClsDisp)],")
        asToString.append("'sClsCopyRight': [\(ClassInfo.sClsCopyRight)],")
        asToString.append("'bClsTrace': [\(ClassInfo.bClsTrace)],")
        asToString.append("'bClsFileLog': [\(ClassInfo.bClsFileLog)],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("'userDefaults': [\(String(describing: self.userDefaults))],")
        asToString.append("],")
        asToString.append("[")
        asToString.append("'bClsTraceInternal': [\(self.bClsTraceInternal)],")
        asToString.append("],")
        asToString.append("]")

        let sContents:String = "{"+(asToString.joined(separator: ""))+"}"

        return sContents

    }   // End of @objc public func toString().

    @objc func getObjCObjectForKey(_ forKey:NSString = "")->Any?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked  - 'forKey' is [\(forKey)]...")

        let sSuppliedForKey:String = forKey as String

        if (sSuppliedForKey.count < 1)
        {
            appLogMsg("\(sCurrMethodDisp) Supplied 'forKey' value is an 'empty' string - this is required - Error!")

            // Exit:

            appLogMsg("\(sCurrMethodDisp) Exiting - 'sSuppliedForKey' was None or empty - Error!...")

            return nil
        }

        let objUserDefaults:Any? = self.getObjectForKey(sSuppliedForKey)

        appLogMsg("\(sCurrMethodDisp) The 'objUserDefaults' value returned from UserDefaults for the key of [\(sSuppliedForKey)] is [\(String(describing: objUserDefaults))]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sSuppliedForKey' is [\(sSuppliedForKey)]...")

        return objUserDefaults

    }   // End of @objc func getObjCObjectForKey(_ forKey:NSString)->Any?.

    public func getObjectForKey(_ forKey:String = "")->Any?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'forKey' is [\(forKey)]...")

        let sSuppliedForKey:String = forKey

        if (sSuppliedForKey.count < 1)
        {
            appLogMsg("\(sCurrMethodDisp) Supplied 'forKey' value is an 'empty' string - this is required - Error!")

            // Exit:

            appLogMsg("\(sCurrMethodDisp) Exiting - 'sSuppliedForKey' was None or empty - Error!...")

            return nil
        }

        let objUserDefaults:Any? = self.userDefaults.object(forKey:sSuppliedForKey)

        appLogMsg("\(sCurrMethodDisp) The 'objUserDefaults' value returned from UserDefaults for the key of [\(sSuppliedForKey)] is [\(String(describing: objUserDefaults))]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sSuppliedForKey' is [\(sSuppliedForKey)]...")

        return objUserDefaults

    }   // End of public func getObjectForKey(_ forKey:String)->Any?).

    @objc public func setObjCObjectForKey(_ keyValue:Any?, forKey:NSString = "")
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'forKey' is [\(forKey)]...")

        let sSuppliedForKey:String = forKey as String

        if (sSuppliedForKey.count < 1)
        {
            appLogMsg("\(sCurrMethodDisp) Supplied 'forKey' value is an 'empty' string - this is required - Error!")

            // Exit:

            appLogMsg("\(sCurrMethodDisp) Exiting - 'sSuppliedForKey' was None or empty - Error!...")

            return
        }

        self.setObjectForKey((keyValue as Any), forKey:sSuppliedForKey)

        appLogMsg("\(sCurrMethodDisp) The Supplied 'kayValue' object has been set into UserDefaults for the key of [\(sSuppliedForKey)] as [\(String(describing: keyValue))]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sSuppliedForKey' is [\(sSuppliedForKey)]...")

        return

    }   // End of @objc public func setObjCObjectForKey().

    public func setObjectForKey(_ keyValue:Any?, forKey:String = "")
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - 'forKey' is [\(forKey)]...")

        let sSuppliedForKey:String = forKey

        if (sSuppliedForKey.count < 1)
        {
            appLogMsg("\(sCurrMethodDisp) Supplied 'forKey' value is an 'empty' string - this is required - Error!")

            // Exit:

            appLogMsg("\(sCurrMethodDisp) Exiting - 'sSuppliedForKey' was None or empty - Error!...")

            return
        }

        self.userDefaults.set(keyValue, forKey:sSuppliedForKey)

        appLogMsg("\(sCurrMethodDisp) The Supplied 'kayValue' object has been set into UserDefaults for the key of [\(sSuppliedForKey)] as [\(String(describing: keyValue))]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'sSuppliedForKey' is [\(sSuppliedForKey)]...")

        return

    }   // End of public func setObjectForKey().

}   // End of class JmUserDefaults(NSObject).

