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
                    Section {
                        LabeledContent("Name") {
                            TextField("Station name", text: $state.config.presets[i].name)
                                .multilineTextAlignment(.trailing)
                        }
                        LabeledContent("Stream URL") {
                            TextField("https://…", text: $state.config.presets[i].streamURL)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                    } header: {
                        Text("Preset \(state.config.presets[i].id)")
                    }
                }

                Section {
                    Button {
                        Task {
                            let ok = await state.saveConfig()
                            saveResult = ok
                                ? .ok
                                : .failed(state.connectionError ?? "Unknown error")
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if state.isBusy {
                                ProgressView().padding(.trailing, 6)
                            }
                            Text("Save & Apply")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(state.isBusy)
                } footer: {
                    Text("Changes are applied to the speaker immediately — no restart required.")
                }
            }
            .navigationTitle("Config")
            .alert("Saved", isPresented: Binding(
                get: { if case .ok = saveResult { return true }; return false },
                set: { if !$0 { saveResult = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Preset config applied on the speaker.")
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
