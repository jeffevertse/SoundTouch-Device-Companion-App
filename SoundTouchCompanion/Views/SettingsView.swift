import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var state
    @State private var statusLine: String?
    @State private var statusIsError = false
    @State private var isConnecting = false

    var body: some View {
        @Bindable var state = state
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Host") {
                        TextField("192.168.1.29", text: $state.host)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.decimalPad)
                    }
                    LabeledContent("Port") {
                        TextField("8099", text: $state.port)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                } header: {
                    Text("Speaker")
                } footer: {
                    Text("Enter the SoundTouch's LAN IP and the soundtouchd port (default 8099).")
                }

                Section {
                    Button {
                        Task { await connect() }
                    } label: {
                        HStack {
                            Spacer()
                            if isConnecting {
                                ProgressView()
                                    .padding(.trailing, 6)
                            }
                            Text(state.isConnected ? "Reconnect" : "Connect")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(isConnecting || state.host.isEmpty)

                    if let line = statusLine {
                        HStack(spacing: 6) {
                            Image(systemName: statusIsError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                                .foregroundStyle(statusIsError ? .red : .green)
                            Text(line)
                                .font(.footnote)
                                .foregroundStyle(statusIsError ? .red : .green)
                        }
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

    private func connect() async {
        isConnecting = true
        statusLine = nil
        defer { isConnecting = false }
        await state.connect()
        if state.isConnected {
            let version = await fetchVersion()
            statusLine = "Connected · soundtouchd \(version)"
            statusIsError = false
        } else {
            statusLine = state.connectionError ?? "Could not connect."
            statusIsError = true
        }
    }

    private func fetchVersion() async -> String {
        guard let portNum = Int(state.port) else { return "?" }
        let c = SoundTouchClient(host: state.host, port: portNum)
        let info = try? await c.healthz()
        return info?["version"] as? String ?? "?"
    }
}
