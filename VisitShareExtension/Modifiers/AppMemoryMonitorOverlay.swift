//
//  AppMemoryMonitorOverlay.swift
//  <<< App 'dependent' >>>
//
//  Created by Claude/Daryl Cox on 03/12/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

//  ==============================================================
//  Reusable AppMemoryMonitorOverlayModifier and View extension...
//  ==============================================================
//
//  ---------------------------------------------------------------------------------------------------------
//
//  Usage:
//  In your 'root' view, use a ZStack so it truly floats above everything:
//
//      ZStack
//      {
//          ContentView()
//          
//      #if DEBUG
//          AppMemoryMonitorOverlay()
//      #endif
//      }
//
//  -OR- install via AppMemoryMonitorOverlayManager in your .task{} block
//  (preferred — persists through fullScreenCover and segues):
//
//      .task
//      {
//      #if INSTANTIATE_APP_GLOBALMEMORYOVERLAY
//          if #available(iOS 13.0, *)
//          {
//              let windowScene = UIApplication.shared
//                                  .connectedScenes
//                                  .compactMap { $0 as? UIWindowScene }
//                                  .first { $0.activationState == .foregroundActive
//                                        || $0.activationState == .foregroundInactive }
//              AppMemoryMonitorOverlayManager.shared.install(in:windowScene)
//          }
//      #endif
//      }
//
//  ---------------------------------------------------------------------------------------------------------
//
//  Architecture notes (UIWindow-level overlay):
//
//  AppMemoryMonitorOverlayManager installs a separate UIWindow above the main
//  app window (windowLevel = .statusBar + 1).  This means the overlay persists
//  across ALL navigation including fullScreenCover, sheet, Storyboard segues,
//  and ObjC performSegue: calls — none of those affect the overlay window.
//
//  Dragging is handled entirely at the UIKit level via UIPanGestureRecognizer
//  on host.view rather than inside SwiftUI.  This avoids a conflict between
//  UIKit's touch-tracking chain and SwiftUI's DragGesture recognizer that
//  would otherwise prevent dragging from working through the passthrough window.
//
//  AppMemoryMonitorOverlay itself is a pure render-only View — no position
//  state, no gesture.  All positioning and dragging is owned by the manager.
//
//  Critical UIKit layout note — why a container VC is required:
//      When a UIHostingController is set directly as window.rootViewController,
//      UIKit resizes its view to fill the entire window, ignoring any frame you
//      set on host.view.  The SwiftUI content then centers itself within that
//      full-screen view — placing the pill in the middle of the screen.
//      The fix is to use a plain transparent UIViewController as rootViewController
//      and add host as a *child* view controller.  UIKit then respects the frame
//      set on host.view, positioning and sizing the pill correctly.
//      UIPanGestureRecognizer moves host.view.frame.origin directly within the
//      container so dragging works without any SwiftUI gesture involvement.
//
//  Critical drag note — why canBecomeKey must return false:
//      After the user taps anywhere in the main app window, the main window
//      becomes the key window.  UIKit then routes subsequent touch events to
//      the key window first.  If the overlay window can become key, it may
//      steal or lose key window status unpredictably, causing the
//      UIPanGestureRecognizer on host.view to stop receiving touches after
//      the first interaction elsewhere.  Overriding canBecomeKey to return
//      false in AppOverlayPassthroughWindow ensures the main app window is
//      always key, touch routing through hitTest always works correctly, and
//      the pan gesture fires reliably regardless of what was tapped last.
//
//  ---------------------------------------------------------------------------------------------------------

struct AppMemoryMonitorOverlay:View
{

    struct ClassInfo
    {
        static let sClsId        = "AppMemoryMonitorOverlay"
        static let sClsVers      = "v1.0213"
        static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = true
    }

    // App Data field(s):
    // NOTE: position, dragOffset, and DragGesture have been intentionally
    // removed from this View.  All positioning and drag handling is owned
    // by AppMemoryMonitorOverlayManager at the UIKit level via
    // UIPanGestureRecognizer.  See architecture notes in the file header.

    @State private var dAppMemoryCurrentUsageInMB:Double = 0.0
    @State private var dAppMemoryCurrentFreeInMB:Double  = 0.0
                   let timerAppMemoryCurrentUsage        = Timer.publish(every:20.0, on:.main, in:.common).autoconnect()

