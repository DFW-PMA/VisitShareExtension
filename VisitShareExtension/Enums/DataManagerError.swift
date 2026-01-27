//
//  DataManagerError.swift
//  JSONSwiftDataDemoApp1
//
//  Created by Daryl Cox on 06/26/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Error Types:

enum DataManagerError:Error, LocalizedError 
{

    case invalidModelContext
    case unsupportedOperation(String)

    var errorDescription:String? 
    {
        switch self 
        {
        case .invalidModelContext:               return "SwiftData modelContext is Invalid"
        case .unsupportedOperation(let message): return message
        }
    }

}   // End of enum DataManagerError:Error, LocalizedError.


