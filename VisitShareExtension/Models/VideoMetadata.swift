//
//  VideoMetadata.swift
//  CinemaPack
//
//  Created by Daryl Cox on 12/25/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - VideoMetadata (Codable struct for .cineview sidecar files)

struct VideoMetadata: Codable
{

    struct ClassInfo
    {
        static let sClsId        = "VideoMetadata"
        static let sClsVers      = "v1.0301"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // File extension for sidecar metadata files...

    static let sMetadataFileExtension:String = "cineview"

    // Metadata fields...

    var playbackProgress:Double     // Seconds watched (position in video) - video only
    var videoDuration:Double        // Total duration in seconds - video only
    var dateLastWatched:Date        // When media was last viewed
    var thumbnailData:Data?         // JPEG thumbnail data (optional)
    var bHasBeenWatched:Bool        // Has media ever been viewed?
    var bIsWatchComplete:Bool       // Has video been watched to completion (>95%)? - video only

    // Phase 4: Loop mode support (video only)...

    var bIsLooping:Bool             // Should video loop when it reaches the end?

    // Phase 5: Media type support...

    var mediaType:MediaType         // Type of media (video or image)

    // Default initializer...

    init()
    {

        self.playbackProgress  = 0.0
        self.videoDuration     = 0.0
        self.dateLastWatched   = Date(timeIntervalSince1970:0)
        self.thumbnailData     = nil
        self.bHasBeenWatched   = false
        self.bIsWatchComplete  = false
        self.bIsLooping        = false
        self.mediaType         = .video

    }   // End of init().

    // Convenience initializer with values...

    init(playbackProgress:Double, 
         videoDuration:Double, 
         dateLastWatched:Date, 
         thumbnailData:Data?, 
         bHasBeenWatched:Bool,
         bIsWatchComplete:Bool,
         bIsLooping:Bool      = false,
         mediaType:MediaType  = .video)
    {

        self.playbackProgress  = playbackProgress
        self.videoDuration     = videoDuration
        self.dateLastWatched   = dateLastWatched
        self.thumbnailData     = thumbnailData
        self.bHasBeenWatched   = bHasBeenWatched
        self.bIsWatchComplete  = bIsWatchComplete
        self.bIsLooping        = bIsLooping
        self.mediaType         = mediaType

    }   // End of init(...).

    // MARK: - Codable conformance with backwards compatibility
    
    // Custom CodingKeys to handle optional fields for backwards compatibility...

    enum CodingKeys: String, CodingKey
    {
        case playbackProgress
        case videoDuration
        case dateLastWatched
        case thumbnailData
        case bHasBeenWatched
        case bIsWatchComplete
        case bIsLooping
        case mediaType
    }

    // Custom decoder to handle missing fields in older sidecar files...

    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        playbackProgress = try container.decode(Double.self, forKey: .playbackProgress)
        videoDuration    = try container.decode(Double.self, forKey: .videoDuration)
        dateLastWatched  = try container.decode(Date.self, forKey: .dateLastWatched)
        thumbnailData    = try container.decodeIfPresent(Data.self, forKey: .thumbnailData)
        bHasBeenWatched  = try container.decode(Bool.self, forKey: .bHasBeenWatched)
        bIsWatchComplete = try container.decode(Bool.self, forKey: .bIsWatchComplete)

        // Handle backwards compatibility - bIsLooping may not exist in older files...

        bIsLooping = try container.decodeIfPresent(Bool.self, forKey: .bIsLooping) ?? false

        // Handle backwards compatibility - mediaType may not exist in older files (default to video)...

        mediaType = try container.decodeIfPresent(MediaType.self, forKey: .mediaType) ?? .video

    }   // End of init(from decoder: Decoder) throws.

    // MARK: - Helper Properties

    // Returns formatted time string for playback progress (e.g., "1:23:45" or "23:45")...

    var sFormattedPlaybackProgress:String
    {
        return VideoMetadata.formatTimeInterval(playbackProgress)
    }

    // Returns formatted time string for duration...

    var sFormattedDuration:String
    {
        return VideoMetadata.formatTimeInterval(videoDuration)
    }

    // Returns percentage watched (0.0 to 1.0)...

    var dPercentageWatched:Double
    {
        guard videoDuration > 0 else { return 0.0 }

        return min(playbackProgress / videoDuration, 1.0)
    }

    // Returns true if there's meaningful progress to resume (> 5 seconds and < 95%)...

    var bCanResume:Bool
    {
        guard mediaType == .video else { return false }

        return playbackProgress > 5.0 && dPercentageWatched < 0.95
    }

    // MARK: - Static Helpers

    // Format a time interval as HH:MM:SS or MM:SS...

    static func formatTimeInterval(_ interval:Double)->String
    {

        guard interval.isFinite && interval >= 0 else { return "0:00" }

        let totalSeconds = Int(interval)
        let hours        = totalSeconds / 3600
        let minutes      = (totalSeconds % 3600) / 60
        let seconds      = totalSeconds % 60

        if hours > 0
        {
            return String(format:"%d:%02d:%02d", hours, minutes, seconds)
        }
        else
        {
            return String(format:"%d:%02d", minutes, seconds)
        }

    }   // End of static func formatTimeInterval(_ interval:Double)->String.

    // Generate the sidecar filename for a media URL...

    static func getMetadataURL(for mediaURL:URL)->URL
    {

        // Append .cineview to the full media filename
        // e.g., "MyVideo.mp4" -> "MyVideo.mp4.cineview"
        // e.g., "MyImage.jpg" -> "MyImage.jpg.cineview"

        return mediaURL.appendingPathExtension(sMetadataFileExtension)

    }   // End of static func getMetadataURL(for mediaURL:URL)->URL.

    // Check if a URL is a metadata sidecar file...

    static func isMetadataFile(_ url:URL)->Bool
    {

        return url.pathExtension.lowercased() == sMetadataFileExtension.lowercased()

    }   // End of static func isMetadataFile(_ url:URL)->Bool.

}   // End of struct VideoMetadata: Codable.
