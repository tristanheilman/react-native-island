import { Text } from 'react-native';

const LiveActivityBody = (props: any) => {
  // parse the props as json
  const parsedProps = JSON.parse(props);

  return <Text>{parsedProps.title}</Text>;
};

export default LiveActivityBody;
