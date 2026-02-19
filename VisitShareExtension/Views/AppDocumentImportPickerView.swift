//
//  AppDocumentImportPickerView.swift
//  QRLinkPack
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
struct AppDocumentImportPickerView:UIViewControllerRepresentable 
{

    struct ClassInfo
    {
        static let sClsId        = "AppDocumentImportPickerView"
        static let sClsVers      = "v1.0401"
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

                    let contentTypes:[UTType]
                    let allowsMultipleSelection:Bool
                    let completion:(Result<[URL], Error>)->Void

    // Convenience initializer for single selection (backwards compatibility)...

    init(contentTypes:[UTType], completion:@escaping(Result<URL, Error>)->Void)
    {

        self.contentTypes            = contentTypes
        self.allowsMultipleSelection = false

        // Wrap the single-URL completion to work with the internal multi-URL completion...

        self.completion =
        { result in

            switch result
            {
            case .success(let urls):
                if let firstURL = urls.first
                {
                    completion(.success(firstURL))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }

    }   // End of init(contentTypes:completion:) - single selection.

    // Primary initializer for multiple selection...

    init(contentTypes:[UTType], allowsMultipleSelection:Bool, completion:@escaping(Result<[URL], Error>)->Void)
    {

        self.contentTypes            = contentTypes
        self.allowsMultipleSelection = allowsMultipleSelection
        self.completion              = completion

    }   // End of init(contentTypes:allowsMultipleSelection:completion:) - multiple selection.
    
    func makeUIViewController(context:Context)->UIDocumentPickerViewController 
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked - 'allowsMultipleSelection' is [\(allowsMultipleSelection)]...")
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes:contentTypes)

        picker.delegate                 = context.coordinator
        picker.allowsMultipleSelection  = allowsMultipleSelection
        picker.shouldShowFileExtensions = true
          
        appLogMsg("\(sCurrMethodDisp) Exiting - 'picker' is [\(picker)]...")

        return picker

    }   // End of func makeUIViewController(context:Context)->UIDocumentPickerViewController.
    
    func updateUIViewController(_ uiViewController:UIDocumentPickerViewController, context:Context) 
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked/Exiting...")
        
        // No updates needed

    }   // End of func updateUIViewController(...).
    
    func makeCoordinator()->Coordinator 
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked/Exiting...")
        
        return Coordinator(completion:completion)

    }   // End of func makeCoordinator()->Coordinator.
    
    class Coordinator:NSObject, UIDocumentPickerDelegate 
    {

        struct ClassInfo
        {
            static let sClsId        = "AppDocumentImportPickerView:Coordinator"
            static let sClsVers      = "v1.0301"
            static let sClsDisp      = sClsId+".("+sClsVers+"): "
            static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
            static let bClsTrace     = true
            static let bClsFileLog   = true
        }

        let completion:(Result<[URL], Error>)->Void
        
        init(completion:@escaping(Result<[URL], Error>)->Void) 
        {

            let sCurrMethod:String     = #function
            let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

            appLogMsg("\(sCurrMethodDisp) Invoked...")

            self.completion = completion

            appLogMsg("\(sCurrMethodDisp) Exiting...")

            return

        }   // End of init(completion:).
        
        func documentPicker(_ controller:UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]) 
        {

            let sCurrMethod:String     = #function
            let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

            appLogMsg("\(sCurrMethodDisp) Invoked - 'urls' contains #(\(urls.count)) URL(s)...")

            guard !urls.isEmpty
            else 
            { 
                appLogMsg("\(sCurrMethodDisp) No URLs selected - returning...")

                return 
            }

            // Log each selected URL...

            for (index, url) in urls.enumerated()
            {
                appLogMsg("\(sCurrMethodDisp) URL[\(index)]: [\(url.lastPathComponent)]...")
            }

            completion(.success(urls))

            appLogMsg("\(sCurrMethodDisp) Exiting - Completion(Success) with #(\(urls.count)) URL(s)...")

            return

        }   // End of func documentPicker(...didPickDocumentsAt urls:[URL]).
        
        func documentPickerWasCancelled(_ controller:UIDocumentPickerViewController) 
        {

            let sCurrMethod:String     = #function
            let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

            appLogMsg("\(sCurrMethodDisp) Invoked/Exiting - User cancelled...")

            // User cancelled - just dismiss

        }   // End of func documentPickerWasCancelled(...).

    }   // End of class Coordinator:NSObject, UIDocumentPickerDelegate.

}   // End of struct AppDocumentImportPickerView:UIViewControllerRepresentable.
#endif

