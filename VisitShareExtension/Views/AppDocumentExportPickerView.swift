//
//  AppDocumentExportPickerView.swift
//  VisitManagementApp
//
//  Created by Claude/Daryl Cox on 11/17/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
#endif
#if os(iOS)
import UIKit
#endif
    
#if os(iOS)
struct AppDocumentExportPickerView:UIViewControllerRepresentable 
{

    struct ClassInfo
    {
        static let sClsId        = "AppDocumentExportPickerView"
        static let sClsVers      = "v1.0301"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // App Data field(s):

//  @Environment(\.dismiss)              var dismiss
    @Environment(\.presentationMode)     var presentationMode
    @Environment(\.openURL)              var openURL
    @Environment(\.appGlobalDeviceType)  var appGlobalDeviceType

                    var appGlobalInfo:AppGlobalInfo = AppGlobalInfo.ClassSingleton.appGlobalInfo

                    let url:URL
                    let completion:(Result<URL, Error>)->Void
    
    func makeUIViewController(context:Context)->UIDocumentPickerViewController 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked <XxPort-JSON> - for supplied context...")
        
        let picker = UIDocumentPickerViewController(forExporting:[url])

        picker.delegate                 = context.coordinator
        picker.shouldShowFileExtensions = true
          
        appLogMsg("\(sCurrMethodDisp) Exiting <XxPort-JSON> - 'picker' is [\(picker)]...")

        return picker

    }
    
    func updateUIViewController(_ uiViewController:UIDocumentPickerViewController, context:Context) 
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked/Exiting <XxPort-JSON>...")
        
        // No updates needed

    }
    
    func makeCoordinator()->Coordinator 
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked/Exiting <XxPort-JSON>...")
        
        return Coordinator(completion:completion)

    }
    
    class Coordinator:NSObject, UIDocumentPickerDelegate 
    {

        struct ClassInfo
        {
            static let sClsId        = "AppDocumentExportPickerView:Coordinator"
            static let sClsVers      = "v1.0207"
            static let sClsDisp      = sClsId+".("+sClsVers+"): "
            static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
            static let bClsTrace     = true
            static let bClsFileLog   = true
        }

        let completion:(Result<URL, Error>)->Void
        
        init(completion:@escaping(Result<URL, Error>)->Void) 
        {

            let sCurrMethod:String     = #function
            let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

            appLogMsg("\(sCurrMethodDisp) Invoked <XxPort-JSON> - 'completion' is [\(String(describing: completion))]...")

            self.completion = completion

            appLogMsg("\(sCurrMethodDisp) Exiting <XxPort-JSON> - 'self.completion' is [\(String(describing: self.completion))]...")

            return

        }
        
        func documentPicker(_ controller:UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]) 
        {

            let sCurrMethod:String     = #function
            let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

            appLogMsg("\(sCurrMethodDisp) Invoked <XxPort-JSON> - 'controller' is [\(controller)] - 'urls' is [\(urls)]...")

            guard let url = urls.first 
            else { return }

            completion(.success(url))

            appLogMsg("\(sCurrMethodDisp) Exiting <XxPort-JSON> - Completion(Success:'url' was [\(url)])...")

            return

        }
        
        func documentPickerWasCancelled(_ controller:UIDocumentPickerViewController) 
        {

            let sCurrMethod:String     = #function
            let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

            appLogMsg("\(sCurrMethodDisp) Invoked/Exiting <XxPort-JSON>...")

            // User cancelled - just dismiss

        }

    }   // End of class Coordinator:NSObject, UIDocumentPickerDelegate.

}   // End of struct AppDocumentExportPickerView:UIViewControllerRepresentable.
#endif

