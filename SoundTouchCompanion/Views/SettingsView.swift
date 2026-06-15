import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var state
    @State private var statusLine: String?
    @State private var isConnecting = false

    var body: some View {
        @Bindable var state = state
        NavigationStack {
            Form {
                Section("Device") {
                    LabeledContent("Host") {
                        TextField("192.168.1.29", text: $state.host)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    LabeledContent("Port") {
                        TextField("8099", text: $state.port)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                }

                Section {
                    Button {
                        Task {
                            isConnecting = true
                            defer { isConnecting = false }
                            await state.connect()
                            if state.isConnected {
                                statusLine = "Connected · v\(await versionString())"
                            } else {
                                statusLine = state.connectionError ?? "Could not connect."
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isConnecting {
                                ProgressView().padding(.trailing, 6)
                            }
                            Text(state.isConnected ? "Reconnect" : "Connect")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(isConnecting)

                    if let s = statusLine {
                        Text(s)
                            .font(.footnote)
                            .foregroundStyle(state.isConnected ? .green : .red)
                    }
                }

                if state.isConnected {
                    Section {
                        Button("Disconnect", role: .destructive) {
                            state.isConnected = false
                            statusLine = nil
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func versionString() async -> String {
        guard let portNum = Int(state.port) else { return "?" }
        let c = SoundTouchClient(host: state.host, port: portNum)
        let info = try? await c.healthz()
        return info?["version"] as? String ?? "?"
    }
}
