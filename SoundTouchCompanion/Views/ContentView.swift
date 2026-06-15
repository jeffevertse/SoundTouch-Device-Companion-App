import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var state
    @State private var pollingTask: Task<Void, Never>?
    @State private var showSettings = false

    var body: some View {
        if state.isConnected {
            mainContent
        } else {
            ConnectView()
        }
    }

    private var mainContent: some View {
        VStack(spacing: 12) {
            if let error = state.connectionError {
                ErrorBanner(message: error)
            }
            NowPlayingCard()
            PresetsSection()
            BassRow()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .overlay(alignment: .bottom) {
            if let toast = state.toast {
                ToastView(message: toast)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.toast)
        .onAppear { startPolling() }
        .onDisappear { stopPolling() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showSettings = true } label: {
                    Image(systemName: "network")
                        .foregroundStyle(Color.green)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            ChangeDeviceSheet()
        }
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
    @State private var showConnect = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "hifispeaker.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Not Connected")
                .font(.title3.weight(.semibold))
            Text("Connect to your SoundTouch device to continue.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Connect to Device") {
                showConnect = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .overlay(alignment: .bottom) {
            if let toast = state.toast {
                ToastView(message: toast)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.toast)
        .sheet(isPresented: $showConnect) {
            ChangeDeviceSheet()
        }
    }
}
