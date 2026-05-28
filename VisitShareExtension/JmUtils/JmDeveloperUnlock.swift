//
//  JmDeveloperUnlock.swift
//  JmUtils
//
//  Extracted from JMASample2FAValidatorApp.swift
//  Created by JustMacApps.net
//  Copyright © JustMacApps 2023-2026. All Rights Reserved.
//
//  Provides HOTP-based developer unlock gating for JustMacApps production apps.
//
//  USAGE:
//    1. Copy this file into the JmUtils shared module (once).
//    2. Add a per-app JmDeveloperUnlockSecret companion file (see below) that
//       supplies the obfuscated secret for that app.  Never share a secret
//       across apps.
//    3. In SettingsSingleViewCore (or equivalent settings view) add:
//         @ObservedObject private var devUnlockMgr:JmDeveloperUnlockManager
//                                   = JmDeveloperUnlockManager.shared
//       and gate developer-only sections on devUnlockMgr.isDevModeActive.
//    4. Present JmDeveloperUnlockView via the hidden App-icon long-press gesture.
//
//  PER-APP SECRET FILE TEMPLATE  (do NOT put this in JmUtils - it is per-app):
//
//    // JmDeveloperUnlockSecret+<AppName>.swift
//    extension JmDeveloperUnlockSecret
//    {
//        // <<CHICKEN-TRACKS>> XOR key - single non-zero byte.  Change per-app.
//        static let uObfKey:UInt8     = 0x5A
//
//        // <<CHICKEN-TRACKS>> Plain-text secret bytes each XOR'd with uObfKey.
//        // Compute as: yourSecret.utf8.map { $0 ^ uObfKey }
//        static let aObfBytes:[UInt8] = [0x10, 0x18, ...]
//    }
//
//  NOTE: JmDeveloperUnlockSecret is defined here with empty stubs so the module
//  compiles standalone.  Override via the per-app extension shown above.
//

import Foundation
import SwiftUI
import SwiftOTP
import Combine

// MARK:- JmDeveloperUnlockSecret (XOR Obfuscation)
//
// <<CHICKEN-TRACKS>> This struct holds the baked-in HOTP secret used exclusively
// for the developer unlock gate.  The plain-text secret is XOR'd with a single-byte
// key so it does NOT appear as a literal string in the binary or in a 'strings' dump.
//
// HOW TO SET YOUR OWN SECRET:
//   1. Enroll an HOTP account in Google Authenticator using your chosen Base32 secret.
//   2. Compute: secret.utf8.map { $0 ^ uObfKey }  (use any non-zero byte as the key).
//   3. Replace aObfBytes in the per-app extension with the result.
//   4. Each production app should have its OWN unique secret - never share secrets
//      across apps.
//
// EXAMPLE (placeholder - replace before shipping):
//   Plain-text:  "JBSWY3DPEHPK3PXP"
//   XOR key:      0x5A
//   XOR result:  [0x10, 0x18, 0x09, 0x0D, 0x03, 0x69, 0x1E, 0x0A,
//                 0x1F, 0x12, 0x0A, 0x11, 0x69, 0x0A, 0x02, 0x0A]
//
// Verify: aObfBytes.map { $0 ^ 0x5A } == Array("JBSWY3DPEHPK3PXP".utf8)  ✓

struct JmDeveloperUnlockSecret
{
    // <<CHICKEN-TRACKS>> XOR key - single non-zero byte.  Override in per-app extension.
    static let uObfKey:UInt8      = 0x5A

    // <<CHICKEN-TRACKS>> Plain-text secret bytes, each XOR'd with uObfKey above.
    // Computed as: "JBSWY3DPEHPK3PXP".utf8.map { $0 ^ 0x5A }
    // Override in per-app extension with your real values.
    static let aObfBytes:[UInt8]  = [0x10, 0x18, 0x09, 0x0D, 0x03, 0x69, 0x1E, 0x0A,
                                      0x1F, 0x12, 0x0A, 0x11, 0x69, 0x0A, 0x02, 0x0A]

    // Reconstruct the plain-text secret at runtime only.
    static func reveal() -> String
    {
        return String(bytes:aObfBytes.map { $0 ^ uObfKey }, encoding:.utf8) ?? ""
    }
}

// MARK:- JmDeveloperUnlockManager

// <<CHICKEN-TRACKS>> Singleton ObservableObject that gates developer feature access
// via counter-based HOTP (no time pressure for the field tech receiving the code).
//
// FLOW:
//   1. You (developer) generate the next HOTP code on your own Google Authenticator
//      HOTP account and send it to the field tech via phone/text/email.
//   2. Field tech enters the code in JmDeveloperUnlockView.
//   3. Manager validates against a 20-code look-ahead window (handles counter drift).
//   4. On success: counter advances (code is consumed/dead), devModeExpiresAt is set
//      60 minutes out, and isDevModeActive flips true.  Both persist in UserDefaults
//      so backgrounding the app does NOT end the session.
//   5. Session expires automatically after 60 minutes (timer fires checkAndRefreshExpiry).
//   6. A used code can never be replayed - the counter only moves forward.

