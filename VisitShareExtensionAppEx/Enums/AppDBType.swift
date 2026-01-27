//
//  AppDBType.swift
//  UrlFetcherWithJsonApp2
//
//  Created by Daryl Cox on 07/09/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - App DB Types:

enum AppDBType:String, CaseIterable, Hashable
{

    case dbUndefined = "Undefined"
    case dbSQL       = "SQL"
    case dbMongo     = "Mongo"

}   // End of AppDBType:String, CaseIterable, Hashable.

