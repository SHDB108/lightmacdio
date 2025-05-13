import Foundation

class MusicPlayerState: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var currentPlaylistID: UUID?
    
    var currentPlaylist: Playlist? {
        if currentPlaylistID == nil {
            let allSongs = playlists.flatMap { $0.songs }
            print("生成所有歌曲播放列表，歌曲数：\(allSongs.count)")
            return Playlist(id: UUID(), name: "所有歌曲", songs: allSongs)
        }
        return playlists.first { $0.id == currentPlaylistID }
    }
    
    func loadPlaylists() {
        if let data = UserDefaults.standard.data(forKey: "playlists"),
           let savedPlaylists = try? JSONDecoder().decode([Playlist].self, from: data) {
            playlists = savedPlaylists
            print("加载播放列表：\(playlists.map { ($0.name, $0.songs.count) })")
        }
    }
    
    func savePlaylists() {
        if let data = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(data, forKey: "playlists")
            print("保存播放列表：\(playlists.map { ($0.name, $0.songs.count) })")
        }
    }
    
    func selectAllSongs() {
        currentPlaylistID = nil
        print("选择所有歌曲视图")
    }
    
    func selectPlaylist(_ playlistID: UUID) {
        currentPlaylistID = playlistID
        print("导航到播放列表：\(playlists.first { $0.id == playlistID }?.name ?? "未知")")
    }
    
    func deleteSong(_ song: Song, playerManager: PlayerManager) {
        if playerManager.currentSong == song {
            playerManager.stop()
        }
        
        if currentPlaylistID == nil {
            for index in playlists.indices {
                playlists[index].songs.removeAll { $0.id == song.id }
            }
            print("从所有播放列表中删除歌曲：\(song.name)")
        } else if let playlistID = currentPlaylistID,
                  let index = playlists.firstIndex(where: { $0.id == playlistID }) {
            playlists[index].songs.removeAll { $0.id == song.id }
            print("从播放列表 \(playlists[index].name) 中删除歌曲：\(song.name)")
        }
        
        savePlaylists()
    }
    
    func deletePlaylist(_ playlistID: UUID) {
        if let playlist = playlists.first(where: { $0.id == playlistID }) {
            if currentPlaylistID == playlistID {
                currentPlaylistID = nil
                print("删除当前选中的播放列表，切换到所有歌曲视图")
            }
            playlists.removeAll { $0.id == playlistID }
            print("删除播放列表：\(playlist.name)")
            savePlaylists()
        }
    }
}
