//
//  VideoMetadataManager.swift
//  CinemaPack
//
//  Created by Daryl Cox on 12/25/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - VideoMetadataManager

class VideoMetadataManager
{

    struct ClassInfo
    {
        static let sClsId        = "VideoMetadataManager"
        static let sClsVers      = "v1.0302"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // Singleton for shared access...

    static let shared = VideoMetadataManager()

    // Thumbnail configuration...

    private let thumbnailSize:CGSize       = CGSize(width:160, height:90)  // 16:9 aspect ratio
    private let thumbnailTimeSeconds:Double = 2.0                           // Capture at 2 seconds
    private let thumbnailJPEGQuality:CGFloat = 0.7                          // JPEG compression quality

    // In-memory cache for thumbnails (to avoid repeated disk reads)...

    private var thumbnailCache:NSCache<NSString, PlatformImage> = NSCache<NSString, PlatformImage>()

    init()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Invoked - Initializing VideoMetadataManager...")

        // Configure cache limits...

        thumbnailCache.countLimit     = 100  // Max 100 thumbnails in memory
        thumbnailCache.totalCostLimit = 50 * 1024 * 1024  // ~50MB

        appLogMsg("\(sCurrMethodDisp) Exiting...")

        return

    }   // End of init().

    // MARK: - Metadata Read/Write

    // Load metadata from sidecar file...

    func loadMetadata(for videoURL:URL)->VideoMetadata?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        let metadataURL = VideoMetadata.getMetadataURL(for:videoURL)

        guard FileManager.default.fileExists(atPath:metadataURL.path) else
        {
            appLogMsg("\(sCurrMethodDisp) No metadata file exists for: [\(videoURL.lastPathComponent)]...")

            return nil
        }

