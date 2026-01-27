//
//  JmAppDeepCopyUtility.swift
//  JmUtils_Library
//
//  Created by Daryl Cox on 09/09/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation

// MARK: - Deep Copy Protocol:

// Protocol for objects that can create deep copies of themselves.
// Implement this protocol in any class that needs deep copy support.
//
// Example implementation in your class:
//
//     extension ScheduledPatientLocationItem: JmAppDeepCopyProtocol
//     {
//         func createDeepCopy() -> Any
//         {
//             return ScheduledPatientLocationItem(bDeepCopyIsAnOverlay:         false,
//                                                sSchedPatLocHasBeenAppliedTag: "JmAppDeepCopyProtocol",
//                                                scheduledPatientLocationItem:  self)
//         }
//     }

protocol JmAppDeepCopyProtocol
{

    // Create and return a deep copy of this object...

    func createDeepCopy()->Any

}

// MARK: 'Deep' Copy Class:

class JmAppDeepCopyUtility
{
    
    struct ClassInfo
    {
        static let sClsId        = "JmAppDeepCopyUtility"
        static let sClsVers      = "v1.1703"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = false
    }

    // App static 'global' field(s):

    private static let bInternalTraceFlag:Bool = false
    
    // MARK: - Type Detection Method (Enhanced version of your original):
    
