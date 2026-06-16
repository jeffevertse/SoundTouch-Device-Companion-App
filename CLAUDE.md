# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

SwiftUI iOS app (iOS 17+) that controls a Bose SoundTouch 20 speaker through
[SoundTouch-Device](https://github.com/jeffevertse/SoundTouch-Device), a Go HTTP server that runs
directly on the speaker hardware and translates HTTP calls to UPnP:

```
iPhone app  ──HTTP──▶  SoundTouch-Device (Go, armv7)  ──UPnP──▶  Bose SoundTouch 20
            GET /status, /config, /bass
            POST /play/:id, /config, /bass
```

No third-party dependencies — pure SwiftUI + `Observation`.

## Project setup

The Xcode project (`SoundTouchCompanion.xcodeproj`) is generated from `project.yml` via
[XcodeGen](https://github.com/yonaskolb/XcodeGen). If you change target settings, sources, or
Info.plist keys, edit `project.yml` and regenerate:

```
xcodegen generate
```

Build/run/test with the standard `xcodebuild`/Xcode workflow against the generated project —
there is no separate test target defined in `project.yml`.

`NSAllowsArbitraryLoads` is enabled in Info.plist because the device is reached over plain HTTP on
the local network.

## Architecture

- **`AppState`** (`AppState.swift`) — single `@Observable` source of truth, injected via
  `.environment(appState)` at the app root and read with `@Environment(AppState.self)` in views.
  Owns the `SoundTouchClient`, connection state, `DeviceConfig`, `NowPlaying`, bass level, and a
  transient toast message. All device calls go through `async` methods on `AppState`
  (`connect`, `refreshNowPlaying`, `play(presetID:)`, `setBass`, `saveConfig`) — views never call
  `SoundTouchClient` directly.
- **`SoundTouchClient`** (`Services/SoundTouchClient.swift`) — an `actor` wrapping `URLSession`
  calls to the SoundTouch-Device HTTP API (`/healthz`, `/config`, `/status`, `/bass`,
  `/play/:id`). Plain `get`/`post` helpers with an 8s timeout; non-2xx responses are surfaced as
  `URLError` with the response body as the localized description.
- **Models** (`Models/`) — `Codable` structs mirroring the device API's JSON shape exactly
  (snake_case `CodingKeys` for the Go server's config/preset payloads, PascalCase `CodingKeys` for
  the SoundTouch's native `NowPlaying`/`ContentItem` fields). `NowPlaying.activePresetID` parses
  the preset id back out of the `ContentItem.Location` path (`…/stream/<id>`).
  `DeviceConfig.empty()` seeds 6 blank presets — the device always exposes exactly 6.
- **Views** (`Views/`) — `ContentView` is the root: shows `ConnectView` until `state.isConnected`,
  otherwise the main layout (now playing card, presets grid, bass slider) with a 5-second polling
  loop calling `state.refreshNowPlaying()`. Connection/host changes happen through
  `ChangeDeviceSheet` in `SettingsView.swift`; preset rename/URL edits happen through
  `PresetEditSheet`. `Views/ConfigView.swift` is currently an empty stub.
- All device I/O is `async`/`await` and mutates `AppState` on `@MainActor`; UI errors surface
  through `state.connectionError` (persistent banner) or `state.showToast(_:)` (transient,
  auto-dismisses after 2s).
