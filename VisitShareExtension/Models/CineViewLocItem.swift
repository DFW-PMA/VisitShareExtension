//
//  CineViewLocItem.swift
//  CinemaPack
//
//  Created by Daryl Cox on 11/10/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - MediaType Enum

enum MediaType: String, Codable, CaseIterable
{
    case video = "video"
    case image = "image"

    // Get SF Symbol for this media type...

    var sfSymbolName:String
    {
        switch self
        {
        case .video: return "film"
        case .image: return "photo"
        }
    }

    // Get display name...

    var displayName:String
    {
        switch self
        {
        case .video: return "Video"
        case .image: return "Image"
        }
    }

    // Determine media type from file extension...

    static func from(fileExtension:String)->MediaType?
    {
        let ext = fileExtension.lowercased()

        // Video extensions...

        let videoExtensions:Set<String> = ["mp4", "mov", "m4v", "avi", "mkv", "wmv", "flv", "webm", "mpeg", "mpg", "3gp"]

        if videoExtensions.contains(ext)
        {
            return .video
        }

        // Image extensions...

        let imageExtensions:Set<String> = ["jpg", "jpeg", "png", "gif", "heic", "heif", "webp", "tiff", "tif", "bmp"]

        if imageExtensions.contains(ext)
        {
            return .image
        }

        return nil
    }

}   // End of enum MediaType.

// MARK: - CineViewLocItem

// CineView 'location' (file) Item - supports both videos and images...

class CineViewLocItem:Identifiable, ObservableObject
{

    struct ClassInfo
    {
        static let sClsId        = "CineViewLocItem"
        static let sClsVers      = "v1.0702"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // 'Global' field(s):

    let id:UUID                           = UUID()

    // Item 'keyed' field(s):

    var sCineViewLocFilespec:String       = ""
    var sCineViewLocFilenameExt:String    = ""
    var urlCineViewLocFile:URL            = URL(fileURLWithPath:"")
    var sCineViewLocFileSizeMB:String     = ""
    var sCineViewLocFileModifiedOn:String = ""
    var dateItemTimestamp:Date            = Date(timeIntervalSince1970:0)

    // Media type (video or image)...

    var mediaType:MediaType               = .video

    // Metadata from sidecar file (Phase 2/3)...

    var videoMetadata:VideoMetadata?      = nil

    @Published
    var isShowingFullScreen:Bool          = false
    @Published
    var isShowingItemDetails:Bool         = false
    @Published
    var isDeleteConfirmAlertShowing:Bool  = false

    // Thumbnail state (Phase 2)...

    @Published
    var thumbnailImage:PlatformImage?     = nil
    @Published
    var bIsThumbnailLoading:Bool          = false

    // Playback resume state (Phase 3) - only applies to videos...

    @Published
    var isShowingResumePrompt:Bool        = false

    init()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of init().

    convenience init(sCineViewLocFilespec:String       = "", 
                     sCineViewLocFilenameExt:String    = "", 
                     urlCineViewLocFile:URL            = URL(fileURLWithPath:""),
                     sCineViewLocFileSizeMB:String     = "",
                     sCineViewLocFileModifiedOn:String = "",
                     dateItemTimestamp:Date            = Date(),
                     mediaType:MediaType               = .video,
                     videoMetadata:VideoMetadata?      = nil)
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
  
        self.init()
        
        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Finish the 'convenience' setup of field(s)...

        self.sCineViewLocFilespec        = sCineViewLocFilespec
        self.sCineViewLocFilenameExt     = sCineViewLocFilenameExt
        self.urlCineViewLocFile          = urlCineViewLocFile
        self.sCineViewLocFileSizeMB      = sCineViewLocFileSizeMB
        self.sCineViewLocFileModifiedOn  = sCineViewLocFileModifiedOn
        self.dateItemTimestamp           = dateItemTimestamp
        self.mediaType                   = mediaType
        self.videoMetadata               = videoMetadata

