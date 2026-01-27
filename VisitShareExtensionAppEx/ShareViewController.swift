//
//  ShareViewController.swift
//  VisitShareExtension
//
//  Share Extension entry point - extracts text and presents app picker
//  Integrates beautiful SwiftUI AppPickerView with robust URL opening fallbacks
//

import Foundation
import UIKit
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController:UIViewController
{
    
    struct ClassInfo
    {
        static let sClsId        = "ShareViewController"
        static let sClsVers      = "v1.0701"
        static let sClsDisp      = sClsId+".("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // MARK:- Properties...
    
    private var sharedText:String?
    private var hostingController:UIHostingController<AppPickerView>?

    private var urlMainHelperApp:URL = URL(string:"VisitShareExtension://")!
    
    // MARK:- Lifecycle...
    
    override func viewDidLoad()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        self.extractSharedContent()
        
        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of override func viewDidLoad().
    
    // MARK:- Content Extraction...
    
    private func extractSharedContent() 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) No extension items - Error!")
            showError("No content to share...")

            return
        }
        
        appLogMsg("\(sCurrMethodDisp) Found [\(extensionItems.count)] extension items...")
        
        for item in extensionItems
        {

            guard let attachments = item.attachments 
            else 
            {
                appLogMsg("\(sCurrMethodDisp) Item has no attachments...")

                continue 
            }
            
            appLogMsg("\(sCurrMethodDisp) Item has [\(attachments.count)] attachments...")
            
            for provider in attachments
            {
                // Plain text...

                if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier)
                {
                    appLogMsg("\(sCurrMethodDisp) Found plain text attachment...")
                    self.loadPlainText(from:provider)

                    return
                }
                
                // URL (some apps share URLs)...

                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier)
                {
                    appLogMsg("\(sCurrMethodDisp) Found URL attachment...")
                    self.loadURL(from:provider)

                    return
                }
            }
        }
        
        appLogMsg("\(sCurrMethodDisp) No text content found - Error!")
        showError("No text content found...")

        return

    }   // End of private func extractSharedContent().
    
    private func loadPlainText(from provider:NSItemProvider)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        provider.loadItem(forTypeIdentifier:UTType.plainText.identifier, options:nil) 
        { [weak self] (item, error) in

            DispatchQueue.main.async
            {
                if let error = error
                {
                    appLogMsg("\(sCurrMethodDisp) Failed to load text: [\(error.localizedDescription)] - Error!")
                    self?.showError("Failed to load text: [\(error.localizedDescription)]...")

                    return
                }
                
                if let text = item as? String
                {
                    appLogMsg("\(sCurrMethodDisp) Extracted text: [\(text.prefix(50))]...")
                    self?.sharedText = text
                    self?.showPickerUI()
                } 
                else
                {
                    appLogMsg("\(sCurrMethodDisp) Invalid text format - Error!")
                    self?.showError("Invalid text format...")
                }
            }

        }

        return

    }   // End of private func loadPlainText(from provider:NSItemProvider).
    
    private func loadURL(from provider:NSItemProvider)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        provider.loadItem(forTypeIdentifier:UTType.url.identifier, options:nil) 
        { [weak self] (item, error) in

            DispatchQueue.main.async 
            {
                if let error = error 
                {
                    appLogMsg("\(sCurrMethodDisp) Failed to load URL: [\(error.localizedDescription)] - Error!")
                    self?.showError("Failed to load URL: [\(error.localizedDescription)]...")

                    return
                }
                
                if let url = item as? URL 
                {
                    appLogMsg("\(sCurrMethodDisp) Extracted URL: [\(url.absoluteString)]...")
                    self?.sharedText = url.absoluteString
                    self?.showPickerUI()
                } 
                else
                {
                    appLogMsg("\(sCurrMethodDisp) Invalid URL format - Error!")
                    self?.showError("Invalid URL format...")
                }
            }

        }

        return

    }   // End of private func loadURL(from provider:NSItemProvider).
    
    // MARK:- UI
    
    private func showPickerUI()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        guard let text = sharedText 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) No text to share - Error!")
            showError("No text to share...")

            return
        }
        
        appLogMsg("\(sCurrMethodDisp) Creating AppPickerView with text length: [\(text.count)]...")
        
        let pickerView = AppPickerView(messageText:text,
                                       onSelect:
                                       { [weak self] targetApp, finalText in

                                           self?.sendToApp(targetApp, text:finalText)

                                       },
                                       onCancel:
                                       { [weak self] in

                                           self?.cancelShare()

                                       })
        
        let hosting                                            = UIHostingController(rootView:pickerView)
        hostingController                                      = hosting
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
                                     hosting.view.topAnchor.constraint(equalTo:view.topAnchor),
                                     hosting.view.bottomAnchor.constraint(equalTo:view.bottomAnchor),
                                     hosting.view.leadingAnchor.constraint(equalTo:view.leadingAnchor),
                                     hosting.view.trailingAnchor.constraint(equalTo:view.trailingAnchor)
                                    ])
        
        hosting.didMove(toParent:self)
        
        appLogMsg("\(sCurrMethodDisp) Exiting - AppPickerView displayed...")

        return

    }   // End of private func showPickerUI().
    
    private func showError(_ message:String)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) Showing error: [\(message)]...")
        
        let alert = UIAlertController(title:         "Unable to Share",
                                      message:       message,
                                      preferredStyle:.alert)

        alert.addAction(UIAlertAction(title:"OK", style:.default) 
        { [weak self] _ in

            self?.cancelShare()

        })

        present(alert, animated:true)

        return

    }   // End of private func showError(_ message:String).
    
    // MARK:- Handoff
    
    private func sendToApp(_ targetApp:VVSharedTargetApps, text:String)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Invoked - targetApp: [\(targetApp.displayName)]...")
        
        // Create handoff...

        let handoff = VVMessageHandoff(targetApp:targetApp,
                                        messageText:text,
                                        sourceAppBundleID:nil)  // Could extract from extensionContext if needed...
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Created handoff - requestID: [\(handoff.requestID)]...")
        
        // Write to shared container...

        do 
        {
            try handoff.write()
            appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Wrote handoff file...")
        } 
        catch
        {
            appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Failed to write handoff: [\(error)] - Error!")
            showError("Failed to save: [\(error.localizedDescription)]...")

            return
        }

        // The 'main' 'Helper' App may NOT be active - issue a URL to fire it up...

        openURLViaMultiFallback(urlMainHelperApp) 
        { [weak self] success in
            
            guard let self = self 
            else { return }
            
            if success
            {
                appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <urlMainHelperApp> Successfully opened [\(urlMainHelperApp)]")
            } 
            else
            {
                appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <urlMainHelperApp> URL opening failed (polling will catch it)...")
            }
        }

        // Issue a Darwin notification to the 'main' 'Helper' App...

        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Issuing 'VVDarwinNotification.postNewHandoff()'...")
        VVDarwinNotification.postNewHandoff()
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> <DarwinNotification> Issued  'VVDarwinNotification.postNewHandoff()'...")
        
        // Build launch URL...

        guard let url = targetApp.buildHandoffURL(requestID:handoff.requestID)
        else 
        {
            appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Failed to create launch URL - Error!")
            showError("Failed to create launch URL...")
            handoff.delete()

            return
        }
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Attempting to open URL: [\(url)]...")
        
        // Use 4-method fallback approach (nice-to-have, polling is primary reliability)
        // This provides instant response when it works, but polling will catch it if it fails
        
    //  openURL(url) 
        openURLViaMultiFallback(url) 
        { [weak self] success in
            
            guard let self = self 
            else { return }
            
            if success
            {
                appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Successfully opened [\(targetApp.displayName)]")
                self.completeShare()
            } 
            else
            {
                appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> URL opening failed (polling will catch it)...")
                // Don't delete handoff - let polling handle it
                // Don't show error - extension is closing anyway
                self.completeShare()
            }
        }

        return

    }   // End of private func sendToApp(_ targetApp:VVSharedTargetApps, text:String).
    
    // MARK:- Completion...
    
    private func completeShare()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Completing share request...")

        extensionContext?.completeRequest(returningItems:nil, completionHandler:nil)

    }   // End of private func completeShare().
    
    private func cancelShare()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'\(sCurrMethod)':"
        
        appLogMsg("\(sCurrMethodDisp) <PendingHandoffs> Canceling share request...")

        let error = NSError(domain:  "com.PreferredMobileApplications.sharedExtensionPack",
                            code:    0,
                            userInfo:[NSLocalizedDescriptionKey:"User cancelled"])

        extensionContext?.cancelRequest(withError:error)

        return

    }   // End of private func cancelShare().

}   // End of class ShareViewController:UIViewController.

