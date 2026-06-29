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

@JmEntityInfo(vers:"v1.0601")
final public class AppSwiftDataModeler
{
    
    //  struct ClassInfo
    //  {
        //  static let sClsId        = "AppSwiftDataModeler"
        //  static let sClsVers      = "v1.0501"
        //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
        //  static let sClsCopyRight = "Copyright (C) JustMacApps 2024-2026. All Rights Reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    class public func getSwiftDataModelTypes()->[any PersistentModel.Type]
    {

        //  let sCurrMethod:String = #function
        //  let sCurrMethodDisp    = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let listSwiftDataModelTypes:[any PersistentModel.Type] =
            [
        //   AlarmSwiftDataItem.self,
            ]

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting - 'listSwiftDataModelTypes' is [\(listSwiftDataModelTypes)]...")

        return listSwiftDataModelTypes
        
    }   // End of class public func getModelTypes()->[any PersistentModel.Type].

}   // End of final public class AppSwiftDataModeler.

