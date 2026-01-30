//
//  SettingsSingleViewIos.swift
//  <<< App 'dependent' >>>
//
//  Created by JustMacApps.net on 03/26/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
struct SettingsSingleViewIos:View 
{
    
    struct ClassInfo
    {
        static let sClsId        = "SettingsSingleViewIos"
        static let sClsVers      = "v1.1101"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // App Data field(s):
    
//  @Environment(\.dismiss)          var dismiss
    @Environment(\.presentationMode) var presentationMode
    
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
        
        let _ = appLogMsg("...'SettingsSingleViewIos(.swift):body' \(JmXcodeBuildSettings.jmAppVersionAndBuildNumber)...")

        SettingsSingleViewCore()
        
    }
    
}   // End of struct SettingsSingleViewIos:View. 

#Preview 
{
    SettingsSingleViewIos()
}

