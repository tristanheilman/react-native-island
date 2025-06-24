import { AppRegistry } from 'react-native';
import App from './src/App';
import { DynamicLiveActivityWrapper } from 'react-native-island';
import { name as appName } from './app.json';
import BaseballExampleBody from './src/BaseballExample/BBLiveActivityBody';

AppRegistry.registerComponent(appName, () => App);
AppRegistry.registerComponent(
  'DynamicLiveActivity',
  () => DynamicLiveActivityWrapper
);
AppRegistry.registerComponent('BubbleContent', () => BaseballExampleBody);
