import { Text, View, StyleSheet } from 'react-native';
import { ComponentViewWrapper } from 'react-native-island';

interface LiveActivityBodyProps {
  title: string;
}

const LiveActivityBody = ({ title }: LiveActivityBodyProps) => {
  // parse the props as json
  //const parsedProps = JSON.parse(props);

  return (
    <ComponentViewWrapper componentId="body">
      <View style={styles.container}>
        <Text style={styles.text}>{title}</Text>
      </View>
    </ComponentViewWrapper>
  );
};

export default LiveActivityBody;

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'blue',
    padding: 10,
  },
  text: {
    color: 'white',
    fontSize: 20,
    fontWeight: 'bold',
  },
});
