import Foundation

actor SoundTouchClient {
    private let baseURL: URL

    init(host: String, port: Int) {
        baseURL = URL(string: "http://\(host):\(port)")!
    }

    // MARK: - Health

    func healthz() async throws -> [String: Any] {
        let data = try await get("/healthz")
        return (try JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
    }

    // MARK: - Config

    func getConfig() async throws -> DeviceConfig {
        let data = try await get("/config")
        return try JSONDecoder().decode(DeviceConfig.self, from: data)
    }

    func postConfig(_ config: DeviceConfig) async throws {
        let body = try JSONEncoder().encode(config)
        _ = try await post("/config", body: body)
    }

    // MARK: - Playback

    func play(presetID: Int) async throws {
        _ = try await post("/play/\(presetID)", body: nil)
    }

    func nowPlaying() async throws -> NowPlaying {
        let data = try await get("/status")
        return try JSONDecoder().decode(NowPlaying.self, from: data)
    }

    // MARK: - Bass

    func getBass() async throws -> Int {
        let data = try await get("/bass")
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return obj?["level"] as? Int ?? 0
    }

    func setBass(_ level: Int) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["level": level])
        _ = try await post("/bass", body: body)
    }

    // MARK: - Internals

    private func get(_ path: String) async throws -> Data {
        let req = URLRequest(url: baseURL.appendingPathComponent(path), timeoutInterval: 8)
        let (data, resp) = try await URLSession.shared.data(for: req)
        try checkHTTP(resp, data: data)
        return data
    }

    private func post(_ path: String, body: Data?) async throws -> Data {
        var req = URLRequest(url: baseURL.appendingPathComponent(path), timeoutInterval: 8)
        req.httpMethod = "POST"
        req.httpBody = body
        if body != nil { req.setValue("application/json", forHTTPHeaderField: "Content-Type") }
        let (data, resp) = try await URLSession.shared.data(for: req)
        try checkHTTP(resp, data: data)
        return data
    }

    private func checkHTTP(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse, http.statusCode < 300 else {
            let msg = String(data: data, encoding: .utf8) ?? "HTTP error"
            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: msg])
        }
    }
}
