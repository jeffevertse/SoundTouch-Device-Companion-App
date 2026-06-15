import SwiftUI

struct BassView: View {
    @Environment(AppState.self) private var state
    @State private var pendingLevel: Int = 0
    @State private var isSetting = false

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Bass")
                    .font(.headline)
                Spacer()
                Text(pendingLevel > 0 ? "+\(pendingLevel)" : "\(pendingLevel)")
                    .font(.title3).fontWeight(.bold)
                    .monospacedDigit()
                    .frame(minWidth: 36, alignment: .trailing)
                Button("Set") {
                    Task { await state.setBass(pendingLevel) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSetting || pendingLevel == state.bassLevel)
            }
            HStack {
                Text("−9").font(.caption).foregroundStyle(.secondary)
                Slider(value: Binding(
                    get: { Double(pendingLevel) },
                    set: { pendingLevel = Int($0.rounded()) }
                ), in: -9...9, step: 1)
                Text("+9").font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear { pendingLevel = state.bassLevel }
        .onChange(of: state.bassLevel) { _, new in pendingLevel = new }
    }
}
