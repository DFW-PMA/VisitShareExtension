//
//  SettingsDataGridView.swift
//  SpreadsheetXMLViewer
//
//  Settings for spreadsheet display preferences
//  v1.0201 - User-controlled column resizing preference
//

import Foundation
import SwiftUI

// MARK: - CSV Delimiter Type Enum

enum CSVDelimiterType:String, CaseIterable, Identifiable
{
    case comma     = "comma"
    case pipe      = "pipe"
    case semicolon = "semicolon"
    case tab       = "tab"
    case custom    = "custom"
    
    var id:String { self.rawValue }
    
    var displayName:String
    {
        switch self
        {
        case .comma:     return "Comma (,)"
        case .pipe:      return "Pipe (|)"
        case .semicolon: return "Semicolon (;)"
        case .tab:       return "Tab (\\t)"
        case .custom:    return "Custom"
        }
    }
    
    var delimiter:String
    {
        switch self
        {
        case .comma:     return ","
        case .pipe:      return "|"
        case .semicolon: return ";"
        case .tab:       return "\t"
        case .custom:    return ""  // Will use custom value
        }
    }
}

struct SettingsDataGridView:View
{
    
    struct ClassInfo 
    {
        static let sClsId        = "SettingsDataGridView"
        static let sClsVers      = "v1.0901"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright © JustMacApps 2023-2026. All rights reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }
    
    // MARK: - Properties...
    
//  @Environment(\.dismiss)              var dismiss
    @Environment(\.presentationMode)     var presentationMode
    @Environment(\.openWindow)           var openWindow
    @Environment(\.openURL)              var openURL
    @Environment(\.appGlobalDeviceType)  var appGlobalDeviceType

    // 'Internal' Trace flag:

                    private var bInternalTraceFlag:Bool           = false

    // App Data field(s):

                            var appGlobalInfo:AppGlobalInfo       = AppGlobalInfo.ClassSingleton.appGlobalInfo
                            var helpBasicLoader:HelpBasicLoader   = HelpBasicLoader()

    @AppStorage("enableColumnResizing") 
                    private var enableColumnResizing              = false

    @AppStorage("csvAutoDetectHeaders") 
                    private var csvAutoDetectHeaders              = true
    
    @AppStorage("csvForceHeaderRow") 
                    private var csvForceHeaderRow                 = false
    
    @AppStorage("csvDelimiterType")
                    private var csvDelimiterTypeString            = CSVDelimiterType.comma.rawValue
    
    @AppStorage("csvCustomDelimiter")
                    private var csvCustomDelimiter                = ","
    
    @State          private var selectedDelimiterType:CSVDelimiterType = .comma

    @State          private var cAppAboutButtonPresses:Int        = 0
    @State          private var cAppHelpViewButtonPresses:Int     = 0

    @State          private var isAppAboutViewModal:Bool          = false
    @State          private var isAppHelpViewModal:Bool           = false
    @State          private var sHelpBasicContents:String         = "-N/A-"

    @AppStorage("helpBasicMode") 
                            var helpBasicMode                     = HelpBasicMode.simpletext
    
    init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Finish the App 'initialization'...

    //  self.finishAppInitialization()

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of init().

