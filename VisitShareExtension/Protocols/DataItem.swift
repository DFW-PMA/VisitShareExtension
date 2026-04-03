//
//  DataItem.swift
//  <<< App 'dependent' >>>
//
//  Modified by Daryl Cox on 03/16/2026 - v1.0201.
//  Created  by Daryl Cox on 06/26/2025 - v1.0101.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - DataItem Protocol (for individual data instances):
//
// Pure in-memory data item protocol. Does NOT require PersistentModel.
// Use DataItem for classes stored in memory only (dictionaries, arrays, etc.)
//     that are NOT inserted into a SwiftData ModelContext.
// Use PersistentDataItem (which inherits DataItem) for @Model classes
//     that ARE inserted into a SwiftData ModelContext.

protocol DataItem:Identifiable, Comparable where ID:CustomStringConvertible
{

    // Validation method...

    func validate() throws

    // Method to compare business equality (not reference equality)...

    func isLogicallyEqual(to other:Self)->Bool

    // Method to update properties from another instance...

    func update(from other:Self)
//  mutating func update(from other:Self)

    // Display the field(s) of the DataItem to the Log...

    func displayDataItemToLog()

}   // End of protocol DataItem:Identifiable, Comparable.

