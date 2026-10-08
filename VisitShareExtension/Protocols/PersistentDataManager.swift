//
//  PersistentDataManager.swift
//  <<< App 'dependent' >>>
//
//  Created by Daryl Cox on 06/11/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - PersistenceBackend Enum
//
// Declares which storage backend a given persistent type uses.
// The config map in AppPersistentDataModeler drives the routing —
// flip one entry there to migrate a type; no other code changes required.

// <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — flagged SENDABLE on
// AppPersistentDataModeler.dictPersistenceBackend ("non-Sendable type '[String:PersistenceBackend]'
// may have shared mutable state"). Swift 6 does not implicitly infer Sendable for 'public'-or-higher
// types (only internal/private types get the automatic inference) — explicit conformance is
// required even for a trivial no-associated-values enum like this one. Safe unconditionally.
public enum PersistenceBackend:Sendable
{

    case swiftData
    case json
    // <<STUB v1>> Future backends added here as comments until needed
    // case coreData  — explicitly ruled out (old tech)

}   // End of enum PersistenceBackend.

// MARK: - PersistentDataManager Protocol (Codable-based, backend-agnostic):
//
// Defines the cross-backend persistence contract used by AppPersistentDataManager.
// Phase 2: AppSwiftDataManager conforms via adapter shims.
// Future:  AppJsonDataManager implements this directly (target end state).
// Callers above AppDataItemsRepo never reference backends directly —
// they go through AppPersistentDataManager only.

protocol PersistentDataManager
{

    func load<T:Codable>(_ type:T.Type) async throws -> [T]
    func save<T:Codable>(_ items:[T])   async throws
    func upsert<T:Codable>(_ item:T)   async throws
    func delete<T:Codable>(_ item:T)   async throws

}   // End of protocol PersistentDataManager.

// MARK: - JsonDataItem Protocol (Codable + stable UUID identity):
//
// Constraint used by AppJsonDataManager. All types that migrate to the JSON backend
// must conform to this protocol. Conformance is added per type in migration order
// (see CLAUDE.md Section 10e). The UUID id is required so upsert/delete can locate
// the correct record on disk without a full-array equality scan.
//
// <<CHICKEN-TRACKS>> Added for Section 10 work (AppJsonDataManager session).

protocol JsonDataItem: Codable
{

    var id: UUID { get }

}   // End of protocol JsonDataItem.

// MARK: - JsonNaturalKeyItem Protocol (optional 'natural key' de-dup for JSON-backed types):
//
// <<CHICKEN-TRACKS>> (2026-09-23) — JsonDataItem's UUID 'id' is the DEFAULT upsert/de-dup identity, but
// some types are rebuilt with a brand-new UUID every time they are re-created from their source (e.g.
// ParsePFTherapistFileItem is re-built from Sashido on every launch, so upsert-by-'id' APPENDED a new
// row per therapist per launch - #(2745) -> #(2811) -> #(2877) rows for #(66) real therapists). A type
// that conforms to JsonNaturalKeyItem supplies a 'naturalKey' (e.g. the TID); AppJsonDataManager then
// upserts/de-dups by that key instead of by 'id'. Types that do NOT conform are unaffected.
// The key must be unique per logical record and stable across rebuilds.

protocol JsonNaturalKeyItem: JsonDataItem
{

    var naturalKey: AnyHashable { get }

}   // End of protocol JsonNaturalKeyItem.
