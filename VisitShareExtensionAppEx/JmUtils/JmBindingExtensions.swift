//
//  JmBindingExtensions.swift
//  JmUtils_Library
//
//  First version created by Daryl Cox on 03/07/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

// Extension class to add extra method(s) to Binding - v1.0401.

extension Binding 
{
    // Method 1: Using unwrapped with default value:

    func unwrappedOrDefault<T>(_ defaultValue: T)->Binding<T> where Value == T? 
    {
        Binding<T> 
        {
            self.wrappedValue ?? defaultValue
        } 
        set: 
        { newValue in
            self.wrappedValue = newValue
        }
    }
    
    // Method 1: Optional Projection:

    func asOptional<Wrapped>() -> Binding<Wrapped?> where Value == Wrapped
    {
        return Binding<Wrapped?> (
            get: { self.wrappedValue },
            set: { newValue in
                if let newValue = newValue {
                    self.wrappedValue = newValue
                }
            }
        )
    }

}   // End of extension Binding.

