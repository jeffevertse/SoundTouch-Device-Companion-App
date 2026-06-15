import SwiftUI

struct ConfigView: View {
    @Environment(AppState.self) private var state
    @State private var saveResult: SaveResult?

    enum SaveResult { case ok, failed(String) }

    var body: some View {
        @Bindable var state = state
        NavigationStack {
            Form {
                ForEach(state.config.presets.indices, id: \.self) { i in
                    Section("Preset \(state.config.presets[i].id)") {
                        LabeledContent("Name") {
                            TextField("Station name", text: $state.config.presets[i].name)
                                .multilineTextAlignment(.trailing)
                        }
                        LabeledContent("URL") {
                            TextField("http(s)://…", text: $state.config.presets[i].streamURL)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                    }
                }

                Section {
                    Button("Save & Apply") {
                        Task {
                            let ok = await state.saveConfig()
                            saveResult = ok ? .ok : .failed(state.connectionError ?? "Unknown error")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(state.isBusy)
                }
            }
            .navigationTitle("Config")
            .alert("Saved", isPresented: Binding(
                get: { if case .ok = saveResult { return true }; return false },
                set: { if !$0 { saveResult = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Preset config applied on the device.")
            }
            .alert("Save failed", isPresented: Binding(
                get: { if case .failed = saveResult { return true }; return false },
                set: { if !$0 { saveResult = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                if case .failed(let msg) = saveResult { Text(msg) }
            }
        }
    }
}
