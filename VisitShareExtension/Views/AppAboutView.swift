//
//  AppAboutView.swift
//  <<< App 'dependent' >>>
//
//  Created by Daryl Cox on 08/24/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
struct AppAboutView:View
{
    
    struct ClassInfo
    {
        static let sClsId        = "AppAboutView"
        static let sClsVers      = "v1.2501"
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

                    var appGlobalInfo:AppGlobalInfo               = AppGlobalInfo.ClassSingleton.appGlobalInfo
#if INSTANTIATE_APP_SWIFTDATAMANAGER
    @ObservedObject var appSwiftDataManager:AppSwiftDataManager   = AppSwiftDataManager.appSwiftDataManager
#endif
#if USE_APP_LOGGING_BY_VISITOR || INSTANTIATE_APP_JMSWIFTDATAMANAGER
                    var jmAppDelegateVisitor:JmAppDelegateVisitor = JmAppDelegateVisitor.ClassSingleton.appDelegateVisitor
#endif

#if os(macOS)
            private let pasteboard                                = NSPasteboard.general
#elseif os(iOS)
            private let pasteboard                                = UIPasteboard.general
#endif

    init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of init().

    var body:some View 
    {
        
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) \(JmXcodeBuildSettings.jmAppVersionAndBuildNumber)...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'appGlobalDeviceType' is (\(String(describing:appGlobalDeviceType)))...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'AppGlobalInfo.bIsAppLoggingByVisitor' is [\(AppGlobalInfo.bIsAppLoggingByVisitor)] and 'AppGlobalInfo.sAppLoggingMethod' is [\(AppGlobalInfo.sAppLoggingMethod)]...")

