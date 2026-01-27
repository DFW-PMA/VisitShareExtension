//
//  SwiftDataManager.swift
//  JmUtils_Library
//
//  Created by Daryl Cox on 06/26/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - SwiftData Manager Protocol (extends DataManager for SwiftData-specific operations):

protocol SwiftDataManager:DataItemRepo
{

    var modelContext:ModelContext?
    { get }

    // SwiftData-specific upsert for PersistentModel...

    func upsertPersistentModel<T:PersistentModel & DataItem>(_ item:T) async throws

    // SwiftData-specific fetch with predicates...

    func fetchPersistentModels<T:PersistentModel & DataItem>(predicate:Predicate<T>?, sortBy:[SortDescriptor<T>]) async throws->[T]

    // SwiftData-specific delete with IndexSet offsets...

    func deletePersistentModels<T:PersistentModel & DataItem>(from items:[T], at offsets:IndexSet) async throws->[T]

    // SwiftData-specific delete for PersistentModel...

    func deletePersistentModel<T:PersistentModel & DataItem>(_ item:T) async throws

    // Reacquire (set) the storage for a PersistentModel...

    func reacquireStoragePersistentModels<T:DataItem>(from items:[T])

}   // End of protocol SwiftDataManager:DataManager.