    var body:some View
    {

        Text(String(format:"Mem:#(%.1f:%.1f)MB", dAppMemoryCurrentUsageInMB, dAppMemoryCurrentFreeInMB))
            .font(.system(size:11, weight:.medium, design:.monospaced))
            .padding(.horizontal, 8)
            .padding(.vertical,   4)
            .background(.ultraThinMaterial)                             // true frosted glass...
            .foregroundColor(dAppMemoryCurrentFreeInMB < 100 ? .red : .green)
            .clipShape(RoundedRectangle(cornerRadius:6))
            .shadow(radius:4)
            .onAppear
            {
                dAppMemoryCurrentUsageInMB = JmAppMemoryUsageInfo.getAppMemoryCurrentUsageInMB()
                dAppMemoryCurrentFreeInMB  = JmAppMemoryUsageInfo.getAppMemoryCurrentFreeInMB()
            }
            .onReceive(timerAppMemoryCurrentUsage)
            { _ in
                dAppMemoryCurrentUsageInMB = JmAppMemoryUsageInfo.getAppMemoryCurrentUsageInMB()
                dAppMemoryCurrentFreeInMB  = JmAppMemoryUsageInfo.getAppMemoryCurrentFreeInMB()
            }

    }

}   // End of struct AppMemoryMonitorOverlay:View.

#if os(iOS)

// ─────────────────────────────────────────────────────────────────────────────
//  AppOverlayPassthroughWindow
//
//  A UIWindow subclass used exclusively by AppMemoryMonitorOverlayManager.
//
//  Problem 1 — touch swallowing:
//      A UIWindow covers the full screen regardless of how small its visible
//      content is.  With isUserInteractionEnabled = true (required so the
//      UIPanGestureRecognizer on the overlay widget works), the overlay window
//      would otherwise swallow every touch across the entire screen — nothing
//      would reach the main app window below.
//
//  Fix 1 — hitTest passthrough:
//      Override hitTest(_:with:) so that touches which land on the transparent
//      container root view return nil, telling UIKit "nothing here owns this
//      touch — keep looking down the window stack."  Touches that land on
//      host.view (the pill widget) still return the correct UIView so
//      UIPanGestureRecognizer fires correctly.
//
//  Problem 2 — drag stops after first tap elsewhere:
//      After the user taps in the main app window, the main window becomes the
//      key window.  UIKit routes subsequent touch events to the key window
//      first.  If the overlay window can become key (the default), it may
//      steal or lose key window status unpredictably after interactions with
//      the main app, causing the pan gesture to stop receiving touches.
//
//  Fix 2 — canBecomeKey returns false:
//      Overriding canBecomeKey to return false ensures the overlay window
//      never takes key window status away from the main app window.  UIKit
//      then always routes touches through hitTest correctly regardless of
//      what was tapped last, and the pan gesture fires reliably every time.
// ─────────────────────────────────────────────────────────────────────────────

@available(iOS 13.0, *)
private final class AppOverlayPassthroughWindow: UIWindow
{

    struct ClassInfo
    {
        static let sClsId        = "AppOverlayPassthroughWindow"
        static let sClsVers      = "v1.0204"
        static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = true
    }

    // Fix 2: Never take key window status from the main app window.
    // Without this, drag stops working after the user taps elsewhere in the app.

    override var canBecomeKey: Bool
    {
        return false
    }

    override func hitTest(_ point:CGPoint, with event:UIEvent?) -> UIView?
    {

        // Ask the normal hit-test machinery what view owns this point...

        let hitView = super.hitTest(point, with:event)

        // If the hit resolves to the container root view (i.e. transparent
        // background — the pill was not hit), return nil so UIKit passes the
        // touch through to the main app window below.
        // Only claim the touch when it lands on a real subview (the pill itself
        // or its SwiftUI render tree) so drag works correctly.

        if hitView == self.rootViewController?.view
        {
            return nil      // transparent — pass through to main app window
        }

        return hitView      // pill was hit — claim the touch for drag

    }   // End of override func hitTest(_:with:).

}   // End of private final class AppOverlayPassthroughWindow.