    private static func getMetaTypeStringForObject(object:Any)->String
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'object' is [\(object)]...")
        }
        
        // Determine the 'meta' Type of the supplied object...
        
        var sValueTypeOf:String = "-undefined-"
        
        switch object
        {
        case is Int:
            sValueTypeOf = "Int"
        case is Double:
            sValueTypeOf = "Double"
        case is Float:
            sValueTypeOf = "Float"
        case is Bool:
            sValueTypeOf = "Bool"
        case is String:
            sValueTypeOf = "String"
        case is NSArray, is [Any]:
            sValueTypeOf = "List"
        case is NSDictionary, is Dictionary<AnyHashable, Any>:
            sValueTypeOf = "Dictionary"
        case is NSNull:
            sValueTypeOf = "Null"
        default:
            sValueTypeOf = "-unmatched-"
        }
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Supplied object is 'typeOf' [\(String(describing:type(of:object)))]/[\(sValueTypeOf)]...")
        }
        
        // Exit:
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Exiting - 'sValueTypeOf' is [\(sValueTypeOf)]...")
        }
        
        return sValueTypeOf
        
    }   // End of private static func getMetaTypeStringForObject(object:Any)->String.
    
    // MARK: - Generic Deep Copy Method:
    
    static func deepCopy<T>(_ object:T, targetObject:inout T?, onMainThread:Bool = false)->T?
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'object' is [\(object)] - 'targetObject' is [\(String(describing: targetObject))] - 'onMainThread' is [\(onMainThread)]...")
        }
        
        // Always perform the deep copy to a local variable first...
        
        let localCopy = performDeepCopy(object)
        
        // Now handle the assignment to the 'inout' parameter based on threading requirements...
        
        if (targetObject != nil)
        {
            if (onMainThread == true)
            {
                DispatchQueue.main.sync
                {
                    targetObject = localCopy
                    
                    if (bInternalTraceFlag == true)
                    {
                        appLogMsg("\(sCurrMethodDisp) Intermediate - 'localCopy' of [\(String(describing: localCopy))] copied to 'targetObject' of [\(String(describing: targetObject))] on the 'main' Thread...")
                    }
                }
            }
            else
            {
                targetObject = localCopy
                
                if (bInternalTraceFlag == true)
                {
                    appLogMsg("\(sCurrMethodDisp) Intermediate - 'localCopy' of [\(String(describing: localCopy))] copied to 'targetObject' of [\(String(describing: targetObject))] on the 'current' Thread...")
                }
            }
        }
        
        // Exit:
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Exiting - 'localCopy' is [\(String(describing: localCopy))]...")
        }
        
        return localCopy
        
    }   // End of static func deepCopy<T>(_ object:T, targetObject:inout T?, onMainThread:Bool = false)->T?.
    
    // MARK: - Core Deep Copy Implementation:
    
    private static func performDeepCopy<T>(_ object:T)->T?
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'object' is [\(object)]...")
        }
        
        // Always perform the deep copy to a local variable and return it...
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Intermediate - Starting deep copy of 'object' of [\(object)]...")
        }
        
        let deepCopyAnyAsT = deepCopyAny(object) as? T
        
        // Exit:
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Exiting - 'deepCopyAnyAsT' is [\(String(describing: deepCopyAnyAsT))]...")
        }
        
        return deepCopyAnyAsT
        
    }   // End of private static func performDeepCopy<T>(_ object:T)->T?.
    
    // MARK: - Recursive Deep Copy for Any Type:
    
    private static func deepCopyAny(_ object:Any)->Any
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'object' is [\(object)]...")
        }
        
        // Always perform the deep copy to a local variable and return it...
        
        let typeString = getMetaTypeStringForObject(object:object)
        
        switch typeString
        {
        case "Int", "Double", "Float", "Bool", "String":
            // Value types are copied by default in Swift...
            return object
        case "List":
            return deepCopyArray(object)
        case "Dictionary":
            return deepCopyDictionary(object)
        case "Null":
            return NSNull()
        default:
            // For custom objects, try to use NSCopying if available...

            if let copyable = object as? NSCopying
            {
                return copyable.copy()
            }

            // NSCopying did NOT work - check if object implements JmAppDeepCopyProtocol:
            
            if let deepCopyableObject = object as? JmAppDeepCopyProtocol
            {
                if (bInternalTraceFlag == true)
                {
                    appLogMsg("\(sCurrMethodDisp) Object conforms to JmAppDeepCopyProtocol - calling 'createDeepCopy()'...")
                }
                
                return deepCopyableObject.createDeepCopy()
            }

            // For other objects, return as-is (reference copy)
            // You might want to add custom handling here for specific types...

            appLogMsg("\(sCurrMethodDisp) Warning::Performing 'shallow' copy for unmatched type:[\(type(of:object))] - simply returning the object...")

            return object
        }
        
    }   // End of private static func deepCopyAny(_ object:Any)->Any.
    
    // MARK: - Array Deep Copy:
    
    private static func deepCopyArray(_ object:Any)->Any
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'object' is [\(object)]...")
        }
        
        // Perform 'array' deep copies:
        
        // Handle NSArray...
        
        if let nsArray = object as? NSArray
        {
            let mutableCopy = NSMutableArray(capacity:nsArray.count)
            
            for item in nsArray
            {
                let copiedItem = deepCopyAny(item)
                
                mutableCopy.add(copiedItem)
            }
            
            return mutableCopy.copy()
        }
        
        // Handle Swift Arrays...
        
        if let array = object as? [Any]
        {
            return array.map { deepCopyAny($0) }
        }
        
        // Handle typed arrays by converting to [Any] first...
        
        let mirror = Mirror(reflecting:object)
        
        if mirror.displayStyle == .collection
        {
            var copiedArray:[Any] = [Any]()
            
            for (_, value) in mirror.children
            {
                copiedArray.append(deepCopyAny(value))
            }
            
            return copiedArray
        }
        
        // Exit:
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Exiting - 'deep' Copy failed - returning original 'object' of [\(object)]...")
        }
        
        return object
        
    }   // End of private static func deepCopyArray(_ object:Any)->Any.
    
    // MARK: - Dictionary Deep Copy:
    
    private static func deepCopyDictionary(_ object:Any)->Any
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'object' is [\(object)]...")
        }
        
        // Perform 'dictionary' deep copies:
        
        // Handle NSDictionary...
        
        if let nsDict = object as? NSDictionary
        {
            let mutableCopy = NSMutableDictionary(capacity:nsDict.count)
            
            for (key, value) in nsDict
            {
                let copiedKey   = deepCopyAny(key)
                let copiedValue = deepCopyAny(value)
                
                mutableCopy.setObject(copiedValue, forKey:copiedKey as! NSCopying)
            }
            
            return mutableCopy.copy()
        }
        
        // Handle Swift Dictionary...
        
        if let dict = object as? Dictionary<AnyHashable, Any>
        {
            var copiedDict:Dictionary<AnyHashable,Any> = [:]
            
            for (key, value) in dict
            {
                let copiedKey   = deepCopyAny(key) as! AnyHashable
                let copiedValue = deepCopyAny(value)
                
                copiedDict[copiedKey] = copiedValue
            }
            
            return copiedDict
        }
        
        
        // Exit:
        
        if (bInternalTraceFlag == true)
        {
            appLogMsg("\(sCurrMethodDisp) Exiting - 'deep' Copy failed - returning original 'object' of [\(object)]...")
        }
        
        return object
        
    }   // End of private static func deepCopyDictionary(_ object:Any)->Any.
    
    // MARK: - Convenience Methods for Common Types
    
    // Deep copy an array of strings:
    
    static func deepCopy(_ array:[String], onMainThread:Bool = false)->[String]?
    {
     
        var dummyArray:[Any]? = [Any]()
        
        return deepCopy(array as [Any], targetObject:&dummyArray, onMainThread: onMainThread) as? [String]
        
    }   // End of static func deepCopy(_ array:[String], onMainThread:Bool = false)->[String]?.
    
    //  [[String:Any]]
    
    static func deepCopy(_ array:[[String:Any]], onMainThread:Bool = false)->[[String:Any]]?
    {
        
        var dummyArrayOfDict:[[String:Any]]? = [[String:Any]]()
        
        return deepCopy(array as [[String:Any]], targetObject:&dummyArrayOfDict, onMainThread: onMainThread)
        
    }   // End of static func deepCopy(_ array:[[String:Any]], onMainThread:Bool = false)->[[String:Any]]?.
    
    // Deep copy an array of integers:
    
    static func deepCopy(_ array:[Int], onMainThread:Bool = false)->[Int]?
    {
        
        var dummyArray:[Any]? = [Any]()
        
        return deepCopy(array as [Any], targetObject:&dummyArray, onMainThread:onMainThread) as? [Int]
        
    }   // End of static func deepCopy(_ array:[Int], onMainThread:Bool = false)->[Int]?.
    
    //  [[Int:Any]]
    
    static func deepCopy(_ array:[[Int:Any]], onMainThread:Bool = false)->[[Int:Any]]?
    {
        
        var dummyArrayOfDict:[[Int:Any]]? = [[Int:Any]]()
        
        return deepCopy(array as [[Int:Any]], targetObject:&dummyArrayOfDict, onMainThread: onMainThread)
        
    }   // End of static func deepCopy(_ array:[[Int:Any]], onMainThread:Bool = false)->[[Int:Any]]?.
    
    static func deepCopy(_ array:[Any], onMainThread:Bool = false)->[Any]?
    {
        
        var dummyArray:[Any]? = [Any]()
        
        return deepCopy(array as [Any], targetObject:&dummyArray, onMainThread: onMainThread)
        
    }   // End of static func deepCopy(_ array:[Any], onMainThread:Bool = false)->[Any]?.
    
    // Deep copy a dictionary with string keys:
    
    static func deepCopy(_ dict:[String:Any], onMainThread:Bool = false)->[String:Any]?
    {
        
        var dummyDict:[AnyHashable:Any]? = [String:Any]()
        
        return deepCopy(dict as Dictionary<AnyHashable,Any>, targetObject:&dummyDict, onMainThread:onMainThread) as? [String:Any]
        
    }   // End of static func deepCopy(_ dict:[String:Any], onMainThread:Bool = false)->[String:Any]?.
    
    /// Deep copy a dictionary with integer keys:
    
    static func deepCopy(_ dict:[Int:Any], onMainThread:Bool = false)->[Int:Any]?
    {
        
        var dummyDict:[AnyHashable:Any]? = [String:Any]()
        
        return deepCopy(dict as Dictionary<AnyHashable,Any>, targetObject:&dummyDict, onMainThread:onMainThread) as? [Int:Any]
        
    }   // End of static func deepCopy(_ dict:[Int:Any], onMainThread:Bool = false)->[Int:Any]?.
    
}   // End of class JmAppDeepCopyUtility.

