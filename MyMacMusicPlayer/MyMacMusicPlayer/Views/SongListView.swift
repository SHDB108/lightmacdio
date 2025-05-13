import SwiftUI
import AVFoundation
import UniformTypeIdentifiers
import AppKit

struct SongListView: View {
    @ObservedObject var playerManager: PlayerManager
    @ObservedObject var musicState: MusicPlayerState
    @Binding var searchText: String
    @State private var errorMessage: String?
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var songs: [Song] {
        let allSongs = musicState.currentPlaylist?.songs ?? []
        print("当前播放列表：\(musicState.currentPlaylist?.name ?? "无"), 歌曲数：\(allSongs.count)")
        if searchText.isEmpty {
            return allSongs
        }
        return allSongs.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        ZStack {
            VStack {
                if songs.isEmpty {
                    Text(musicState.currentPlaylistID == nil ? "没有歌曲" : "播放列表为空")
                        .font(.title2)
                        .foregroundColor(.secondary)
                } else {
                    List(songs) { song in
                        Button(action: {
                            playerManager.playSong(song)
                        }) {
                            HStack {
                                if let image = song.albumArt {
                                    Image(nsImage: image)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(5)
                                } else {
                                    Image(systemName: "music.note")
                                        .frame(width: 40, height: 40)
                                }
                                VStack(alignment: .leading) {
                                    Text(song.name)
                                        .foregroundColor(playerManager.currentSong?.id == song.id ? .accentColor : .primary)
                                    Text(formatTime(song.duration))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if playerManager.currentSong?.id == song.id && playerManager.isPlaying {
                                    Image(systemName: "play.fill")
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("删除") {
                                musicState.deleteSong(song, playerManager: playerManager)
                            }
                        }
                    }
                }
                
                if playerManager.currentSong != nil {
                    NowPlayingBar(
                        playerManager: playerManager,
                        playPrevious: {
                            playerManager.playPrevious()
                            if playerManager.currentSong == nil && songs.isEmpty {
                                showToast = true
                                toastMessage = "播放列表为空，已停止播放"
                            }
                        },
                        playNext: {
                            playerManager.playNext()
                            if playerManager.currentSong == nil && songs.isEmpty {
                                showToast = true
                                toastMessage = "播放列表为空，已停止播放"
                            }
                        }
                    )
                }
            }
            ToastView(message: toastMessage, isShowing: $showToast)
                .offset(y: -50)
        }
        .toolbar {
            ToolbarItemGroup {
                Button(action: {
                    loadMusicFolder()
                }) {
                    Image(systemName: "folder")
                }
                Button(action: {
                    loadSingleSong()
                }) {
                    Image(systemName: "music.note")
                }
            }
        }
        .alert("错误", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("确定") {}
        } message: {
            Text(errorMessage ?? "未知错误")
        }
        .onChange(of: playerManager.currentSong) { newValue in
            print("currentSong 变化：\(newValue?.name ?? "nil")")
        }
    }
    
    private func loadMusicFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.folder]
        
        if panel.runModal() == .OK, let url = panel.url {
            Task {
                let newSongs = await loadSongs(from: url, isSingleFile: false)
                await MainActor.run {
                    if newSongs.isEmpty {
                        errorMessage = "未找到 .mp3 文件，请选择其他文件夹"
                    } else {
                        if let currentID = musicState.currentPlaylistID,
                           let index = musicState.playlists.firstIndex(where: { $0.id == currentID }) {
                            musicState.playlists[index].songs.append(contentsOf: newSongs)
                        } else {
                            let newPlaylist = Playlist(name: "新播放列表", songs: newSongs)
                            musicState.playlists.append(newPlaylist)
                            musicState.currentPlaylistID = newPlaylist.id
                        }
                        musicState.savePlaylists()
                        print("添加文件夹后，播放列表：\(musicState.playlists.map { ($0.name, $0.songs.count) })")
                    }
                }
            }
        } else {
            print("用户取消了文件夹选择")
        }
    }
    
    private func loadSingleSong() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.mp3]
        
        if panel.runModal() == .OK, let url = panel.url {
            Task {
                let newSongs = await loadSongs(from: url, isSingleFile: true)
                await MainActor.run {
                    if newSongs.isEmpty {
                        errorMessage = "无法加载歌曲，请选择有效的 .mp3 文件"
                    } else {
                        if let currentID = musicState.currentPlaylistID,
                           let index = musicState.playlists.firstIndex(where: { $0.id == currentID }) {
                            musicState.playlists[index].songs.append(contentsOf: newSongs)
                        } else {
                            let newPlaylist = Playlist(name: "新播放列表", songs: newSongs)
                            musicState.playlists.append(newPlaylist)
                            musicState.currentPlaylistID = newPlaylist.id
                        }
                        musicState.savePlaylists()
                        print("添加歌曲后，播放列表：\(musicState.playlists.map { ($0.name, $0.songs.count) })")
                    }
                }
            }
        } else {
            print("用户取消了歌曲选择")
        }
    }
    
    private func loadSongs(from url: URL, isSingleFile: Bool) async -> [Song] {
        var songs: [Song] = []
        let fileManager = FileManager.default
        
        guard url.startAccessingSecurityScopedResource() else {
            print("无法访问资源：权限不足")
            return songs
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            if isSingleFile {
                if url.pathExtension.lowercased() == "mp3" {
                    print("处理文件：\(url.lastPathComponent)")
                    let asset = AVURLAsset(url: url)
                    let duration = try await asset.load(.duration).seconds
                    let albumArt = await getAlbumArt(from: url)
                    let name = url.lastPathComponent
                    songs.append(Song(name: name, url: url, duration: duration, albumArt: albumArt))
                } else {
                    print("文件不是 .mp3 格式：\(url.lastPathComponent)")
                }
            } else {
                let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.contentTypeKey])
                print("找到 \(contents.count) 个文件")
                
                for fileURL in contents {
                    if fileURL.pathExtension.lowercased() == "mp3" {
                        print("处理文件：\(fileURL.lastPathComponent)")
                        let asset = AVURLAsset(url: fileURL)
                        let duration = try await asset.load(.duration).seconds
                        let albumArt = await getAlbumArt(from: fileURL)
                        let name = fileURL.lastPathComponent
                        songs.append(Song(name: name, url: fileURL, duration: duration, albumArt: albumArt))
                    }
                }
            }
        } catch {
            print("加载失败: \(error.localizedDescription)")
        }
        print("加载完成，找到 \(songs.count) 首歌曲")
        return songs
    }
    
    private func getAlbumArt(from url: URL) async -> NSImage? {
        let asset = AVURLAsset(url: url)
        do {
            let metadata = try await asset.load(.commonMetadata)
            for item in metadata {
                if item.commonKey?.rawValue == "artwork", let data = try await item.load(.value) as? Data {
                    return NSImage(data: data)
                }
            }
        } catch {
            print("加载封面失败: \(error)")
        }
        return nil
    }
}

struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            Text(message)
                .padding()
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
        }
    }
}
