import SwiftUI

struct PresetsView: View {
    @Environment(AppState.self) private var state
    @State private var pollingTask: Task<Void, Never>?

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    NowPlayingBanner()

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(state.config.presets) { preset in
                            PresetButton(preset: preset)
                        }
                    }

                    BassView()
                }
                .padding()
            }
            .navigationTitle("SoundTouch")
            .background(Color(.systemGroupedBackground))
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

private struct PresetButton: View {
    @Environment(AppState.self) private var state
    let preset: Preset

    var isActive: Bool {
        state.nowPlaying?.activePresetID == preset.id && state.nowPlaying?.isPlaying == true
    }

    var body: some View {
        Button {
            Task { await state.play(presetID: preset.id) }
        } label: {
            VStack(spacing: 6) {
                Text("\(preset.id)")
                    .font(.caption2).fontWeight(.semibold)
                    .foregroundStyle(isActive ? .white.opacity(0.8) : .secondary)
                Text(preset.name.isEmpty ? "Empty" : preset.name)
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(isActive ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 72)
            .padding(.horizontal, 8)
            .background(isActive ? Color.accentColor : Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isActive ? .clear : Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(preset.streamURL.isEmpty)
        .opacity(preset.streamURL.isEmpty ? 0.4 : 1)
    }
}
