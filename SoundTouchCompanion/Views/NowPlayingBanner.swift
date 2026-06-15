import SwiftUI

struct NowPlayingCard: View {
    @Environment(AppState.self) private var state

    private var isPlaying: Bool { state.nowPlaying?.isPlaying == true }

    private var displayName: String {
        if state.nowPlaying?.isStandby == true { return "Standby" }
        if let id = state.nowPlaying?.activePresetID,
           let preset = state.config.presets.first(where: { $0.id == id }),
           !preset.name.isEmpty {
            return preset.name
        }
        return isPlaying ? "Playing" : "—"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("NOW PLAYING")

            HStack(spacing: 12) {
                Circle()
                    .fill(isPlaying ? Color.green : Color(.systemGray4))
                    .frame(width: 8, height: 8)
                    .scaleEffect(isPlaying ? 1.5 : 1)
                    .animation(
                        isPlaying
                            ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
                            : .default,
                        value: isPlaying
                    )

                Text(displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.vertical, 8)
    }
}
