//
//  AppSwiftDataModeler.swift
//  <<< App 'dependent' >>>
//
//  Created by Daryl Cox on 06/25/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import Foundation
import SwiftUI
import SwiftData

@JmEntityInfo(vers:"v1.1101")
final public class AppSwiftDataModeler
{
    
    class public func getSwiftDataModelTypes()->[any PersistentModel.Type]
    {

        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let listSwiftDataModelTypes:[any PersistentModel.Type] =
            [
        //   CoreLocationSiteTrackingItem.self,
        //   CLRequestGoodItem.self,
        //   StatusItemMenuItem.self,
        //   AlarmSwiftDataItem.self,
        //   Item.self,
            ]

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'listSwiftDataModelTypes' is [\(listSwiftDataModelTypes)]...")

        return listSwiftDataModelTypes
        
    }   // End of class public func getModelTypes()->[any PersistentModel.Type].

}   // End of final public class AppSwiftDataModeler.

