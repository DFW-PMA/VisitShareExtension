//
//  AppPersistentDataModeler.swift
//  <<< App 'dependent' >>>
//
//  Created by Daryl Cox on 06/11/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import Foundation
import SwiftUI
import SwiftData

// <<CHICKEN-TRACKS>> Replaces AppSwiftDataModeler as the per-type persistence registry.
// AppSwiftDataModeler remains untouched until AppSwiftDataManager migrates in Phase 2.
// Once Phase 2 is complete, AppSwiftDataManager will call this class instead of AppSwiftDataModeler.

@JmEntityInfo(vers:"v1.0601")
final public class AppPersistentDataModeler
{

    //  struct ClassInfo
    //  {
        //  static let sClsId        = "AppPersistentDataModeler"
        //  static let sClsVers      = "v1.0203"
        //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
        //  static let sClsCopyRight = "Copyright (C) JustMacApps 2024-2026. All Rights Reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    // Per-type backend config map.
    // One entry per persistent type. Change a value here to flip that type's backend.
    // No other code changes required to migrate a type.
    // <<CHICKEN-TRACKS>> All types start on .swiftData. Entries will flip to .json
    //                    as each type completes its JSON migration (separate sessions).

    static let dictPersistenceBackend:[String:PersistenceBackend] =
        [
            :
        // <<CHICKEN-TRACKS>> Flipped to .json (v1.0203) — ParsePFTherapistFileItem migrated to JSON backend.
        //                    Bootstrap export confirmed good (1876 items, 2026-06-16).
        //  "CoreLocationSiteTrackingItem" : .swiftData,
        //  "CLRequestGoodItem"            : .swiftData,
        //  "CoreLocationSiteTrackingItem" : .json,
        //  "CLRequestGoodItem"            : .json,
        // <<CHICKEN-TRACKS>> Flipped to .json (v1.0202) — ParsePFTherapistFileItem migrated to JSON backend.
        //                    Bootstrap export confirmed good (63 items, 2026-06-16).
        //  "ParsePFTherapistFileItem"     : .swiftData,
        //  "ParsePFTherapistFileItem"     : .json,
        // <<CHICKEN-TRACKS>> Flipped to .json (v1.0201) — DataItemDBQuery migrated to JSON backend.
        //                    Bootstrap export confirmed good (3 items, 2026-06-16).
        //  "DataItemDBQuery"              : .json,
        // <<CHICKEN-TRACKS>> AlarmDataItem added (v1.0401, Phase 2, 2026-06-23) — JSON-only from day
        //                    one, never SwiftData. Separate from AlarmSwiftDataItem/JmAppSwiftDataManager,
        //                    which are intentionally left untouched per Daryl's instruction.
        //  "AlarmDataItem"                : .json,
        // <<STUB v1>> JSON-backed type entries added here as migration proceeds
        ]

    // Returns the persistence backend for a given type name.

    class public func getPersistenceBackend(for sTypeName:String) -> PersistenceBackend
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked - 'sTypeName' is [\(sTypeName)]...")

        let persistenceBackend:PersistenceBackend = dictPersistenceBackend[sTypeName] ?? .json

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'persistenceBackend' is [\(persistenceBackend)] for type [\(sTypeName)]...")

        return persistenceBackend

    }   // End of class public func getPersistenceBackend(for sTypeName:String)->PersistenceBackend.

    // Returns the SwiftData PersistentModel types for ModelSchema / ModelContainer initialization.
    // <<CHICKEN-TRACKS>> Explicit type list kept in sync with .swiftData entries in dictPersistenceBackend.
    //                    Not yet wired into AppSwiftDataManager — that swap happens in Phase 2.
    //                    AppSwiftDataModeler.getSwiftDataModelTypes() remains the active call until then.

    class public func getSwiftDataModelTypes() -> [any PersistentModel.Type]
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let listSwiftDataModelTypes:[any PersistentModel.Type] =
            [
            //  CoreLocationSiteTrackingItem.self,
            //  CLRequestGoodItem.self,
            //  ParsePFTherapistFileItem.self,
            //  DataItemDBQuery.self,
            ]

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'listSwiftDataModelTypes' is [\(listSwiftDataModelTypes)]...")

        return listSwiftDataModelTypes

    }   // End of class public func getSwiftDataModelTypes()->[any PersistentModel.Type].

    // Returns the type name strings for all JSON-backed types.
    // Used during AppJsonDataManager initialization (future session).
    // <<STUB v1>> Returns empty until first type flips to .json in dictPersistenceBackend.

    class public func getJsonModelTypeNames() -> [String]
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let listJsonTypeNames:[String] = dictPersistenceBackend
            .filter  { $0.value == .json }
            .map     { $0.key }

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'listJsonTypeNames' is [\(listJsonTypeNames)]...")

        return listJsonTypeNames

    }   // End of class public func getJsonModelTypeNames()->[String].

}   // End of final public class AppPersistentDataModeler.
