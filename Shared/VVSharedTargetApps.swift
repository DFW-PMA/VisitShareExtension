//
//  VVSharedTargetApps.swift
//  Shared between Helper App and Share Extension
//
//  Defines all target apps that can receive shared content.
//  To add a new app:add a case here and implement all computed properties.
//

import SwiftUI

// All JustMacApps products that can receive shared content...

enum VVSharedTargetApps:String, CaseIterable, Identifiable
{
    case visitVerify        = "visitverify"
    case visitReportingApp  = "visitreportingapp"
    case visitManagementApp = "visitmanagementapp"
    case visitSchedulingApp = "visitschedulingapp"
    
    var id:String 
    { 
        rawValue
    }
    
    // MARK:- Display Properties
    
    // Human-readable name for the app...

    var displayName:String
    {
        switch self
        {
        case .visitVerify:
            return "VisitVerify"
        case .visitReportingApp:
            return "VisitReportingApp"
        case .visitManagementApp:
            return "VisitManagementApp"
        case .visitSchedulingApp:
            return "VisitSchedulingApp"
        }
    }
    
    // Description of what this app does with shared content...

    var actionDescription:String
    {
        switch self
        {
        case .visitVerify:
            return "Send to VV to create a support ticket"
        case .visitReportingApp:
            return "Create a support ticket"
        case .visitManagementApp:
            return "Add to management notes"
        case .visitSchedulingApp:
            return "Create schedule metadata"
        }
    }
    
    // SF Symbol name for the app icon...

    var iconName:String
    {
        switch self
        {
        case .visitVerify:
            return "ticket"
        case .visitReportingApp:
            return "ticket"
        case .visitManagementApp:
            return "doc.text.magnifyingglass"
        case .visitSchedulingApp:
            return "calendar.badge.plus"
        }
    }
    
    // Brand color for the app...

    var brandColor:Color
    {
        switch self
        {
        case .visitVerify:
            return .orange
        case .visitReportingApp:
            return .blue
        case .visitManagementApp:
            return .purple
        case .visitSchedulingApp:
            return .green
        }
    }
    
    // MARK:- URL Scheme
    
    // The URL scheme registered by this app...

    var urlScheme:String
    {
        return rawValue
    }
    
    // The host/path used for share handoffs...

    var handoffPath:String
    {
        switch self
        {
        case .visitVerify:
            return "ticket"
        case .visitReportingApp:
            return "ticket"
        case .visitManagementApp:
            return "management"
        case .visitSchedulingApp:
            return "metadata"
        }
    }
    
    // Build the full URL to launch this app with a handoff:
    // - Parameter requestID:The unique ID for this handoff request
    // - Returns:            URL to open, or nil if construction fails...

    func buildHandoffURL(requestID:UUID)->URL?
    {

        var components        = URLComponents()
        components.scheme     = urlScheme
        components.host       = handoffPath
        components.queryItems = [
                                 URLQueryItem(name:"source", value:"share"),
                                 URLQueryItem(name:"id",     value:requestID.uuidString)
                                ]

        return components.url

    }   // End of func buildHandoffURL(requestID:UUID)->URL?.
    
    // MARK:- App Detection
    
    // Check if this app can be opened (is installed)
    // Note:Requires LSApplicationQueriesSchemes in Info.plist...

    var canOpen:Bool
    {
        guard let url = URL(string:"\(urlScheme)://") 
        else { return false }

        // In extensions, we can't check this directly, so we attempt and handle failure
        // In the main app, UIApplication.shared.canOpenURL(url) works...

        return true                         // Assume available; handle failure gracefully...
    }
    
    // MARK:- Factory
    
    // Get a target app from its URL scheme...

    static func from(urlScheme:String)->VVSharedTargetApps?
    {

        return VVSharedTargetApps(rawValue:urlScheme.lowercased())

    }   // End of static func from(urlScheme:String)->VVSharedTargetApps?.

}   // End of enum VVSharedTargetApps:String, CaseIterable, Identifiable.

// MARK:- Preview Support

extension VVSharedTargetApps
{
    // All apps for preview/testing

    static var previewApps:[VVSharedTargetApps]
    {
        return VVSharedTargetApps.allCases
    }
}