class JmDeveloperUnlockManager:ObservableObject
{

    struct ClassInfo
    {
        static let sClsId        = "JmDeveloperUnlockManager"
        static let sClsVers      = "v1.0103"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // Singleton...

    static let shared:JmDeveloperUnlockManager = JmDeveloperUnlockManager()

    // Published state...

    @Published var isDevModeActive:Bool                                 = false
    @Published var devModeExpiresAt:Date?                               = nil
    @Published var validationState:DevUnlockValidationState             = .waiting

    // UserDefaults key(s)...

    private let sKeyHotpCounter:String                                  = "JMA.devUnlock.hotpCounter"
    private let sKeyExpiresAt:String                                    = "JMA.devUnlock.expiresAt"

    // Session duration - 60 minutes...

    private let dSessionDurationSecs:TimeInterval                       = 60.0 * 60.0

    // HOTP engine...

    private var hotp:HOTP?

    // Countdown timer for expiry display...

    private var expiryTimer:Timer?

    // -----------------------------------------------------------------------

    enum DevUnlockValidationState
    {
        case waiting
        case validating
        case success
        case failure(String)

        var sMessage:String
        {
            switch self
            {
                case .waiting:              return "Enter your HOTP developer code"
                case .validating:           return "Validating..."
                case .success:              return "✅ Developer access granted!"
                case .failure(let sMsg):    return "❌ \(sMsg)"
            }
        }

        var colorState:Color
        {
            switch self
            {
                case .waiting:    return .secondary
                case .validating: return .blue
                case .success:    return .green
                case .failure:    return .red
            }
        }
    }

    // -----------------------------------------------------------------------

    private init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        setupHOTP()
        restoreExpiryState()

        appLogMsg("\(sCurrMethodDisp) Exiting - 'isDevModeActive' is [\(isDevModeActive)]...")

        return

    }   // End of private init().

    // -----------------------------------------------------------------------

    private func setupHOTP()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let sSecret = JmDeveloperUnlockSecret.reveal()

        guard (!sSecret.isEmpty) else
        {
            appLogMsg("\(sCurrMethodDisp) ERROR: JmDeveloperUnlockSecret.reveal() returned an empty string!")
            return
        }

        guard let dataSecret = base32DecodeToData(sSecret) else
        {
            appLogMsg("\(sCurrMethodDisp) ERROR: Failed to Base32-decode the developer unlock secret!")
            return
        }

        self.hotp = HOTP(secret:dataSecret, digits:6, algorithm:.sha1)

        appLogMsg("\(sCurrMethodDisp) Exiting - HOTP engine [\(self.hotp != nil ? "initialized OK" : "FAILED to initialize")]...")

