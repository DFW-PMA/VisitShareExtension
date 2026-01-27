//
//  DataItemRepo.swift
//  JmUtils_Library
//
//  Created by Daryl Cox on 06/26/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - DataItemRepo Protocol (a repo <repository> of collections of DataItems):

protocol DataItemRepo 
{

    // Generic comparison with custom comparator...

    func areEqual<T>(_ lhs:T, _ rhs:T, using comparator:(T, T)->Bool)->Bool

    // Generic fetch method (returns a list of item(s))...

    func fetch<T:DataItem>() async throws->[T]

    // Generic fetch by ID...

    func fetch<T:DataItem>(byId id:T.ID) async throws->T?

    // Generic save method...

    func save<T:DataItem>(_ item:T) async throws

    // Generic batch operations...

    func saveBatch<T:DataItem>(_ items:[T]) async throws

    // Generic upsert method...

    func upsert<T:DataItem>(_ item:T) async throws

    // Generic delete method...

    func delete<T:DataItem>(_ item:T) async throws

    // Generic delete method with IndexSet offsets...

    func delete<T:DataItem>(from items:[T], at offsets:IndexSet) async throws->[T]

    // Generic transform method...

    func transform<Input, Output>(_ input:Input, using transformer:(Input)->Output)->Output

    // Display the item(s) of the Repo to the Log...

    func displayDataItemsToLog()

//  // Retrieve the storage for a given Type...
//  // NOTE: Do NOT use SortDescriptor(s) - these are unstable in runtime...
//
//  func retrieveStorage<T:DataItem>(sortBy:[SortDescriptor<T>])->[T]

    // Retrieve the storage for a given Type...
    // NOTE: Use a 'comparson' closure for sort and NOT SortDescriptor(s)...

    func retrieveStorage<T:DataItem>(by comparison:((T, T)->Bool)?)->[T]

//  // Retrieve the storage for a given Key (aka, Type.self)...
//  // NOTE: Do NOT use SortDescriptor(s) - these are unstable in runtime...
//
//  func retrieveStorage(for sTypeKey:String, sortBy:[SortDescriptor<Any>])->[Any]

    // Retrieve the storage for a given Key (aka, Type.self)...
    // NOTE: Use a 'comparson' closure for sort and NOT SortDescriptor(s)...
    
    func retrieveStorage<T>(for sTypeKey:String, by comparison:((T, T)->Bool)?)->[T] where T:Comparable

    // Reacquire (set) the storage for a given Type...

    func reacquireStorage<T:DataItem>(from items:[T])

    // Reacquire (set) the storage for a given Type...

    func reacquireStorage(for sTypeKey:String, from items:[Any])

}   // End of protocol DataItemRepo.

