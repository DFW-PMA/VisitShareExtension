//
//  PersistentDataItem.swift
//  <<< App 'dependent' >>>
//
//  Modified by Claude/Daryl Cox on 03/17/2026 - v1.0201.
//  Created  by Claude/Daryl Cox on 03/16/2026 - v1.0101.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

// Retroactive conformance required for iOS 26+:
// @Model now synthesizes 'id: PersistentIdentifier' as the Identifiable witness,
// but DataItem constrains 'ID: CustomStringConvertible'. This bridges the gap.

extension PersistentIdentifier:@retroactive CustomStringConvertible
{
    public var description:String
    {
        return "\(self.entityName)-\(self.hashValue)"
    }
}

// MARK:- PersistentDataItem Protocol (for DataItem instances backed by SwiftData):
//
// Use this protocol ONLY for @Model classes that ARE inserted into a SwiftData ModelContext.
// Adds PersistentModel conformance and FetchDescriptor support on top of DataItem.
//
// For in-memory-only data classes (stored in dictionaries or arrays, never in a ModelContext),
// use DataItem directly and do NOT use @Model.
//
// Example - a SwiftData-backed class:
//
//     @Model
//     final class MyPersistedItem:PersistentDataItem
//     {
//         ...
//         static func fetchDescriptorForLogicalEquality(to item:MyPersistedItem)->FetchDescriptor<MyPersistedItem>
//         {
//             var fd = FetchDescriptor<MyPersistedItem>()
//             let targetId = item.id
//             fd.predicate = #Predicate<MyPersistedItem> { $0.id == targetId }
//             return fd
//         }
//     }

protocol PersistentDataItem:DataItem, PersistentModel
{

    // Method to create a fetch descriptor for logical equality...
    // Required only for persisted (@Model) classes with a ModelContext.

    static func fetchDescriptorForLogicalEquality(to item:Self)->FetchDescriptor<Self>

}   // End of protocol PersistentDataItem:DataItem, PersistentModel.

