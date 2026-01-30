//
//  ProgressOverlay.swift
//  DataGridPack
//
//  Created by Daryl Cox on 05/01/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

#if os(iOS)
import Combine
#endif

// Reusable ProgressOverlay 'trigger' (Bool wrapper) class:

class ProgressOverlayTrigger:ObservableObject
{

    struct ClassInfo
    {
        static let sClsId        = "ProgressOverlayTrigger"
        static let sClsVers      = "v1.0401"
        static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // 'Internal' Trace flag:

    private 
    var bInternalTraceFlag:Bool             = false

    // App Data field(s):

    @Published var isProgressOverlayOn:Bool = false

    public func setProgressOverlay(isProgressOverlayOn:Bool = false)
    {
    
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'isProgressOverlayOn' is [\(isProgressOverlayOn)]...")
        
        // Set the 'self.isProgressOverlayOn' field to the supplied 'isProgressOverlayOn' field (accordingly)...
        
        if (self.isProgressOverlayOn != isProgressOverlayOn)
        {
            self.isProgressOverlayOn.toggle()
        }

        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting - 'self.isProgressOverlayOn' is [\(self.isProgressOverlayOn)]...")
    
        return
    
    }   // End of public func setProgressOverlay(isProgressOverlayOn:Bool = false).

}   // End of class ProgressOverlayTrigger:ObservableObject.

// Reusable ProgressOverlayModifier and View extension...

struct ProgressOverlayModifier:ViewModifier
{

    struct ClassInfo
    {
        static let sClsId        = "ProgressOverlay"
        static let sClsVers      = "v1.0301"
        static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // App Data field(s):

    @ObservedObject var trigger:ProgressOverlayTrigger
    
    func body(content:Content)->some View 
    {

        let _ = appLogMsg("<ContentLoading> ProgressOverlay:ViewModifier - 'self.trigger.isProgressOverlayOn' is [\(self.trigger.isProgressOverlayOn)] - launching the 'ZStack'...")

        ZStack 
        {
            content
                .disabled(self.trigger.isProgressOverlayOn)
            //  .blur(radius:((isProgressOverlayOn == true) ? 2 : 0))
                .opacity(trigger.isProgressOverlayOn ? 0.25 : 1.0)
                // Optional: dim the content when overlay is active...

        if (trigger.isProgressOverlayOn == true)
        {
            ZStack 
            {
                // Semi-transparent background...

                Color.black
                    .opacity(0.5)
                    .edgesIgnoringSafeArea(.all)

                // Progress indicator...

                HStack
                {

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint:.white))
                        .scaleEffect(0.65)

                    Text("...Loading...")
                        .foregroundColor(.white)
                        .font(.caption2)

                }
                .padding()
                .background(RoundedRectangle(cornerRadius:1).fill(Color.gray.opacity(0.5)))
            }
            .transition(.opacity)
            .zIndex(100) // Ensure it's above all other content
        }
        }
        .animation(.easeInOut(duration:0.2), value:self.trigger.isProgressOverlayOn)

    }   // End of func body(content:Content)->some View.

}   // End of struct ProgressOverlayModifier:ViewModifier.

extension View 
{

    func progressOverlay(trigger:ProgressOverlayTrigger)->some View 
    {

        self.modifier(ProgressOverlayModifier(trigger:trigger))

    }   // End of func progressOverlay(trigger:ProgressOverlayTrigger)->some View.

}   // End of extension View.