// MARK: - SwiftUI Integration Helper:

#if canImport(SwiftUI)
import SwiftUI

extension JmAppDeepCopyUtility
{
    
    // Convenience method for SwiftUI - always assigns on main thread...
    
    static func deepCopyForSwiftUI<T>(_ object:T, targetObject:inout T?)->T?
    {
        
        return deepCopy(object, targetObject:&targetObject, onMainThread:true)
        
    }   // End of static func deepCopyForSwiftUI<T>(_ object:T, targetObject:inout T?)->T?.
    
    // Add this overload for non-optional targets...

    static func deepCopyForSwiftUI<T>(_ object:T, targetObject:inout T)->T?
    {

        var optionalTarget:T? = targetObject
        let result            = deepCopy(object, targetObject:&optionalTarget, onMainThread:false)
    
        // Only the assignment to the non-optional targetObject needs main thread...
        
        if let unwrapped = optionalTarget
        {
            jmAppSyncUpdateUIOnMainThread
            {
                targetObject = unwrapped
            }
        }

    //  if let unwrapped = optionalTarget 
    //  {
    //      if Thread.isMainThread 
    //      {
    //          // Already on main thread, assign directly...
    //
    //          targetObject = unwrapped
    //      } 
    //      else 
    //      {
    //          // On background thread, sync to main...
    //
    //          DispatchQueue.main.sync 
    //          {
    //              targetObject = unwrapped
    //          }
    //      }
    //  }
    
        return result

    }   // End of static func deepCopyForSwiftUI<T>(_ object:T, targetObject:inout T)->T?.

}   // End of extension JmAppDeepCopyUtility.
#endif