        VStack
        {
        #if os(iOS)
            HStack(alignment:.center)
            {
                Spacer()

                Button
                {
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):AppAboutView.Button(Xcode).'Dismiss' pressed...")

                    self.presentationMode.wrappedValue.dismiss()
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage:"xmark.circle")
                            .help(Text("Dismiss this Screen"))
                            .imageScale(.small)
                        Text("Dismiss")
                            .font(.caption2)
                    }
                }
            #if os(macOS)
                .buttonStyle(.borderedProminent)
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
                .padding(1.00)
            }
        #endif

            ZStack(alignment:.bottom)
            {
                ScrollView
                {
                    if #available(iOS 17.0, *)
                    {
                        Image(ImageResource(name:"Gfx/AppIcon", bundle:Bundle.main))
                            .resizable()
                            .scaledToFit()
                            .containerRelativeFrame(.horizontal)
                                { size, axis in
                                    size * 0.10
                                }
                    }
                    else
                    {
                        Image(ImageResource(name:"Gfx/AppIcon", bundle:Bundle.main))
                            .resizable()
                            .scaledToFit()
                            .frame(width:50, height:50, alignment:.center)
                    }

                        Text("")
                        Text("Display Name: \(JmXcodeBuildSettings.jmAppDisplayName)")
                            .bold()
                        Text("")

                        ScrollView
                        {
                        Text("Application Category:")
                            .bold()
                            .italic()
                            .font(.footnote)
                        Text("\(JmXcodeBuildSettings.jmAppCategory)")
                            .font(.footnote)
                        Text("")
                            .font(.footnote)
                        Text("\(JmXcodeBuildSettings.jmAppVersionAndBuildNumber)")     // <=== Version...
                            .italic()
                            .font(.footnote)
                        Text("")
                            .font(.caption2)
                        Text("- - - - - - - - - - - - - - -")
                            .font(.caption2)
                    #if USE_APP_LOGGING_BY_VISITOR
                        Text("Log file:")
                            .font(.caption2)
                        Text(self.jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec ?? "...empty...")
                            .font(.caption2)
                            .contextMenu
                            {
                                Button
                                {
                                    let _ = appLogMsg("...\(ClassInfo.sClsDisp):AppAboutView in Text.contextMenu.'copy' button #1...")

                                    self.copyLogFilespecToClipboard()
                                }
                                label:
                                {
                                    Text("Copy to Clipboard")
                                }
                            }
                        Text("Log file 'size' is: [\(self.getLogFilespecFileSizeDisplayableMB())]")
                            .font(.caption2)
                        Text("")
                            .font(.caption2)
                    #endif
                        Text("UserDefaults file:")
                            .font(.caption2)
                        Text("\(self.appGlobalInfo.sAppUserDefaultsFileLocation)")
                            .font(.caption2)
                            .contextMenu
                            {
                                Button
                                {
                                    let _ = appLogMsg("...\(ClassInfo.sClsDisp):AppAboutView in Text.contextMenu.'copy' button #2...")

                                    self.copyUserDefaultsFilespecToClipboard()
                                }
                                label:
                                {
                                    Text("Copy to Clipboard")
                                }
                            }
                    #if USE_APP_LOGGING_BY_VISITOR && INSTANTIATE_APP_JMSWIFTDATAMANAGER
                        Text("")
                            .font(.caption2)
                        Text("(Jm) SwiftData file(s) location:")
                            .font(.caption2)
                        Text("\(self.getJmSwiftDataFilesLocation())")
                            .font(.caption2)
                            .contextMenu
                            {
                                Button
                                {
                                    let _ = appLogMsg("...\(ClassInfo.sClsDisp):AppAboutView in Text.contextMenu.'copy' button #3...")

                                    self.copyJmSwiftDataFilesLocationToClipboard()
                                }
                                label:
                                {
                                    Text("Copy to Clipboard")
                                }
                            }
                    #endif
                    #if INSTANTIATE_APP_SWIFTDATAMANAGER
                        Text("")
                            .font(.caption2)
                        Text("(App) SwiftData file(s) location:")
                            .font(.caption2)
                        Text("\(self.getAppSwiftDataFilesLocation())")
                            .font(.caption2)
                            .contextMenu
                            {
                                Button
                                {
                                    let _ = appLogMsg("...\(ClassInfo.sClsDisp):AppAboutView in Text.contextMenu.'copy' button #4...")

                                    self.copyAppSwiftDataFilesLocationToClipboard()
                                }
                                label:
                                {
                                    Text("Copy to Clipboard")
                                }
                            }
                    #endif
                        Text("- - - - - - - - - - - - - - -")
                            .font(.caption2)
                        Text("")
                            .font(.caption2)

                        Text("\(JmXcodeBuildSettings.jmAppCopyright)")
                            .italic()
                            .font(.caption2)

                #if os(iOS) && INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
                    if (AppGlobalInfo.bEnableAppAdsPlaceholder == true ||
                        AppGlobalInfo.bEnableAppAdsTesting     == true ||
                        AppGlobalInfo.bEnableAppAdsProduction  == true)
                    {
                        Text("")            
                            .hidden()
                            .frame(minWidth: 1, idealWidth: 2, maxWidth: 3,
                                   minHeight:1, idealHeight:2, maxHeight:3)
                            .padding(.bottom, 100)
                    }
                #endif
                    }
                #if os(macOS)
                    .frame(height:300)
                #elseif os(iOS)
                    .frame(minHeight:200)
                #endif

                    Divider()

            #if os(iOS) && INSTANTIATE_APP_GOOGLEADMOBMOBILEADS
                if (AppGlobalInfo.bEnableAppAdsPlaceholder == true ||
                    AppGlobalInfo.bEnableAppAdsTesting     == true ||
                    AppGlobalInfo.bEnableAppAdsProduction  == true)
                {
                    VStack
                    {
                    if (AppGlobalInfo.bEnableAppAdsTesting    == true ||
                        AppGlobalInfo.bEnableAppAdsProduction == true)
                    {
                        let _ = print("ContentView.View: Invoking 'BannerContentView()'...")
          
                        BannerContentView(navigationTitle:"AdMobSwiftUIDemoApp2")
          
                        let _ = print("ContentView.View: Invoked  'BannerContentView()'...")
                    }
                    else
                    {
                        if (AppGlobalInfo.bEnableAppAdsPlaceholder == true)
                        {
                            HStack
                            {
                            if #available(iOS 17.0, *)
                            {
                                GeometryReader 
                                { geometry in
          
                                    Image(ImageResource(name:"Gfx/Placeholder-for-Ads", bundle:Bundle.main))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:geometry.size.width)
                                    //  .frame(width:geometry.size.width, height:50)
                                    //  .containerRelativeFrame(.horizontal)
                                    //      { size, axis in
                                    //          size * 1.000
                                    //      }
                                }
                            }
                            else
                            {
                                Image(ImageResource(name:"Gfx/Placeholder-for-Ads", bundle:Bundle.main))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:320, height:50, alignment:.center)
                            }
                            }
                        }
                    }
                    }
                    .frame(minHeight:75)
                }
            #endif
                }

                Text("")            
                    .hidden()
                    .onAppear(
                        perform:
                        {
                            let _ = self.finishAppInitialization()
                        })
                    .frame(minWidth: 1, idealWidth: 2, maxWidth: 3,
                           minHeight:1, idealHeight:2, maxHeight:3)
            }
            .frame(minHeight:75)
        }
        
    }
    
    private func finishAppInitialization()
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Finish the App 'initialization'...
  
    #if USE_APP_LOGGING_BY_VISITOR
        appLogMsg("\(ClassInfo.sClsDisp) Invoking the 'jmAppDelegateVisitor.checkAppDelegateVisitorTraceLogFileForSize()'...")

        self.jmAppDelegateVisitor.checkAppDelegateVisitorTraceLogFileForSize()

        appLogMsg("\(ClassInfo.sClsDisp) Invoked  the 'jmAppDelegateVisitor.checkAppDelegateVisitorTraceLogFileForSize()'...")
    #endif

        // Exit...
  
        appLogMsg("\(sCurrMethodDisp) Exiting...")
  
        return

    } // End of private func finishAppInitialization().
    
