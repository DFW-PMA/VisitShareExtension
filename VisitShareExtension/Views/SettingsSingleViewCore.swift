//
//  SettingsSingleViewCore.swift
//  <<< App 'dependent' >>>
//
//  Created by JustMacApps.net on 11/25/2024.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import SwiftUI

struct SettingsSingleViewCore:View 
{
    
    struct ClassInfo
    {
        static let sClsId        = "SettingsSingleViewCore"
        static let sClsVers      = "v1.2604"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // App Data field(s):
    
//  @Environment(\.dismiss)              var dismiss
    @Environment(\.presentationMode)     var presentationMode
    @Environment(\.openWindow)           var openWindow
    @Environment(\.openURL)              var openURL
    @Environment(\.appGlobalDeviceType)  var appGlobalDeviceType
        
                   var appGlobalInfo:AppGlobalInfo               = AppGlobalInfo.ClassSingleton.appGlobalInfo
                   var jmAppDelegateVisitor:JmAppDelegateVisitor = JmAppDelegateVisitor.ClassSingleton.appDelegateVisitor
    
           private var bInternalZipTest:Bool                     = false
           private var bIsAppUploadUsingLongMsg:Bool             = true

    @State private var isAppExecutionCurrentShowing:Bool         = false
           private var sAppExecutionCurrentButtonText:String     = "Share the current App Log with Developers..."
           private var sAppExecutionCurrentAlertText:String      = "Do you want to 'send' the current App LOG data to the Developers?"

           private var bWasAppLogFilePresentAtStartup:Bool       = false
           private var bDidAppCrash:Bool                         = false
           private var sAppExecutionPreviousTypeText:String      = "-N/A-"
           private var sAppExecutionPreviousButtonText:String    = "App::-N/A-"
           private var sAppExecutionPreviousAlertText:String     = "Do you want to 'send' the App LOG data?"
           private var sAppExecutionPreviousLogToUpload:String   = ""
    @State private var isAppExecutionPreviousShowing:Bool        = false

    @State private var cAppViewSuspendButtonPresses:Int          = 0
    @State private var cAppZipFileButtonPresses:Int              = 0
    @State private var cAppCrashButtonPresses:Int                = 0

    @State private var isAppSuspendShowing:Bool                  = false
    @State private var isAppZipFileShowing:Bool                  = false
    @State private var isAppCrashShowing:Bool                    = false

    @State private var cAppAboutButtonPresses:Int                = 0
    @State private var cAppHelpViewButtonPresses:Int             = 0
    @State private var cAppLogViewButtonPresses:Int              = 0

    @State private var isAppAboutViewModal:Bool                  = false
    @State private var isAppHelpViewModal:Bool                   = false
    @State private var isAppLogViewModal:Bool                    = false

#if os(iOS)
    @State private var cAppReleaseUpdateButtonPresses:Int        = 0
    @State private var cAppPreReleaseUpdateButtonPresses:Int     = 0

    @State private var isAppDownloadReleaseUpdateShowing:Bool    = false
    @State private var isAppDownloadPreReleaseUpdateShowing:Bool = false
#endif
    
    init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Get some 'internal' Dev Detail(s)...

        if (AppGlobalInfo.bAppShouldShowLogFiles == true)
        {
            bWasAppLogFilePresentAtStartup = checkIfAppLogWasPresent()
            bDidAppCrash                   = checkIfAppDidCrash()

            if (bDidAppCrash == false)
            {
                sAppExecutionPreviousTypeText    = "Success"
                sAppExecutionPreviousButtonText  = "Share the App 'success' Log with Developers..."
                sAppExecutionPreviousAlertText   = "Do you want to 'send' the App execution 'success' LOG data to the Developers?"
                sAppExecutionPreviousLogToUpload = AppGlobalInfo.sGlobalInfoAppLastGoodLogFilespec
            }
            else
            {
                sAppExecutionPreviousTypeText    = "Crash"
                sAppExecutionPreviousButtonText  = "Share the App CRASH Log with Developers..."
                sAppExecutionPreviousAlertText   = "Do you want to 'send' the App execution 'crash' LOG data to the Developers?"
                sAppExecutionPreviousLogToUpload = AppGlobalInfo.sGlobalInfoAppLastCrashLogFilespec
            }
        }

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting - 'bDidAppCrash' is [\(bDidAppCrash)]...")

