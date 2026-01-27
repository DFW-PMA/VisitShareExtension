//
//  ShareExtensionDiagnostics.swift
//  Comprehensive diagnostics for share extension URL opening issues
//

import Foundation
import UIKit

// MARK: - Diagnostic Helper

struct ShareExtensionDiagnostics
{
    
    /// Run all diagnostic checks and log results
    /// Call this from ShareViewController.viewDidLoad() during testing
    
    static func runFullDiagnostics(from viewController: UIViewController)
    {
        appLogMsg("=== SHARE EXTENSION DIAGNOSTICS START ===")
        
        checkAppGroupAccess()
        checkTargetAppSchemes()
        checkExtensionContext(viewController)
        checkResponderChain(viewController)
        checkBundleInfo()
        
        appLogMsg("=== SHARE EXTENSION DIAGNOSTICS END ===")
    }
    
    // MARK: - Individual Checks
    
    /// Check if App Group container is accessible
    
    static func checkAppGroupAccess()
    {
        appLogMsg("--- Checking App Group Access ---")
        
        if let containerURL = VVSharedConfig.sharedContainerURL
        {
            appLogMsg("✓ App Group container accessible: [\(containerURL.path)]")
            
            // Try to write a test file
            let testFile = containerURL.appendingPathComponent("extension-diagnostic-test.txt")
            let testContent = "Extension diagnostic test - \(Date())"
            
            do
            {
                try testContent.write(to: testFile, atomically: true, encoding: .utf8)
                appLogMsg("✓ Successfully wrote test file to App Group")
                
                // Try to read it back
                let readContent = try String(contentsOf: testFile, encoding: .utf8)
                appLogMsg("✓ Successfully read test file: [\(readContent.prefix(50))]")
                
                // Clean up
                try? FileManager.default.removeItem(at: testFile)
            }
            catch
            {
                appLogMsg("✗ Failed to write/read test file: [\(error)]")
            }
        }
        else
        {
            appLogMsg("✗ CRITICAL: App Group container NOT accessible!")
            appLogMsg("   Check: Extension target has App Group entitlement?")
            appLogMsg("   Check: App Group ID matches in all targets?")
        }
    }
    
    /// Check if target app URL schemes can be queried
    
    static func checkTargetAppSchemes()
    {
        appLogMsg("--- Checking Target App URL Schemes ---")
        
        let schemes = [
            "visitverify",
            "visitreportingapp",
            "visitmanagementapp", 
            "visitschedulingapp"
        ]
        
        // Check Info.plist for LSApplicationQueriesSchemes
        if let queriedSchemes = Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String]
        {
            appLogMsg("✓ LSApplicationQueriesSchemes found in Info.plist: [\(queriedSchemes)]")
            
            for scheme in schemes
            {
                if queriedSchemes.contains(scheme)
                {
                    appLogMsg("  ✓ [\(scheme)] is in LSApplicationQueriesSchemes")
                }
                else
                {
                    appLogMsg("  ✗ [\(scheme)] is MISSING from LSApplicationQueriesSchemes")
                }
            }
        }
        else
        {
            appLogMsg("✗ CRITICAL: LSApplicationQueriesSchemes NOT found in Info.plist!")
            appLogMsg("   This must be added to the EXTENSION'S Info.plist, not just the main app")
        }
        
