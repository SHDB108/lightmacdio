import SwiftUI

struct NowPlayingBar: View {
    @ObservedObject var playerManager: PlayerManager
    let playPrevious: () -> Void
    let playNext: () -> Void
    
    var body: some View {
        HStack {
            if let song = playerManager.currentSong {
                if let image = song.albumArt {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(5)
                } else {
                    Image(systemName: "music.note")
                        .frame(width: 50, height: 50)
                }
                VStack(alignment: .leading) {
                    Text(song.name)
                        .font(.headline)
                    Text(formatTime(playerManager.currentTime) + " / " + formatTime(playerManager.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Slider(value: $playerManager.currentTime, in: 0...playerManager.duration, onEditingChanged: { editing in
                    if !editing {
                        playerManager.seek(to: playerManager.currentTime)
                    }
                })
                .frame(maxWidth: 200)
                Button(action: playPrevious) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                Button(action: {
                    playerManager.togglePlayPause()
                }) {
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .keyboardShortcut(.space, modifiers: [])
                Button(action: playNext) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
            } else {
                Text("未选择歌曲")
                    .foregroundColor(.secondary)
                Spacer()
            }
            // 播放模式切换按钮
            Button(action: {
                switch playerManager.playbackMode {
                case .normal:
                    playerManager.playbackMode = .shuffle
                case .shuffle:
                    playerManager.playbackMode = .repeatOne
                case .repeatOne:
                    playerManager.playbackMode = .normal
                }
            }) {
                Image(systemName: playbackModeIcon())
                    .font(.title2)
                    .foregroundColor(playerManager.currentSong != nil ? .accentColor : .gray)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private func playbackModeIcon() -> String {
        switch playerManager.playbackMode {
        case .normal:
            return "play"
        case .shuffle:
            return "shuffle"
        case .repeatOne:
            return "repeat.1"
        }
    }
}
