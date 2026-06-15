import SwiftUI

struct PresetsSection: View {
    @Environment(AppState.self) private var state
    @State private var editingPreset: Preset?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("RADIO PRESETS")

            GeometryReader { geo in
                let cardHeight = max(72, (geo.size.height - 12 * 2) / 3)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(state.config.presets) { preset in
                        PresetCard(preset: preset, height: cardHeight, onEdit: { editingPreset = preset })
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(item: $editingPreset) { preset in
            PresetEditSheet(preset: preset)
        }
    }
}

// MARK: - Preset card

private struct PresetCard: View {
    @Environment(AppState.self) private var state
    let preset: Preset
    let height: CGFloat
    let onEdit: () -> Void

    private var isActive: Bool {
        state.nowPlaying?.activePresetID == preset.id && state.nowPlaying?.isPlaying == true
    }
    private var isEmpty: Bool { preset.streamURL.isEmpty }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                guard !isEmpty else { return }
                Task { await state.play(presetID: preset.id) }
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Preset \(preset.id)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(isEmpty ? "Empty" : preset.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isEmpty ? .secondary : .primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(14)
                .frame(height: height, alignment: .leading)
                .frame(maxWidth: .infinity)
                .background(
                    isActive
                        ? Color.accentColor.opacity(0.10)
                        : Color(.secondarySystemGroupedBackground)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    if isActive {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.accentColor, lineWidth: 1.5)
                    }
                }
            }
            .buttonStyle(.plain)
            .opacity(isEmpty ? 0.5 : 1)
            .contextMenu {
                Button("Edit Preset") { onEdit() }
                if !isEmpty {
                    Button("Play") { Task { await state.play(presetID: preset.id) } }
                }
            }

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
    }
}