//  NOTE: see the file 'ShareViewControllerExtensionURLOpening.swift':
//
//  // MARK: - URL Opening Extension with 4-Method Fallback
//  // Integrated from ShareViewControllerExtensionURLOpening.swift
//
//  extension ShareViewController
//  {
//      
//      /// Primary method: Try multiple approaches to open a URL from the extension
//      /// - Parameters:
//      ///   - url: The URL to open (should be a custom URL scheme for your target app)
//      ///   - completion: Called with true if any method succeeded, false otherwise
//      
//      func openURL(_ url: URL, completion: ((Bool) -> Void)? = nil)
//      {
//          appLogMsg("ShareViewController.openURL: Attempting to open [\(url)]...")
//          
//          // Method 1: Standard extensionContext.open (iOS 10+)
//          if let extensionContext = extensionContext
//          {
//              appLogMsg("ShareViewController.openURL: Trying Method 1 - extensionContext.open...")
//              
//              extensionContext.open(url) { [weak self] success in
//                  
//                  appLogMsg("ShareViewController.openURL: Method 1 result - success: [\(success)]")
//                  
//                  if success
//                  {
//                      completion?(true)
//                  }
//                  else
//                  {
//                      // Method 1 failed, try fallback methods
//                      appLogMsg("ShareViewController.openURL: Method 1 failed, trying fallbacks...")
//                      self?.openURLViaResponderChain(url, completion: completion)
//                  }
//              }
//          }
//          else
//          {
//              appLogMsg("ShareViewController.openURL: No extensionContext, trying fallbacks...")
//              openURLViaResponderChain(url, completion: completion)
//          }
//      }
//      
//      // MARK: - Method 2: Responder Chain
//      
//      /// Try to open URL by walking the responder chain looking for an openURL: selector
//      
//      private func openURLViaResponderChain(_ url: URL, completion: ((Bool) -> Void)? = nil)
//      {
//          appLogMsg("ShareViewController.openURLViaResponderChain: Attempting responder chain method...")
//          
//          let selector = NSSelectorFromString("openURL:")
//          var responder: UIResponder? = self
//          var depth = 0
//          
//          while let r = responder
//          {
//              depth += 1
//              appLogMsg("ShareViewController.openURLViaResponderChain: Checking responder #\(depth) - [\(type(of: r))]...")
//              
//              if r.responds(to: selector) && r != self
//              {
//                  appLogMsg("ShareViewController.openURLViaResponderChain: Found responder that responds to openURL: at depth \(depth)")
//                  
//                  // Perform the selector
//                  r.perform(selector, with: url)
//                  
//                  // Give it a moment to process, then call completion
//                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
//                  {
//                      appLogMsg("ShareViewController.openURLViaResponderChain: Method 2 completed - assuming success")
//                      completion?(true)
//                  }
//                  
//                  return
//              }
//              
//              responder = r.next
//          }
//          
//          appLogMsg("ShareViewController.openURLViaResponderChain: No responder found, trying Method 3...")
//          
//          // Method 2 failed, try Method 3
//          openURLViaSharedApplication(url, completion: completion)
//      }
//      
//      // MARK: - Method 3: Direct UIApplication Access
//      
//      /// Try to access UIApplication.shared via dynamic selector calls
//      /// This works around the API unavailability in extensions
//      
//      private func openURLViaSharedApplication(_ url: URL, completion: ((Bool) -> Void)? = nil)
//      {
//          appLogMsg("ShareViewController.openURLViaSharedApplication: Attempting direct UIApplication access...")
//          
//          // Get the UIApplication class dynamically
//          guard let applicationClass = NSClassFromString("UIApplication") as? NSObject.Type
//          else
//          {
//              appLogMsg("ShareViewController.openURLViaSharedApplication: Could not get UIApplication class")
//              openURLViaDirectSelector(url, completion: completion)
//              return
//          }
//          
//          // Create selector for sharedApplication (non-optional)
//          let sharedSelector = NSSelectorFromString("sharedApplication")
//          
//          // Check if the class responds to the selector
//          guard applicationClass.responds(to: sharedSelector)
//          else
//          {
//              appLogMsg("ShareViewController.openURLViaSharedApplication: UIApplication doesn't respond to sharedApplication")
//              openURLViaDirectSelector(url, completion: completion)
//              return
//          }
//          
//          // Get the shared application instance
//          guard let sharedApplicationUnmanaged = applicationClass.perform(sharedSelector),
//                let application = sharedApplicationUnmanaged.takeUnretainedValue() as? NSObject
//          else
//          {
//              appLogMsg("ShareViewController.openURLViaSharedApplication: Could not get shared application instance")
//              openURLViaDirectSelector(url, completion: completion)
//              return
//          }
//          
//          // Try openURL: first (older iOS)
//          let openURLSelector = NSSelectorFromString("openURL:")
//          if application.responds(to: openURLSelector)
//          {
//              appLogMsg("ShareViewController.openURLViaSharedApplication: Calling openURL: (legacy method)")
//              application.perform(openURLSelector, with: url)
//              
//              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
//              {
//                  appLogMsg("ShareViewController.openURLViaSharedApplication: Method 3a completed - assuming success")
//                  completion?(true)
//              }
//              
//              return
//          }
//          
//          // Try open:options:completionHandler: (newer iOS)
//          let openOptionsSelector = NSSelectorFromString("openURL:options:completionHandler:")
//          if application.responds(to: openOptionsSelector)
//          {
//              appLogMsg("ShareViewController.openURLViaSharedApplication: Calling openURL:options:completionHandler:")
//              
//              // This is tricky because we can't directly call a method with multiple parameters via perform
//              // But we can try...
//              application.perform(openOptionsSelector, with: url, with: [:])
//              
//              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
//              {
//                  appLogMsg("ShareViewController.openURLViaSharedApplication: Method 3b completed - assuming success")
//                  completion?(true)
//              }
//              
//              return
//          }
//          
//          appLogMsg("ShareViewController.openURLViaSharedApplication: No suitable open method found, trying Method 4...")
//          openURLViaDirectSelector(url, completion: completion)
//      }
//      
//      // MARK: - Method 4: Low-Level Selector Registration
//      
//      /// Last resort: Register and call selector directly
//      
//      private func openURLViaDirectSelector(_ url: URL, completion: ((Bool) -> Void)? = nil)
//      {
//          appLogMsg("ShareViewController.openURLViaDirectSelector: Attempting direct selector method...")
//          
//          let openURLSelector = sel_registerName("openURL:")
//          
//          // Walk responder chain one more time with registered selector
//          var responder: UIResponder? = self
//          var depth = 0
//          
//          while let r = responder
//          {
//              depth += 1
//              
//              if r.responds(to: openURLSelector)
//              {
//                  // Try to get the IMP and call it directly
//                  if let method = class_getInstanceMethod(type(of: r), openURLSelector)
//                  {
//                      appLogMsg("ShareViewController.openURLViaDirectSelector: Found method at depth \(depth)")
//                      
//                      typealias OpenURLFunction = @convention(c) (AnyObject, Selector, URL) -> Void
//                      let imp = method_getImplementation(method)
//                      let openURL = unsafeBitCast(imp, to: OpenURLFunction.self)
//                      
//                      openURL(r, openURLSelector, url)
//                      
//                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
//                      {
//                          appLogMsg("ShareViewController.openURLViaDirectSelector: Method 4 completed - assuming success")
//                          completion?(true)
//                      }
//                      
//                      return
//                  }
//              }
//              
//              responder = r.next
//          }
//          
//          appLogMsg("ShareViewController.openURLViaDirectSelector: All methods exhausted - FAILED")
//          completion?(false)
//      }
//      
//  }   // End of extension ShareViewController.