        self.isShowingFullScreen         = false
        self.isShowingItemDetails        = false
        self.isDeleteConfirmAlertShowing = false
        self.thumbnailImage              = nil
        self.bIsThumbnailLoading         = false
        self.isShowingResumePrompt       = false
        
        // Exit:
  
        appLogMsg("\(sCurrMethodDisp) Exiting...")
  
        return
  
    }   // End of convenience init(...).

    convenience init(cineViewLocItem:CineViewLocItem)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        self.init()

        appLogMsg("\(sCurrMethodDisp) Invoked - parameters - 'cineViewLocItem' is [\(cineViewLocItem)]...")

        // Finish the 'convenience' setup of field(s)...

        self.sCineViewLocFilespec        = cineViewLocItem.sCineViewLocFilespec
        self.sCineViewLocFilenameExt     = cineViewLocItem.sCineViewLocFilenameExt
        self.urlCineViewLocFile          = cineViewLocItem.urlCineViewLocFile
        self.sCineViewLocFileSizeMB      = cineViewLocItem.sCineViewLocFileSizeMB
        self.sCineViewLocFileModifiedOn  = cineViewLocItem.sCineViewLocFileModifiedOn
        self.dateItemTimestamp           = cineViewLocItem.dateItemTimestamp
        self.mediaType                   = cineViewLocItem.mediaType
        self.videoMetadata               = cineViewLocItem.videoMetadata

        self.isShowingFullScreen         = false
        self.isShowingItemDetails        = false
        self.isDeleteConfirmAlertShowing = false
        self.thumbnailImage              = nil
        self.bIsThumbnailLoading         = false
        self.isShowingResumePrompt       = false

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of convenience init(...).

    // MARK: - Media Type Helpers

    var bIsVideo:Bool
    {
        return mediaType == .video
    }

    var bIsImage:Bool
    {
        return mediaType == .image
    }

    // MARK: - Computed Properties for Metadata (Video-specific)

    // Has this video been watched at all?

    var bHasBeenWatched:Bool
    {
        guard bIsVideo else { return videoMetadata?.bHasBeenWatched ?? false }

        return videoMetadata?.bHasBeenWatched ?? false
    }

    // Is this video completely watched (>95%)?

    var bIsWatchComplete:Bool
    {
        guard bIsVideo else { return false }

        return videoMetadata?.bIsWatchComplete ?? false
    }

    // Can we resume playback (has progress > 5 seconds and < 95%)?

    var bCanResume:Bool
    {
        guard bIsVideo else { return false }

        return videoMetadata?.bCanResume ?? false
    }

    // Formatted playback progress string (e.g., "23:45")

    var sPlaybackProgress:String
    {
        guard bIsVideo else { return "N/A" }

        return videoMetadata?.sFormattedPlaybackProgress ?? "0:00"
    }

    // Formatted duration string

    var sDuration:String
    {
        guard bIsVideo else { return "N/A" }

        return videoMetadata?.sFormattedDuration ?? "0:00"
    }

    // Playback progress in seconds

    var dPlaybackProgressSeconds:Double
    {
        guard bIsVideo else { return 0.0 }

        return videoMetadata?.playbackProgress ?? 0.0
    }

    // Duration in seconds

    var dDurationSeconds:Double
    {
        guard bIsVideo else { return 0.0 }

        return videoMetadata?.videoDuration ?? 0.0
    }

    // Percentage watched (0.0 to 1.0)

    var dPercentageWatched:Double
    {
        guard bIsVideo else { return 0.0 }

        return videoMetadata?.dPercentageWatched ?? 0.0
    }

    // Last watched date

    var dateLastWatched:Date?
    {
        guard bIsVideo else { return nil }

        guard let metadata = videoMetadata,
              metadata.bHasBeenWatched else { return nil }

        return metadata.dateLastWatched
    }

    // Phase 4: Is loop playback enabled for this video?

    var bIsLooping:Bool
    {
        guard bIsVideo else { return false }

        return videoMetadata?.bIsLooping ?? false
    }

    // MARK: - Thumbnail Methods

