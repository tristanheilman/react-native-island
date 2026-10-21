# Roadmap

## Goal
react-native-island lets React Native developers ship glanceable live status UI
from one typed JavaScript API: iOS Live Activities on the Lock Screen and Dynamic
Island, and Android ongoing notifications. It works by snapshotting the app's own
React Native components. Done means a 1.0 that an app team can adopt without
writing SwiftUI or Kotlin: setup is automated, Expo included; updates arrive while
the app is in the background; the behaviour is covered by tests; and the API is
stable under semver.

## Phases
### Phase 1 — Cross-platform core [done]
Evidence: version 0.1.1 is on npm with the unified typed slot API, iOS snapshot Live Activities and Android ongoing notifications (3597fe3, aa6a42d, 6ddeafa). CI is green on main at 5d8fd2f, including the iOS and Android builds, and the baseball example app is in `example/`.
### Phase 2 — A 0.x people can trust and set up [current]
Exit when:
- The JS API has unit tests with real assertions in `src/__tests__/`, covering start, update, end, the typed slots and the deprecated aliases, and CI fails when they fail. Today there is one `todo` test.
- An Expo app gets the iOS widget extension and App Group from a config plugin, with no manual Xcode steps, shown working in a fresh Expo project.
- The README's manual setup steps are re-checked against the example app.
- CI builds iOS on a current Xcode, or the macos-15 / Xcode 16.2 pin is recorded with what must change to remove it.
### Phase 3 — Native depth on both platforms [next]
Exit when:
- On Android 16, the example's notification appears as a promoted Live Update with a progress bar (`ProgressStyle`) and falls back cleanly on older Android.
- iOS snapshots render at each Dynamic Island region's native size and follow light and dark mode.
- The iOS module is a codegen TurboModule.
### Phase 4 — Updates while the app is in the background [next]
Exit when:
- A running Live Activity in the example updates from an APNs push while the app is in the background.
- An Android ongoing notification updates from an FCM message.
- The README documents the server-side payload contract for both.
### Phase 5 — 1.0 [next]
Exit when:
- 1.0.0 is published with the deprecated `startIslandActivity`-style aliases removed.
- A migration guide from 0.x exists.
- The API is documented as stable under semver.

## Side quests
- Add a `CLAUDE.md` that records the repo's conventions: conventional commits checked by lefthook, release-please releases, and an issue before any API change. Sessions then follow them without rediscovering them.
- Record a short demo of the example on both platforms for the README. The library is visual, and the README only describes it in words.
- Add native rendering checks for the iOS snapshot sizes and the Android notification layout. The JS unit tests in Phase 2 cannot see native regressions.

## Reserved for the owner
- Publishing to npm, cutting releases, and changing release-please or version numbers.
- Breaking changes to the public JS API, including removing the deprecated aliases. `CONTRIBUTING.md` asks for an issue first.
- Adding push credentials (APNs keys, FCM server keys) to the repo, CI or the example.
- Deleting branches, and changing the licence or CODEOWNERS.

## Settled
- **Android uses ongoing notifications, not bubbles.** The Bubbles API was tried and replaced (3597fe3, PR #7).
- **No live React Native views inside an iOS Live Activity.** The platform does not allow it, so snapshots are the approach (README, Limitations).
- **Interactive buttons are a later tier.** They need native SwiftUI App Intents and are not current scope (README).
