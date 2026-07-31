# react-native-island

> ⚠️ **Active development — not yet production ready.** APIs will change before `1.0`. iOS Live Activities are the current focus; Android is in progress. Expect breaking changes.

Build **iOS Live Activities** (Lock Screen + Dynamic Island) and **Android ongoing notifications** from your React Native UI — one JavaScript API for both.

You author the UI as ordinary React Native components. The library snapshots each one to an image and renders it inside the native surface, so the same components power a Live Activity on iOS and an updatable notification on Android.

## Why this exists

iOS Live Activities and Android's ongoing/"Live Update" notifications are the two platforms' answer to the same problem: **glanceable, updatable status shown outside your app** — deliveries, ride status, sports scores, timers, workouts. They're used in tandem across mobile apps, but each requires very different native work. This library gives React Native developers one API to drive both.

## How it works

You **cannot** run live React Native views inside an iOS Live Activity — widget extensions are a separate process that renders static SwiftUI. So this library takes the only pragmatic approach for reusing arbitrary RN UI:

1. You wrap the components you want to show in `<IslandWrapper>` and register them by id.
2. On start/update, the library renders each component to an image (a PNG on iOS written to a shared **App Group**; a bitmap on Android placed into the notification).
3. The native surface (Live Activity widget / notification) displays that image.

This means the rendered UI is a **snapshot**, not an interactive live view. See [Limitations](#limitations).

## Update model

Updates fall into two tiers. **Tier 1 requires no server** and covers most use cases.

| | iOS Live Activity | Android notification |
|---|---|---|
| **Tier 1 — Local** (app/foreground running) | ✅ update from your app | ✅ update from your app (or a foreground service) |
| **Tier 2 — Push** (process not running) | Requires APNs push (bring your own server) | Foreground service (local) or FCM push |

The example app is entirely Tier 1 — no server needed to try it.

## Requirements

- React Native 0.76+
- iOS 16.2+ (Live Activities / Dynamic Island)
- Android 8+ (API 26, notification channels); Android 16 "Live Update" enhancements applied where available

## Installation

```sh
npm install react-native-island
# or
yarn add react-native-island
```

```sh
cd ios && pod install
```

### iOS setup

Run the setup helper to automate the mechanical parts (patches `Info.plist`,
drops the widget Swift templates into place) and print the remaining Xcode steps:

```sh
node node_modules/react-native-island/auto-setup.js DynamicWidgetExtension group.your.app.island
```

Then, in Xcode, you still need to:

1. Add a Live Activity **Widget Extension** target and add the generated Swift files to it.
2. Add an **App Group** (the one you passed above) to **both** the app and the extension.
3. Call `setAppGroup('group.your.app.island')` from JS before starting an activity.

Full walkthrough with screenshots: [`docs/DYNAMIC_WIDGET_SETUP.md`](./docs/DYNAMIC_WIDGET_SETUP.md).

### Android setup

No extension to configure — a live activity is an ongoing notification. You just
need to request the `POST_NOTIFICATIONS` permission at runtime (Android 13+).
Full walkthrough: [`docs/ANDROID_SETUP.md`](./docs/ANDROID_SETUP.md).

## API

The surface is a small, fully-typed, slot-based API. You register components,
wrap them in `<IslandWrapper>`, then reference them by id in the activity slots.

| Method | Signature | Description |
|--------|-----------|-------------|
| `setAppGroup` | `(appGroup: string) => Promise<void>` | (iOS) App Group shared with the widget extension. No-op on Android. |
| `registerComponent` | `(id: string, componentName: string) => void` | Register a component so it can be snapshotted for an activity. |
| `startLiveActivity` | `(slots: IslandSlots) => Promise<string>` | Snapshots the slot components and starts the activity. Resolves with the activity id. |
| `updateLiveActivity` | `(id: string, slots: IslandSlots) => Promise<string>` | Re-snapshots the slots and updates the running activity. |
| `endLiveActivity` | `() => Promise<void>` | Ends all running activities. |
| `getLiveActivities` | `() => Promise<string[]>` | Ids of currently running activities. |

`IslandSlots` maps UI regions to registered component ids:

| Slot | iOS | Android |
|------|-----|---------|
| `lockScreen` | Lock Screen banner | expanded notification (fallback) |
| `body` | Dynamic Island expanded | expanded notification |
| `compactLeading` | Dynamic Island compact leading | collapsed notification |
| `compactTrailing` | Dynamic Island compact trailing | ignored |
| `minimal` | Dynamic Island minimal | ignored |

```jsx
import {
  registerComponent,
  startLiveActivity,
  updateLiveActivity,
  endLiveActivity,
} from 'react-native-island';

registerComponent('body', 'ScoreCard');

const id = await startLiveActivity({ body: 'body', compactLeading: 'compactLeading' });
await updateLiveActivity(id, { body: 'body' });
await endLiveActivity();
```

> The previous `startIslandActivity` / `updateIslandActivity` / `endIslandActivity` /
> `getIslandList` functions remain as deprecated aliases.

### `<IslandWrapper>`

Wrap any component you want to use in an activity. It registers the underlying native view so the library can snapshot it.

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `componentId` | string | yes | Id of the registered component |

```jsx
import { Text, View, StyleSheet } from 'react-native';
import { IslandWrapper } from 'react-native-island';

const LiveActivityBody = () => (
  <IslandWrapper componentId="body">
    <View style={styles.container}>
      <Text style={styles.text}>Island Data</Text>
    </View>
  </IslandWrapper>
);

const styles = StyleSheet.create({
  container: { backgroundColor: 'green', width: '100%', flexDirection: 'row' },
  text: { color: 'white', fontSize: 14, fontWeight: 'bold' },
});

export default LiveActivityBody;
```

See the [`example`](./example) app for a full working setup.

## Limitations

- **Snapshots, not live views.** The UI shown in a Live Activity/notification is an image. Interactive buttons require native SwiftUI App Intents (a future tier), not RN touch handlers.
- **Fidelity.** Custom fonts, vector icons, scale, and dark mode need care to reproduce faithfully in a snapshot.
- **Dynamic Island sizing.** The compact/minimal regions are small and size-constrained; design accordingly.
- **Background updates need Tier 2 push.** Local updates only happen while your app (or an Android foreground service) is running.

## Roadmap

Done:
- ✅ New Architecture / bridgeless support
- ✅ Unified, fully-typed slot-based JS API
- ✅ Android ongoing notifications at local parity with iOS

Planned:
- Automated iOS setup (Expo config plugin + CLI)
- Android 16 "Live Update" / `ProgressStyle` promoted notifications
- iOS codegen TurboModule migration; per-region snapshot sizing & dark mode
- Optional Tier 2 push (APNs / FCM)

## Contributing

See the [contributing guide](CONTRIBUTING.md).

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
