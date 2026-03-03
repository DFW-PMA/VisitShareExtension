//
//  AppPlatformImageModel.swift
//  CinemaPack
//
//  Created by Daryl Cox on 03/03/2026.
//  Copyright (C) JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - PlatformImage Typealias
//
// Provides a single PlatformImage type across iOS and macOS targets so that
// all callers can use PlatformImage uniformly without per-file #if os() guards
// on the type itself.  UIImage and NSImage share the same surface area we need
// (contentsOfFile init, size, data inits), with the exceptions handled below.

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

// MARK: - SwiftUI Image Extension

extension Image
{

    // Single call site for building a SwiftUI Image from either UIImage or NSImage.

    init(platformImage:PlatformImage)
    {
        #if os(iOS)
        self.init(uiImage:platformImage)
        #elseif os(macOS)
        self.init(nsImage:platformImage)
        #endif
    }

}   // End of extension Image.

// MARK: - NSImage Extensions (macOS only)
//
// Adds the UIImage-style API surface that CinemaPack uses so that all callers
// above this layer can be written once against PlatformImage without any
// additional per-call #if os() guards.

#if os(macOS)
extension NSImage
{

    // Equivalent to UIImage.pngData()...

    func pngData()->Data?
    {

        guard let tiffData  = tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data:tiffData) else { return nil }

        return bitmapRep.representation(using:.png, properties:[:])

    }   // End of func pngData()->Data?.

    // Equivalent to UIImage.jpegData(compressionQuality:)...

    func jpegData(compressionQuality:CGFloat)->Data?
    {

        guard let tiffData  = tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data:tiffData) else { return nil }

        let props:[NSBitmapImageRep.PropertyKey:Any] = [.compressionFactor:compressionQuality]

        return bitmapRep.representation(using:.jpeg, properties:props)

    }   // End of func jpegData(compressionQuality:CGFloat)->Data?.

    // Equivalent to UIImage(cgImage:) - matches UIImage single-argument init...

    convenience init(cgImage:CGImage)
    {

        let size = NSSize(width:cgImage.width, height:cgImage.height)

        self.init(cgImage:cgImage, size:size)

    }   // End of convenience init(cgImage:CGImage).

}   // End of extension NSImage.
#endif