// ─────────────────────────────────────────────────────────────────────────────
//  AppMemoryMonitorOverlayManager
//
//  Owns the overlay UIWindow, the transparent container UIViewController,
//  and the UIHostingController child.
//
//  Layout design — why a container VC is required:
//      UIKit resizes a window's rootViewController.view to fill the window.
//      Setting host.view.frame after assigning host as rootViewController has
//      no effect — UIKit overrides it.  The fix is a two-level hierarchy:
//
//          overlayWindow (AppOverlayPassthroughWindow, full-screen)
//            └── containerVC.view  (UIViewController, full-screen, clear)
//                  └── host.view   (UIHostingController, fixed frame = pill size)
//
//      UIKit sizes containerVC.view to fill the window (intentional — it is
//      transparent).  host.view is a child with a manually-set frame that
//      UIKit does NOT override, so it stays exactly where we put it.
//
//  Dragging design:
//      UIPanGestureRecognizer on host.view moves host.view.frame.origin
//      directly within containerVC.view's coordinate space.  No SwiftUI
//      gesture involvement — avoids the gesture-recognizer conflict.
//
//  NSObject inheritance:
//      Required so handleOverlayPan(_:) can be an @objc selector target.
// ─────────────────────────────────────────────────────────────────────────────

final class AppMemoryMonitorOverlayManager: NSObject
{

    struct ClassInfo
    {
        static let sClsId        = "AppMemoryMonitorOverlayManager"
        static let sClsVers      = "v1.0205"
        static let sClsDisp      = sClsId+"(.swift).("+sClsVers+"):"
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = false
        static let bClsFileLog   = true
    }

    // Overlay widget frame constants:
    // Width is generous enough for "Mem:#(XXX.X:XXX.X)MB" at 11pt monospaced
    // with horizontal padding.  Height covers the text + vertical padding + shadow.
    // topPadding is 0 — pill sits flush to the bottom edge of the status bar,
    // as high as it can go without overlapping system UI.

    private enum OverlayMetrics
    {
        static let width:CGFloat        = 210
        static let height:CGFloat       = 32
        static let rightMargin:CGFloat  = 8
        static let topPadding:CGFloat   = 0     // flush to status bar bottom edge
    }

    // App Data field(s):

                  static  let shared                    = AppMemoryMonitorOverlayManager()
                  private var overlayWindow:UIWindow?
                  private var isInstalled:Bool          = false

    // Scene-based install (iOS 13+ scene lifecycle).
    // Called from .task{} in the SwiftUI @main App struct — the earliest
    // safe point at which a UIWindowScene is guaranteed to exist.

    @available(iOS 13.0, *)
    func install(in scene:UIWindowScene?)
    {

        guard !isInstalled
        else { return }

        guard let scene = scene
        else { return }

        isInstalled = true
        buildOverlay(in:scene)

    }   // End of func install(in scene:UIWindowScene?).

    // Legacy install (application:didFinishLaunchingWithOptions:).
    // Also acts as a no-op in scene-based apps if the scene path already
    // ran first (isInstalled will already be true).

    func install(in window:UIWindow?)
    {

        guard !isInstalled
        else { return }

        guard let window = window
        else { return }

        if #available(iOS 13.0, *)
        {
            guard let scene = window.windowScene
            else { return }

            isInstalled = true
            buildOverlay(in:scene)
        }
        // else: pre-iOS 13 has no UIWindowScene — overlay simply not installed,
        // which is acceptable since this is a debug-only diagnostic tool.

    }   // End of func install(in window:UIWindow?).

//  func install(in scene:UIWindowScene) 
//  {
//
//      let window                                      = UIWindow(windowScene:scene)
//      window.windowLevel                              = .statusBar + 1    // above everything
//      window.backgroundColor                          = .clear
//      window.isUserInteractionEnabled                 = true
//      window.rootViewController                       = UIHostingController(rootView:AppMemoryMonitorOverlay())
//      window.rootViewController?.view.backgroundColor = .clear
//      window.isHidden                                 = false
//      self.overlayWindow                              = window
//
//  }   // End of func install(in scene:UIWindowScene).

