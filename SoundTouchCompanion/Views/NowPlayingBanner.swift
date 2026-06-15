import SwiftUI

struct NowPlayingBanner: View {
    @Environment(AppState.self) private var state

    private var isPlaying: Bool { state.nowPlaying?.isPlaying == true }

    private var stationName: String {
        if state.nowPlaying?.isStandby == true { return "Standby" }
        if let id = state.nowPlaying?.activePresetID,
           let preset = state.config.presets.first(where: { $0.id == id }),
           !preset.name.isEmpty {
            return preset.name
        }
        return isPlaying ? "Playing" : "Not playing"
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isPlaying ? "waveform" : "speaker.slash.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isPlaying ? Color.accentColor : .secondary)
                .symbolEffect(.variableColor.cumulative.reversing, isActive: isPlaying)
                .frame(width: 22)

            Text(stationName)
                .font(.subheadline.weight(isPlaying ? .semibold : .regular))
                .foregroundStyle(isPlaying ? .primary : .secondary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .glassEffect(in: Capsule())
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
}