        return

    }   // End of init().

    var body:some View 
    {
        
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body \(JmXcodeBuildSettings.jmAppVersionAndBuildNumber)...")
        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - 'appGlobalDeviceType' is (\(String(describing:appGlobalDeviceType)))...")

        Spacer()

        VStack(alignment:.leading)
        {
            Spacer()
                .frame(height:5)
            HStack(alignment:.center)
            {
                Button
                {
                    self.cAppAboutButtonPresses += 1
      
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsSingleViewCore in Button(Xcode).'App About'.#(\(self.cAppAboutButtonPresses))...")
      
                #if os(iOS)
                    self.isAppAboutViewModal.toggle()
                #endif
                #if os(macOS)
                    openWindow(id:"AppAboutView")
                #endif
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage: "questionmark.diamond")
                            .help(Text("App About Information"))
                            .imageScale(.large)
                        Text("App About")
                            .font(.caption)
                    }
                }
            #if os(iOS)
                .fullScreenCover(isPresented:$isAppAboutViewModal)
                {
                    AppAboutView()
                }
            #endif
            #if os(macOS)
                .buttonStyle(.borderedProminent)
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
      
                Spacer()
      
                Button
                {
                    self.cAppHelpViewButtonPresses += 1
      
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsSingleViewCore in Button(Xcode).'App HelpView'.#(\(self.cAppHelpViewButtonPresses))...")
      
                #if os(iOS)
                    self.isAppHelpViewModal.toggle()
                #endif
                #if os(macOS)
                    openWindow(id:"HelpBasicView")
                #endif
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage: "questionmark.circle")
                            .help(Text("App HELP Information"))
                            .imageScale(.large)
                        Text("Help")
                            .font(.caption)
                    }
                }
            #if os(iOS)
                .fullScreenCover(isPresented:$isAppHelpViewModal)
                {
                    HelpBasicView(sHelpBasicContents:jmAppDelegateVisitor.getAppDelegateVisitorHelpBasicContents())
                        .navigationBarBackButtonHidden(true)
                }
            #endif
            #if os(macOS)
                .buttonStyle(.borderedProminent)
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
      
                Spacer()
      
                Button
                {
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsSingleViewCore.Button(Xcode).'Dismiss' pressed...")
                    
                    self.presentationMode.wrappedValue.dismiss()
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage: "xmark.circle")
                            .help(Text("Dismiss this Screen"))
                            .imageScale(.large)
                        Text("Dismiss")
                            .font(.caption)
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

            Spacer()
                .frame(height:10)

        if (AppGlobalInfo.bAppShouldShowLogFiles == true)
        {
            HStack(alignment:.center)
            {
            if (bWasAppLogFilePresentAtStartup == true)
            {
                Button
                {
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsSingleViewCore in Button(Xcode).'\(sAppExecutionPreviousButtonText)'...")

                    self.isAppExecutionPreviousShowing.toggle()
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage: "arrow.up.message")
                            .help(Text("'Send' \(sAppExecutionPreviousTypeText) App LOG"))
                            .imageScale(.large)
                        Text("\(sAppExecutionPreviousTypeText) LOG")
                            .font(.caption)
                    }
                }
                .alert(sAppExecutionPreviousAlertText, isPresented:$isAppExecutionPreviousShowing)
                {
                    Button("Cancel", role:.cancel)
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Cancel' to 'send' the \(sAppExecutionPreviousTypeText) App LOG - resuming...")
                    }
                    Button("Ok", role:.destructive)
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Ok' to 'send' the \(sAppExecutionPreviousTypeText) App LOG - sending...")

                        self.uploadPreviousAppLogToDevs()
                    }
                }
            #if os(macOS)
                .buttonStyle(.borderedProminent)
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
            }

                Spacer()

            if (jmAppDelegateVisitor.bAppDelegateVisitorLogFilespecIsUsable == true)
            {
                Button
                {
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsSingleViewCore in Button(Xcode).'\(sAppExecutionCurrentButtonText)'...")

                    self.isAppExecutionCurrentShowing.toggle()
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage: "arrow.up.message")
                            .help(Text("'Send' current App LOG"))
                            .imageScale(.large)
                        Text("Current LOG")
                            .font(.caption)
                    }
                }
                .alert(sAppExecutionCurrentAlertText, isPresented:$isAppExecutionCurrentShowing)
                {
                    Button("Cancel", role:.cancel)
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Cancel' to 'send' the current App LOG - resuming...")
                    }
                    Button("Ok", role:.destructive)
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Ok' to 'send' the current App LOG - sending...")

                        self.uploadCurrentAppLogToDevs()
                    }
                }
            #if os(macOS)
                .buttonStyle(.borderedProminent)
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif

                Spacer()
            }

                Button
                {
                    self.cAppLogViewButtonPresses += 1
      
                    let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsSingleViewCore in Button(Xcode).'App LogView'.#(\(self.cAppLogViewButtonPresses))...")
                          
                #if os(iOS)
                    self.isAppLogViewModal.toggle()
                #endif
                #if os(macOS)
                    openWindow(id:"LogFileView")
                #endif
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage: "doc.text.magnifyingglass")
                            .help(Text("App LOG Viewer"))
                            .imageScale(.large)
                        Text("View Log")
                            .font(.caption)
                    }
                }
            #if os(iOS)
                .fullScreenCover(isPresented:$isAppLogViewModal)
                {
                    LogFileView()
                }
            #endif
            #if os(macOS)
                .buttonStyle(.borderedProminent)
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
                .padding(1.00)
            }
      
            Spacer()
                .frame(height:10)
        }

            Spacer()
                .frame(height:10)
      
            VStack(alignment:.center)
            {
                HStack(alignment:.center)
                {
                    Spacer()
                    Text(" - - - - - - - - - - - - - - - ")
                        .bold()
                    Spacer()
                }
                HStack(alignment:.center)
                {
                    Spacer()
                    VStack(alignment:.center)
                    {
                    if #available(iOS 15.0, *) 
                    {
                        Text("Application Setting(s):")
                            .bold()
                            .dynamicTypeSize(.small)
                    }
                    else
                    {
                        Text("Application Setting(s):")
                            .bold()
                    }
                    }
                    Spacer()
                }
                HStack(alignment:.center)
                {
                    Spacer()
                    Text(" - - - - - - - - - - - - - - - ")
                        .bold()
                    Spacer()
                }
            }

            Spacer()

            HStack(alignment:.center)
            {
            #if os(iOS)
                Spacer()
                
                Button
                {
                    self.cAppViewSuspendButtonPresses += 1

                    let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsSingleViewCore in Button(Xcode).'Quit'.#(\(self.cAppViewSuspendButtonPresses))...")

                    self.isAppSuspendShowing.toggle()
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage: "xmark.circle")
                            .help(Text("Suspend this App"))
                            .imageScale(.large)
                        Text("Suspend")
                            .font(.caption2)
                    }
                }
                .alert("Are you sure you want to 'suspend' this App?", isPresented:$isAppSuspendShowing)
                {
                    Button("Cancel", role:.cancel)
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Cancel' to 'suspend' the App - resuming...")
                    }
                    Button("Ok", role:.destructive)
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Ok' to 'suspend' the App - suspending...")

                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    }
                }
            #endif

                Spacer()

            if (AppGlobalInfo.bPerformAppDevTesting == true)
            {
                Button
                {
                    self.cAppZipFileButtonPresses += 1
      
                    let _ = appLogMsg("\(ClassInfo.sClsDisp)SettingsSingleViewCore in Button(Xcode).'App ZipFile'.#(\(self.cAppZipFileButtonPresses))...")
      
                    self.isAppZipFileShowing.toggle()
                }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage: "square.resize.down")
                            .help(Text("Test this App creating a ZIP File"))
                            .imageScale(.large)
                        Text("Test ZIP")
                            .font(.caption2)
                    }
                }
                .alert("Are you sure you want to TEST this App 'creating' a ZIP File?", isPresented:$isAppZipFileShowing)
                {
                    Button("Cancel", role:.cancel)
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Cancel' to 'test' the App ZIP File - resuming...")
                    }
                    Button("Ok", role:.destructive)
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Ok' to 'test' the App ZIP File - testing...")
      
                        self.uploadCurrentAppLogToDevs()
                    }
                }
            #if os(macOS)
                .buttonStyle(.borderedProminent)
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
      
                Spacer()
      
                Button
                {
      
                    self.cAppCrashButtonPresses += 1
      
                    let _ = appLogMsg("\(ClassInfo.sClsDisp)SettingsSingleViewCore in Button(Xcode).'App Crash'.#(\(self.cAppCrashButtonPresses))...")
      
                    self.isAppCrashShowing.toggle()
      
                }
                label:
                {
      
                    VStack(alignment:.center)
                    {
      
                        Label("", systemImage: "autostartstop.slash")
                            .help(Text("FORCE this App to CRASH"))
                            .imageScale(.large)
      
                        Text("Force CRASH")
                            .font(.caption2)
      
                    }
      
                }
                .alert("Are you sure you want to 'crash' this App?", isPresented:$isAppCrashShowing)
                {
                    Button("Cancel", role:.cancel)
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Cancel' to 'crash' the App - resuming...")
                    }
                    Button("Ok", role:.destructive)
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Ok' to 'crash' the App - crashing...")
      
                        fatalError("The User pressed 'Ok' to force an App 'crash'!")
                    }
                }
            #if os(macOS)
                .buttonStyle(.borderedProminent)
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
      
                Spacer()
            }
            }
      
        #if os(iOS)
        if (AppGlobalInfo.bEnableAppReleaseDownloads == true)
        {
            Spacer()
      
            VStack(alignment:.center)
            {
                HStack(alignment:.center)
                {
                    Spacer()

                    Text(" - - - - - - - - - - - - - - - ")
                        .bold()
                    Spacer()
                }
                HStack(alignment:.center)
                {
                    Spacer()
      
                    Button
                    {
                        self.cAppReleaseUpdateButtonPresses += 1
      
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsSingleViewCore in Button(Xcode).'App 'download' Release'.#(\(self.cAppReleaseUpdateButtonPresses))...")
      
                        self.isAppDownloadReleaseUpdateShowing.toggle()
                    }
                    label: 
                    {
                    if #available(iOS 14.0, *) 
                    {
                        VStack(alignment:.center)
                        {
                            Label("", systemImage: "arrow.down.app")
                                .help(Text("App 'download' RELEASE"))
                                .imageScale(.large)
                            Text("Update Release")
                                .font(.caption2)
                        }
                    } 
                    else
                    {
                        Text("App 'download' RELEASE")
                    }
                    }
                    .alert("Do you want to 'download' (and install) the App RELEASE?", isPresented:$isAppDownloadReleaseUpdateShowing)
                    {
                        Button("Cancel", role:.cancel)
                        {
                            let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Cancel' to 'download' the App RELEASE - resuming...")
                        }
                        Button("Ok", role:.destructive)
                        {
                            let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Ok' to 'download' the App RELEASE - updating...")
      
                            self.downloadAppReleaseUpdate()
                        }
                    }
                    .padding()
      
                    Spacer()
      
                    Button
                    {
                        self.cAppPreReleaseUpdateButtonPresses += 1
      
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsSingleViewCore in Button(Xcode).'App 'download' Pre-Release'.#(\(self.cAppPreReleaseUpdateButtonPresses))...")
      
                        self.isAppDownloadPreReleaseUpdateShowing.toggle()
                    }
                    label: 
                    {
                    if #available(iOS 14.0, *) 
                    {
                        VStack(alignment:.center)
                        {
                            Label("", systemImage: "arrow.down.app.fill")
                                .help(Text("App 'download' Pre-Release"))
                                .imageScale(.large)
                            Text("Update PreRelease")
                                .font(.caption2)
                        }
                    } 
                    else 
                    {
                        Text("App 'download' Pre-Release")
                    }
                    }
                    .alert("Do you want to 'download' (and install) the App Pre-Release?", isPresented:$isAppDownloadPreReleaseUpdateShowing)
                    {
                        Button("Cancel", role:.cancel)
                        {
                            let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Cancel' to 'download' the App Pre-Release - resuming...")
                        }
                        Button("Ok", role:.destructive)
                        {
                            let _ = appLogMsg("\(ClassInfo.sClsDisp) User pressed 'Ok' to 'download' the App Pre-Release - updating...")
      
                            self.downloadAppPreReleaseUpdate()
      
                        }
                    }
                    .padding()
      
                    Spacer()
                }
                HStack(alignment:.center)
                {
                    Spacer()
                    Text(" - - - - - - - - - - - - - - - ")
                        .bold()
                    Spacer()
                }
            }
        }
        #endif

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
        .padding()

    }

    private func finishAppInitialization()
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Finish the App 'initialization'...
  
        appLogMsg("\(ClassInfo.sClsDisp) Invoking the 'jmAppDelegateVisitor.checkAppDelegateVisitorTraceLogFileForSize()'...")

        self.jmAppDelegateVisitor.checkAppDelegateVisitorTraceLogFileForSize()

        appLogMsg("\(ClassInfo.sClsDisp) Invoked  the 'jmAppDelegateVisitor.checkAppDelegateVisitorTraceLogFileForSize()'...")

        // Exit...
  
        appLogMsg("\(sCurrMethodDisp) Exiting...")
  
        return

    } // End of private func finishAppInitialization().

    func checkIfAppLogWasPresent() -> Bool
    {
  
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")
  
        appLogMsg("\(sCurrMethodDisp) 'jmAppDelegateVisitor' is [\(String(describing: jmAppDelegateVisitor))] - details are [\(jmAppDelegateVisitor.toString())]...")
  
        let bWasAppLogPresentAtStart:Bool = jmAppDelegateVisitor.bWasAppLogFilePresentAtStartup
        
        // Exit...
  
        appLogMsg("\(sCurrMethodDisp) Exiting - 'bWasAppLogPresentAtStart' is [\(String(describing: bWasAppLogPresentAtStart))]...")
  
        return bWasAppLogPresentAtStart
  
    }   // End of checkIfAppLogWasPresent().

    func checkIfAppDidCrash() -> Bool
    {
  
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")
  
        appLogMsg("\(sCurrMethodDisp) 'jmAppDelegateVisitor' is [\(String(describing: jmAppDelegateVisitor))] - details are [\(jmAppDelegateVisitor.toString())]...")
  
        let bDidAppCrashOnLastRun:Bool = jmAppDelegateVisitor.bWasAppCrashFilePresentAtStartup
  
        appLogMsg("\(sCurrMethodDisp) 'bDidAppCrashOnLastRun' is [\(String(describing: bDidAppCrashOnLastRun))]...")
        
        // Exit...
  
        appLogMsg("\(sCurrMethodDisp) Exiting - 'bDidAppCrashOnLastRun' is [\(String(describing: bDidAppCrashOnLastRun))]...")
  
        return bDidAppCrashOnLastRun
  
    }   // End of checkIfAppDidCrash().

    private func uploadCurrentAppLogToDevs()
    {
  
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Prepare specifics to 'upload' the AppLog file...

        var urlAppDelegateVisitorLogFilepath:URL?     = nil
        var urlAppDelegateVisitorLogFilespec:URL?     = nil
        var sAppDelegateVisitorLogFilespec:String!    = nil
        var sAppDelegateVisitorLogFilepath:String!    = nil
        var sAppDelegateVisitorLogFilenameExt:String! = nil

        do 
        {
            urlAppDelegateVisitorLogFilepath  = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask ,appropriateFor: nil, create: true)
            urlAppDelegateVisitorLogFilespec  = urlAppDelegateVisitorLogFilepath?.appendingPathComponent(AppGlobalInfo.sGlobalInfoAppLogFilespec)
            sAppDelegateVisitorLogFilespec    = urlAppDelegateVisitorLogFilespec?.path
            sAppDelegateVisitorLogFilepath    = urlAppDelegateVisitorLogFilepath?.path
            sAppDelegateVisitorLogFilenameExt = urlAppDelegateVisitorLogFilespec?.lastPathComponent

            appLogMsg("[\(sCurrMethodDisp)] 'sAppDelegateVisitorLogFilespec'    (computed) is [\(String(describing: sAppDelegateVisitorLogFilespec))]...")
            appLogMsg("[\(sCurrMethodDisp)] 'sAppDelegateVisitorLogFilepath'    (resolved #2) is [\(String(describing: sAppDelegateVisitorLogFilepath))]...")
            appLogMsg("[\(sCurrMethodDisp)] 'sAppDelegateVisitorLogFilenameExt' (computed) is [\(String(describing: sAppDelegateVisitorLogFilenameExt))]...")
        }
        catch
        {
            appLogMsg("[\(sCurrMethodDisp)] Failed to 'stat' item(s) in the 'path' of [.documentDirectory] - Error: \(error)...")
        }

        // Check that the 'current' App LOG file 'exists'...

        let bIsCurrentAppLogFilePresent:Bool = JmFileIO.fileExists(sFilespec:sAppDelegateVisitorLogFilespec)

        if (bIsCurrentAppLogFilePresent == true)
        {
            appLogMsg("[\(sCurrMethodDisp)] Preparing to Zip the 'source' filespec ('current' App LOG) of [\(String(describing: sAppDelegateVisitorLogFilespec))]...")
        }
        else
        {
            let sZipFileErrorMsg:String = "Unable to Zip the 'current' App LOG of [\(String(describing: sAppDelegateVisitorLogFilespec))] - the file does NOT Exist - Error!"

            DispatchQueue.main.async
            {
                self.jmAppDelegateVisitor.setAppDelegateVisitorSignalGlobalAlert("Alert::\(sZipFileErrorMsg)",
                                                                                 alertButtonText:"Ok")
            }

            appLogMsg("[\(sCurrMethodDisp)] \(sZipFileErrorMsg)")

            // Exit...

            appLogMsg("\(sCurrMethodDisp) Exiting...")

            return
        }

        // Create the AppLog's 'multipartRequestInfo' object (but WITHOUT any Data (yet))...

        let multipartRequestInfo:MultipartRequestInfo       = MultipartRequestInfo()

        multipartRequestInfo.bAppZipSourceToUpload          = false
        multipartRequestInfo.sAppUploadURL                  = ""          // "" takes the Upload URL 'default'...
        multipartRequestInfo.sAppUploadNotifyTo             = ""          // This is email notification - "" defaults to all Dev(s)...
        multipartRequestInfo.sAppUploadNotifyCc             = ""          // This is email notification - "" defaults to 'none'...
        multipartRequestInfo.sAppSourceFilespec             = sAppDelegateVisitorLogFilespec
        multipartRequestInfo.sAppSourceFilename             = sAppDelegateVisitorLogFilenameExt
        multipartRequestInfo.sAppZipFilename                = sAppDelegateVisitorLogFilenameExt
        multipartRequestInfo.sAppSaveAsFilename             = sAppDelegateVisitorLogFilenameExt
        multipartRequestInfo.sAppFileMimeType               = "text/plain"

        // Create the AppLog's 'multipartRequestInfo.dataAppFile' object...

        multipartRequestInfo.dataAppFile                    = FileManager.default.contents(atPath: sAppDelegateVisitorLogFilespec)

        appLogMsg("\(sCurrMethodDisp) The 'upload' is using 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo.toString()))]...")

        // Attempting to 'zip' the file (content(s))...

        let multipartZipFileCreator:MultipartZipFileCreator = MultipartZipFileCreator()

        multipartRequestInfo.sAppZipFilename                = multipartRequestInfo.sAppSourceFilename

        var urlCreatedZipFile:URL? = multipartZipFileCreator.createTargetZipFileFromSource(multipartRequestInfo:multipartRequestInfo)

        // Check if we actually got the 'target' Zip file created...

        if let urlCreatedZipFile = urlCreatedZipFile 
        {
            appLogMsg("\(sCurrMethodDisp) Produced a Zip file 'urlCreatedZipFile' of [\(urlCreatedZipFile)]...")

            multipartRequestInfo.sAppZipFilename  = "\(multipartRequestInfo.sAppZipFilename).zip"
        } 
        else 
        {
            appLogMsg("\(sCurrMethodDisp) Failed to produce a Zip file - the 'target' Zip filename was [\(multipartRequestInfo.sAppZipFilename)] - Error!")

            multipartRequestInfo.sAppZipFilename  = "-N/A-"
            multipartRequestInfo.sAppFileMimeType = "text/plain"
            multipartRequestInfo.dataAppFile      = FileManager.default.contents(atPath: sAppDelegateVisitorLogFilespec)

            appLogMsg("\(sCurrMethodDisp) Reset the 'multipartRequestInfo' to upload the <raw> file without 'zipping'...")

            urlCreatedZipFile = nil
        }

        // If this is NOT an 'internal' Zip 'test', then send the upload:

        if (bInternalZipTest == false)
        {
            // Send the AppLog as an 'upload' to the Server...

            let multipartRequestDriver:MultipartRequestDriver = MultipartRequestDriver(bGenerateResponseLongMsg:true)

            appLogMsg("\(sCurrMethodDisp) Using 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo.toString()))]...")
            appLogMsg("\(sCurrMethodDisp) Calling 'multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:)'...")

            multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:multipartRequestInfo)

            appLogMsg("\(sCurrMethodDisp) Called  'multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:)'...")
        }

        // Exit...
  
        appLogMsg("\(sCurrMethodDisp) Exiting...")
  
        return
  
    }   // End of private func uploadCurrentAppLogToDevs().

    func uploadPreviousAppLogToDevs()
    {
  
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Prepare specifics to 'upload' the AppLog file...

        var urlAppDelegateVisitorLogFilepath:URL?     = nil
        var urlAppDelegateVisitorLogFilespec:URL?     = nil
        var sAppDelegateVisitorLogFilespec:String!    = nil
        var sAppDelegateVisitorLogFilepath:String!    = nil
        var sAppDelegateVisitorLogFilenameExt:String! = nil

        do 
        {
            urlAppDelegateVisitorLogFilepath  = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask ,appropriateFor: nil, create: true)
            urlAppDelegateVisitorLogFilespec  = urlAppDelegateVisitorLogFilepath?.appendingPathComponent(sAppExecutionPreviousLogToUpload)
            sAppDelegateVisitorLogFilespec    = urlAppDelegateVisitorLogFilespec?.path
            sAppDelegateVisitorLogFilepath    = urlAppDelegateVisitorLogFilepath?.path
            sAppDelegateVisitorLogFilenameExt = urlAppDelegateVisitorLogFilespec?.lastPathComponent

            appLogMsg("[\(sCurrMethodDisp)] 'sAppDelegateVisitorLogFilespec'    (computed) is [\(String(describing: sAppDelegateVisitorLogFilespec))]...")
            appLogMsg("[\(sCurrMethodDisp)] 'sAppDelegateVisitorLogFilepath'    (resolved #2) is [\(String(describing: sAppDelegateVisitorLogFilepath))]...")
            appLogMsg("[\(sCurrMethodDisp)] 'sAppDelegateVisitorLogFilenameExt' (computed) is [\(String(describing: sAppDelegateVisitorLogFilenameExt))]...")
        }
        catch
        {
            appLogMsg("[\(sCurrMethodDisp)] Failed to 'stat' item(s) in the 'path' of [.documentDirectory] - Error: \(error)...")
        }

        // Create the AppLog's 'multipartRequestInfo' object (but WITHOUT any Data (yet))...

        let multipartRequestInfo:MultipartRequestInfo     = MultipartRequestInfo()

        multipartRequestInfo.bAppZipSourceToUpload        = false
        multipartRequestInfo.sAppUploadURL                = ""          // "" takes the Upload URL 'default'...
        multipartRequestInfo.sAppUploadNotifyTo           = ""          // This is email notification - "" defaults to all Dev(s)...
        multipartRequestInfo.sAppUploadNotifyCc           = ""          // This is email notification - "" defaults to 'none'...
        multipartRequestInfo.sAppSourceFilespec           = sAppDelegateVisitorLogFilespec
        multipartRequestInfo.sAppSourceFilename           = sAppDelegateVisitorLogFilenameExt
        multipartRequestInfo.sAppZipFilename              = "-N/A-"
        multipartRequestInfo.sAppSaveAsFilename           = sAppDelegateVisitorLogFilenameExt
        multipartRequestInfo.sAppFileMimeType             = "text/plain"

        // Create the AppLog's 'multipartRequestInfo.dataAppFile' object...

        multipartRequestInfo.dataAppFile                  = FileManager.default.contents(atPath: sAppDelegateVisitorLogFilespec)

        appLogMsg("\(sCurrMethodDisp) The 'upload' is using 'multipartRequestInfo' of [\(String(describing: multipartRequestInfo.toString()))]...")

        // Send the AppLog as an 'upload' to the Server...

        let multipartRequestDriver:MultipartRequestDriver = MultipartRequestDriver(bGenerateResponseLongMsg:self.bIsAppUploadUsingLongMsg)

        appLogMsg("\(sCurrMethodDisp) Calling 'multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:)'...")

        multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:multipartRequestInfo)
        
        appLogMsg("\(sCurrMethodDisp) Called  'multipartRequestDriver.executeMultipartRequest(multipartRequestInfo:)'...")

        // Exit...
  
        appLogMsg("\(sCurrMethodDisp) Exiting...")
  
        return
  
    }   // End of uploadPreviousAppLogToDevs().

