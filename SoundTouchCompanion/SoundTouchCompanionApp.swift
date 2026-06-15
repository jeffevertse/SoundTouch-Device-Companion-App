import SwiftUI

@main
struct SoundTouchCompanionApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .navigationTitle("SoundTouch")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .environment(appState)
        }
    }
}
