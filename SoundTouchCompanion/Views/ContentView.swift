import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var state
    @State private var pollingTask: Task<Void, Never>?

    var body: some View {
        if state.isConnected {
            mainContent
        } else {
            ConnectView()
        }
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    if let error = state.connectionError {
                        ErrorBanner(message: error)
                    }
                    NowPlayingCard()
                    BassRow()
                    PresetsSection()
                    SettingsSection()
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
            .background(Color(.systemGroupedBackground))

            if let toast = state.toast {
                ToastView(message: toast)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.toast)
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

// MARK: - Error banner

private struct ErrorBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(Color(.systemRed))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemRed).opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.vertical, 8)
    }
}

// MARK: - Toast

struct ToastView: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.75))
            .clipShape(Capsule())
    }
}

// MARK: - Connect view (not yet connected)

private struct ConnectView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    SettingsSection()
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
            .background(Color(.systemGroupedBackground))

            if let toast = state.toast {
                ToastView(message: toast)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.toast)
    }
}
