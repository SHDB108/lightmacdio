import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var playerManager: PlayerManager
    @ObservedObject var musicState: MusicPlayerState
    let onExit: () -> Void
    
    var body: some View {
        HStack {
            if let song = playerManager.currentSong {
                if let image = song.albumArt {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(5)
                } else {
                    Image(systemName: "music.note")
                        .frame(width: 40, height: 40)
                }
                Text(song.name)
                    .font(.caption)
                    .lineLimit(1)
                Spacer()
                Button(action: {
                    playerManager.playPrevious()
                }) {
                    Image(systemName: "backward.fill")
                }
                Button(action: {
                    if playerManager.isPlaying {
                        playerManager.togglePlayPause()
                    } else if let song = playerManager.currentSong {
                        playerManager.playSong(song)
                    }
                }) {
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                }
                Button(action: {
                    playerManager.playNext()
                }) {
                    Image(systemName: "forward.fill")
                }
            } else {
                Text("请先播放一首歌曲")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            Button(action: onExit) {
                Image(systemName: "rectangle.expand.vertical")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}