        // Try to check if apps can be opened (this is limited in extensions)
        for scheme in schemes
        {
            if let url = URL(string: "\(scheme)://test")
            {
                appLogMsg("  Checking if URL [\(url)] is valid...")
                // Note: UIApplication.shared.canOpenURL is not available in extensions
                // We'll see if the actual open attempt works
            }
        }
    }
    
    /// Check extension context availability
    
    static func checkExtensionContext(_ viewController: UIViewController)
    {
        appLogMsg("--- Checking Extension Context ---")
        
        if let extensionContext = viewController.extensionContext
        {
            appLogMsg("✓ Extension context is available")
            appLogMsg("  Extension context type: [\(type(of: extensionContext))]")
            
            // Check if we can access inputItems
            let inputItems = extensionContext.inputItems as? [NSExtensionItem]
            appLogMsg("  Input items count: [\(inputItems?.count ?? 0)]")
            
        }
        else
        {
            appLogMsg("✗ WARNING: Extension context is nil")
            appLogMsg("   This is unusual - the extension may not be properly configured")
        }
    }
    
    /// Walk the responder chain and log what we find
    
    static func checkResponderChain(_ viewController: UIViewController)
    {
        appLogMsg("--- Checking Responder Chain ---")
        
        var responder: UIResponder? = viewController
        var depth = 0
        let maxDepth = 20
        
        while let r = responder, depth < maxDepth
        {
            depth += 1
            let responderType = type(of: r)
            
            appLogMsg("  [\(depth)]: \(responderType)")
            
            // Check for openURL: selector
            let openURLSelector = NSSelectorFromString("openURL:")
            if r.responds(to: openURLSelector)
            {
                appLogMsg("    ✓ Responds to openURL:")
            }
            
            responder = r.next
        }
        
        if depth == maxDepth
        {
            appLogMsg("  ... (stopped at max depth of \(maxDepth))")
        }
        
        appLogMsg("  Total responder chain depth: \(depth)")
    }
    
    /// Check bundle and entitlements info
    
    static func checkBundleInfo()
    {
        appLogMsg("--- Checking Bundle Info ---")
        
        if let bundleID = Bundle.main.bundleIdentifier
        {
            appLogMsg("✓ Bundle ID: [\(bundleID)]")
        }
        else
        {
            appLogMsg("✗ WARNING: Could not get bundle identifier")
        }
        
        // Check for entitlements file
        if let entitlements = Bundle.main.object(forInfoDictionaryKey: "com.apple.developer.associated-domains")
        {
            appLogMsg("  Associated domains: [\(entitlements)]")
        }
        
        // Check App Group entitlement
        // Note: This is in the .entitlements file, not Info.plist, so may not be accessible this way
        appLogMsg("  Note: App Group entitlement is in .entitlements file, verify in Xcode:")
        appLogMsg("    Target → Signing & Capabilities → App Groups")
        appLogMsg("    Should include: group.com.PreferredMobileApplications.sharedVisitApps")
    }
    
}

// MARK: - Test URL Builder

struct ShareExtensionTestURLs
{
    
    /// Generate test URLs for each target app
    /// Use these with the Safari test method
    
    static func printTestURLs()
    {
        appLogMsg("=== TEST URLs FOR SAFARI ===")
        appLogMsg("Copy these URLs and paste them into Safari to test URL scheme registration:")
        appLogMsg("")
        appLogMsg("VisitVerify:")
        appLogMsg("  visitverify://handoff?requestID=\(UUID().uuidString)")
        appLogMsg("")
        appLogMsg("VisitReportingApp:")
        appLogMsg("  visitreportingapp://handoff?requestID=\(UUID().uuidString)")
        appLogMsg("")
        appLogMsg("VisitManagementApp:")
        appLogMsg("  visitmanagementapp://handoff?requestID=\(UUID().uuidString)")
        appLogMsg("")
        appLogMsg("VisitSchedulingApp:")
        appLogMsg("  visitschedulingapp://handoff?requestID=\(UUID().uuidString)")
        appLogMsg("")
        appLogMsg("=== END TEST URLs ===")
    }
    
}

// MARK: - Usage Instructions

/*
 
 1. Add to ShareViewController.swift:
 
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        
        // Run diagnostics on first launch
        #if DEBUG
        ShareExtensionDiagnostics.runFullDiagnostics(from: self)
        ShareExtensionTestURLs.printTestURLs()
        #endif
        
        // ... rest of your viewDidLoad code
    }
 
 
 2. Build and run the extension
 
 3. Check Console.app:
    - Open Console.app on your Mac
    - Connect your iPad
    - Select your iPad in the left sidebar
    - Filter by your extension's name or process
    - Share a message to your extension
    - Watch the console output
 
 4. Verify each section:
    ✓ App Group Access - should show green checkmarks
    ✓ URL Schemes - should show all schemes in LSApplicationQueriesSchemes
    ✓ Extension Context - should be available
    ✓ Responder Chain - should show a chain of responders
 
 5. If any section shows errors:
    - App Group Access errors → Check .entitlements file in extension target
    - URL Schemes errors → Check Info.plist in extension target
    - Extension Context nil → Check extension configuration
 
 6. Safari URL Test:
    - Copy one of the test URLs from the console
    - Paste into Safari on your iPad
    - The target app should launch
    - If it doesn't, the URL scheme isn't registered in that app's Info.plist
 
 */
