import Island, { type ActivityData } from './NativeIsland';
import IslandWrapper from './IslandWrapper';

export function registerComponent(id: string, componentName: string): void {
  Island.registerComponent(id, componentName);
}

export function setAppGroup(appGroup: string): Promise<void> {
  return Island.setAppGroup(appGroup);
}

export function getIslandList(): Promise<string[]> {
  return Island.getIslandList();
}

export function startIslandActivity(data: any): Promise<void> {
  return Island.startIslandActivity(data);
}

export function updateIslandActivity(data: any): Promise<void> {
  return Island.updateIslandActivity(data);
}

export function endIslandActivity(): Promise<void> {
  return Island.endIslandActivity();
}

export function storeViewReference(
  componentId: string,
  nodeHandle: number
): Promise<void> {
  return Island.storeViewReference(componentId, nodeHandle);
}

// Export Components
export { IslandWrapper };

// Types
export type { ActivityData };
