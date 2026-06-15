import Foundation

struct DeviceConfig: Codable {
    var deviceHost: String
    var proxyPort: Int
    var lastPresetID: Int
    var presets: [Preset]

    enum CodingKeys: String, CodingKey {
        case deviceHost = "device_host"
        case proxyPort = "proxy_port"
        case lastPresetID = "last_preset_id"
        case presets
    }

    static func empty() -> DeviceConfig {
        DeviceConfig(deviceHost: "", proxyPort: 8099, lastPresetID: 0, presets: (1...6).map {
            Preset(id: $0, name: "Preset \($0)", streamURL: "")
        })
    }
}
