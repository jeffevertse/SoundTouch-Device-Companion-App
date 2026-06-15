import SwiftUI

struct NowPlayingBanner: View {
    @Environment(AppState.self) private var state

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: state.nowPlaying?.isPlaying == true ? "waveform" : "speaker.slash")
                .foregroundStyle(state.nowPlaying?.isPlaying == true ? .green : .secondary)
                .symbolEffect(.variableColor.iterative, isActive: state.nowPlaying?.isPlaying == true)
            VStack(alignment: .leading, spacing: 1) {
                if state.nowPlaying?.isStandby == true {
                    Text("Standby")
                        .font(.subheadline).foregroundStyle(.secondary)
                } else if let id = state.nowPlaying?.activePresetID,
                          let preset = state.config.presets.first(where: { $0.id == id }) {
                    Text(preset.name)
                        .font(.subheadline).fontWeight(.semibold)
                } else {
                    Text(state.nowPlaying?.isPlaying == true ? "Playing" : "Idle")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
