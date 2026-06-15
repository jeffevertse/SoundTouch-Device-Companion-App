import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        if state.isConnected {
            TabView {
                PresetsView()
                    .tabItem { Label("Presets", systemImage: "radio") }
                ConfigView()
                    .tabItem { Label("Config", systemImage: "slider.horizontal.3") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
        } else {
            SettingsView()
        }
    }
}