    var body:some View
    {

        NavigationStack
        {
            Form
            {
                Section
                {
                    Toggle("Enable Column Resizing", isOn:$enableColumnResizing)
                        .onChange(of:enableColumnResizing) 
                        { oldValue, newValue in

                            appLogMsg("\(ClassInfo.sClsDisp) ✓ Settings: Column resizing now [\(newValue ? "ENABLED" : "DISABLED")] - was [\(oldValue ? "ENABLED" : "DISABLED")]")

                        }
                } 
                header: 
                {
                    Text("Display Options")
                } 
                footer: 
                {
                    Text("When enabled, drag column borders to resize. When disabled, tap any cell to view full content in a detail sheet.")
                        .font(.caption2)
                }
                
                Section
                {
                    Toggle("Auto-Detect CSV Headers", isOn:$csvAutoDetectHeaders)
                        .onChange(of:csvAutoDetectHeaders) 
                        { oldValue, newValue in

                            appLogMsg("\(ClassInfo.sClsDisp) ✓ Settings: CSV auto-detect headers now [\(newValue ? "ENABLED" : "DISABLED")] - was [\(oldValue ? "ENABLED" : "DISABLED")]")
                            
                            // If auto-detect is enabled, disable force header
                            if (newValue == true)
                            {
                                csvForceHeaderRow = false
                            }

                        }
                    
                    Toggle("Force First Row as Headers", isOn:$csvForceHeaderRow)
                        .onChange(of:csvForceHeaderRow) 
                        { oldValue, newValue in

                            appLogMsg("\(ClassInfo.sClsDisp) ✓ Settings: CSV force header row now [\(newValue ? "ENABLED" : "DISABLED")] - was [\(oldValue ? "ENABLED" : "DISABLED")]")
                            
                            // If force header is enabled, disable auto-detect
                            if (newValue == true)
                            {
                                csvAutoDetectHeaders = false
                            }

                        }
                        .disabled(csvAutoDetectHeaders == true)
                } 
                header: 
                {
                    Text("CSV Import Options")
                } 
                footer: 
                {
                    Text("Auto-detect analyzes the first two rows to determine if row 1 contains column headers. Force header treats row 1 as headers regardless of content. If both are off, all rows are treated as data.")
                        .font(.caption2)
                }
                
                Section
                {
                    Picker("Delimiter", selection:$selectedDelimiterType)
                    {
                        ForEach(CSVDelimiterType.allCases)
                        { delimiterType in
                            Text(delimiterType.displayName).tag(delimiterType)
                        }
                    }
                    .onChange(of:selectedDelimiterType)
                    { oldValue, newValue in
                        
                        appLogMsg("\(ClassInfo.sClsDisp) ✓ Settings: CSV delimiter type changed from [\(oldValue.displayName)] to [\(newValue.displayName)]")
                        
                        // Save the raw value string for persistence
                        csvDelimiterTypeString = newValue.rawValue
                        
                        // If not custom, update the custom delimiter field with the standard value
                        if (newValue != .custom)
                        {
                            csvCustomDelimiter = newValue.delimiter
                            appLogMsg("\(ClassInfo.sClsDisp) ✓ Settings: CSV delimiter set to [\(csvCustomDelimiter)]")
                        }
                        
                    }
                    
                    // Custom delimiter text field - only visible when Custom is selected
                    if (selectedDelimiterType == .custom)
                    {
                        HStack
                        {
                            Text("Custom Delimiter:")
                                .font(.body)
                            TextField("Enter delimiter", text:$csvCustomDelimiter)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design:.monospaced))
                            #if os(iOS)
                                .autocapitalization(.none)
                            #endif
                                .disableAutocorrection(true)
                                .onChange(of:csvCustomDelimiter)
                                { oldValue, newValue in
                                    
                                    appLogMsg("\(ClassInfo.sClsDisp) ✓ Settings: Custom CSV delimiter changed from [\(oldValue)] to [\(newValue)]")
                                    
                                }
                        }
                    }
                }
                header:
                {
                    Text("CSV Delimiter")
                }
                footer:
                {
                    if (selectedDelimiterType == .custom)
                    {
                        Text("Enter any delimiter string. Examples: single characters like '|' or ';', or multi-character strings like '->;' or '::'. The delimiter separates fields in each row.")
                            .font(.caption2)
                    }
                    else
                    {
                        Text("Select the character(s) used to separate fields in CSV files. Most files use comma, but some (like Texas state files) use pipe '|' or semicolon ';'.")
                            .font(.caption2)
                    }
                }
            }
            .navigationTitle("DataGrid Settings")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar
            {
            //  ToolbarItem(placement:.navigationBarLeading) 
            //  {
            //      Button
            //      {
            //          self.cAppAboutButtonPresses += 1
            //
            //          let _ = appLogMsg("SettingsView.Button(Xcode).'App About'.#(\(self.cAppAboutButtonPresses))...")
            //
            //          self.isAppAboutViewModal.toggle()
            //      }
            //      label:
            //      {
            //          VStack(alignment:.center)
            //          {
            //              Label("", systemImage: "questionmark.diamond")
            //                  .help(Text("App About Information"))
            //                  .imageScale(.small)
            //              Text("About")
            //                  .font(.caption2)
            //          }
            //      }
            //      .fullScreenCover(isPresented:$isAppAboutViewModal)
            //      {
            //          AppAboutView()
            //      }
            //  #if os(macOS)
            //      .buttonStyle(.borderedProminent)
            //  //  .background(???.isPressed ? .blue : .gray)
            //      .cornerRadius(10)
            //      .foregroundColor(Color.primary)
            //  #endif
            //      .padding()
            //  }
            //
            //  ToolbarItem(placement:.navigationBarLeading) 
            //  {
            //      Button
            //      {
            //          self.cAppHelpViewButtonPresses += 1
            //
            //          let _ = appLogMsg("SettingsView.Button(Xcode).'App Help'.#(\(self.cAppHelpViewButtonPresses))...")
            //
            //          self.isAppHelpViewModal.toggle()
            //      }
            //      label:
            //      {
            //          VStack(alignment:.center)
            //          {
            //              Label("", systemImage: "questionmark.circle")
            //                  .help(Text("App HELP Information"))
            //                  .imageScale(.small)
            //              Text("Help")
            //                  .font(.caption2)
            //          }
            //      }
            //      .fullScreenCover(isPresented:$isAppHelpViewModal)
            //      {
            //      //  HelpBasicView(sHelpBasicContents:jmAppDelegateVisitor.getAppDelegateVisitorHelpBasicContents())
            //      //  HelpBasicView(sHelpBasicContents:"---working-on-it---")
            //      //  HelpBasicView(sHelpBasicContents:self.sHelpBasicContents)
            //          HelpBasicView(sHelpBasicContents:self.getAppHelpBasicContents())
            //              .navigationBarBackButtonHidden(true)
            //      }
            //  #if os(macOS)
            //      .buttonStyle(.borderedProminent)
            //  //  .background(???.isPressed ? .blue : .gray)
            //      .cornerRadius(10)
            //      .foregroundColor(Color.primary)
            //  #endif
            //      .padding()
            //  }
          
            //  ToolbarItem(placement:.navigationBarTrailing)
                ToolbarItem(placement:.primaryAction)
                {
                    Button
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):SettingsView.Button(Xcode).'Dismiss' pressed...")
          
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
                    .padding()
                }
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

    }

    private func finishAppInitialization()
    {

        let sCurrMethod:String     = #function;
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Finish the App 'initialization'...
        
        // Load saved delimiter type from AppStorage...

        if let savedType = CSVDelimiterType(rawValue:csvDelimiterTypeString)
        {
            selectedDelimiterType = savedType

            appLogMsg("\(sCurrMethodDisp) Loaded CSV delimiter type: [\(savedType.displayName)]")
        }
        else
        {
            // Default to comma if invalid value stored...

            selectedDelimiterType  = .comma
            csvDelimiterTypeString = CSVDelimiterType.comma.rawValue

            appLogMsg("\(sCurrMethodDisp) Defaulted to comma delimiter (invalid stored value)")
        }
        
        appLogMsg("\(sCurrMethodDisp) Current custom delimiter: [\(csvCustomDelimiter)]...")

        // Exit...

        appLogMsg("\(sCurrMethodDisp) Exiting...")
  
        return

    } // End of private func finishAppInitialization().
    
