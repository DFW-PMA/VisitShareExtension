//
//  AppGlassEffectCompatModifier.swift
//  NomadPack
//
//  Created by Daryl Cox on 09/10/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import JmEntityInfo
import SwiftUI

// <<CHICKEN-TRACKS>> New file (2026-09-10, branch 'PossibleLiquidGlassEffects') — evaluation-only
// exploration of Liquid Glass ahead of iOS 27 GA (2026-09-14). Companion to
// 'AppGlassCompatButtonStyleModifier.swift' — that one compat-wraps BUTTON styles
// ('.buttonStyle(.glass/.glassProminent)'), this one compat-wraps '.glassEffect(...)' for
// card/panel-style container backgrounds (the 3 previously-abandoned spots in
// ContentViewClock.swift, plus the handful of '.background(Color(...)) + .cornerRadius(...)'
// card panels found across Views/ — NWSNexRadRadarViews, DeveloperUnlockView, SpreadsheetXMLViewer,
// AppMarkdownViewerView, AppDictionaryDisplayView). Same 'if #available(iOS 26.0, macOS 26.0, *)'
// gate already established at AppGuruQuestionsView.swift/ContentViewClock.swift — the pre-iOS-26
// branch is exactly the container's EXISTING background, never changed by this pass. Tinted to
// the app's AccentColor (hex 6A3DE8, Daryl's brand color) per the on-device finding in
// JMALiquidGlassSample1 that a bare, untinted '.glassEffect(.regular)' reads as a mild frosted-blur
// card, not the intended look.

@JmEntityInfo(vers:"v1.0102")
struct AppGlassEffectCompatModifier:ViewModifier
{

    var cornerRadius:CGFloat = 16

    @ViewBuilder
    func body(content:Content)->some View
    {

        if #available(iOS 26.0, macOS 26.0, *)
        {
            content
                // <<CHICKEN-TRACKS>> (2026-09-10) — '.tint(Color("AccentColor"))' commented out,
                // not deleted (§2f). On-device (Daryl, iPad Pro M4, ContentViewClock) the brand-hex
                // tint at glass '.regular' intensity rendered as a near-solid purple wash — badly
                // reduced contrast on the icon+caption buttons and clock text sitting on top of it
                // ("washout"). Reverted to a bare, untinted '.glassEffect(.regular)' to see the more
                // conservative/subtle look. Daryl's verdict pending — may stay untinted, may get
                // re-tinted at a much lower opacity, or Liquid Glass may get dropped from this app
                // entirely; don't re-add the tint without his explicit go-ahead.
                .glassEffect(.regular, in:RoundedRectangle(cornerRadius:self.cornerRadius))
            //  .glassEffect(.regular.tint(Color("AccentColor")), in:RoundedRectangle(cornerRadius:self.cornerRadius))
        }
        else
        {
            content
                .background(.regularMaterial)
        }

    }   // End of func body(content:Content)->some View.

}   // End of struct AppGlassEffectCompatModifier:ViewModifier.

extension View
{

    func appGlassEffectCompat(cornerRadius:CGFloat = 16)->some View
    {

        self.modifier(AppGlassEffectCompatModifier(cornerRadius:cornerRadius))

    }   // End of func appGlassEffectCompat(cornerRadius:CGFloat)->some View.

}   // End of extension View.

// MARK: - Variant with a caller-supplied fallback background

// <<CHICKEN-TRACKS>> Several card panels (DeveloperUnlockView, NWSNexRadRadarViews,
// SpreadsheetXMLViewer, AppMarkdownViewerView, AppDictionaryDisplayView) have their OWN specific
// pre-iOS-26 background (a platform-conditional 'Color(...)', not '.regularMaterial') that must be
// preserved exactly for anyone below iOS 26/macOS 26 — 'AppGlassEffectCompatModifier' above always
// falls back to '.regularMaterial', which would silently change those panels' pre-26 appearance.
// This generic variant takes the fallback as a '@ViewBuilder' closure instead, so each call site
// supplies its own untouched pre-26 background.
// <<CHICKEN-TRACKS>> No '@JmEntityInfo' here (unlike every other type in this file/App) — the
// macro's generated 'struct ClassInfo { static let ... }' hits a genuine Swift compiler
// restriction ("static stored properties not supported in generic types") because this struct is
// generic over 'Fallback:View'. Confirmed via a real build error, not a guess — v1.0101 tracked
// here in this comment instead since the macro can't be used on this one type.

struct AppGlassEffectCardFallbackModifier<Fallback:View>:ViewModifier   // v1.0102
{

    var cornerRadius:CGFloat = 16
    @ViewBuilder var fallback:() -> Fallback

    @ViewBuilder
    func body(content:Content)->some View
    {

        if #available(iOS 26.0, macOS 26.0, *)
        {
            content
                // <<CHICKEN-TRACKS>> (2026-09-10) — '.tint(Color("AccentColor"))' commented out,
                // not deleted (§2f). On-device (Daryl, iPad Pro M4, ContentViewClock) the brand-hex
                // tint at glass '.regular' intensity rendered as a near-solid purple wash — badly
                // reduced contrast on the icon+caption buttons and clock text sitting on top of it
                // ("washout"). Reverted to a bare, untinted '.glassEffect(.regular)' to see the more
                // conservative/subtle look. Daryl's verdict pending — may stay untinted, may get
                // re-tinted at a much lower opacity, or Liquid Glass may get dropped from this app
                // entirely; don't re-add the tint without his explicit go-ahead.
                .glassEffect(.regular, in:RoundedRectangle(cornerRadius:self.cornerRadius))
            //  .glassEffect(.regular.tint(Color("AccentColor")), in:RoundedRectangle(cornerRadius:self.cornerRadius))
        }
        else
        {
            content
                .background(self.fallback())
                .cornerRadius(self.cornerRadius)
        }

    }   // End of func body(content:Content)->some View.

}   // End of struct AppGlassEffectCardFallbackModifier<Fallback:View>:ViewModifier.
