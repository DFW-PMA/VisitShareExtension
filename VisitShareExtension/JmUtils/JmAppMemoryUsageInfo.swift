//
//  JmAppMemoryUsageInfo.swift
//  CinemaPack
//
//  Created by Claude/Daryl Cox on 03/12/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import Darwin

// MARK:- JmAppMemoryUsageInfo (Codable struct for App 'memory' usage info)

struct JmAppMemoryUsageInfo:Codable
{

    struct ClassInfo
    {
        static let sClsId        = "JmAppMemoryUsageInfo"
        static let sClsVers      = "v1.0201"
        static let sClsDisp      = sClsId+".("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = true
    }

    // App Data field(s):

    static let dValueOfOneMB:Double = 1_048_576.0

    static func getAppMemoryCurrentUsageInMB()->Double
    {

        var info   = task_vm_info_data_t()
        var count  = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4

        let result = withUnsafeMutablePointer(to:&info)
        {
            $0.withMemoryRebound(to:integer_t.self, capacity:1)
            {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS
        else { return 0.0 }

        return (Double(info.phys_footprint) / dValueOfOneMB)                        // bytes → MB...

    }
    
    static func getAppMemoryLimitInMB()->Double
    {

        return (Double(ProcessInfo.processInfo.physicalMemory) / dValueOfOneMB)     // bytes → MB...

    }

    static func getAppMemoryCurrentFreeInMB()->Double
    {

    #if os(iOS)
        return (Double(os_proc_available_memory()) / dValueOfOneMB)                 // bytes → MB...
    #else
        return 0   // macOS has no per-process Jetsam budget
    #endif
    //  return (Double(os_proc_available_memory()) / dValueOfOneMB)                 // bytes → MB...

    }

}   // End of struct JmAppMemoryUsageInfo:Codable.

