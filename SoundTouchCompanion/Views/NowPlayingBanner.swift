import SwiftUI

struct NowPlayingBanner: View {
    @Environment(AppState.self) private var state

    private var isPlaying: Bool { state.nowPlaying?.isPlaying == true }

    private var label: String {
        if state.nowPlaying?.isStandby == true { return "Standby" }
        if let id = state.nowPlaying?.activePresetID,
           let preset = state.config.presets.first(where: { $0.id == id }),
           !preset.name.isEmpty {
            return preset.name
        }
        return isPlaying ? "Playing" : "Not playing"
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: isPlaying ? "waveform" : "speaker.slash.fill")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(isPlaying ? Color.accentColor : .secondary)
                .symbolEffect(.variableColor.cumulative.reversing, isActive: isPlaying)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .fontWeight(isPlaying ? .semibold : .regular)
                .foregroundStyle(isPlaying ? .primary : .secondary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 11)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }
}