    @available(iOS 13.0, *)
    private func buildOverlay(in scene:UIWindowScene)
    {

        // ── Window ────────────────────────────────────────────────────────────
        // AppOverlayPassthroughWindow ensures:
        //   (1) touches that miss the pill fall through to the main app window
        //   (2) canBecomeKey = false keeps the main app as key window always,
        //       so drag works reliably after any number of taps elsewhere.

        let window                          = AppOverlayPassthroughWindow(windowScene:scene)
        window.windowLevel                  = .statusBar + 1
        window.backgroundColor              = .clear
        window.isUserInteractionEnabled     = true

        // ── Container view controller ─────────────────────────────────────────
        // Plain transparent VC as rootViewController.  UIKit sizes this to fill
        // the window (intentional — it is invisible).  host.view is added as a
        // child with a fixed frame that UIKit will NOT override, unlike the
        // rootViewController's view which UIKit always resizes to fill the window.

        let containerVC                     = UIViewController()
        containerVC.view.backgroundColor    = .clear

        // ── Hosting controller ────────────────────────────────────────────────
        // AppMemoryMonitorOverlay is render-only — no position state, no
        // DragGesture.  All positioning is owned here at the UIKit level.

        let host                            = UIHostingController(rootView:AppMemoryMonitorOverlay())
        host.view.backgroundColor           = .clear

        // ── Initial position ──────────────────────────────────────────────────
        // Place the pill at top-right, flush to the bottom of the status bar.
        // statusBarManager.statusBarFrame.height gives the actual status bar
        // height for this scene (accounts for notch / Dynamic Island / iPad).
        // Falls back to 8pt if unavailable — keeps it near the top on any device.

        let screenBounds                    = scene.coordinateSpace.bounds
        let statusBarHeight:CGFloat         = scene.statusBarManager?.statusBarFrame.height ?? 8
        let initialX:CGFloat                = screenBounds.width
                                              - OverlayMetrics.width
                                              - OverlayMetrics.rightMargin
        let initialY:CGFloat                = statusBarHeight
                                              + OverlayMetrics.topPadding

        host.view.frame                     = CGRect(x:      initialX,
                                                     y:      initialY,
                                                     width:  OverlayMetrics.width,
                                                     height: OverlayMetrics.height)

        // Prevent UIKit from resizing host.view when the container lays out...

        host.view.autoresizingMask          = []

        // ── Child VC wiring ───────────────────────────────────────────────────
        // Proper UIKit child view controller pattern.  Must call addChild /
        // didMove so UIKit routes appearance callbacks correctly.

        containerVC.addChild(host)
        containerVC.view.addSubview(host.view)
        host.didMove(toParent:containerVC)

        // ── Drag via UIPanGestureRecognizer ───────────────────────────────────
        // Gesture is on host.view so only touches on the pill trigger it.
        // handleOverlayPan moves host.view.frame.origin within containerVC.view.

        let pan                             = UIPanGestureRecognizer(target:self,
                                                                     action:#selector(handleOverlayPan(_:)))
        host.view.addGestureRecognizer(pan)

        // ── Assemble ──────────────────────────────────────────────────────────

        window.rootViewController           = containerVC
        window.isHidden                     = false
        self.overlayWindow                  = window

    }   // End of private func buildOverlay(in scene:UIWindowScene).

    // ── UIPanGestureRecognizer handler ────────────────────────────────────────
    // Moves host.view's frame origin directly within containerVC.view's
    // coordinate space.  Using .translation(in:nil) gives screen-space delta
    // which is correct since containerVC.view fills the full screen.

    @objc
    private func handleOverlayPan(_ gesture:UIPanGestureRecognizer)
    {

        guard let view = gesture.view
        else { return }

        let delta       = gesture.translation(in:nil)
        var newOrigin   = view.frame.origin

        newOrigin.x    += delta.x
        newOrigin.y    += delta.y

        // Clamp to window bounds so the pill can't be dragged fully offscreen...

        if let windowBounds = overlayWindow?.bounds
        {
            newOrigin.x = max(0,
                              min(newOrigin.x,
                                  windowBounds.width  - OverlayMetrics.width))
            newOrigin.y = max(0,
                              min(newOrigin.y,
                                  windowBounds.height - OverlayMetrics.height))
        }

        view.frame.origin = newOrigin

        // Reset translation each cycle so delta is always incremental...

        gesture.setTranslation(.zero, in:nil)

    }   // End of private func handleOverlayPan(_:).

}   // End of final class AppMemoryMonitorOverlayManager.
#endif

