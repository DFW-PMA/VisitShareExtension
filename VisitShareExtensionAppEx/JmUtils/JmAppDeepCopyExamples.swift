//
//  JmAppDeepCopyExamples.swift
//  JmUtils_Library
//
//  Created by Daryl Cox on 09/09/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

//  > Run by calling: JmAppDeepCopyExamples.runExamples()

import Foundation

// MARK: - Usage Examples and Test Cases:

class JmAppDeepCopyExamples
{
    
    struct ClassInfo
    {
        static let sClsId        = "JmAppDeepCopyExamples"
        static let sClsVers      = "v1.0201"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = false
    }
    
    static func runExamples()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")
        
        // Perform 'dictionary' deep copies...
        
        appLogMsg("=== Deep Copy Utility Examples ===\n")
        
        // Example 1: Simple array of strings...
        
        let stringArray          = ["Hello", "World", "Swift"]
        
        if let copiedStringArray = JmAppDeepCopyUtility.deepCopy(stringArray)
        {
            appLogMsg("Original 'string' array:          [\(stringArray)]...")
            appLogMsg("Copied   'string' array:          [\(copiedStringArray)]...")
            appLogMsg("Are they the same reference?      [\(stringArray as NSArray === copiedStringArray as NSArray)]...")
        }
        
        // Example 2: Array of integers...
        
        let intArray:[Int]          = [1, 2, 3, 4, 5]
        
        if let copiedIntArray:[Int] = JmAppDeepCopyUtility.deepCopy(intArray)
        {
            appLogMsg("Original 'int' array:             [\(intArray)]...")
            appLogMsg("Copied   'int' array:             [\(copiedIntArray)]...")
            appLogMsg("Are they the same reference?      [\(intArray as NSArray === copiedIntArray as NSArray)]...")
        }
        
        // Example 3: Complex nested structure...
        
        let complexStructure:[String:Any] =
        [
            "name":    "John Doe",
            "age":     30,
            "scores":  [85, 90, 78, 92],
            "address": [
                "street":     "123 Main St",
                "city":       "Anytown",
                "coordinates":[40.7128, -74.0060]
                       ],
            "hobbies": ["reading", "swimming", "coding"],
            "metadata":[
                "nested":[
                    "deeply":[
                        "level":3,
                        "items":["a", "b", "c"]
                             ]
                         ]
                       ]
        ]
        
        if let copiedComplex = JmAppDeepCopyUtility.deepCopy(complexStructure)
        {
            appLogMsg("Original 'complex' structure:     [\(complexStructure)]...")
            appLogMsg("Copied   'complex' structure:     [\(copiedComplex)]...")
            appLogMsg("Are they the same reference?      [\(complexStructure as NSDictionary === copiedComplex as NSDictionary)]...")
        }
        
        // Example 4: Array of dictionaries...
        
        let arrayOfDicts:[[String:Any]] =
        [
            ["name":"Alice",   "age": 25, "skills":["Swift",      "iOS"]],
            ["name":"Bob",     "age": 30, "skills":["Python",     "Django"]],
            ["name":"Charlie", "age": 35, "skills":["JavaScript", "React"]]
        ]
        
        if let copiedArrayOfDicts = JmAppDeepCopyUtility.deepCopy(arrayOfDicts)
        {
            appLogMsg("Original 'array' of dictionaries: [\(arrayOfDicts)]...")
            appLogMsg("Copied   'array' of dictionaries: [\(copiedArrayOfDicts)]...")
            appLogMsg("Are they the same reference?      [\(arrayOfDicts as NSArray === copiedArrayOfDicts as NSArray)]...")
        }
        
        // Example 5: Deep copy on main thread (useful for SwiftUI)...
        
        DispatchQueue.global().async
        {
            let backgroundData    = ["background":"data", "processed":true]
            
            if let mainThreadCopy = JmAppDeepCopyUtility.deepCopy(backgroundData, onMainThread:true)
            {
                // This would be safe to use for SwiftUI updates...
                appLogMsg("Data original on 'main' thread:   [\(backgroundData)]...")
                appLogMsg("Data copied   on 'main' thread:   [\(mainThreadCopy)]...")
                appLogMsg("Are they the same reference?      [\(backgroundData as NSDictionary === mainThreadCopy as NSDictionary)]...")
            }
        }
        
        // Exit:
        
        appLogMsg("\(sCurrMethodDisp) Exiting...")
        
        return
        
    }   // End of static func runExamples().
    
}   // End of class JmAppDeepCopyExamples.

