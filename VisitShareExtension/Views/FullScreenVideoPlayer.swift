//
//  FullScreenVideoPlayer.swift
//  CineViewApp2
//
//  Created by Daryl Cox on 11/12/2025.
//  Copyright © JustMacApps 2023-2026. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import AVKit
import UniformTypeIdentifiers
import Combine

// Mark: 'Full' Screen Video Player...

struct FullScreenVideoPlayer:View
{
    
    struct ClassInfo
    {
        static let sClsId        = "FullScreenVideoPlayer"
        static let sClsVers      = "v1.0801"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

    // App 'environmental' field(s):

    @Environment(\.presentationMode)     var presentationMode
    @Environment(\.openWindow)           var openWindow
    @Environment(\.openURL)              var openURL

    // App 'global' field(s):

                             var appGlobalInfo:AppGlobalInfo = AppGlobalInfo.ClassSingleton.appGlobalInfo

    // App Data field(s):

    @StateObject     private var playerManager:PlayerManager
    @Binding                 var isPresented:Bool
                             let videoURL:URL

    // Phase 3: CineViewItem reference and resume flag...

                             var cineViewItem:CineViewLocItem?
                             let bResumeFromProgress:Bool

    init(videoURL:URL, 
         isPresented:Binding<Bool>,
         cineViewItem:CineViewLocItem? = nil,
         bResumeFromProgress:Bool = false) 
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - 'videoURL' is [\(videoURL)] - 'bResumeFromProgress' is [\(bResumeFromProgress)]...")
    
        self.videoURL            = videoURL
        self._isPresented        = isPresented
        self.cineViewItem        = cineViewItem
        self.bResumeFromProgress = bResumeFromProgress

        // Determine starting position...

        var startingPosition:Double = 0.0

        if bResumeFromProgress, let item = cineViewItem
        {
            startingPosition = item.dPlaybackProgressSeconds

            appLogMsg("\(sCurrMethodDisp) Will resume from position: \(VideoMetadata.formatTimeInterval(startingPosition))...")
        }

        // Get initial loop state from metadata...

        let initialLoopState = VideoMetadataManager.shared.getLoopState(for:videoURL)

        appLogMsg("\(sCurrMethodDisp) Initial loop state: \(initialLoopState)...")

        self._playerManager = StateObject(wrappedValue:PlayerManager(url:videoURL, 
                                                                      startingPosition:startingPosition,
                                                                      cineViewItem:cineViewItem,
                                                                      initialLoopState:initialLoopState))

        appLogMsg("\(sCurrMethodDisp) Exiting...")
    
        return

    }   // End of init(...).

    var body:some View 
    {

        let _ = appLogMsg("\(ClassInfo.sClsDisp):Body(some View) is launching - 'videoURL' is [\(videoURL)]...")

        VStack
        {
            // Top control bar...

            VStack
            {
                HStack
                {
                    // Status indicator...

                    if playerManager.isLoading
                    {
                        ProgressView()
                            .padding(.leading)
                        Text("Loading...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    else if let errorMessage = playerManager.errorMessage
                    {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .padding(.leading)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .lineLimit(1)
                    }
                    else
                    {
                        // Show current playback position...

                        Text(playerManager.sCurrentTimeFormatted)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading)

                        Text(" / ")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(playerManager.sDurationFormatted)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Loop indicator (shows when looping is enabled)...

                        if playerManager.bIsLooping
                        {
                            Image(systemName:"repeat")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.leading, 4)
                        }
                    }
                    
                    Spacer()

                    // Loop Toggle Button...

                    Button
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):Button.'Loop Toggle' pressed - current state: \(playerManager.bIsLooping)...")

                        playerManager.toggleLoop()
                    }
                    label:
                    {
                        VStack(alignment: .center)
                        {
                            Label("", systemImage: playerManager.bIsLooping ? "repeat.circle.fill" : "repeat.circle")
                                .help(Text(playerManager.bIsLooping ? "Disable Loop" : "Enable Loop"))
                                .imageScale(.small)
                                .foregroundColor(playerManager.bIsLooping ? .blue : .primary)
                            Text(playerManager.bIsLooping ? "Loop On" : "Loop Off")
                                .font(.caption2)
                                .foregroundColor(playerManager.bIsLooping ? .blue : .primary)
                        }
                    }
                #if os(macOS)
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(10)
                #endif
                    .padding(.trailing, 8)

                    // Dismiss Button...

                    Button
                    {
                        let _ = appLogMsg("\(ClassInfo.sClsDisp):Button(Xcode).'Dismiss' pressed...")

                        // Save progress before dismissing...

                        playerManager.saveProgressOnExit()
                        playerManager.pause()

                        self.presentationMode.wrappedValue.dismiss()
                    }
                    label:
                    {
                        VStack(alignment: .center)
                        {
                            Label("", systemImage: "xmark.circle")
                                .help(Text("Dismiss this Screen"))
                                .imageScale(.small)
                            Text("Dismiss")
                                .font(.caption2)
                        }
                    }
                #if os(macOS)
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(10)
                    .foregroundColor(Color.primary)
                #endif
                    .padding()
                }
            }