#if os(iOS)
    private func downloadAppReleaseUpdate()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        if (AppGlobalInfo.bEnableAppReleaseDownloads == true)
        {
            // Open the URL that will download (and install) the App Release UPDATE...

            let urlToOpen:URL = URL(string:"itms-services://?action=download-manifest&url=https://raw.githubusercontent.com/DFW-PMA/VisitShareExtension/refs/heads/main/VisitShareExtension/VisitShareExtension.plist")!

            appLogMsg("\(sCurrMethodDisp) Calling 'AppDelegate.openAppSuppliedURL(urlToOpen:)' to download and install the App Release on the URL of [\(urlToOpen)]...")

            self.openAppSuppliedURL(urlToOpen:urlToOpen)

            appLogMsg("\(sCurrMethodDisp) Called  'AppDelegate.openAppSuppliedURL(urlToOpen:)' to download and install the App Release on the URL of [\(urlToOpen)]...")

            // Suspend this App...

            appLogMsg("\(sCurrMethodDisp) Suspending this App...")

            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of private func downloadAppReleaseUpdate().

    private func downloadAppPreReleaseUpdate()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        if (AppGlobalInfo.bEnableAppReleaseDownloads == true)
        {
            // Open the URL that will download (and install) the App Release UPDATE...

            let urlToOpen:URL = URL(string:"itms-services://?action=download-manifest&url=https://raw.githubusercontent.com/DFW-PMA/VisitShareExtension/refs/heads/main/VisitShareExtension/VisitShareExtension_Pre.plist")!

            appLogMsg("\(sCurrMethodDisp) Calling 'AppDelegate.openAppSuppliedURL(urlToOpen:)' to download and install the App Pre-Release on the URL of [\(urlToOpen)]...")

            self.openAppSuppliedURL(urlToOpen:urlToOpen)

            appLogMsg("\(sCurrMethodDisp) Called  'AppDelegate.openAppSuppliedURL(urlToOpen:)' to download and install the App Pre-Release on the URL of [\(urlToOpen)]...")

            // Suspend this App...

            appLogMsg("\(sCurrMethodDisp) Suspending this App...")

            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of private func downloadAppPreReleaseUpdate().
#endif

    private func openAppSuppliedURL(urlToOpen:URL)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - parameter 'urlToOpen' is [\(urlToOpen)]...")

        // Open the supplied URL...

    #if os(macOS)
        NSWorkspace.shared.open(urlToOpen)
    #elseif os(iOS)
        UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
    #endif

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of private func openAppSuppliedURL(urlToOpen:URL).

}   // End of struct SettingsSingleViewCore:View. 

#Preview 
{
    SettingsSingleViewCore()
}

