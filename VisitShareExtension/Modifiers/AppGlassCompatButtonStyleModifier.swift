//
//  AppGlassCompatButtonStyleModifier.swift
//  NomadPack
//
//  Created by Daryl Cox on 09/10/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import SwiftUI

// <<CHICKEN-TRACKS>> New file (2026-09-10, branch 'PossibleLiquidGlassEffects') — evaluation-only
// exploration of Liquid Glass button styling ahead of iOS 27 GA (2026-09-14). Centralizes the
// 'if #available(iOS 26.0, macOS 26.0, *)' compat gate (same pattern already established at
// AppGuruQuestionsView.swift and ContentViewClock.swift) into ONE reusable modifier instead of
// duplicating the branch at every one of the ~90 '.buttonStyle(.bordered/.borderedProminent)'
// call sites and ~140 previously-unstyled icon+caption Dismiss/utility-button call sites across
// Views/. '.controlSize(.mini)' on the glass branch is required to keep the button's on-screen
// footprint matching its pre-glass size — 'glass'/'glassProminent' add their own internal padding
// on top of the label's intrinsic size, same as '.bordered'/'.borderedProminent' already do
// (confirmed on-device in JMALiquidGlassSample1, 2026-09-10). Per-App evaluation branch — subject
// to being discarded wholesale if Daryl doesn't like the on-device look.

// MARK: - Fallback selector

// <<CHICKEN-TRACKS>> 'fallback' names the EXISTING (pre-iOS-26) styling this call site had before
// this pass touched it, so the < iOS 26 / < macOS 26 branch is byte-for-byte what the App already
// shipped — this modifier only ever ADDS the iOS 26+ glass branch, never changes pre-26 behavior.
// No '@JmEntityInfo' here — the macro only supports 'struct'/'class', not 'enum'.

enum AppGlassButtonStyleFallback   // v1.0101
{
    case bordered           // was '.buttonStyle(.bordered)'
    case borderedProminent  // was '.buttonStyle(.borderedProminent)'
    case plain               // was no '.buttonStyle(...)' at all (default/plain Button)
}

// MARK: - Modifier

@JmEntityInfo(vers:"v1.0101")
struct AppGlassCompatButtonStyleModifier:ViewModifier
{

    let fallback:AppGlassButtonStyleFallback

    @ViewBuilder
    func body(content:Content)->some View
    {

        if #available(iOS 26.0, macOS 26.0, *)
        {
            switch (self.fallback)
            {
                case .bordered:
                    content
                        .buttonStyle(.glass)
                        .controlSize(.mini)

                case .borderedProminent:
                    content
                        .buttonStyle(.glassProminent)
                        .controlSize(.mini)

                case .plain:
                    content
                        .buttonStyle(.glass)
                        .controlSize(.mini)
            }
        }
        else
        {
            switch (self.fallback)
            {
                case .bordered:
                    content
                        .buttonStyle(.bordered)

                case .borderedProminent:
                    content
                        .buttonStyle(.borderedProminent)

                case .plain:
                    content
            }
        }

    }   // End of func body(content:Content)->some View.

}   // End of struct AppGlassCompatButtonStyleModifier:ViewModifier.

// MARK: - View extension

extension View
{

    // <<CHICKEN-TRACKS>> 'fallback' defaults to '.plain' since the majority call sites this is
    // applied to (the icon+caption Dismiss/utility-button idiom) had no prior '.buttonStyle(...)'.

    func appGlassCompatButtonStyle(fallback:AppGlassButtonStyleFallback = .plain)->some View
    {

        self.modifier(AppGlassCompatButtonStyleModifier(fallback:fallback))

    }   // End of func appGlassCompatButtonStyle(fallback:AppGlassButtonStyleFallback)->some View.

}   // End of extension View.
