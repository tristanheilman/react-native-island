# Android setup

On Android, a live activity is rendered as an **ongoing, updatable
notification**. Each slot component you register is snapshotted from its
on-screen React Native view into a bitmap and shown in the notification's
collapsed and expanded content views.

There is no separate extension to configure (unlike iOS) — but you must handle
the notification runtime permission.

## 1. Notification permission (Android 13 / API 33+)

The library declares `POST_NOTIFICATIONS` in its manifest, but on Android 13+
the **host app must request it at runtime**. Request it before starting an
activity, e.g. with `PermissionsAndroid`:

```ts
import { PermissionsAndroid, Platform } from 'react-native';

async function ensureNotificationPermission() {
  if (Platform.OS === 'android' && Platform.Version >= 33) {
    await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.POST_NOTIFICATIONS
    );
  }
}
```

If the permission is not granted, the notification is created but not shown.

## 2. Register and wrap your components

Exactly like iOS — register the component and wrap it in `<IslandWrapper>` so
the library can snapshot it:

```tsx
import { registerComponent, IslandWrapper } from 'react-native-island';

registerComponent('body', 'ScoreCard');

const ScoreCard = () => (
  <IslandWrapper componentId="body">
    {/* your RN UI */}
  </IslandWrapper>
);
```

The wrapped component must be **mounted on screen** when you start or update the
activity, so its view can be snapshotted.

## 3. Start / update / end

```ts
const id = await startLiveActivity({ body: 'body', compactLeading: 'body' });
await updateLiveActivity(id, { body: 'body' });
await endLiveActivity();
```

## Slot mapping on Android

| Slot | Android surface |
|------|-----------------|
| `body` | expanded notification content |
| `lockScreen` | expanded notification (fallback if `body` is absent) |
| `compactLeading` | collapsed notification content (fallback: `body`) |
| `compactTrailing`, `minimal` | ignored |

## Keeping updates alive in the background

Local updates work while your app process is running. To keep updating after the
app is backgrounded/killed without a server, run a **foreground service** (the
ongoing notification can be its service notification). For fully push-driven
background updates, deliver an FCM data message and call `updateLiveActivity`
from its handler. Both are optional — foreground/local updates need neither.

## Notes & limitations

- The notification shows a **snapshot image**, not a live view. Taps/buttons in
  the RN UI are not interactive inside the notification.
- Android 16's "Live Update" / `ProgressStyle` promoted notifications are on the
  roadmap; below Android 16 this renders as a standard ongoing notification.
