import SwiftUI

struct PresetEditSheet: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss

    let preset: Preset
    @State private var name: String
    @State private var streamURL: String

    init(preset: Preset) {
        self.preset = preset
        _name = State(initialValue: preset.name)
        _streamURL = State(initialValue: preset.streamURL)
    }

    private var hasChanges: Bool {
        name != preset.name || streamURL != preset.streamURL
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Station") {
                    TextField("Name", text: $name)
                    TextField("Stream URL", text: $streamURL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Section {
                    Text("Paste an MP3, PLS or M3U stream URL. The URL is proxied on the speaker — HTTPS streams are supported.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Preset \(preset.id)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save & Apply") {
                        Task { await save() }
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || !hasChanges || state.isBusy)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func save() async {
        guard let idx = state.config.presets.firstIndex(where: { $0.id == preset.id }) else { return }
        state.config.presets[idx].name = name.trimmingCharacters(in: .whitespaces)
        state.config.presets[idx].streamURL = streamURL.trimmingCharacters(in: .whitespaces)
        let ok = await state.saveConfig()
        if ok { dismiss() }
    }
}
