import React, { useRef, useEffect } from 'react';
import { View } from 'react-native';
import { findNodeHandle } from 'react-native';
import { NativeModules } from 'react-native';

const { RNIsland } = NativeModules;

interface IslandWrapperProps {
  componentId: string;
  children: React.ReactNode;
}

const IslandWrapper: React.FC<IslandWrapperProps> = ({
  componentId,
  children,
}) => {
  const viewRef = useRef<View>(null);
  const hasStoredRef = useRef(false);

  useEffect(() => {
    if (viewRef.current && !hasStoredRef.current) {
      // Add a delay to ensure the view is fully created in the native layer
      const timer = setTimeout(() => {
        const nodeHandle = findNodeHandle(viewRef.current);
        if (nodeHandle) {
          RNIsland.storeViewReference(componentId, nodeHandle)
            .then(() => {
              hasStoredRef.current = true;
            })
            .catch((error: any) => {
              hasStoredRef.current = false;
              // Don't set hasStoredRef to true on error, so we can retry
              console.log(
                `❌ Failed to store view reference for ${componentId}:`,
                error
              );
            });
        }
      }, 100); // 100ms delay

      return () => clearTimeout(timer);
    }

    return () => {
      console.log(`Component ${componentId} unmounted`);
    };
  }, [componentId]);

  return (
    <View ref={viewRef} collapsable={false}>
      {children}
    </View>
  );
};

export default IslandWrapper;
