import SwiftUI

struct SettingsSection: View {
    @Environment(AppState.self) private var state
    @State private var showChangeDevice = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("DEVICE")

            VStack(spacing: 0) {
                // Status row
                HStack(spacing: 12) {
                    IconBadge(systemName: "network", color: .accentColor)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(state.host):\(state.port)")
                            .font(.subheadline)
                        Text(state.isConnected ? "Connected" : "Not connected")
                            .font(.caption)
                            .foregroundStyle(state.isConnected ? .green : .secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                Divider().padding(.leading, 54)

                // Change device row
                Button {
                    showChangeDevice = true
                } label: {
                    HStack(spacing: 12) {
                        IconBadge(systemName: "arrow.triangle.2.circlepath", color: .orange)
                        Text(state.isConnected ? "Change device" : "Connect to device")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.bottom, 8)
        .sheet(isPresented: $showChangeDevice) {
            ChangeDeviceSheet()
        }
    }
}

// MARK: - Change device sheet

private struct ChangeDeviceSheet: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var isConnecting = false
    @State private var error: String?

    var body: some View {
        @Bindable var state = state
        NavigationStack {
            Form {
                Section("Speaker address") {
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
                }

                if let e = error {
                    Section {
                        Text(e).foregroundStyle(.red).font(.footnote)
                    }
                }

                Section {
                    Button {
                        Task { await connect() }
                    } label: {
                        HStack {
                            Spacer()
                            if isConnecting { ProgressView().padding(.trailing, 6) }
                            Text("Connect")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(isConnecting || state.host.isEmpty)
                }
            }
            .navigationTitle("Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func connect() async {
        isConnecting = true
        error = nil
        defer { isConnecting = false }
        await state.connect()
        if state.isConnected {
            dismiss()
        } else {
            error = state.connectionError ?? "Could not connect."
        }
    }
}

// MARK: - Shared helpers

struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .kerning(0.5)
            .padding(.top, 12)
            .padding(.bottom, 2)
    }
}

struct IconBadge: View {
    let systemName: String
    let color: Color
    var body: some View {
        Image(systemName: systemName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