#if USE_APP_LOGGING_BY_VISITOR
    private func getLogFilespecFileSizeDisplayableMB()->String
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked - 'sAppDelegateVisitorLogFilespec' is [\(jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec!)]...")

        // Get the size of the LogFilespec in a displayable MB string...

        let sLogFilespecSizeInMB:String = JmFileIO.getFilespecSizeAsDisplayableMB(sFilespec:self.jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec)

        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting - 'sLogFilespecSizeInMB' is [\(sLogFilespecSizeInMB)] for 'sAppDelegateVisitorLogFilespec' of [\(jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec!)]...")
    
        return sLogFilespecSizeInMB
        
    }   // End of private func getLogFilespecFileSizeDisplayableMB()->String.
#endif

#if USE_APP_LOGGING_BY_VISITOR && INSTANTIATE_APP_JMSWIFTDATAMANAGER
    private func getJmSwiftDataFilesLocation()->String
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Get the location of the (Jm) SwiftData file(s)...

        var sJmSwiftDataFilesLocation:String = "-unknown-"

        if (self.jmAppDelegateVisitor.jmAppSwiftDataManager != nil)
        {
            if (self.jmAppDelegateVisitor.jmAppSwiftDataManager?.modelContext != nil)
            {
                if let urlSwiftDataLocation = self.jmAppDelegateVisitor.jmAppSwiftDataManager?.modelContext!.container.configurations.first?.url 
                {
                    sJmSwiftDataFilesLocation = String(describing:urlSwiftDataLocation).stripOptionalStringWrapper()
                
                    appLogMsg("\(sCurrMethodDisp) <JmSwiftData Location> 📱 The SwiftData 'location' is [\(String(describing:urlSwiftDataLocation).stripOptionalStringWrapper())]...")
                    appLogMsg("\(sCurrMethodDisp) <JmSwiftData Location> 📱 The SwiftData 'self.jmAppDelegateVisitor.jmAppSwiftDataManager?.modelContext!.container.configurations' is [\(String(describing: self.jmAppDelegateVisitor.jmAppSwiftDataManager?.modelContext!.container.configurations))]...")
                }
            }
        }

        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting - 'sJmSwiftDataFilesLocation' is [\(sJmSwiftDataFilesLocation)]...")
    
        return sJmSwiftDataFilesLocation
        
    }   // End of private func getJmSwiftDataFilesLocation()->String.
#endif
    
