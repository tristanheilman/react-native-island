import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

// Flat, serializable shape passed across the bridge. Both the iOS and Android
// native modules read exactly these keys. Prefer the typed slot-based API in
// index.tsx over building this by hand.
export interface ActivityData {
  id?: string;
  lockScreenComponentId?: string;
  bodyComponentId?: string;
  compactLeadingComponentId?: string;
  compactTrailingComponentId?: string;
  minimalComponentId?: string;
}

export interface Spec extends TurboModule {
  setAppGroup(appGroup: string): Promise<void>;
  registerComponent(id: string, componentName: string): Promise<void>;
  getIslandList(): Promise<string[]>;
  startIslandActivity(data: ActivityData): Promise<string>;
  updateIslandActivity(data: ActivityData): Promise<string>;
  endIslandActivity(): Promise<void>;
  storeViewReference(componentId: string, nodeHandle: number): Promise<void>;
  clearViewReference(componentId: string): Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNIsland');
