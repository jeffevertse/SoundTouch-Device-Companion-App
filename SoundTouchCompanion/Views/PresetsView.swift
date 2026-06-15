import SwiftUI

struct PresetsView: View {
    @Environment(AppState.self) private var state
    @State private var pollingTask: Task<Void, Never>?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(state.config.presets) { preset in
                        PresetCard(preset: preset)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                BassView()
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SoundTouch")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("SoundTouch")
                            .font(.headline)
                        Text(state.host)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            NowPlayingBanner()
        }
        .onAppear { startPolling() }
        .onDisappear { stopPolling() }
    }

    private func startPolling() {
        pollingTask = Task {
            while !Task.isCancelled {
                await state.refreshNowPlaying()
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    private func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
}

// MARK: - Preset card

private struct PresetCard: View {
    @Environment(AppState.self) private var state
    let preset: Preset

    private var isActive: Bool {
        state.nowPlaying?.activePresetID == preset.id && state.nowPlaying?.isPlaying == true
    }
    private var isEmpty: Bool { preset.streamURL.isEmpty }

    var body: some View {
        Button {
            Task { await state.play(presetID: preset.id) }
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isActive ? Color.accentColor : Color(.secondarySystemGroupedBackground))

                if isActive {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white.opacity(0.08))
                }

                VStack(alignment: .leading, spacing: 0) {
                    // Preset number badge
                    Text("\(preset.id)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(isActive ? .white.opacity(0.75) : .secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(isActive ? .white.opacity(0.18) : Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                        .padding(10)

                    Spacer(minLength: 0)

                    Text(isEmpty ? "Empty" : preset.name)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(isActive ? .white : (isEmpty ? .secondary : .primary))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 14)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 96)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isEmpty)
        .opacity(isEmpty ? 0.45 : 1)
    }
}

// MARK: - Button style with press scale

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(duration: 0.2, bounce: 0.3), value: configuration.isPressed)
    }
}
