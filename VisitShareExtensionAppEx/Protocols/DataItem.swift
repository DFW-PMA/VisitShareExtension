//
//  DataItem.swift
//  JmUtils_Library
//
//  Created by Daryl Cox on 06/26/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - DataItem Protocol (for individual data instances):

protocol DataItem:Identifiable, Comparable, PersistentModel where ID:CustomStringConvertible
{

    // Validation method...

    func validate() throws

    // Method to compare business equality (not reference equality)...

    func isLogicallyEqual(to other:Self)->Bool

    // Method to update properties from another instance...

    func update(from other:Self)
//  mutating func update(from other:Self)

    // Method to create a fetch descriptor for logical equality...

    static func fetchDescriptorForLogicalEquality(to item:Self)->FetchDescriptor<Self>

    // Display the field(s) of the DataItem to the Log...

    func displayDataItemToLog()

}   // End of protocol DataItem:Identifiable, Codable.