        return

    }   // End of private func setupHOTP().

    private func restoreExpiryState()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        let dStoredExpiry:Double = UserDefaults.standard.double(forKey:sKeyExpiresAt)

        guard (dStoredExpiry > 0.0) else
        {
            appLogMsg("\(sCurrMethodDisp) Exiting - no stored expiry found...")
            return
        }

        let dtExpiry:Date = Date(timeIntervalSince1970:dStoredExpiry)

        if (dtExpiry > Date())
        {
            self.devModeExpiresAt = dtExpiry
            self.isDevModeActive  = true
            startExpiryTimer()
            appLogMsg("\(sCurrMethodDisp) Exiting - dev mode RESTORED, expires: [\(dtExpiry)]...")
        }
        else
        {
            deactivate()
            appLogMsg("\(sCurrMethodDisp) Exiting - stored session had expired - deactivated...")
        }

        return

    }   // End of private func restoreExpiryState().

    // -----------------------------------------------------------------------

    func validateCode(_ sCode:String)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - sCode.count is [\(sCode.count)]...")

        guard (sCode.count == 6), (sCode.allSatisfy { $0.isNumber }) else
        {
            self.validationState = .failure("Must be exactly 6 digits")
            appLogMsg("\(sCurrMethodDisp) Exiting - invalid format...")
            return
        }

        guard let hotp = self.hotp else
        {
            self.validationState = .failure("HOTP engine not initialized")
            appLogMsg("\(sCurrMethodDisp) ERROR: HOTP engine is nil - setup failed at launch!")
            return
        }

        self.validationState = .validating

        var uCounter:UInt64 = UInt64(UserDefaults.standard.integer(forKey:sKeyHotpCounter))

        appLogMsg("\(sCurrMethodDisp) Testing sCode against look-ahead window (20) starting at counter [\(uCounter)]...")

        // <<CHICKEN-TRACKS>> Look-ahead window of 20 handles counter drift when codes are
        // generated on your device but never consumed by the field tech (e.g. you generate
        // 3 codes while waiting for the tech to find the screen - window absorbs all 3).

        for iOffset in 0..<20
        {
            let uTestCounter:UInt64 = uCounter + UInt64(iOffset)

            guard let sExpected = hotp.generate(counter:uTestCounter) else { continue }

            if (sCode == sExpected)
            {
                // Advance counter past the consumed code (code is now dead)...

                uCounter = uTestCounter + 1
                UserDefaults.standard.set(Int(uCounter), forKey:sKeyHotpCounter)

                // Grant session - 60 minutes from now, surviving backgrounding...

                let dtExpiry:Date = Date().addingTimeInterval(dSessionDurationSecs)
                UserDefaults.standard.set(dtExpiry.timeIntervalSince1970, forKey:sKeyExpiresAt)

                self.devModeExpiresAt = dtExpiry
                self.isDevModeActive  = true
                self.validationState  = .success

                startExpiryTimer()

                appLogMsg("\(sCurrMethodDisp) SUCCESS - matched at counter offset [\(iOffset)], new counter [\(uCounter)], expires [\(dtExpiry)]...")
                return
            }
        }

        // No match in the look-ahead window...

        self.validationState = .failure("Invalid code - check counter sync")

        appLogMsg("\(sCurrMethodDisp) Exiting - FAILURE - no match in look-ahead window of 20...")

        return

    }   // End of func validateCode(_:).

    func deactivate()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        self.isDevModeActive  = false
        self.devModeExpiresAt = nil
        self.validationState  = .waiting

        UserDefaults.standard.removeObject(forKey:sKeyExpiresAt)

        stopExpiryTimer()

        appLogMsg("\(sCurrMethodDisp) Exiting - dev mode deactivated...")

        return

    }   // End of func deactivate().

    func checkAndRefreshExpiry()
    {
        guard let dtExpiry = devModeExpiresAt else { return }

        if (dtExpiry <= Date())
        {
            appLogMsg("\(ClassInfo.sClsDisp) checkAndRefreshExpiry() - session expired - deactivating...")
            deactivate()
        }
    }

    var sTimeRemainingDisplay:String
    {
        guard let dtExpiry = devModeExpiresAt,
              (dtExpiry > Date()) else { return "Expired" }

        let dRemaining:TimeInterval = dtExpiry.timeIntervalSince(Date())
        let iMins:Int               = Int(dRemaining) / 60
        let iSecs:Int               = Int(dRemaining) % 60

        return String(format:"%d:%02d remaining", iMins, iSecs)
    }

    // The HOTP code JmDeveloperUnlockManager currently expects, formatted with a
    // centre space for readability (e.g. "123 456").  Read-only - does NOT consume
    // the counter.  Safe to call repeatedly for display purposes.

    var sCurrentExpectedCode:String
    {
        guard let hotp = self.hotp else { return "------" }

        let uCounter:UInt64 = UInt64(UserDefaults.standard.integer(forKey:sKeyHotpCounter))

        guard let sCode:String = hotp.generate(counter:uCounter) else { return "------" }

        let iMid:Int = sCode.count / 2
        guard (sCode.count >= 6) else { return sCode }

        let idxMid = sCode.index(sCode.startIndex, offsetBy:iMid)
        return sCode.prefix(iMid) + " " + sCode.suffix(from:idxMid)
    }

    // -----------------------------------------------------------------------

    private func startExpiryTimer()
    {
        stopExpiryTimer()
        expiryTimer = Timer.scheduledTimer(withTimeInterval:1.0, repeats:true)
        { [weak self] _ in
            DispatchQueue.main.async { self?.checkAndRefreshExpiry() }
        }
    }

    private func stopExpiryTimer()
    {
        expiryTimer?.invalidate()
        expiryTimer = nil
    }

    // -----------------------------------------------------------------------
    //  Base32 decode helper
    //  <<CHICKEN-TRACKS>> Self-contained so JmDeveloperUnlockManager has no
    //  dependency on TwoFactorManager or any other sample-app class.  When this
    //  module is in JmUtils, collapse this into the shared JmStringExtensions
    //  or equivalent Base32 utility if one exists.

    private func base32DecodeToData(_ sBase32:String) -> Data?
    {
        let sAlphabet:String  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let sCleaned:String   = sBase32
                                    .replacingOccurrences(of:" ", with:"")
                                    .replacingOccurrences(of:"-", with:"")
                                    .uppercased()
        var sBits:String      = ""

        for char in sCleaned
        {
            guard let idxChar = sAlphabet.firstIndex(of:char) else { return nil }
            let iVal:Int      = sAlphabet.distance(from:sAlphabet.startIndex, to:idxChar)
            sBits += String(iVal, radix:2).leftPadding(toLength:5, withPad:"0")
        }

        var data:Data    = Data()
        var iByteIdx:Int = 0

        while (iByteIdx + 8) <= sBits.count
        {
            let sSlice:String = String(sBits[sBits.index(sBits.startIndex, offsetBy:iByteIdx)..<sBits.index(sBits.startIndex, offsetBy:iByteIdx+8)])
            if let uByte = UInt8(sSlice, radix:2) { data.append(uByte) }
            iByteIdx += 8
        }

        return data
    }

    deinit
    {
        stopExpiryTimer()
    }

}   // End of class JmDeveloperUnlockManager:ObservableObject.
