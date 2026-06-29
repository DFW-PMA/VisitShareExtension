//
//  AppDocumentExportPickerView.swift
//  VisitManagementApp
//
//  Created by Claude/Daryl Cox on 11/17/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
// <<CHICKEN-TRACKS>> @preconcurrency (2026-06-25) — NSSavePanel.begin(completionHandler:) isn't
//                    Swift 6 concurrency-audited; without this, the closure literal itself is
//                    flagged as "sending non-Sendable type" regardless of nonisolated(unsafe) on
//                    its captures. Standard PRECONCURRENCY fix per CLAUDE.md §12c.
@preconcurrency import AppKit
#endif
#if os(iOS)
import UIKit
#endif
    
#if os(iOS)
@JmEntityInfo(vers:"v1.0402")
struct AppDocumentExportPickerView:UIViewControllerRepresentable
{

    //  struct ClassInfo
    //  {
        //  static let sClsId        = "AppDocumentExportPickerView"
        //  static let sClsVers      = "v1.0402"
        //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
        //  static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    // App Data field(s):

//  @Environment(\.dismiss)              var dismiss
    @Environment(\.presentationMode)     var presentationMode
    @Environment(\.openURL)              var openURL
    @Environment(\.appGlobalDeviceType)  var appGlobalDeviceType

                    var appGlobalInfo:AppGlobalInfo = AppGlobalInfo.appGlobalInfo

                    let url:URL
                    let completion:(Result<URL, Error>)->Void
    
    func makeUIViewController(context:Context)->UIDocumentPickerViewController 
    {

        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo
          
        appLogMsg("\(sCurrMethodDisp) Invoked <XxPort-JSON> - for supplied context...")

        // <<CHICKEN-TRACKS>> asCopy:true added (2026-06-25) — without it, forExporting: defaults to
        //                    asCopy:false, which takes ownership of 'url' and MOVES it (deletes the
        //                    original on-disk JSON file) instead of copying it. Button label was
        //                    showing "Move" instead of "Save" - this is what caused that. Same
        //                    asCopy:true requirement already noted for the import side in
        //                    AppDocumentImportPickerView.swift.
        let picker = UIDocumentPickerViewController(forExporting:[url], asCopy:true)

        picker.delegate                 = context.coordinator
        picker.shouldShowFileExtensions = true
          
        appLogMsg("\(sCurrMethodDisp) Exiting <XxPort-JSON> - 'picker' is [\(picker)]...")

        return picker

    }
    
    func updateUIViewController(_ uiViewController:UIDocumentPickerViewController, context:Context) 
    {
        
        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo
          
        appLogMsg("\(sCurrMethodDisp) Invoked/Exiting <XxPort-JSON>...")
        
        // No updates needed

    }
    
    func makeCoordinator()->Coordinator 
    {
        
        //  let sCurrMethod:String     = #function
        //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        let sCurrMethodDisp:String = #JmCurrentMethodInfo
          
        appLogMsg("\(sCurrMethodDisp) Invoked/Exiting <XxPort-JSON>...")
        
        return Coordinator(completion:completion)

    }
    
    @JmEntityInfo(vers:"v1.0207")
    class Coordinator:NSObject, UIDocumentPickerDelegate 
    {

        //  struct ClassInfo
        //  {
            //  static let sClsId        = "AppDocumentExportPickerView:Coordinator"
            //  static let sClsVers      = "v1.0207"
            //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
            //  static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
            //  static let bClsTrace     = true
            //  static let bClsFileLog   = true
        //  }

        let completion:(Result<URL, Error>)->Void
        
        init(completion:@escaping(Result<URL, Error>)->Void) 
        {

            //  let sCurrMethod:String     = #function
            //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
            let sCurrMethodDisp:String = #JmCurrentMethodInfo

            appLogMsg("\(sCurrMethodDisp) Invoked <XxPort-JSON> - 'completion' is [\(String(describing: completion))]...")

            self.completion = completion

            appLogMsg("\(sCurrMethodDisp) Exiting <XxPort-JSON> - 'self.completion' is [\(String(describing: self.completion))]...")

            return

        }
        
