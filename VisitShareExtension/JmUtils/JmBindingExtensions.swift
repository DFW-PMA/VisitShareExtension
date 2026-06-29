//
//  JmBindingExtensions.swift
//  JmUtils_Library
//
//  First version created by Daryl Cox on 03/07/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

// Extension class to add extra method(s) to Binding - v1.0501.

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

    // <<CHICKEN-TRACKS>> Swift 6 migration — Swift 6 rejects a generic parameter made strictly
    // equivalent to another via a same-type `where` clause ("makes generic parameters 'Wrapped' and
    // 'Value' equivalent"). Fix: drop the redundant generic parameter, use the outer `Value` directly
    // — behaviorally identical, no call-site changes needed (confirmed via grep — zero callers use
    // explicit generic syntax). Same fix as CinemaPack's JmBindingExtensions.swift (§12d).
    func asOptional() -> Binding<Value?>
    {
        return Binding<Value?> (
            get: { self.wrappedValue },
            set: { newValue in
                if let newValue = newValue {
                    self.wrappedValue = newValue
                }
            }
        )
    }

}   // End of extension Binding.

