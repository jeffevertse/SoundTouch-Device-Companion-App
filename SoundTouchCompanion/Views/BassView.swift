import SwiftUI

struct BassView: View {
    @Environment(AppState.self) private var state
    @State private var pendingLevel: Int = 0

    private var hasChanged: Bool { pendingLevel != state.bassLevel }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Label("Bass", systemImage: "dial.low.fill")
                    .font(.headline)
                Spacer()
                Text(pendingLevel > 0 ? "+\(pendingLevel)" : "\(pendingLevel)")
                    .font(.title2.monospacedDigit().weight(.bold))
                    .foregroundStyle(hasChanged ? Color.accentColor : .primary)
                    .contentTransition(.numericText(value: Double(pendingLevel)))
                    .animation(.snappy, value: pendingLevel)
            }

            HStack(spacing: 8) {
                Text("−9")
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(minWidth: 20, alignment: .trailing)
                Slider(
                    value: Binding(
                        get: { Double(pendingLevel) },
                        set: { pendingLevel = Int($0.rounded()) }
                    ),
                    in: -9...9, step: 1
                )
                Text("+9")
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(minWidth: 20, alignment: .leading)
            }

            if hasChanged {
                Button {
                    Task { await state.setBass(pendingLevel) }
                } label: {
                    Text("Apply Bass")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .transition(.push(from: .bottom).combined(with: .opacity))
            }
        }
        .padding(16)
        .glassEffect(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .animation(.spring(duration: 0.3), value: hasChanged)
        .onAppear { pendingLevel = state.bassLevel }
        .onChange(of: state.bassLevel) { _, new in pendingLevel = new }
    }
}
