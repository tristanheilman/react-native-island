import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

// Define specific types for the data structures
export interface ActivityData {
  headerComponentId?: string;
  headerProps?: string | null;
  bodyComponentId?: string;
  bodyProps?: string | null;
  footerComponentId?: string;
  footerProps?: string | null;
  id?: string;
}

export interface Spec extends TurboModule {
  registerComponent(id: string, componentName: string): Promise<void>;
  getIslandList(): Promise<string[]>;
  startIslandActivity(data: ActivityData): void;
  updateIslandActivity(data: ActivityData): void;
  endIslandActivity(): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNIsland');
