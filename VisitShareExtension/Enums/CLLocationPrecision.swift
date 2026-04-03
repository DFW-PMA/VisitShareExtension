//
//  CLLocationPrecision.swift
//  <<< App 'dependent' >>>
//
//  Created by Daryl Cox on 08/08/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Error Types:

enum CLLocationPrecision:String, CaseIterable, Hashable
{
    
    case useLatLong4 = "UsingLatLong4"
    case useLatLong5 = "UsingLatLong5"
    
}   // End of enum CLLocationPrecision(String, CaseIterable).

