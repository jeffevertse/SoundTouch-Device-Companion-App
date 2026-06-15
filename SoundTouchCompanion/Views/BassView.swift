import SwiftUI

struct BassRow: View {
    @Environment(AppState.self) private var state
    @State private var pendingLevel: Int = 0
    @State private var debounceTask: Task<Void, Never>?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("BASS")

            HStack(spacing: 12) {
                Image(systemName: "dial.low.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)

                Slider(
                    value: Binding(
                        get: { Double(pendingLevel) },
                        set: { newValue in
                            pendingLevel = Int(newValue.rounded())
                            schedule()
                        }
                    ),
                    in: -9...9, step: 1
                )
                .tint(.teal)

                Text(pendingLevel > 0 ? "+\(pendingLevel)" : "\(pendingLevel)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 32, alignment: .trailing)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onAppear { pendingLevel = state.bassLevel }
        .onChange(of: state.bassLevel) { _, new in pendingLevel = new }
    }

    private func schedule() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            if !Task.isCancelled {
                await state.setBass(pendingLevel)
            }
        }
    }
}
