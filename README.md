# react-native-island

> ⚠️ **WARNING: This library is currently in active development and is NOT ready for production use.**
> 
> - The implementation is incomplete and may contain bugs
> - API changes are likely to occur
> - Some features may not work as expected
> - Testing has been limited to specific devices and scenarios
> 
> Use at your own risk and expect breaking changes in future releases.


AR object capture session for React Native using Apple's Object Capture API. This library provides a React Native wrapper for capturing 3D objects using the device's camera. **This library does not currently work for Android.**

## Requirements

- iOS 16.1 or later
- Android 11 (API level >= 30)
- React Native 0.76.0 or later

## Installation
1. Install library

    from npm
    ```
    npm install react-native-object-capture
    ```

    from yarn
    ```
    yarn add react-native-object-capture
    ```

2. Link native code
    ```
    cd ios && pod install
    ```

### iOS Additional Setup

1. Add the following keys to your `Info.plist`:
    ```xml
    <key>NSSupportsLiveActivities</key>
    <true/>
    ```
2. Follow the setup instructions for the [`DynamicWidgetExtension`](./docs/DYNAMIC_WIDGET_SETUP.md)



## Methods


| Method | Params | Description |
|--------|--------|-------------|
| `registerComponent` | {id: string, componentName: string} | Registers the components in the root tree with so they can be found later to be used in an island activity |
| `getIslandList` | None | Returns the list of activity IDs currently active |
| `startIslandActivity` | ActivityData | Prerenders react native components to images and starts an island activity with the provided componentIds |
| `updateIslandActivity` | ActivityData | Updates the island activity with refreshed components |
| `endIslandActivity` | None | Ends all island activities current active |
| `storeViewReference` | {componentId: string, nodeHandle: number} | Stores a view reference with link to node |

## Components

### IslandWraper

Utilize this component to wrap any components that will be utilize in an island activity. The component will register the children node components for use in the island activity.

#### Props

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `componentId` | String | Yes | The ID of the registered component |

#### Example

```jsx
import { Text, View, StyleSheet } from 'react-native';
import { IslandWrapper } from 'react-native-island';

const LiveActivityComponent = () => {
  return (
    <IslandWrapper componentId="body">
      <View style={styles.container}>
          <Text style={styles.text}>Island Data</Text>
      </View>
    </IslandWrapper>
  );
};

export default LiveActivityComponent;

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'green',
    width: '100%',
    flexDirection: 'row',
  },
  text: {
    color: 'white',
    fontSize: 14,
    fontWeight: 'bold',
  },
});
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)