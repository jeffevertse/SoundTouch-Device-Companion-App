import Foundation

struct NowPlaying: Codable {
    var source: String?
    var playStatus: String?
    var contentItem: ContentItem?

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case playStatus = "PlayStatus"
        case contentItem = "ContentItem"
    }

    var isStandby: Bool { source?.uppercased() == "STANDBY" }
    var isPlaying: Bool { playStatus == "PLAY_STATE" }

    // Extracts preset id from ContentItem.Location "…/stream/<id>"
    var activePresetID: Int? {
        guard let loc = contentItem?.location,
              let last = loc.split(separator: "/").last,
              let id = Int(last) else { return nil }
        return id
    }
}

struct ContentItem: Codable {
    var source: String?
    var location: String?
    var itemName: String?

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case location = "Location"
        case itemName = "ItemName"
    }
}
