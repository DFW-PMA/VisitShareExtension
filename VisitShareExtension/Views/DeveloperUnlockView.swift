//
//  DeveloperUnlockView.swift
//  HOTP 2FA Validator - Production-Style Flow
//
//  Updated:2026-05-28 - Added HOTP mode toggle, JmDeveloperUnlockSecret (XOR obfuscation),
//                       JmDeveloperUnlockManager (singleton, counter persistence, expiry),
//                       DeveloperUnlockView, DeveloperFeaturesView.
//

import JmEntityInfo
import Foundation
import SwiftUI
import SwiftData
import SwiftOTP
import Combine
import CoreImage.CIFilterBuiltins

// MARK:- Developer Unlock View

// <<CHICKEN-TRACKS>> Presented via hidden gesture on App icon in SettingsSingleViewCore.
// In production: move to its own DeveloperUnlockView.swift file in a shared module.
// DeveloperFeaturesView stays per-app (different options per app).

@JmEntityInfo(vers:"v1.0701")
struct DeveloperUnlockView:View
{

    //  struct ClassInfo
    //  {
        //  static let sClsId        = "DeveloperUnlockView"
        //  static let sClsVers      = "v1.0601"
        //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
        //  static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    // App Data field(s):

//  @Environment(\.dismiss)          var dismiss
    @Environment(\.presentationMode) var presentationMode

    // <<CHICKEN-TRACKS>> @ObservedObject (not @StateObject) because JmDeveloperUnlockManager
    // is a singleton whose lifecycle we do NOT own.  The singleton is always alive so
    // @ObservedObject deallocation is not a concern.

    @ObservedObject private var devUnlockMgr:JmDeveloperUnlockManager  = JmDeveloperUnlockManager.shared

    // <<CHICKEN-TRACKS>> tfaManager not needed here - the debug display uses
    // devUnlockMgr.sCurrentExpectedCode (the baked-in developer secret) rather than
    // the user's enrolled 2FA account.  Retained commented-out in case a future
    // version of this view needs access to the user's account state.
//  @ObservedObject private var tfaManager:TwoFactorManager          = TwoFactorManager.shared

    @State          private var sEnteredCode:String                  = ""
    @State          private var bShowDevFeatures:Bool                = false