    // Load thumbnail asynchronously...

    func loadThumbnail()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        // Don't reload if already loading or loaded...

        if bIsThumbnailLoading || thumbnailImage != nil
        {
            return
        }

        bIsThumbnailLoading = true

        if bIsImage
        {
            // For images, load directly (scaled down for thumbnail)...

            DispatchQueue.global(qos:.utility).async
            { [weak self] in

                guard let self = self else { return }

                if let uiImage = PlatformImage(contentsOfFile:self.urlCineViewLocFile.path)
                {
                    // Scale down for thumbnail...

                    let thumbnailSize  = CGSize(width:160, height:90)
                    let scaledImage    = self.scaleImage(uiImage, toFit:thumbnailSize)

                    DispatchQueue.main.async
                    {
                        self.thumbnailImage      = scaledImage
                        self.bIsThumbnailLoading = false
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        self.bIsThumbnailLoading = false
                    }
                }
            }
        }
        else
        {
            // For videos, use VideoMetadataManager...

            VideoMetadataManager.shared.getThumbnail(for:urlCineViewLocFile)
            { [weak self] image in

                guard let self = self else { return }

                DispatchQueue.main.async
                {
                    self.thumbnailImage      = image
                    self.bIsThumbnailLoading = false
                }
            }
        }

    }   // End of func loadThumbnail().

    // Scale image to fit within a size while maintaining aspect ratio...

    #if os(iOS)
    private func scaleImage(_ image:PlatformImage, toFit targetSize:CGSize)->PlatformImage
    {

        let widthRatio  = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let ratio       = min(widthRatio, heightRatio)

        let newSize = CGSize(width:  image.size.width * ratio,
                             height: image.size.height * ratio)

        let renderer = UIGraphicsImageRenderer(size:newSize)

        return renderer.image
        { _ in

            image.draw(in:CGRect(origin:.zero, size:newSize))

        }

    }   // End of private func scaleImage(...)->PlatformImage [iOS].
    #elseif os(macOS)
    private func scaleImage(_ image:PlatformImage, toFit targetSize:CGSize)->PlatformImage
    {

        let widthRatio  = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let ratio       = min(widthRatio, heightRatio)

        let newSize = CGSize(width:  image.size.width * ratio,
                             height: image.size.height * ratio)

        let scaledImage = PlatformImage(size:newSize)

        scaledImage.lockFocus()

        image.draw(in:    CGRect(origin:.zero, size:newSize),
                   from:  CGRect(origin:.zero, size:image.size),
                   operation:.copy,
                   fraction:1.0)

        scaledImage.unlockFocus()

        return scaledImage

    }   // End of private func scaleImage(...)->PlatformImage [macOS].
    #endif

    // Get SwiftUI Image from thumbnail...

    var thumbnailSwiftUIImage:Image?
    {
        guard let uiImage = thumbnailImage else { return nil }

        return Image(platformImage:uiImage)
    }

    // MARK: - Metadata Update Methods

    // Reload metadata from sidecar file...

    func reloadMetadata()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Reloading metadata for: [\(sCineViewLocFilenameExt)]...")

        videoMetadata = VideoMetadataManager.shared.loadMetadata(for:urlCineViewLocFile)

    }   // End of func reloadMetadata().

    // Update playback progress (video only)...

    func updatePlaybackProgress(currentTime:Double, duration:Double)
    {

        guard bIsVideo else { return }

        VideoMetadataManager.shared.updatePlaybackProgress(for:urlCineViewLocFile, 
                                                           currentTime:currentTime, 
                                                           duration:duration)

        // Reload to get updated metadata...

        reloadMetadata()

    }   // End of func updatePlaybackProgress(currentTime:duration:).

    // Reset playback to beginning (video only)...

    func resetPlaybackProgress()
    {

        guard bIsVideo else { return }

        VideoMetadataManager.shared.resetPlaybackProgress(for:urlCineViewLocFile)

        // Reload to get updated metadata...

        reloadMetadata()

    }   // End of func resetPlaybackProgress().

    // Phase 4: Toggle loop preference for this video (video only)...

    func toggleLoopState()->Bool
    {

        guard bIsVideo else { return false }

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Toggling loop state for: [\(sCineViewLocFilenameExt)]...")

        let newState = VideoMetadataManager.shared.toggleLoopState(for:urlCineViewLocFile)

        // Reload to get updated metadata...

        reloadMetadata()

        return newState

    }   // End of func toggleLoopState()->Bool.

    // Phase 4: Set loop state for this video (video only)...

    func setLoopState(isLooping:Bool)
    {

        guard bIsVideo else { return }

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Setting loop state to \(isLooping) for: [\(sCineViewLocFilenameExt)]...")

        VideoMetadataManager.shared.setLoopState(for:urlCineViewLocFile, isLooping:isLooping)

        // Reload to get updated metadata...

        reloadMetadata()

    }   // End of func setLoopState(isLooping:Bool).

    // MARK: - Debug/Display Methods

    public func displayDataItemToLog()
    {

        return self.displayCineViewLocItemToLog()

    }

    public func displayCineViewLocItemToLog()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked...")

        // Display the various field(s) of this object...

        appLogMsg("\(sCurrMethodDisp) 'self'                        is [\(String(describing: self))]...")
        appLogMsg("\(sCurrMethodDisp) 'id'                          is [\(String(describing: self.id))]...")

        appLogMsg("\(sCurrMethodDisp) 'sCineViewLocFilespec'        is [\(String(describing: self.sCineViewLocFilespec))]...")
        appLogMsg("\(sCurrMethodDisp) 'sCineViewLocFilenameExt'     is [\(String(describing: self.sCineViewLocFilenameExt))]...")
        appLogMsg("\(sCurrMethodDisp) 'urlCineViewLocFile'          is [\(String(describing: self.urlCineViewLocFile))]...")
        appLogMsg("\(sCurrMethodDisp) 'sCineViewLocFileSizeMB'      is [\(String(describing: self.sCineViewLocFileSizeMB))]...")
        appLogMsg("\(sCurrMethodDisp) 'sCineViewLocFileModifiedOn'  is [\(String(describing: self.sCineViewLocFileModifiedOn))]...")
        appLogMsg("\(sCurrMethodDisp) 'dateItemTimestamp'           is [\(String(describing: self.dateItemTimestamp))]...")
        appLogMsg("\(sCurrMethodDisp) 'mediaType'                   is [\(String(describing: self.mediaType))]...")

        appLogMsg("\(sCurrMethodDisp) 'videoMetadata'               is [\(String(describing: self.videoMetadata))]...")
        appLogMsg("\(sCurrMethodDisp) 'bHasBeenWatched'             is [\(String(describing: self.bHasBeenWatched))]...")
        appLogMsg("\(sCurrMethodDisp) 'bCanResume'                  is [\(String(describing: self.bCanResume))]...")
        appLogMsg("\(sCurrMethodDisp) 'sPlaybackProgress'           is [\(String(describing: self.sPlaybackProgress))]...")
        appLogMsg("\(sCurrMethodDisp) 'bIsLooping'                  is [\(String(describing: self.bIsLooping))]...")

        appLogMsg("\(sCurrMethodDisp) 'isShowingFullScreen'         is [\(String(describing: self.isShowingFullScreen))]...")
        appLogMsg("\(sCurrMethodDisp) 'isShowingItemDetails'        is [\(String(describing: self.isShowingItemDetails))]...")
        appLogMsg("\(sCurrMethodDisp) 'isDeleteConfirmAlertShowing' is [\(String(describing: self.isDeleteConfirmAlertShowing))]...")
        appLogMsg("\(sCurrMethodDisp) 'thumbnailImage'              is [\(thumbnailImage != nil ? "loaded" : "nil")]...")

        // Exit:

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of public func displayCineViewLocItemToLog().

}   // End of class CineViewLocItem:Identifiable.