            ZStack 
            {
                Color.black.edgesIgnoringSafeArea(.all)
          
                VideoPlayer(player: playerManager.player)
                    .ignoresSafeArea(.all, edges: [.leading, .trailing, .bottom])
            }
            .onAppear 
            {
                appLogMsg("\(ClassInfo.sClsDisp):onAppear - requesting play start...")

                playerManager.startPlaybackWhenReady()
            }
            .onDisappear 
            {
                appLogMsg("\(ClassInfo.sClsDisp):onDisappear - saving progress and pausing player...")

                playerManager.saveProgressOnExit()
                playerManager.pause()
            }
            .frame(minWidth: 800, idealWidth: 1920, maxWidth: .infinity, 
                   minHeight: 400, idealHeight: 800, maxHeight: .infinity)
        }

    }

}   // End of struct FullScreenVideoPlayer:View.

// MARK: - PlayerManager (Observable wrapper for AVPlayer with progress saving and loop support)

class PlayerManager:ObservableObject
{

    struct ClassInfo
    {
        static let sClsId        = "PlayerManager"
        static let sClsVers      = "v1.0301"
        static let sClsDisp      = sClsId+".("+sClsVers+"): "
        static let sClsCopyRight = "Copyright (C) JustMacApps 2023-2026. All Rights Reserved."
        static let bClsTrace     = true
        static let bClsFileLog   = true
    }

            let player:AVPlayer
            let videoURL:URL
    private var cancellables            = Set<AnyCancellable>()
    private var timeObserver:Any?
    private var shouldPlayWhenReady     = false
    private let startingPosition:Double
    private weak var cineViewItem:CineViewLocItem?
    private var bHasSeekToStart         = false
    
    @Published var isLoading:Bool       = true
    @Published var errorMessage:String? = nil
    @Published var currentTime:Double   = 0.0
    @Published var duration:Double      = 0.0

    // Phase 4: Loop mode support...

    @Published var bIsLooping:Bool      = false

    // Formatted time strings for display...

    var sCurrentTimeFormatted:String
    {
        return VideoMetadata.formatTimeInterval(currentTime)
    }

    var sDurationFormatted:String
    {
        return VideoMetadata.formatTimeInterval(duration)
    }
    
    init(url:URL, startingPosition:Double = 0.0, cineViewItem:CineViewLocItem? = nil, initialLoopState:Bool = false)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Invoked - Creating player for URL: [\(url)] with startingPosition: [\(startingPosition)] - initialLoopState: [\(initialLoopState)]...")
        
        self.videoURL         = url
        self.startingPosition = startingPosition
        self.cineViewItem     = cineViewItem
        self.bIsLooping       = initialLoopState

        let playerItem = AVPlayerItem(url:url)
        self.player    = AVPlayer(playerItem:playerItem)
        
        // Configure player for reliable playback...

        player.automaticallyWaitsToMinimizeStalling = true
        
        setupObservers()
        
        appLogMsg("\(sCurrMethodDisp) Exiting - observers configured - looping: \(bIsLooping)...")

