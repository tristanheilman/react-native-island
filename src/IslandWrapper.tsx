import React, { useRef, useEffect, useState } from 'react';
import { View, findNodeHandle, StyleSheet } from 'react-native';
import { NativeModules } from 'react-native';

const { RNIsland } = NativeModules;

interface IslandWrapperProps {
  componentId: string;
  children: React.ReactNode;
}

const IslandWrapper = ({ componentId, children }: IslandWrapperProps) => {
  const viewRef = useRef<View>(null);
  const hasStoredRef = useRef(false);
  const [nodeHandle, setNodeHandle] = useState<number | null>(null);

  useEffect(() => {
    if (viewRef.current && !hasStoredRef.current) {
      const timer = setTimeout(() => {
        const handle = findNodeHandle(viewRef.current);
        if (handle) {
          setNodeHandle(handle);
          // Set the native tag property on the view
          // @ts-ignore
          RNIsland.storeViewReference(componentId, handle)
            .then(() => {
              hasStoredRef.current = true;
            })
            .catch((error: any) => {
              hasStoredRef.current = false;
              console.log(
                `❌ Failed to store view reference for ${componentId}:`,
                error
              );
            });
        }
      }, 100);

      return () => clearTimeout(timer);
    }

    return () => {
      console.log(`Component ${componentId} unmounted`);
      RNIsland.clearViewReference(componentId);
    };
  }, [componentId]);

  return (
    <View
      ref={viewRef}
      collapsable={false}
      testID={nodeHandle ? nodeHandle.toString() : undefined}
      pointerEvents="box-none" // Allow touches to pass through
      style={styles.container}
    >
      {children}
    </View>
  );
};

export default IslandWrapper;

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    backgroundColor: 'transparent',
  },
});
