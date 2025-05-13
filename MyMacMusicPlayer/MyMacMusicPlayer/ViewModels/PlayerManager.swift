import Foundation
import AVFoundation

class PlayerManager: ObservableObject {
    private var player: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var currentSong: Song?
    private var timer: Timer?
    private weak var musicState: MusicPlayerState?
    @Published var playbackMode: PlaybackMode = .normal {
        didSet {
            UserDefaults.standard.set(playbackMode.rawValue, forKey: "playbackMode")
            print("播放模式切换至：\(playbackMode.rawValue)")
        }
    }
    
    enum PlaybackMode: String, Codable {
        case normal
        case shuffle
        case repeatOne
    }
    
    func setMusicState(_ musicState: MusicPlayerState) {
        self.musicState = musicState
        if let savedMode = UserDefaults.standard.string(forKey: "playbackMode"),
           let mode = PlaybackMode(rawValue: savedMode) {
            playbackMode = mode
        }
    }
    
    func playSong(_ song: Song) {
        do {
            player = try AVAudioPlayer(contentsOf: song.url)
            player?.prepareToPlay()
            duration = player?.duration ?? 0
            currentSong = song
            isPlaying = true
            player?.play()
            print("播放歌曲：\(song.name)")
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let player = self?.player else { return }
                self?.currentTime = player.currentTime
            }
        } catch {
            print("播放失败: \(error)")
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            player?.play()
            isPlaying = true
        }
    }
    
    func seek(to time: Double) {
        player?.currentTime = time
        currentTime = time
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        currentTime = 0
        currentSong = nil
        timer?.invalidate()
        print("停止播放，currentSong 已置为 nil")
    }
    
    func saveState() {
        if let song = currentSong {
            UserDefaults.standard.set(song.url.path, forKey: "lastSongURL")
            UserDefaults.standard.set(currentTime, forKey: "lastPosition")
        }
    }
    
    func restoreState(songs: [Song]) {
        if let lastURL = UserDefaults.standard.string(forKey: "lastSongURL"),
           let song = songs.first(where: { $0.url.path == lastURL }) {
            playSong(song)
            if let lastPosition = UserDefaults.standard.value(forKey: "lastPosition") as? Double {
                seek(to: lastPosition)
            }
        }
    }
    
    func playNext() {
        guard let musicState = musicState,
              let playlist = musicState.currentPlaylist else { return }
        
        let songs = playlist.songs
        if songs.isEmpty {
            stop()
            print("播放列表为空，停止播放")
            return
        }
        
        if let current = currentSong {
            switch playbackMode {
            case .normal:
                if let index = songs.firstIndex(where: { $0.id == current.id }) {
                    if index < songs.count - 1 {
                        playSong(songs[index + 1])
                    } else {
                        playSong(songs[0])
                    }
                } else {
                    playSong(songs[0])
                }
            case .shuffle:
                let shuffledSongs = songs.filter { $0.id != current.id }
                if let randomSong = shuffledSongs.randomElement() {
                    playSong(randomSong)
                } else {
                    playSong(songs[0])
                }
            case .repeatOne:
                playSong(current)
            }
        } else {
            playSong(songs[0])
        }
    }
    
    func playPrevious() {
        guard let musicState = musicState,
              let playlist = musicState.currentPlaylist else { return }
        
        let songs = playlist.songs
        if songs.isEmpty {
            stop()
            print("播放列表为空，停止播放")
            return
        }
        
        if let current = currentSong {
            switch playbackMode {
            case .normal:
                if let index = songs.firstIndex(where: { $0.id == current.id }) {
                    if index > 0 {
                        playSong(songs[index - 1])
                    } else {
                        playSong(songs[songs.count - 1])
                    }
                } else {
                    playSong(songs[0])
                }
            case .shuffle:
                let shuffledSongs = songs.filter { $0.id != current.id }
                if let randomSong = shuffledSongs.randomElement() {
                    playSong(randomSong)
                } else {
                    playSong(songs[0])
                }
            case .repeatOne:
                playSong(current)
            }
        } else {
            playSong(songs[0])
        }
    }
}