        return

    }   // End of init(url:URL, startingPosition:...).
    
    deinit
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        appLogMsg("\(sCurrMethodDisp) Cleaning up observer(s) and saving final progress...")

        // Save final progress before cleanup...

        saveProgressOnExit()
        
        cancellables.removeAll()
        
        if let timeObserver = timeObserver
        {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        NotificationCenter.default.removeObserver(self)
        
        appLogMsg("\(sCurrMethodDisp) Cleanup complete...")

        return

    }   // End of deinit.

    // MARK: - Loop Mode Control (Phase 4)

    func toggleLoop()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        bIsLooping = !bIsLooping

        appLogMsg("\(sCurrMethodDisp) Loop toggled to: \(bIsLooping) - persisting to metadata...")

        // Persist the loop state to metadata sidecar file...

        VideoMetadataManager.shared.setLoopState(for:videoURL, isLooping:bIsLooping)

        // Update CineViewItem's metadata if available...

        cineViewItem?.reloadMetadata()

    }   // End of func toggleLoop().

    func setLoop(_ enabled:Bool)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        guard bIsLooping != enabled else { return }

        bIsLooping = enabled

        appLogMsg("\(sCurrMethodDisp) Loop set to: \(bIsLooping) - persisting to metadata...")

        // Persist the loop state to metadata sidecar file...

        VideoMetadataManager.shared.setLoopState(for:videoURL, isLooping:bIsLooping)

        // Update CineViewItem's metadata if available...

        cineViewItem?.reloadMetadata()

    }   // End of func setLoop(_ enabled:Bool).

    // MARK: - Observer Setup
    
    private func setupObservers()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Setting up player observer(s)...")
        
        // Observe player item status (ready to play, failed, etc.)...

        player.publisher(for:\.currentItem?.status)
            .receive(on:DispatchQueue.main)
            .sink 
            { [weak self] status in

                self?.handleStatusChange(status)

            }
            .store(in:&cancellables)
        
        // Observe time control status (playing, paused, waiting)...

        player.publisher(for:\.timeControlStatus)
            .receive(on:DispatchQueue.main)
            .sink 
            { [weak self] status in

                self?.handleTimeControlStatusChange(status)

            }
            .store(in: &cancellables)
        
        // Observe reason for waiting (if stalled)...

        player.publisher(for:\.reasonForWaitingToPlay)
            .receive(on:DispatchQueue.main)
            .sink 
            { [weak self] reason in

                if let reason = reason
                {
                    appLogMsg("\(sCurrMethodDisp) Reason for waiting: [\(reason.rawValue)]...")

                    self?.isLoading = true
                }
            }
            .store(in:&cancellables)
        
        // Observe playback errors on the current item...

        player.publisher(for:\.currentItem?.error)
            .receive(on:DispatchQueue.main)
            .sink 
            { [weak self] error in

                if let error = error
                {
                    appLogMsg("\(sCurrMethodDisp) Player item error: [\(error.localizedDescription)]...")

                    self?.errorMessage = error.localizedDescription
                    self?.isLoading    = false
                }

            }
            .store(in:&cancellables)
        
        // Notification: video played to end - handle looping here...

        NotificationCenter.default.publisher(for:.AVPlayerItemDidPlayToEndTime, object:player.currentItem)
            .receive(on:DispatchQueue.main)
            .sink 
            { [weak self] _ in

                guard let self = self else { return }

                appLogMsg("\(sCurrMethodDisp) Video played to end - bIsLooping: \(self.bIsLooping)...")

                self.isLoading = false

                // Check if looping is enabled...

                if self.bIsLooping
                {
                    appLogMsg("\(sCurrMethodDisp) Loop mode enabled - seeking to beginning and restarting playback...")

                    // Seek to beginning and restart playback...

                    self.player.seek(to:CMTime.zero)
                    { [weak self] completed in

                        if completed
                        {
                            appLogMsg("\(sCurrMethodDisp) Loop seek completed - restarting playback...")

                            self?.player.play()
                        }
                    }
                }
                else
                {
                    appLogMsg("\(sCurrMethodDisp) Video completed (no loop) - marking as complete...")

                    // Mark as complete...

                    self.saveProgress(isComplete:true)
                }

            }
            .store(in:&cancellables)
        
        // Notification: video failed to play to end...

        NotificationCenter.default.publisher(for:.AVPlayerItemFailedToPlayToEndTime, object:player.currentItem)
            .receive(on:DispatchQueue.main)
            .sink 
            { notification in

                if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
                {
                    appLogMsg("\(sCurrMethodDisp) Failed to play to end: [\(error.localizedDescription)] - Error!")
                }
                else
                {
                    appLogMsg("\(sCurrMethodDisp) Failed to play to end (unknown error) - Error!")
                }

            }
            .store(in:&cancellables)
        
        // Notification: playback stalled...

        NotificationCenter.default.publisher(for:.AVPlayerItemPlaybackStalled, object:player.currentItem)
            .receive(on:DispatchQueue.main)
            .sink 
            { [weak self] _ in

                appLogMsg("\(sCurrMethodDisp) Playback stalled - will attempt to resume...")

                self?.isLoading = true

                // Attempt to resume after a brief delay...

                DispatchQueue.main.asyncAfter(deadline:.now() + 0.5)
                {
                    self?.player.play()
                }

            }
            .store(in:&cancellables)
        
        // Periodic time observer - every 5 seconds for progress saving...

        let interval = CMTime(seconds:5.0, preferredTimescale:CMTimeScale(NSEC_PER_SEC))

        timeObserver = player.addPeriodicTimeObserver(forInterval:interval, queue:.main) 
        { [weak self] time in

            guard let self = self else { return }
            
            let currentSeconds = CMTimeGetSeconds(time)
            self.currentTime   = currentSeconds
            
            if let duration = self.player.currentItem?.duration, duration.isNumeric
            {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.duration       = durationSeconds

                // Save progress periodically...

                self.saveProgress(isComplete:false)

                // Log every 30 seconds...

                if Int(currentSeconds) % 30 == 0
                {
                    appLogMsg("\(sCurrMethodDisp) Playback progress: \(String(format: "%.1f", currentSeconds))s / \(String(format: "%.1f", durationSeconds))s - Looping: \(self.bIsLooping)")
                }
            }
        }
        
        appLogMsg("\(sCurrMethodDisp) All observer(s) configured...")

        return

    }   // End of private func setupObservers().
    
    private func handleStatusChange(_ status:AVPlayerItem.Status?)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        guard let status = status 
        else
        {
            appLogMsg("\(sCurrMethodDisp) Status is 'nil' (no current item)...")

            return
        }
        
        switch status
        {
        case .unknown:
            appLogMsg("\(sCurrMethodDisp) Player item status: UNKNOWN...")

            isLoading = true

        case .readyToPlay:
            appLogMsg("\(sCurrMethodDisp) Player item status: READY TO PLAY...")

            isLoading    = false
            errorMessage = nil
            
            if let duration = player.currentItem?.duration, duration.isNumeric
            {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.duration       = durationSeconds

                appLogMsg("\(sCurrMethodDisp) Video duration: \(String(format: "%.1f", durationSeconds)) second(s)...")
            }

            // Seek to starting position if needed (resume functionality)...

            if !bHasSeekToStart && startingPosition > 0
            {
                bHasSeekToStart = true

                let seekTime = CMTime(seconds:startingPosition, preferredTimescale:600)

                appLogMsg("\(sCurrMethodDisp) Seeking to starting position: \(VideoMetadata.formatTimeInterval(startingPosition))...")

                player.seek(to:seekTime)
                { [weak self] completed in

                    if completed
                    {
                        appLogMsg("\(sCurrMethodDisp) Seek completed - starting playback...")

                        if self?.shouldPlayWhenReady == true
                        {
                            self?.player.play()
                        }
                    }
                }
            }
            else if shouldPlayWhenReady
            {
                appLogMsg("\(sCurrMethodDisp) Starting playback...")

                shouldPlayWhenReady = false
                player.play()
            }

        case .failed:
            isLoading = false

            if let error = player.currentItem?.error
            {
                appLogMsg("\(sCurrMethodDisp) Player item status: FAILED - Error: [\(error.localizedDescription)] - Error!")

                errorMessage = error.localizedDescription
            }
            else
            {
                appLogMsg("\(sCurrMethodDisp) Player item status: FAILED - Unknown error - Error!")

                errorMessage = "Failed to load video"
            }

        @unknown default:
            appLogMsg("\(sCurrMethodDisp) Player item status: UNKNOWN DEFAULT CASE...")
        }

        return

    }   // End of private func handleStatusChange(_ status:AVPlayerItem.Status?).
    
    private func handleTimeControlStatusChange(_ status:AVPlayer.TimeControlStatus)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        switch status
        {
        case .paused:
            appLogMsg("\(sCurrMethodDisp) Time control status: PAUSED - saving progress...")

            // Save progress when paused...

            saveProgress(isComplete:false)

        case .playing:
            appLogMsg("\(sCurrMethodDisp) Time control status: PLAYING...")

            isLoading = false

        case .waitingToPlayAtSpecifiedRate:
            appLogMsg("\(sCurrMethodDisp) Time control status: WAITING TO PLAY...")

            isLoading = true

        @unknown default:
            appLogMsg("\(sCurrMethodDisp) Time control status: UNKNOWN...")
        }

        return

    }   // End of private func handleTimeControlStatusChange(_ status:AVPlayer.TimeControlStatus).

    // MARK: - Progress Saving (Phase 3)

    private func saveProgress(isComplete:Bool)
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"

        guard duration > 0 else { return }

        // Use VideoMetadataManager to save progress...

        VideoMetadataManager.shared.updatePlaybackProgress(
            for:        videoURL, 
            currentTime:currentTime, 
            duration:   duration
        )

        // Update CineViewItem's metadata if available...

        cineViewItem?.reloadMetadata()

    }   // End of private func saveProgress(isComplete:Bool).

    func saveProgressOnExit()
    {
        
        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Saving progress on exit - currentTime: \(currentTime), duration: \(duration), bIsLooping: \(bIsLooping)...")
        
        // Get current position from player...
        
        if let currentItem = player.currentItem
        {
            let currentSeconds = CMTimeGetSeconds(player.currentTime())
            
            if currentSeconds.isFinite && currentSeconds >= 0
            {
                currentTime = currentSeconds
            }
            
            let itemDuration = currentItem.duration.seconds
            
            if itemDuration.isFinite
            {
                duration = itemDuration
            }
        }
        
        // Save progress...
        
        if duration > 0
        {
            saveProgress(isComplete:false)
        }
        
    }   // End of func saveProgressOnExit().
    
    func startPlaybackWhenReady()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        if player.currentItem?.status == .readyToPlay
        {
            // If we need to seek first, handle that...

            if !bHasSeekToStart && startingPosition > 0
            {
                bHasSeekToStart = true

                let seekTime = CMTime(seconds:startingPosition, preferredTimescale:600)

                appLogMsg("\(sCurrMethodDisp) Seeking to starting position: \(VideoMetadata.formatTimeInterval(startingPosition))...")

                player.seek(to:seekTime)
                { [weak self] completed in

                    if completed
                    {
                        appLogMsg("\(sCurrMethodDisp) Seek completed - starting playback immediately...")

                        self?.player.play()
                    }
                }
            }
            else
            {
                appLogMsg("\(sCurrMethodDisp) Already ready - starting playback immediately...")

                player.play()
            }
        }
        else
        {
            appLogMsg("\(sCurrMethodDisp) Not ready yet - will start when ready...")

            shouldPlayWhenReady = true
        }

        return

    }   // End of func startPlaybackWhenReady().
    
    func pause()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Pausing playback...")

        shouldPlayWhenReady = false
        player.pause()

        return

    }   // End of func pause().
    
    func play()
    {

        let sCurrMethod:String     = #function
        let sCurrMethodDisp:String = "\(ClassInfo.sClsDisp)'"+sCurrMethod+"':"
        
        appLogMsg("\(sCurrMethodDisp) Requesting play...")

        startPlaybackWhenReady()

        return

    }   // End of func play().

}   // End of class PlayerManager:ObservableObject.
