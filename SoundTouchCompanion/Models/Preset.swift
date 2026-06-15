import Foundation

struct Preset: Codable, Identifiable {
    let id: Int
    var name: String
    var streamURL: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case streamURL = "stream_url"
    }
}
