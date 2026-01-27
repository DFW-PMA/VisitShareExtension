//
//  ShareViewController+URLOpening.swift
//  URL Opening Workaround for Share Extensions
//
//  This provides multiple fallback methods for opening URLs from share extensions,
//  which is a known problematic area in iOS share extension APIs.
//
//  Version History:
//  - v1.0201:Renamed openURL(...) to openURLViaMultiFallback(..._)
//  - v1.0101:Fixed compile errors with NSSelectorFromString (non-optional) and 
//             class method invocation for UIApplication.sharedApplication
//

import UIKit

// MARK:- URL Opening Extension...

extension ShareViewController
{
    
    // Primary method:Try multiple approaches to open a URL from the extension
    // - Parameters:
    //   - url:       The URL to open (should be a custom URL scheme for your target app)
    //   - completion:Called with true if any method succeeded, false otherwise
    
    func openURLViaMultiFallback(_ url:URL, completion:((Bool)->Void)? = nil)
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - Attempting to open [\(url)]...")
        
        // Method 1:Standard extensionContext.open (iOS 10+)...

        if let extensionContext = extensionContext
        {
            appLogMsg("ShareViewController.openURL:Trying Method 1 - 'extensionContext.open(url)'...")
            
            extensionContext.open(url) 
            { [weak self] success in
                
                appLogMsg("ShareViewController.openURL:Method 1 result - success:[\(success)]...")
                
                if success
                {
                    completion?(true)
                }
                else
                {
                    // Method 1 failed, try fallback methods...

                    appLogMsg("ShareViewController.openURL:Method 1 failed, trying fallback(s)...")

                    self?.openURLViaResponderChain(url, completion:completion)
                }
            }
        }
        else
        {
            appLogMsg("ShareViewController.openURL:No extensionContext, trying fallback(s)...")

            self.openURLViaResponderChain(url, completion:completion)
        }

    }   // End of func openURLViaMultiFallback(_ url:URL, completion:((Bool)->Void)?).
    
    // MARK:- Method 2:Responder Chain
    
    // Try to open URL by walking the responder chain looking for an openURL:selector...
    
    private func openURLViaResponderChain(_ url:URL, completion:((Bool)->Void)? = nil)
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - Attempting to open [\(url)] by the responder chain method...")
        
        let selector               = NSSelectorFromString("openURL:")
        var responder:UIResponder? = self
        var depth                  = 0
        
        while let r = responder
        {
            depth += 1

            appLogMsg("\(sCurrMethodDisp) Checking responder #(\(depth)) - [\(type(of:r))]...")
            
            if r.responds(to:selector) && r != self
            {
                appLogMsg("\(sCurrMethodDisp) Found a responder that responds to 'openURL:at' depth #(\(depth))...")
                
                // Perform the selector...

                r.perform(selector, with:url)
                
                // Give it a moment to process, then call completion...

                DispatchQueue.main.asyncAfter(deadline:(.now() + 0.1))
                {
                    appLogMsg("\(sCurrMethodDisp) Method 2 completed - assuming success...")

                    completion?(true)
                }
                
                return
            }
            
            responder = r.next
        }
        
        appLogMsg("\(sCurrMethodDisp) No responder found, trying Method 3...")
        
        // Method 2 failed, try Method 3...

        self.openURLViaSharedApplication(url, completion:completion)

    }   // End of private func openURLViaResponderChain(_ url:URL, completion:((Bool)->Void)?).
    
    // MARK:- Method 3:Direct UIApplication Access
    
    // Try to access UIApplication.shared via dynamic selector calls
    // This works around the API unavailability in extensions...
    
    private func openURLViaSharedApplication(_ url:URL, completion:((Bool)->Void)? = nil)
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - Attempting to open [\(url)] by direct UIApplication access...")
        
        // Get the UIApplication class dynamically...

        guard let applicationClass = NSClassFromString("UIApplication") as? NSObject.Type
        else
        {
            appLogMsg("\(sCurrMethodDisp) Could not get UIApplication class - Warning!")

            self.openURLViaDirectSelector(url, completion:completion)

            return
        }
        
        // Create selector for sharedApplication (non-optional)...

        let sharedSelector = NSSelectorFromString("sharedApplication")
        
        // Check if the class responds to the selector...

        guard applicationClass.responds(to:sharedSelector)
        else
        {
            appLogMsg("\(sCurrMethodDisp) UIApplication doesn't respond to 'sharedApplication' - Warning!")

            self.openURLViaDirectSelector(url, completion:completion)

            return
        }
        
        // Get the shared application instance...

        guard let sharedApplicationUnmanaged = applicationClass.perform(sharedSelector),
              let application                = sharedApplicationUnmanaged.takeUnretainedValue() as? NSObject
        else
        {
            appLogMsg("\(sCurrMethodDisp) Could not get shared application instance - Warning!")

            self.openURLViaDirectSelector(url, completion:completion)

            return
        }
        
        // Try openURL:first (older iOS)...

        let openURLSelector = NSSelectorFromString("openURL:")

        if application.responds(to:openURLSelector)
        {
            appLogMsg("\(sCurrMethodDisp) Calling openURL:(legacy method)...")

            application.perform(openURLSelector, with:url)
            
            DispatchQueue.main.asyncAfter(deadline:(.now() + 0.1))
            {
                appLogMsg("\(sCurrMethodDisp) Method 3a completed - assuming success...")

                completion?(true)
            }
            
            return
        }
        
        // Try open:options:completionHandler:(newer iOS)...

        let openOptionsSelector = NSSelectorFromString("openURL:options:completionHandler:")

        if application.responds(to:openOptionsSelector)
        {
            appLogMsg("\(sCurrMethodDisp) Calling openURL:options:completionHandler:...")
            
            // This is tricky because we can't directly call a method with multiple parameters via perform
            // But we can try...

            application.perform(openOptionsSelector, with:url, with:[:])
            
            DispatchQueue.main.asyncAfter(deadline:(.now() + 0.1))
            {
                appLogMsg("\(sCurrMethodDisp) Method 3b completed - assuming success...")

                completion?(true)
            }
            
            return
        }
        
        appLogMsg("\(sCurrMethodDisp) No suitable open method found, trying Method 4...")

        self.openURLViaDirectSelector(url, completion:completion)

    }   // End of private func openURLViaSharedApplication(_ url:URL, completion:((Bool)->Void)? = nil).
    
    // MARK:- Method 4:Low-Level Selector Registration
    
    // Last resort:Register and call selector directly...
    
    private func openURLViaDirectSelector(_ url:URL, completion:((Bool)->Void)? = nil)
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - Attempting to open [\(url)] by direct selector method...")
        
        let openURLSelector = sel_registerName("openURL:")
        
        // Walk responder chain one more time with registered selector...

        var responder:UIResponder? = self
        var depth                  = 0
        
        while let r = responder
        {
            depth += 1
            
            if r.responds(to:openURLSelector)
            {
                // Try to get the IMP and call it directly...

                if let method = class_getInstanceMethod(type(of:r), openURLSelector)
                {
                    appLogMsg("\(sCurrMethodDisp) Found a responder method at depth #(\(depth))...")
                    
                    typealias OpenURLFunction = @convention(c)(AnyObject, Selector, URL)->Void
                    let       imp             = method_getImplementation(method)
                    let       openURL         = unsafeBitCast(imp, to:OpenURLFunction.self)
                    
                    openURL(r, openURLSelector, url)
                    
                    DispatchQueue.main.asyncAfter(deadline:(.now() + 0.1))
                    {
                        appLogMsg("\(sCurrMethodDisp) Method 4 completed - assuming success...")

                        completion?(true)
                    }
                    
                    return
                }
            }
            
            responder = r.next
        }
        
        appLogMsg("\(sCurrMethodDisp) All methods exhausted - FAILED - Error!")

        completion?(false)

    }   // End of private func openURLViaDirectSelector(_ url:URL, completion:((Bool)->Void)? = nil).
    
}   // End of extension ShareViewController.

