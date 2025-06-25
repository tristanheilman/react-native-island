import React, { useRef, useEffect, useState } from 'react';
import { View, findNodeHandle } from 'react-native';
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
    };
  }, [componentId]);

  return (
    <View
      ref={viewRef}
      collapsable={false}
      testID={nodeHandle ? nodeHandle.toString() : undefined}
      pointerEvents="box-none" // Allow touches to pass through
      style={{
        // Make the wrapper completely transparent to layout
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'transparent',
      }}
    >
      {children}
    </View>
  );
};

export default IslandWrapper;
