import Island, { type ActivityData } from './NativeIsland';
import IslandWrapper from './IslandWrapper';

/**
 * The UI regions a live activity can render. Each value is the `componentId` of
 * a component you registered with {@link registerComponent} and wrapped in
 * {@link IslandWrapper}.
 *
 * Platform mapping:
 * - **iOS** — `lockScreen` → Lock Screen banner; `body` → Dynamic Island
 *   expanded; `compactLeading`/`compactTrailing` → Dynamic Island compact;
 *   `minimal` → Dynamic Island minimal.
 * - **Android** — `body` (falling back to `lockScreen`) → expanded notification;
 *   `compactLeading` (falling back to `body`) → collapsed notification.
 *   `compactTrailing` and `minimal` are ignored.
 */
export interface IslandSlots {
  lockScreen?: string;
  body?: string;
  compactLeading?: string;
  compactTrailing?: string;
  minimal?: string;
}

function slotsToActivityData(slots: IslandSlots, id?: string): ActivityData {
  const data: ActivityData = {};
  if (id) data.id = id;
  if (slots.lockScreen) data.lockScreenComponentId = slots.lockScreen;
  if (slots.body) data.bodyComponentId = slots.body;
  if (slots.compactLeading)
    data.compactLeadingComponentId = slots.compactLeading;
  if (slots.compactTrailing) {
    data.compactTrailingComponentId = slots.compactTrailing;
  }
  if (slots.minimal) data.minimalComponentId = slots.minimal;
  return data;
}

/**
 * Register a component by id so it can be snapshotted into a live activity.
 * The id must match the `componentId` you pass to {@link IslandWrapper} and to
 * the slots of {@link startLiveActivity}.
 */
export function registerComponent(id: string, componentName: string): void {
  Island.registerComponent(id, componentName);
}

/**
 * iOS only. The App Group shared between your app and the widget extension,
 * used to hand rendered snapshots to the Live Activity. No-op on Android.
 */
export function setAppGroup(appGroup: string): Promise<void> {
  return Island.setAppGroup(appGroup);
}

/** Start a live activity from the given slots. Resolves with the activity id. */
export function startLiveActivity(slots: IslandSlots): Promise<string> {
  return Island.startIslandActivity(slotsToActivityData(slots));
}

/**
 * Update a running live activity, re-snapshotting the given slots. Resolves with
 * the activity id.
 */
export function updateLiveActivity(
  id: string,
  slots: IslandSlots
): Promise<string> {
  return Island.updateIslandActivity(slotsToActivityData(slots, id));
}

/** End all running live activities. */
export function endLiveActivity(): Promise<void> {
  return Island.endIslandActivity();
}

/** The ids of the currently running live activities. */
export function getLiveActivities(): Promise<string[]> {
  return Island.getIslandList();
}

// --- Deprecated aliases (kept for backward compatibility) -------------------

/** @deprecated Use {@link startLiveActivity} with typed slots. */
export function startIslandActivity(data: ActivityData): Promise<string> {
  return Island.startIslandActivity(data);
}

/** @deprecated Use {@link updateLiveActivity}(id, slots). */
export function updateIslandActivity(data: ActivityData): Promise<string> {
  return Island.updateIslandActivity(data);
}

/** @deprecated Use {@link endLiveActivity}. */
export function endIslandActivity(): Promise<void> {
  return Island.endIslandActivity();
}

/** @deprecated Use {@link getLiveActivities}. */
export function getIslandList(): Promise<string[]> {
  return Island.getIslandList();
}

// --- Internal (used by IslandWrapper; exported for advanced use) ------------

export function storeViewReference(
  componentId: string,
  nodeHandle: number
): Promise<void> {
  return Island.storeViewReference(componentId, nodeHandle);
}

export function clearViewReference(componentId: string): Promise<void> {
  return Island.clearViewReference(componentId);
}

// Components
export { IslandWrapper };

// Types
export type { ActivityData };
