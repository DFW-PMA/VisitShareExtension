//
//  AutoDismissAlertCustomizableModifier.swift
//  JustAMenuBarApp2
//
//  Created by Daryl Cox on 07/23/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

// Reusable and customizable Auto 'dismiss' Alert modifier:

// MARK: - Advanced Version with Customization:

struct AutoDismissAlertCustomizableModifier:ViewModifier 
{

    struct ClassInfo
    {
        static let sClsId        = "AutoDismissAlertCustomizableModifier"
        static let sClsVers      = "v1.0201"
        static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // 'Internal' Trace flag:

//  private
    var bInternalTraceFlag:Bool  = false

    // App Data field(s):

    @Binding var isPresented:Bool

             let title:String
             let message:String
             let duration:TimeInterval
             let backgroundColor:Color 
             let textColor:Color
             let cornerRadius:CGFloat

    func body(content:Content)->some View 
    {

        let _ = appLogMsg("<ContentLoading> AutoDismissAlertCustomizableModifier:ViewModifier - 'isPresented' is [\(isPresented)] - 'title' is [\(title)] - 'message' is [\(message)] - launching the 'overlay'...")

        content
            .overlay(
                Group 
                {
                    if isPresented 
                    {
                        // Use Group instead of ZStack for better overlay behavior...
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                            .overlay(
                                // Alert positioned in center...
                                VStack(spacing:4)
                                {
                                    Text(title)
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(textColor)
                                        .multilineTextAlignment(.center)
                                    Text(message)
                                        .font(.footnote)
                                        .foregroundColor(textColor)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal:false, vertical:true)
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 10)
                                .background(backgroundColor)
                                .cornerRadius(cornerRadius)
                                .shadow(color:Color.black.opacity(0.15), radius:8, x:0, y:2)
                                .frame(maxWidth:320)  // Maximum width constraint
                                .scaleEffect(isPresented ? 1.0 : 0.9)
                                .opacity(isPresented ? 1.0 : 0.0)
                                .animation(.spring(response:0.4, dampingFraction:0.8), value:isPresented))
                    }
                }
            )
            .onChange(of:isPresented)
            { newValue in

                if newValue 
                {
                    DispatchQueue.main.asyncAfter(deadline:(.now() + duration))
                    {
                        withAnimation(.easeOut(duration:0.3)) 
                        {
                            isPresented = false
                        }
                    }
                }

            }

    }   // End of func body(content:Content)->some View.

}   // End of struct AutoDismissAlertCustomizableModifier:ViewModifier.

// MARK: - Extended View Extension with Customization:

extension View 
{

    func customAutoDismissAlert(isPresented:Binding<Bool>,
                                title:String,
                                message:String,
                                duration:TimeInterval = 3.0,
                                backgroundColor:Color = .white,
                                textColor:Color = .primary,
                                cornerRadius:CGFloat = 12)->some View 
    {

        modifier(AutoDismissAlertCustomizableModifier(isPresented:isPresented,
                                                      title:title,
                                                      message:message,
                                                      duration:duration,
                                                      backgroundColor:backgroundColor,
                                                      textColor:textColor,
                                                      cornerRadius:cornerRadius))

    }   // End of func customAutoDismissAlert(...).

}   // End of extension View.

