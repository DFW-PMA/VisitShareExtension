//
//  SettingsSingleView.swift
//  <<< App 'dependent' >>>
//
//  Created by JustMacApps.net on 03/26/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import SwiftUI

struct SettingsSingleView:View 
{
    
    struct ClassInfo
    {
        static let sClsId        = "SettingsSingleView"
        static let sClsVers      = "v1.0901"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // App Data field(s):

    init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of init().

    var body:some View 
    {
        
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body \(JmXcodeBuildSettings.jmAppVersionAndBuildNumber)...")

    #if os(macOS)
        SettingsSingleViewMac()
    #elseif os(iOS)
        SettingsSingleViewIos()
    #endif

    }
    
}   // End of struct SettingsSingleView:View.

#Preview 
{
    SettingsSingleView()
}