#if INSTANTIATE_APP_SWIFTDATAMANAGER
    private func getAppSwiftDataFilesLocation()->String
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Get the location of the (App) SwiftData file(s)...

        var sAppSwiftDataFilesLocation:String = "-unknown-"

        if (self.appSwiftDataManager.modelContext != nil)
        {
            if let urlSwiftDataLocation = self.appSwiftDataManager.modelContext!.container.configurations.first?.url 
            {
                sAppSwiftDataFilesLocation = String(describing:urlSwiftDataLocation).stripOptionalStringWrapper()
      
                appLogMsg("\(sCurrMethodDisp) <AppSwiftData Location> 📱 The SwiftData 'location' is [\(String(describing:urlSwiftDataLocation).stripOptionalStringWrapper())]...")
                appLogMsg("\(sCurrMethodDisp) <AppSwiftData Location> 📱 The SwiftData 'self.appSwiftDataManager.modelContext.container.configurations' is [\(self.appSwiftDataManager.modelContext!.container.configurations)]...")
            }
        }

        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting - 'sAppSwiftDataFilesLocation' is [\(sAppSwiftDataFilesLocation)]...")
    
        return sAppSwiftDataFilesLocation
        
    }   // End of private func getAppSwiftDataFilesLocation()->String.
#endif
    
#if USE_APP_LOGGING_BY_VISITOR
    private func copyLogFilespecToClipboard()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked - for text of [\(self.jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec!)]...")
        
    #if os(macOS)
        pasteboard.prepareForNewContents()
        pasteboard.setString(self.jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec!, forType:.string)
    #elseif os(iOS)
        pasteboard.string = self.jmAppDelegateVisitor.sAppDelegateVisitorLogFilespec!
    #endif

        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting...")
    
        return
        
    }   // End of private func copyLogFilespecToClipboard().
#endif
    
    private func copyUserDefaultsFilespecToClipboard()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
          
        appLogMsg("\(sCurrMethodDisp) Invoked - for text of [\(self.appGlobalInfo.sAppUserDefaultsFileLocation)]...")
        
    #if os(macOS)
        pasteboard.prepareForNewContents()
        pasteboard.setString(self.appGlobalInfo.sAppUserDefaultsFileLocation, forType:.string)
    #elseif os(iOS)
        pasteboard.string = self.appGlobalInfo.sAppUserDefaultsFileLocation
    #endif

        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting...")
    
        return
        
    }   // End of private func copyUserDefaultsFilespecToClipboard().
    
#if USE_APP_LOGGING_BY_VISITOR && INSTANTIATE_APP_JMSWIFTDATAMANAGER
    private func copyJmSwiftDataFilesLocationToClipboard()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        let sJmSwiftDataFilesLocation:String = self.getJmSwiftDataFilesLocation()
          
        appLogMsg("\(sCurrMethodDisp) Invoked - for text of [\(sJmSwiftDataFilesLocation)]...")
        
    #if os(macOS)
        pasteboard.prepareForNewContents()
        pasteboard.setString(sJmSwiftDataFilesLocation, forType:.string)
    #elseif os(iOS)
        pasteboard.string = sJmSwiftDataFilesLocation
    #endif

        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting...")
    
        return
        
    }   // End of private func copyJmSwiftDataFilesLocationToClipboard().
#endif
    
#if INSTANTIATE_APP_SWIFTDATAMANAGER
    private func copyAppSwiftDataFilesLocationToClipboard()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        let sAppSwiftDataFilesLocation:String = self.getAppSwiftDataFilesLocation()
          
        appLogMsg("\(sCurrMethodDisp) Invoked - for text of [\(sAppSwiftDataFilesLocation)]...")
        
    #if os(macOS)
        pasteboard.prepareForNewContents()
        pasteboard.setString(sAppSwiftDataFilesLocation, forType:.string)
    #elseif os(iOS)
        pasteboard.string = sAppSwiftDataFilesLocation
    #endif

        // Exit...
    
        appLogMsg("\(sCurrMethodDisp) Exiting...")
    
        return
        
    }   // End of private func copyAppSwiftDataFilesLocationToClipboard().
#endif
    
}   // End of struct AppAboutView:View.

@available(iOS 15.0, *)
#Preview
{
    AppAboutView()
}

