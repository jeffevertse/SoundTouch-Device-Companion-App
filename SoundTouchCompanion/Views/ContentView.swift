import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        if state.isConnected {
            TabView {
                Tab("Presets", systemImage: "radio.fill") {
                    PresetsView()
                }
                Tab("Config", systemImage: "slider.horizontal.3") {
                    ConfigView()
                }
                Tab("Settings", systemImage: "gearshape.fill") {
                    SettingsView()
                }
            }
        } else {
            SettingsView()
        }
    }
}
