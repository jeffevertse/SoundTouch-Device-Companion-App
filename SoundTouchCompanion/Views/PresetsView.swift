import SwiftUI

struct PresetsView: View {
    @Environment(AppState.self) private var state
    @Environment(\.colorScheme) private var colorScheme
    @State private var pollingTask: Task<Void, Never>?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                background.ignoresSafeArea()

                ScrollView {
                    GlassEffectContainer(spacing: 12) {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(state.config.presets) { preset in
                                PresetCard(preset: preset)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    BassView()
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle("SoundTouch")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(state.host)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            NowPlayingBanner()
        }
        .onAppear { startPolling() }
        .onDisappear { stopPolling() }
    }

    private var background: some View {
        MeshGradient(
            width: 2, height: 3,
            points: [
                .init(0, 0),    .init(1, 0),
                .init(0, 0.5),  .init(1, 0.5),
                .init(0, 1),    .init(1, 1),
            ],
            colors: colorScheme == .dark
                ? [.indigo,              .purple.opacity(0.6),
                   .blue.opacity(0.4),   .indigo.opacity(0.3),
                   Color(white: 0.04),   Color(white: 0.07)]
                : [.cyan.opacity(0.25),  .blue.opacity(0.18),
                   .blue.opacity(0.08),  .indigo.opacity(0.06),
                   Color(.systemBackground), Color(.systemBackground)]
        )
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
    @Namespace private var ns
    let preset: Preset

    private var isActive: Bool {
        state.nowPlaying?.activePresetID == preset.id && state.nowPlaying?.isPlaying == true
    }
    private var isEmpty: Bool { preset.streamURL.isEmpty }

    var body: some View {
        Button {
            Task { await state.play(presetID: preset.id) }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(preset.id)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(isActive ? .white.opacity(0.75) : .secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(isActive ? .white.opacity(0.2) : Color(.tertiarySystemFill))
                    .clipShape(Capsule())
                    .padding(10)

                Spacer(minLength: 0)

                Text(isEmpty ? "Empty" : preset.name)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(isActive ? .white : .primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 96)
            .glassEffect(
                isActive
                    ? Glass.regular.tint(.accentColor)
                    : Glass.regular,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .glassEffectID(preset.id, in: ns)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isEmpty)
        .opacity(isEmpty ? 0.45 : 1)
    }
}

// MARK: - Press scale animation

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(duration: 0.2, bounce: 0.35), value: configuration.isPressed)
    }
}