        func documentPicker(_ controller:UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]) 
        {

            //  let sCurrMethod:String     = #function
            //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
            let sCurrMethodDisp:String = #JmCurrentMethodInfo

            appLogMsg("\(sCurrMethodDisp) Invoked <XxPort-JSON> - 'controller' is [\(controller)] - 'urls' is [\(urls)]...")

            guard let url = urls.first 
            else { return }

            completion(.success(url))

            appLogMsg("\(sCurrMethodDisp) Exiting <XxPort-JSON> - Completion(Success:'url' was [\(url)])...")

            return

        }
        
        func documentPickerWasCancelled(_ controller:UIDocumentPickerViewController) 
        {

            //  let sCurrMethod:String     = #function
            //  let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
            let sCurrMethodDisp:String = #JmCurrentMethodInfo

            appLogMsg("\(sCurrMethodDisp) Invoked/Exiting <XxPort-JSON>...")

            // User cancelled - just dismiss

        }

    }   // End of class Coordinator:NSObject, UIDocumentPickerDelegate.

}   // End of struct AppDocumentExportPickerView:UIViewControllerRepresentable.
#endif

#if os(macOS)
// <<CHICKEN-TRACKS>> macOS equivalent added (Section 13/11 follow-on, 2026-06-25) — NSSavePanel
//                    presents its own native modal directly; no SwiftUI Representable wrapper
//                    (and no .sheet() presentation) is needed the way UIDocumentPickerViewController
//                    requires on iOS.
@JmEntityInfo(vers:"v1.0101")
struct AppDocumentExportPickerMac
{

    //  struct ClassInfo
    //  {
        //  static let sClsId        = "AppDocumentExportPickerMac"
        //  static let sClsVers      = "v1.0101"
        //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
        //  static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    // <<CHICKEN-TRACKS>> @MainActor added (2026-06-25) — NSSavePanel.init()/begin(completionHandler:)
    //                    are main-actor-isolated; without this, the static func runs task-isolated
    //                    and "sending" the begin completion closure across isolation domains is
    //                    flagged even with nonisolated(unsafe) captures and @preconcurrency.
    @MainActor
    static func present(url:URL, completion:@escaping(Result<URL, Error>)->Void)
    {

        let sCurrMethodDisp:String = #JmCurrentMethodInfo

        appLogMsg("\(sCurrMethodDisp) Invoked <XxPort-JSON> - 'url' is [\(url.lastPathComponent)]...")

        let savePanel:NSSavePanel       = NSSavePanel()
        savePanel.nameFieldStringValue  = url.lastPathComponent
        savePanel.canCreateDirectories  = true

        savePanel.begin
        { response in

            guard (response == .OK),
                  let destURL = savePanel.url
            else
            {
                appLogMsg("\(sCurrMethodDisp) Exiting <XxPort-JSON> - User cancelled the save panel...")

                return
            }

            do
            {
                if (FileManager.default.fileExists(atPath:destURL.path) == true)
                {
                    try FileManager.default.removeItem(at:destURL)
                }

                try FileManager.default.copyItem(at:url, to:destURL)

                completion(.success(destURL))

                appLogMsg("\(sCurrMethodDisp) Exiting <XxPort-JSON> - Export succeeded to [\(destURL)]...")
            }
            catch
            {
                completion(.failure(error))

                appLogMsg("\(sCurrMethodDisp) Export copy failed - Error: [\(error.localizedDescription)] - Error!")
            }

            return
        }

        return

    }   // End of static func present(url:URL, completion:@escaping(Result<URL,Error>)->Void).

}   // End of struct AppDocumentExportPickerMac.
#endif

