//
//  FullScreenImageViewer.swift
//  CinemaPack
//
//  Created by Daryl Cox on 01/04/2026.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - FullScreenImageViewer

struct FullScreenImageViewer: View
{

    struct ClassInfo
    {
        static let sClsId        = "FullScreenImageViewer"
        static let sClsVers      = "v1.0401"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // App 'environmental' field(s):

    @Environment(\.presentationMode)     var presentationMode

    // Parameters...

                    let imageURL:URL
    @Binding        var isPresented:Bool
    @ObservedObject var cineViewItem:CineViewLocItem

    // State for zoom and pan...

    @State private  var scale:CGFloat      = 1.0
    @State private  var lastScale:CGFloat  = 1.0
    @State private  var offset:CGSize      = .zero
    @State private  var lastOffset:CGSize  = .zero
    @State private  var uiImage:PlatformImage?    = nil
    @State private  var bIsLoading:Bool    = true
    @State private  var bShowControls:Bool = true

    // Animation namespace...

    @Namespace private var animation

    var body: some View
    {

        let _ = appLogMsg("\(ClassInfo.sClsDisp):body(some View) - Displaying image: [\(imageURL.lastPathComponent)]...")

        GeometryReader
        { geometry in

            ZStack
            {
                // Background...

                Color.black
                    .ignoresSafeArea()
                    .onTapGesture
                    {
                        withAnimation(.easeInOut(duration:0.2))
                        {
                            bShowControls.toggle()
                        }
                    }

                // Image content...

                if bIsLoading
                {
                    VStack(spacing:20)
                    {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint:.white))
                            .scaleEffect(1.5)

                        Text("Loading image...")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                else if let image = uiImage
                {
                    Image(platformImage:image)
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged
                                { value in

                                    let delta = value / lastScale
                                    lastScale = value
                                    scale     = min(max(scale * delta, 1.0), 5.0)

                                }
                                .onEnded
                                { _ in

                                    lastScale = 1.0

                                    // Reset if scale is near 1.0...

                                    if scale < 1.1
                                    {
                                        withAnimation(.spring())
                                        {
                                            scale  = 1.0
                                            offset = .zero
                                        }
                                    }
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged
                                { value in

                                    // Only allow drag when zoomed in...

                                    if scale > 1.0
                                    {
                                        offset = CGSize(
                                            width:  lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded
                                { _ in

                                    lastOffset = offset
                                }
                        )
                        .onTapGesture(count:2)
                        {
                            // Double-tap to toggle zoom...

                            withAnimation(.spring())
                            {
                                if scale > 1.0
                                {
                                    scale      = 1.0
                                    offset     = .zero
                                    lastOffset = .zero
                                }
                                else
                                {
                                    scale = 2.5
                                }
                            }
                        }
                        .onTapGesture
                        {
                            withAnimation(.easeInOut(duration:0.2))
                            {
                                bShowControls.toggle()
                            }
                        }
                }
                else
                {
                    VStack(spacing:20)
                    {
                        Image(systemName:"photo.badge.exclamationmark")
                            .font(.system(size:60))
                            .foregroundColor(.gray)

                        Text("Unable to load image")
                            .foregroundColor(.white)
                            .font(.headline)

                        Text(imageURL.lastPathComponent)
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }

                // Top control bar...

                if bShowControls
                {
                    VStack
                    {
                        HStack
                        {
                            // Image info...

                            VStack(alignment:.leading, spacing:2)
                            {
                                Text(cineViewItem.sCineViewLocFilenameExt)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Text(cineViewItem.sCineViewLocFileSizeMB)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // Zoom indicator (when zoomed)...

                            if scale > 1.0
                            {
                                Text("\(Int(scale * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(4)
                            }

                            // Dismiss button...

                            Button
                            {
                                let _ = appLogMsg("\(ClassInfo.sClsDisp):Button.'Dismiss' pressed...")

                                self.presentationMode.wrappedValue.dismiss()
                            }
                            label:
                            {
                                VStack(spacing:2)
                                {
                                    Image(systemName:"xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)

                                    Text("Close")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.leading, 16)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient:  Gradient(colors:[Color.black.opacity(0.7), Color.clear]),
                                startPoint:.top,
                                endPoint:  .bottom
                            )
                        )

                        Spacer()

                        // Bottom info bar...

                        HStack
                        {
                            // Image dimensions (if available)...

                            if let image = uiImage
                            {
                                Text("\(Int(image.size.width)) x \(Int(image.size.height))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // Reset zoom button (when zoomed)...

                            if scale > 1.0
                            {
                                Button
                                {
                                    withAnimation(.spring())
                                    {
                                        scale      = 1.0
                                        offset     = .zero
                                        lastOffset = .zero
                                    }
                                }
                                label:
                                {
                                    HStack(spacing:4)
                                    {
                                        Image(systemName:"arrow.counterclockwise")
                                        Text("Reset Zoom")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(16)
                                }
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient:  Gradient(colors:[Color.clear, Color.black.opacity(0.7)]),
                                startPoint:.top,
                                endPoint:  .bottom
                            )
                        )
                    }
                    .transition(.opacity)
                }
            }
        }
    #if os(ios)
        .statusBar(hidden:true)
    #endif
        .onAppear
        {
            loadImage()

            // Mark as viewed...

            markAsViewed()
        }

    }   // End of var body: some View.

    // MARK: - Image Loading

    private func loadImage()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Loading image from: [\(imageURL)]...")

        bIsLoading = true

        DispatchQueue.global(qos:.userInitiated).async
        {
            if let loadedImage = PlatformImage(contentsOfFile:imageURL.path)
            {
                DispatchQueue.main.async
                {
                    self.uiImage    = loadedImage
                    self.bIsLoading = false

                    appLogMsg("\(sCurrMethodDisp) Image loaded successfully - Size: \(loadedImage.size)...")
                }
            }
            else
            {
                DispatchQueue.main.async
                {
                    self.bIsLoading = false

                    appLogMsg("\(sCurrMethodDisp) Failed to load image from: [\(imageURL)]...")
                }
            }
        }

    }   // End of private func loadImage().

    // MARK: - Metadata Updates

    private func markAsViewed()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Marking image as viewed: [\(imageURL.lastPathComponent)]...")

        // Create or update metadata to mark as viewed...

        var metadata = VideoMetadataManager.shared.loadMetadata(for:imageURL) ?? VideoMetadata()

        metadata.bHasBeenWatched = true
        metadata.dateLastWatched = Date()
        metadata.mediaType       = .image

        VideoMetadataManager.shared.saveMetadata(metadata, for:imageURL)

        // Reload item metadata...

        cineViewItem.reloadMetadata()

    }   // End of private func markAsViewed().

}   // End of struct FullScreenImageViewer: View.

// MARK: - Preview

#Preview
{
    let testItem = CineViewLocItem(
        sCineViewLocFilespec:   "/test/image.jpg",
        sCineViewLocFilenameExt:"TestImage.jpg",
        urlCineViewLocFile:     URL(fileURLWithPath:"/test/image.jpg"),
        sCineViewLocFileSizeMB: "2.5 MB",
        mediaType:              .image
    )

    return FullScreenImageViewer(
        imageURL:    URL(fileURLWithPath:"/test/image.jpg"),
        isPresented: .constant(true),
        cineViewItem:testItem
    )
}