    var body:some View
    {

        let _ = appLogMsg("\(ClassInfo.sClsDisp):body - 'isDevModeActive' is [\(devUnlockMgr.isDevModeActive)]...")

        NavigationStack
        {
            VStack(spacing:25)
            {
                Spacer()

                // Header icon + status...

                VStack(spacing:12)
                {
                    Image(systemName:devUnlockMgr.isDevModeActive ? "lock.open.fill" : "lock.fill")
                        .font(.system(size:70))
                        .foregroundColor(devUnlockMgr.isDevModeActive ? .green : .orange)

                    Text("Developer Access")
                        .font(.title2)
                        .fontWeight(.bold)

                    if devUnlockMgr.isDevModeActive
                    {
                        VStack(spacing:4)
                        {
                            Text("🟢 Active")
                                .font(.headline)
                                .foregroundColor(.green)

                            Text(devUnlockMgr.sTimeRemainingDisplay)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                        }
                        .padding(10)
                        .background(Color.green.opacity(0.12))
                        .cornerRadius(8)
                    }
                    else
                    {
                        Text("Enter your HOTP developer code to unlock developer features for 60 minutes.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                Spacer()

                // HOTP code entry (only shown when not yet active)...

                if (!devUnlockMgr.isDevModeActive)
                {
                    VStack(spacing:15)
                    {
                        Text(devUnlockMgr.validationState.sMessage)
                            .font(.subheadline)
                            .foregroundColor(devUnlockMgr.validationState.colorState)
                            .multilineTextAlignment(.center)

                        TextField("000000", text:$sEnteredCode)
                            .font(.system(size:42, weight:.bold, design:.monospaced))
                            .multilineTextAlignment(.center)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                            .padding(.horizontal)
                        #endif
                            .frame(height:70)
                        //  .background(Color.appSystemGray6)
                        #if os(macOS)
                            .background(Color(nsColor:.systemGray))
                        #endif
                        #if os(iOS)
                            .background(Color(UIColor.systemGray6))
                        #endif
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .onChange(of:sEnteredCode) { _, sNew in
                                if sNew.count > 6 { sEnteredCode = String(sNew.prefix(6)) }
                                if sNew.count == 6
                                {
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.3)
                                    {
                                        devUnlockMgr.validateCode(sEnteredCode)
                                    }
                                }
                            }

                        Button(action: { devUnlockMgr.validateCode(sEnteredCode) })
                        {
                            Label("Validate", systemImage:"checkmark.shield.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth:.infinity)
                                .padding()
                                .background(sEnteredCode.count == 6 ? Color.orange : Color.gray)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .disabled(sEnteredCode.count != 6)
                                    
                        Spacer()
                        
                        // Debug display: the code JmDeveloperUnlockManager currently expects.
                        // <<CHICKEN-TRACKS>> Uses devUnlockMgr (not tfaManager) because the
                        // developer unlock has its own baked-in secret entirely separate from
                        // the user's enrolled 2FA accounts.  tfaManager engines are only
                        // initialized after an account is loaded in the main flow - they are
                        // not available here.
                        
                        VStack(spacing:8) 
                        {
                            Text("HOTP expects: \(devUnlockMgr.sCurrentExpectedCode)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(.systemYellow).opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.bottom)
                    }
                }

                // Developer Features button + Lock button (only shown when active)...

                if devUnlockMgr.isDevModeActive
                {
                    VStack(spacing:12)
                    {
                        Button(action:{ bShowDevFeatures = true })
                        {
                            Label("View Developer Features", systemImage:"wrench.and.screwdriver.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth:.infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        Button(action:{ devUnlockMgr.deactivate() })
                        {
                            Label("Lock Developer Mode", systemImage:"lock.fill")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                #if os(macOS)
                    .sheet(isPresented:$bShowDevFeatures)
                    {
                        DeveloperFeaturesView()
                    }
                #endif
                #if os(iOS)
                    .fullScreenCover(isPresented:$bShowDevFeatures)
                    {
                        DeveloperFeaturesView()
                    }
                #endif
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Developer Unlock")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement:.primaryAction)
                {
                    Button("Dismiss") { presentationMode.wrappedValue.dismiss() }
                    #if os(macOS)
                        .buttonStyle(.borderedProminent)
                        .padding()
                    //  .background(???.isPressed ? .blue : .gray)
                        .cornerRadius(10)
                        .foregroundColor(Color.primary)
                    #endif
                }
            }
        #endif
        #if os(macOS)
            // <<CHICKEN-TRACKS>> (2026-06-24) — 'ToolbarItem(placement:.primaryAction)' is a
            // title-bar placement; macOS '.sheet()' panels have no title bar, so that toolbar item
            // silently never renders here, leaving no way to dismiss this view (it works fine on
            // iOS because '.fullScreenCover' there is a full window, not a sheet). Use a plain
            // in-body Dismiss button instead, matching the xmark.circle/"Dismiss" style used
            // elsewhere in this app (see NWSNexRadRadarViews.swift).
            .overlay(alignment:.topTrailing)
            {
                Button { presentationMode.wrappedValue.dismiss() }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage:"xmark.circle").imageScale(.medium)
                        Text("Dismiss").font(.caption2)
                    }
                }
                .buttonStyle(.plain)
            #if os(macOS)
                .buttonStyle(.borderedProminent)
                .padding()
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
                .padding()
            }
        #endif
            .onChange(of:devUnlockMgr.isDevModeActive) { _, bNewVal in
                if bNewVal { sEnteredCode = "" }      // Clear the field on success
            }
        }
    }

}   // End of struct DeveloperUnlockView:View.

// MARK:- Developer Features View

// <<CHICKEN-TRACKS>> Per-app developer options (DataGrid, Directories, Test ZIP,
// Force CRASH, and any other App-specific items) live in SettingsSingleViewCore,
// gated by devUnlockMgr.isDevModeActive.  This view shows session status, the
// redirect note, and the Lock button.  Dismiss here to return to Settings where
// the developer sections are now visible.

@JmEntityInfo(vers:"v1.0601")
struct DeveloperFeaturesView:View
{

    //  struct ClassInfo
    //  {
        //  static let sClsId        = "DeveloperFeaturesView"
        //  static let sClsVers      = "v1.0501"
        //  static let sClsDisp      = sClsId+".("+sClsVers+"): "
        //  static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        //  static let bClsTrace     = true
        //  static let bClsFileLog   = true
    //  }

    // App Data field(s):

//  @Environment(\.dismiss)          var dismiss
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject private var devUnlockMgr:JmDeveloperUnlockManager = JmDeveloperUnlockManager.shared

    var body:some View
    {

        let _ = appLogMsg("\(ClassInfo.sClsDisp):body - Invoked...")

        NavigationStack
        {
            List
            {
                Section(header:Text("Session"))
                {
                    HStack
                    {
                        Label("Status", systemImage:"checkmark.shield.fill")
                        Spacer()
                        Text(devUnlockMgr.isDevModeActive ? "Active" : "Inactive")
                            .foregroundColor(devUnlockMgr.isDevModeActive ? .green : .red)
                    }

                    HStack
                    {
                        Label("Expires", systemImage:"timer")
                        Spacer()
                        Text(devUnlockMgr.sTimeRemainingDisplay)
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                            .font(.caption)
                    }
                }

                // <<CHICKEN-TRACKS>> Developer options are in SettingsSingleViewCore,
                // now visible because devUnlockMgr.isDevModeActive is true.
                // Per-app items (DataGrid, Directories, Test ZIP, Force CRASH, etc.)
                // appear there rather than here to avoid duplicating view plumbing.

                Section(header:Text("Developer Options"))
                {
                    HStack(spacing:12)
                    {
                        Image(systemName:"arrow.turn.up.left")
                            .foregroundColor(.orange)
                            .font(.headline)

                        VStack(alignment:.leading, spacing:3)
                        {
                            Text("Developer options are now visible in Settings.")
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Text("Dismiss this screen and return to Settings to access DataGrid, Directories, Test ZIP, Force CRASH, and any other App-specific developer options.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section
                {
                    Button(role:.destructive,
                           action:
                           {
                               devUnlockMgr.deactivate()
                               presentationMode.wrappedValue.dismiss()
                           })
                    {
                        Label("Lock Developer Mode", systemImage:"lock.fill")
                    }
                }
            }
            .navigationTitle("Developer Features")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement:.primaryAction)
                {
                    Button("Dismiss") { presentationMode.wrappedValue.dismiss() }
                }
            }
        #endif
        #if os(macOS)
            // <<CHICKEN-TRACKS>> (2026-06-24) — same macOS '.sheet()' title-bar-toolbar issue as
            // DeveloperUnlockView above - see that view's comment for the full explanation.
            .overlay(alignment:.topTrailing)
            {
                Button { presentationMode.wrappedValue.dismiss() }
                label:
                {
                    VStack(alignment:.center)
                    {
                        Label("", systemImage:"xmark.circle").imageScale(.medium)
                        Text("Dismiss").font(.caption2)
                    }
                }
            #if os(iOS)
                .buttonStyle(.plain)
            #endif
            #if os(macOS)
                .buttonStyle(.borderedProminent)
                .padding()
            //  .background(???.isPressed ? .blue : .gray)
                .cornerRadius(10)
                .foregroundColor(Color.primary)
            #endif
                .padding()
            }
        #endif
        }
    }

}   // End of struct DeveloperFeaturesView:View.