        do
        {
            let data     = try Data(contentsOf:metadataURL)
            let decoder  = JSONDecoder()
            let metadata = try decoder.decode(VideoMetadata.self, from:data)

            appLogMsg("\(sCurrMethodDisp) Loaded metadata for: [\(videoURL.lastPathComponent)] - Progress: \(metadata.sFormattedPlaybackProgress) - Looping: \(metadata.bIsLooping)...")

            return metadata
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Failed to load metadata for [\(videoURL.lastPathComponent)]: \(error.localizedDescription)...")

            return nil
        }

    }   // End of func loadMetadata(for videoURL:URL)->VideoMetadata?.

    // Save metadata to sidecar file...

    func saveMetadata(_ metadata:VideoMetadata, for videoURL:URL)->Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        let metadataURL = VideoMetadata.getMetadataURL(for:videoURL)

        do
        {
            let encoder = JSONEncoder()

            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(metadata)

            try data.write(to:metadataURL, options:.atomic)

            appLogMsg("\(sCurrMethodDisp) Saved metadata for: [\(videoURL.lastPathComponent)] - Progress: \(metadata.sFormattedPlaybackProgress) - Looping: \(metadata.bIsLooping)...")

            return true
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Failed to save metadata for [\(videoURL.lastPathComponent)]: \(error.localizedDescription)...")

            return false
        }

    }   // End of func saveMetadata(_ metadata:VideoMetadata, for videoURL:URL)->Bool.

    // Delete metadata sidecar file...

    func deleteMetadata(for videoURL:URL)->Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        let metadataURL = VideoMetadata.getMetadataURL(for:videoURL)

        guard FileManager.default.fileExists(atPath:metadataURL.path) else
        {
            appLogMsg("\(sCurrMethodDisp) No metadata file to delete for: [\(videoURL.lastPathComponent)]...")

            return true  // No file = success
        }

        do
        {
            try FileManager.default.removeItem(at:metadataURL)

            // Also remove from thumbnail cache...

            let cacheKey = videoURL.path as NSString

            thumbnailCache.removeObject(forKey:cacheKey)

            appLogMsg("\(sCurrMethodDisp) Deleted metadata for: [\(videoURL.lastPathComponent)]...")

            return true
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Failed to delete metadata for [\(videoURL.lastPathComponent)]: \(error.localizedDescription)...")

            return false
        }

    }   // End of func deleteMetadata(for videoURL:URL)->Bool.

    // MARK: - Playback Progress

    // Update playback progress...

    func updatePlaybackProgress(for videoURL:URL, currentTime:Double, duration:Double)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Updating progress for [\(videoURL.lastPathComponent)]: \(VideoMetadata.formatTimeInterval(currentTime)) / \(VideoMetadata.formatTimeInterval(duration))...")

        // Load existing metadata or create new...

        var metadata = loadMetadata(for:videoURL) ?? VideoMetadata()

        // Update progress fields...

        metadata.playbackProgress  = currentTime
        metadata.videoDuration     = duration
        metadata.dateLastWatched   = Date()
        metadata.bHasBeenWatched   = true

        // Check if watch is complete (>95%)...

        if duration > 0 && (currentTime / duration) >= 0.95
        {
            metadata.bIsWatchComplete = true
        }

        // Save back to sidecar file (preserves existing bIsLooping value)...

        let _ = saveMetadata(metadata, for:videoURL)

    }   // End of func updatePlaybackProgress(for videoURL:URL, currentTime:Double, duration:Double).

    // Reset playback progress to beginning...

    func resetPlaybackProgress(for videoURL:URL)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Resetting progress for: [\(videoURL.lastPathComponent)]...")

        var metadata = loadMetadata(for:videoURL) ?? VideoMetadata()

        metadata.playbackProgress = 0.0

        let _ = saveMetadata(metadata, for:videoURL)

    }   // End of func resetPlaybackProgress(for videoURL:URL).

    // MARK: - Loop Mode (Phase 4)

    // Get the current loop state for a video...

    func getLoopState(for videoURL:URL)->Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        let metadata = loadMetadata(for:videoURL)
        let isLooping = metadata?.bIsLooping ?? false

        appLogMsg("\(sCurrMethodDisp) Loop state for [\(videoURL.lastPathComponent)]: \(isLooping)...")

        return isLooping

    }   // End of func getLoopState(for videoURL:URL)->Bool.

    // Set the loop state for a video...

    func setLoopState(for videoURL:URL, isLooping:Bool)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Setting loop state for [\(videoURL.lastPathComponent)] to: \(isLooping)...")

        // Load existing metadata or create new...

        var metadata = loadMetadata(for:videoURL) ?? VideoMetadata()

        // Update loop state...

        metadata.bIsLooping = isLooping

        // Save back to sidecar file...

        let _ = saveMetadata(metadata, for:videoURL)

    }   // End of func setLoopState(for videoURL:URL, isLooping:Bool).

    // Toggle the loop state for a video (convenience method)...

    func toggleLoopState(for videoURL:URL)->Bool
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        let currentState = getLoopState(for:videoURL)
        let newState     = !currentState

        appLogMsg("\(sCurrMethodDisp) Toggling loop state for [\(videoURL.lastPathComponent)] from \(currentState) to \(newState)...")

        setLoopState(for:videoURL, isLooping:newState)

        return newState

    }   // End of func toggleLoopState(for videoURL:URL)->Bool.

    // MARK: - Thumbnail Generation

    // Get thumbnail for video (from cache, disk, or generate)...

    func getThumbnail(for videoURL:URL, completion:@escaping(PlatformImage?)->Void)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        let cacheKey = videoURL.path as NSString

        // 1. Check memory cache first...

        if let cachedImage = thumbnailCache.object(forKey:cacheKey)
        {
            appLogMsg("\(sCurrMethodDisp) Thumbnail from memory cache for: [\(videoURL.lastPathComponent)]...")

            completion(cachedImage)

            return
        }

        // 2. Check if thumbnail exists in metadata sidecar...

        if let metadata = loadMetadata(for:videoURL),
           let thumbnailData = metadata.thumbnailData,
           let image = PlatformImage(data:thumbnailData)
        {
            appLogMsg("\(sCurrMethodDisp) Thumbnail from sidecar file for: [\(videoURL.lastPathComponent)]...")

            // Cache in memory...

            thumbnailCache.setObject(image, forKey:cacheKey)

            completion(image)

            return
        }

        // 3. Generate thumbnail on background thread...

        appLogMsg("\(sCurrMethodDisp) Generating thumbnail for: [\(videoURL.lastPathComponent)]...")

        DispatchQueue.global(qos:.utility).async
        { [weak self] in

            guard let self = self else
            {
                DispatchQueue.main.async { completion(nil) }

                return
            }

            let image = self.generateThumbnail(for:videoURL)

            if let image = image
            {
                // Save to metadata sidecar...

                self.saveThumbnailToMetadata(image, for:videoURL)

                // Cache in memory...

                self.thumbnailCache.setObject(image, forKey:cacheKey)
            }

            DispatchQueue.main.async
            {
                completion(image)
            }
        }

    }   // End of func getThumbnail(for videoURL:URL, completion:...).

    // Synchronous thumbnail retrieval (for use when already on background thread)...

    func getThumbnailSync(for videoURL:URL)->PlatformImage?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        let cacheKey = videoURL.path as NSString

        // 1. Check memory cache...

        if let cachedImage = thumbnailCache.object(forKey:cacheKey)
        {
            return cachedImage
        }

        // 2. Check sidecar file...

        if let metadata = loadMetadata(for:videoURL),
           let thumbnailData = metadata.thumbnailData,
           let image = PlatformImage(data:thumbnailData)
        {
            thumbnailCache.setObject(image, forKey:cacheKey)

            return image
        }

        // 3. Generate thumbnail...

        if let image = generateThumbnail(for:videoURL)
        {
            saveThumbnailToMetadata(image, for:videoURL)
            thumbnailCache.setObject(image, forKey:cacheKey)

            return image
        }

        appLogMsg("\(sCurrMethodDisp) Failed to get thumbnail for: [\(videoURL.lastPathComponent)]...")

        return nil

    }   // End of func getThumbnailSync(for videoURL:URL)->PlatformImage?.

    // Generate thumbnail from video using AVAssetImageGenerator...

    private func generateThumbnail(for videoURL:URL)->PlatformImage?
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        let asset     = AVAsset(url:videoURL)
        let generator = AVAssetImageGenerator(asset:asset)

        generator.appliesPreferredTrackTransform = true
        generator.maximumSize                    = thumbnailSize

        let time = CMTime(seconds:thumbnailTimeSeconds, preferredTimescale:600)

        do
        {
            let cgImage = try generator.copyCGImage(at:time, actualTime:nil)
            let image   = PlatformImage(cgImage:cgImage)

            appLogMsg("\(sCurrMethodDisp) Generated thumbnail for: [\(videoURL.lastPathComponent)]...")

            return image
        }
        catch
        {
            appLogMsg("\(sCurrMethodDisp) Failed to generate thumbnail for [\(videoURL.lastPathComponent)]: \(error.localizedDescription)...")

            // Try at time 0 as fallback...

            do
            {
                let cgImage = try generator.copyCGImage(at:CMTime.zero, actualTime:nil)
                let image   = PlatformImage(cgImage:cgImage)

                appLogMsg("\(sCurrMethodDisp) Generated thumbnail at time 0 for: [\(videoURL.lastPathComponent)]...")

                return image
            }
            catch
            {
                appLogMsg("\(sCurrMethodDisp) Failed fallback thumbnail generation for [\(videoURL.lastPathComponent)]: \(error.localizedDescription)...")

                return nil
            }
        }

    }   // End of private func generateThumbnail(for videoURL:URL)->PlatformImage?.

    // Save thumbnail to metadata sidecar file...

    private func saveThumbnailToMetadata(_ image:PlatformImage, for videoURL:URL)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        guard let jpegData = image.jpegData(compressionQuality:thumbnailJPEGQuality) else
        {
            appLogMsg("\(sCurrMethodDisp) Failed to create JPEG data for thumbnail...")

            return
        }

        var metadata = loadMetadata(for:videoURL) ?? VideoMetadata()

        metadata.thumbnailData = jpegData

        let _ = saveMetadata(metadata, for:videoURL)

        appLogMsg("\(sCurrMethodDisp) Saved thumbnail to metadata for: [\(videoURL.lastPathComponent)] (\(jpegData.count) bytes)...")

    }   // End of private func saveThumbnailToMetadata(_ image:PlatformImage, for videoURL:URL).

    // MARK: - Cache Management

    // Clear all cached thumbnails from memory...

    func clearThumbnailCache()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Clearing thumbnail cache...")

        thumbnailCache.removeAllObjects()

    }   // End of func clearThumbnailCache().

    // Pre-generate thumbnails for a list of video URLs (call on background thread)...

    func preGenerateThumbnails(for videoURLs:[URL], progressCallback:((Int, Int)->Void)? = nil)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Pre-generating thumbnails for \(videoURLs.count) videos...")

        for (index, url) in videoURLs.enumerated()
        {
            let _ = getThumbnailSync(for:url)

            progressCallback?(index + 1, videoURLs.count)
        }

        appLogMsg("\(sCurrMethodDisp) Completed pre-generating thumbnails...")

    }   // End of func preGenerateThumbnails(for videoURLs:[URL], progressCallback:...).

}   // End of class VideoMetadataManager.
