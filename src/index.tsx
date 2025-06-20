import Island, { type ActivityData } from './NativeIsland';
import ComponentRegistry from './ComponentRegistry';
import IslandWrapper from './IslandWrapper';

export function registerComponent(
  id: string,
  componentName: string
  //component: React.ComponentType<any>
): void {
  //ComponentRegistry.register(id, component);
  Island.registerComponent(id, componentName);
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

export function getComponent(id: string): React.ComponentType<any> | undefined {
  return ComponentRegistry.get(id);
}

export function getAllComponents(): Map<string, React.ComponentType<any>> {
  return ComponentRegistry.getAll();
}

// Export Components
export { IslandWrapper };

// Types
export type { ActivityData };