//  private func getAppHelpBasicContents()->String
//  {
//
//      let sCurrMethod:String     = #function;
//      let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
//
//      appLogMsg("\(sCurrMethodDisp) Invoked...")
//
//      // Obtain the App 'help' string...
//
//      if (self.bInternalTraceFlag == true)
//      {
//          appLogMsg("\(sCurrMethodDisp) 'helpBasicLoader' is [\(String(describing:helpBasicLoader))]...")
//      }
//
//      var sHelpBasicContents:String   = "-None-Available-"
//      var bWasHelpSetupPerformed:Bool = false
//
//      if (helpBasicLoader.bHelpSetupRequired == true)
//      {
//          appLogMsg("\(sCurrMethodDisp) Setting up HELP 'basic' content(s) - 'helpBasicLoader.bHelpSetupRequired' is [\(String(describing:helpBasicLoader.bHelpSetupRequired))]...")
//
//          sHelpBasicContents                 = helpBasicLoader.loadHelpBasicContents(helpbasicfileext:AppGlobalInfo.sHelpBasicFileExt, helpbasicloadertag:"'get...()'")
//          helpBasicLoader.bHelpSetupRequired = false
//          bWasHelpSetupPerformed             = true
//
//          if (self.bInternalTraceFlag == true)
//          {
//              appLogMsg("\(sCurrMethodDisp) 'helpBasicLoader.bHelpSetupRequired' is [\(String(describing:helpBasicLoader.bHelpSetupRequired))] - 'sHelpBasicContents' is [\(sHelpBasicContents)]...")
//          }
//
//      //  jmAppSyncUpdateUIOnMainThread
//      //  {
//      //      self.sHelpBasicContents = sHelpBasicContents
//      //
//      //      appLogMsg("\(sCurrMethodDisp) Setting up the HELP 'basic' content(s) of #(\(self.sHelpBasicContents.count)) byte(s) from the 'loader' of #(\(sHelpBasicContents.count)) byte(s) - complete...")
//      //  }
//      }
//      else
//      {
//
//          sHelpBasicContents     = helpBasicLoader.sHelpBasicContents
//          bWasHelpSetupPerformed = false
//      }
//
//      // Exit:
//
//      if (self.bInternalTraceFlag == true)
//      {
//          appLogMsg("\(sCurrMethodDisp) 'bWasHelpSetupPerformed' is [\(bWasHelpSetupPerformed)] - 'helpBasicLoader.bHelpSetupRequired' is [\(String(describing:helpBasicLoader.bHelpSetupRequired))] - 'self.sHelpBasicContents' is [\(self.sHelpBasicContents)]...")
//      }
//
//      // Exit...
//
//      appLogMsg("\(sCurrMethodDisp) Exiting...")
//
//      return sHelpBasicContents
//
//  } // End of private func getAppHelpBasicContents()->String.
    
}   // End of struct SettingsDataGridView:View.

#Preview 
{
    SettingsDataGridView()
}

