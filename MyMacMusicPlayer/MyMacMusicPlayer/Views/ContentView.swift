import SwiftUI

struct ContentView: View {
    @StateObject private var playerManager = PlayerManager()
    @StateObject private var musicState = MusicPlayerState()
    @State private var searchText = ""
    @State private var isMiniPlayer = false
    @StateObject private var miniPlayerController = MiniPlayerController()
    @State private var isShowingNewPlaylistAlert = false
    @State private var newPlaylistName = ""
    
    var body: some View {
        NavigationView {
            SidebarView(
                musicState: musicState,
                isShowingNewPlaylistAlert: $isShowingNewPlaylistAlert
            )
            
            SongListView(
                playerManager: playerManager,
                musicState: musicState,
                searchText: $searchText
            )
        }
        .searchable(text: $searchText, prompt: "搜索歌曲")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Mac 音乐播放器")
                    .font(.headline)
            }
            ToolbarItem {
                Button(action: { isMiniPlayer.toggle() }) {
                    Image(systemName: isMiniPlayer ? "rectangle.expand.vertical" : "rectangle.compress.vertical")
                }
            }
        }
        .alert("新建播放列表", isPresented: $isShowingNewPlaylistAlert) {
            TextField("播放列表名称", text: $newPlaylistName)
            Button("创建") {
                if !newPlaylistName.isEmpty {
                    musicState.playlists.append(Playlist(name: newPlaylistName, songs: []))
                    newPlaylistName = ""
                }
            }
            Button("取消", role: .cancel) {}
        }
        .onChange(of: isMiniPlayer) { newValue in
            if newValue {
                miniPlayerController.showMiniPlayer(
                    playerManager: playerManager,
                    musicState: musicState,
                    onExit: { isMiniPlayer = false }
                )
            } else {
                miniPlayerController.hideMiniPlayer()
            }
        }
        .onAppear {
            musicState.loadPlaylists()
            playerManager.setMusicState(musicState)
            playerManager.restoreState(songs: musicState.playlists.flatMap { $0.songs })
        }
        .onDisappear {
            playerManager.saveState()
            musicState.savePlaylists()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
