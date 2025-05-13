import Foundation
import AppKit

struct Song: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let url: URL
    let duration: Double
    private let albumArtData: Data?
    
    var albumArt: NSImage? {
        guard let data = albumArtData else { return nil }
        return NSImage(data: data)
    }
    
    init(id: UUID = UUID(), name: String, url: URL, duration: Double, albumArt: NSImage?) {
        self.id = id
        self.name = name
        self.url = url
        self.duration = duration
        self.albumArtData = albumArt?.tiffRepresentation
    }
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, duration, albumArtData
    }
}
