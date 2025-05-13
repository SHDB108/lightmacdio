import SwiftUI

struct SidebarView: View {
    @ObservedObject var musicState: MusicPlayerState
    @Binding var isShowingNewPlaylistAlert: Bool
    @State private var isShowingDeleteConfirmation = false
    @State private var playlistToDelete: Playlist?
    
    var body: some View {
        List {
            Section(header: Text("音乐库")) {
                Button(action: {
                    musicState.selectAllSongs()
                }) {
                    Label("所有歌曲", systemImage: "music.note.list")
                        .foregroundColor(musicState.currentPlaylistID == nil ? .accentColor : .primary)
                }
            }
            Section(header: Text("播放列表")) {
                ForEach(musicState.playlists) { playlist in
                    Button(action: {
                        if NSEvent.modifierFlags.contains(.control) {
                            playlistToDelete = playlist
                            isShowingDeleteConfirmation = true
                        } else {
                            musicState.selectPlaylist(playlist.id)
                        }
                    }) {
                        Label(playlist.name, systemImage: "music.note")
                            .foregroundColor(musicState.currentPlaylistID == playlist.id ? .accentColor : .primary)
                    }
                }
                Button(action: { isShowingNewPlaylistAlert = true }) {
                    Label("新建播放列表", systemImage: "plus")
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
        .alert(isPresented: $isShowingDeleteConfirmation) {
            Alert(
                title: Text("删除播放列表"),
                message: Text("是否删除播放列表 “\(playlistToDelete?.name ?? "")”？此操作不可撤销。"),
                primaryButton: .destructive(Text("删除")) {
                    if let playlist = playlistToDelete {
                        musicState.deletePlaylist(playlist.id)
                    }
                    playlistToDelete = nil
                },
                secondaryButton: .cancel(Text("取消")) {
                    playlistToDelete = nil
                }
            )
        }
    }
}
