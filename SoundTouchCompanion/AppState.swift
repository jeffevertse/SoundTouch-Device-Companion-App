import Foundation
import Observation

@Observable
final class AppState {
    // Connection settings (persisted)
    var host: String {
        didSet { UserDefaults.standard.set(host, forKey: "st_host") }
    }
    var port: String {
        didSet { UserDefaults.standard.set(port, forKey: "st_port") }
    }

    // Live state
    var isConnected = false
    var connectionError: String?
    var config: DeviceConfig = .empty()
    var nowPlaying: NowPlaying?
    var bassLevel: Int = 0
    var isBusy = false

    private(set) var client: SoundTouchClient?

    init() {
        host = UserDefaults.standard.string(forKey: "st_host") ?? "192.168.1.29"
        port = UserDefaults.standard.string(forKey: "st_port") ?? "8099"
    }

    @MainActor
    func connect() async {
        guard let portNum = Int(port), !host.isEmpty else {
            connectionError = "Invalid host or port."
            return
        }
        connectionError = nil
        isBusy = true
        defer { isBusy = false }

        let c = SoundTouchClient(host: host, port: portNum)
        do {
            _ = try await c.healthz()
            client = c
            isConnected = true
            async let cfg = c.getConfig()
            async let bass = c.getBass()
            async let np = c.nowPlaying()
            config = try await cfg
            bassLevel = try await bass
            nowPlaying = try? await np
        } catch {
            isConnected = false
            connectionError = error.localizedDescription
        }
    }

    @MainActor
    func refreshNowPlaying() async {
        guard let c = client else { return }
        nowPlaying = try? await c.nowPlaying()
    }

    @MainActor
    func play(presetID: Int) async {
        guard let c = client else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            try await c.play(presetID: presetID)
            try? await Task.sleep(for: .seconds(1))
            nowPlaying = try? await c.nowPlaying()
        } catch {
            connectionError = error.localizedDescription
        }
    }

    @MainActor
    func setBass(_ level: Int) async {
        guard let c = client else { return }
        do {
            try await c.setBass(level)
            bassLevel = level
        } catch {
            connectionError = error.localizedDescription
        }
    }

    @MainActor
    func saveConfig() async -> Bool {
        guard let c = client else { return false }
        isBusy = true
        defer { isBusy = false }
        do {
            try await c.postConfig(config)
            return true
        } catch {
            connectionError = error.localizedDescription
            return false
        }
    }
}
