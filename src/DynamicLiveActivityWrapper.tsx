import React from 'react';
import { View, Text } from 'react-native';
import ComponentRegistry from './ComponentRegistry';

interface DynamicLiveActivityWrapperProps {
  componentId: string;
  props: any;
}

const DynamicLiveActivityWrapper: React.FC<DynamicLiveActivityWrapperProps> = ({
  componentId,
  props,
}) => {
  const Component = ComponentRegistry.get(componentId);

  if (!Component) {
    return (
      <View>
        <Text>Component not found: {componentId}</Text>
      </View>
    );
  }

  return <Component {...props} />;
};

export default DynamicLiveActivityWrapper;
