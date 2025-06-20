import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

// Define specific types for the data structures
export interface ActivityData {
  headerComponentId?: string;
  bodyComponentId?: string;
  footerComponentId?: string;
  compactComponentId?: string;
  minimalComponentId?: string;
  id?: string;
}

export interface Spec extends TurboModule {
  registerComponent(id: string, componentName: string): Promise<void>;
  getIslandList(): Promise<string[]>;
  startIslandActivity(data: ActivityData): Promise<void>;
  updateIslandActivity(data: ActivityData): Promise<void>;
  endIslandActivity(): Promise<void>;
  storeViewReference(componentId: string, nodeHandle: number): Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNIsland');
