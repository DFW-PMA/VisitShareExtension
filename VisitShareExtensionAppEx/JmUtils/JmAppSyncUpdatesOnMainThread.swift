//
//  JmAppSyncUpdatesOnMainThread.swift
//  JmUtils_Library
//
//  Created by Claude/Daryl Cox on 11/19/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

//  ===================
//  Invocation Examples:
//  ===================
//
//  // Basic Usage - clean and obvious...
//
//  jmAppSyncUpdateUIOnMainThread 
//  {
//      self.alertMessage = message
//      self.showingAlert = true
//  }
//
//  // Can update...
//
//  jmAppSyncReadUIOnMainThread 
//  {
//      self.value = newValue
//  }
//
//  // Can also read...
//
//  let currentValue = jmAppSyncReadUIOnMainThread
//  {
//      return self.someValue
//  }
//
//  // Can update AND return status...
//
//  let success = jmAppSyncReadUIOnMainThread
//  {
//      self.data = processedData
//
//      return true
//  }

import Foundation

// MARK: - 'Sync' Updates on Main Thread utilities - v1.0202:

// <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — @MainActor()->Void closure-type
// syntax with no space between the attribute and parameter list parsed leniently under Swift 5 but is a
// hard parse error under Swift 6 ("expected parameter type following ':'"). Fixed at all 3 sites in this
// file by adding ONLY the one mandatory space (between the attribute and the parameter list) — the
// arrow itself never needed surrounding spaces; see §2k-Swift6-Closures. This was a parser-strictness
// break, not a concurrency-semantics issue — no behavioral change.
@inlinable
func jmAppSyncUpdateUIOnMainThread(_ operation:@MainActor ()->Void)
{

    let fileName:String = #file
    let function:String = #function
    let line:Int        = #line

    // Synchronously update UI state on main thread...

    if (Thread.isMainThread)
    {
    //  appLogMsg("[\(fileName):\(function):\(line)] <JmUtils> <MainThread> - Updating UI on MainThread (already there)...")

        MainActor.assumeIsolated(operation)

    //  appLogMsg("[\(fileName):\(function):\(line)] <JmUtils> <MainThread> - Updated  UI on MainThread (already there)...")
    } 
    else 
    {
    //  appLogMsg("[\(fileName):\(function):\(line)] <JmUtils> <MainSync> - Syncing to MainThread...")

        DispatchQueue.main.sync 
        {
            MainActor.assumeIsolated(operation)
        }

    //  appLogMsg("[\(fileName):\(function):\(line)] <JmUtils> <MainSync> - Sync'd  to MainThread ...")
    }

}   // End of @inlinable func jmAppSyncUpdateUIOnMainThread(_ operation:@MainActor ()->Void).

@inlinable
func jmAppSyncUpdateUIOnMainThreadLogged(_ operation:@MainActor ()->Void,
                                          file:    String = #file,
                                          function:String = #function,
                                          line:    Int    = #line) 
{

    // Synchronously update UI state on main thread (with logging)...

    let fileName = (file as NSString).lastPathComponent
    
    if (Thread.isMainThread)
    {
    //  appLogMsg("[\(fileName):\(function):\(line)] <JmUtils> <MainThread> - Updating UI on MainThread (already there)...")

        MainActor.assumeIsolated(operation)

    //  appLogMsg("[\(fileName):\(function):\(line)] <JmUtils> <MainThread> - Updated  UI on MainThread (already there)...")
    } 
    else 
    {
    //  appLogMsg("[\(fileName):\(function):\(line)] <JmUtils> <MainSync> - Syncing to MainThread...")

        DispatchQueue.main.sync 
        {
            MainActor.assumeIsolated(operation)
        }

    //  appLogMsg("[\(fileName):\(function):\(line)] <JmUtils> <MainSync> - Sync'd  to MainThread ...")
    }

}   // End of @inlinable func jmAppSyncUpdateUIOnMainThreadLogged(_ operation:@MainActor ()->Void, file:String, function:String, line:Int),

// <<CHICKEN-TRACKS>> Swift 6 migration (Section 12, NWSNexRadRadarApp2) — flagged "type 'T' does not
// conform to the 'Sendable' protocol" (MainActor.assumeIsolated's generic return crossing back out
// to the nonisolated caller can't be proven safe for an unconstrained T). No actual callers of this
// function exist anywhere in the codebase (confirmed via grep), so Daryl chose the compiler's own
// suggested fix — adding 'T: Sendable' — over nonisolated(unsafe), since this is shared JmUtils
// infrastructure pushed to other PACK Apps via JMACodeSync and the constraint is the more honest,
// self-enforcing fix for whatever future callers show up there.
@inlinable
func jmAppSyncReadUIOnMainThread<T:Sendable>(_ operation:@MainActor ()->T)->T
{

    let fileName:String = #file
    let function:String = #function
    let line:Int        = #line

    // Synchronously read UI state from main thread...

    if Thread.isMainThread
    {
    //  appLogMsg("[\(fileName):\(function):\(line)] <JmUtils> <MainThread> - Updating UI on MainThread (already there)...")

        return MainActor.assumeIsolated(operation)
    }
    else
    {
    //  appLogMsg("[\(fileName):\(function):\(line)] <JmUtils> <MainSync> - Syncing to MainThread...")

        return DispatchQueue.main.sync
        {
            MainActor.assumeIsolated(operation)
        }
    }

}   // End of @inlinable func jmAppSyncReadUIOnMainThread<T>(_ operation:@MainActor ()->T)->T.

