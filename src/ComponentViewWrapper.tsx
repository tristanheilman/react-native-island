import React, { useRef, useEffect } from 'react';
import { View } from 'react-native';
import { findNodeHandle } from 'react-native';
import { NativeModules } from 'react-native';

const { RNIsland } = NativeModules;

interface ComponentViewWrapperProps {
  componentId: string;
  children: React.ReactNode;
}

const ComponentViewWrapper: React.FC<ComponentViewWrapperProps> = ({
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
          console.log(
            `Component ${componentId} rendered with node handle: ${nodeHandle}`
          );
          RNIsland.storeViewReference(componentId, nodeHandle)
            .then(() => {
              console.log(
                `View reference stored for component: ${componentId}`
              );
              hasStoredRef.current = true;
            })
            .catch((error: any) => {
              console.error(
                `Failed to store view reference for ${componentId}:`,
                error
              );
              // Don't set hasStoredRef to true on error, so we can retry
            });
        }
      }, 100); // 100ms delay

      return () => clearTimeout(timer);
    }
  }, [componentId]);

  return (
    <View ref={viewRef} collapsable={false}>
      {children}
    </View>
  );
};

export default ComponentViewWrapper;
