import Island, { type ActivityData } from './NativeIsland';
import ComponentRegistry from './ComponentRegistry';
import DynamicLiveActivityWrapper from './DynamicLiveActivityWrapper';

export function registerComponent(
  id: string,
  componentName: string,
  component: React.ComponentType<any>
): void {
  ComponentRegistry.register(id, component);
  Island.registerComponent(id, componentName);
}

export function getIslandList(): Promise<string[]> {
  return Island.getIslandList();
}

export function startIslandActivity(data: any): void {
  Island.startIslandActivity(data);
}

export function updateIslandActivity(data: any): void {
  Island.updateIslandActivity(data);
}

export function endIslandActivity(): void {
  Island.endIslandActivity();
}

export function getComponent(id: string): React.ComponentType<any> | undefined {
  return ComponentRegistry.get(id);
}

export function getAllComponents(): Map<string, React.ComponentType<any>> {
  return ComponentRegistry.getAll();
}

// Export Components
export { DynamicLiveActivityWrapper };

// Types
export type { ActivityData };
