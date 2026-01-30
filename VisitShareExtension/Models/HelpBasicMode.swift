//
//  HelpBasicMode.swift
//  JustAMenuBarApp2
//
//  Created by JustMacApps.net on 05/09/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
enum HelpBasicMode:String, CaseIterable
{
    case hypertext  = "html"
    case markdown   = "md"
    case simpletext = "text"
    
    static func changeHelpBasicMode(to mode: HelpBasicMode)
    {
        @AppStorage("helpBasicMode") var helpBasicMode = HelpBasicMode.simpletext
        
        helpBasicMode = mode
    }
}