// MARK:- Usage in ShareViewController

/*
 
 Replace your current sendToApp method with this:
 
 private func sendToApp(_ targetApp:VVSharedTargetApps, text:String)
 {
     let sCurrMethod:String = #function
     let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
     
     appLogMsg("\(sCurrMethodDisp) Invoked - targetApp:[\(targetApp.displayName)]...")
     
     // Create handoff
     let handoff = VVMessageHandoff(
         requestID:UUID(),
         targetApp:targetApp,
         messageText:text,
         createdAt:Date()
     )
     
     // Write handoff file
     do
     {
         try handoff.write()
         appLogMsg("\(sCurrMethodDisp) Wrote handoff to:[\(handoff.fileURL.path)]")
     }
     catch
     {
         appLogMsg("\(sCurrMethodDisp) Failed to write handoff:[\(error)] - Error!")
         showError("Failed to save message data:\(error.localizedDescription)")
         return
     }
     
     // Build URL
     guard let url = targetApp.buildHandoffURL(requestID:handoff.requestID)
     else
     {
         appLogMsg("\(sCurrMethodDisp) Failed to create launch URL - Error!")
         showError("Failed to create launch URL")
         handoff.delete()
         return
     }
     
     appLogMsg("\(sCurrMethodDisp) Opening URL:[\(url)]...")
     
     // Use the new workaround method
     openURLViaMultiFallback(url) 
     { [weak self] success in
         
         guard let self = self else { return }
         
         if success
         {
             appLogMsg("\(sCurrMethodDisp) Successfully opened [\(targetApp.displayName)]")
             self.completeShare()
         }
         else
         {
             appLogMsg("\(sCurrMethodDisp) FAILED to open URL:[\(url)] - Error!")
             handoff.delete()
             self.showError("\(targetApp.displayName) could not be opened. Is it installed?")
         }
     }
     
     appLogMsg("\(sCurrMethodDisp) Exiting...")
 }
 
 */
