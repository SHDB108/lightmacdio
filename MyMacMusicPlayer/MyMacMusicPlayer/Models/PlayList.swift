import Foundation

struct Playlist: Identifiable, Codable {
    let id: UUID
    var name: String
    var songs: [Song]
    
    init(id: UUID = UUID(), name: String, songs: [Song]) {
        self.id = id
        self.name = name
        self.songs = songs
    }
}
