//
//  ValidationError.swift
//  JSONSwiftDataDemoApp1
//
//  Created by Daryl Cox on 06/26/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Error Types:

enum ValidationError:Error, LocalizedError 
{

    case invalidID
    case invalidObjectId
    case invalidDateUpdated

    var errorDescription:String? 
    {

        switch self 
        {
        case .invalidID:          return "ID cannot be empty"
        case .invalidObjectId:    return "ObjectId cannot be empty"
        case .invalidDateUpdated: return "Date 'updated' is Invalid"
        }

    }

}   // End of enum ValidationError:Error, LocalizedError.

