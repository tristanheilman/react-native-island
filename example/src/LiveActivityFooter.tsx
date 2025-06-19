import { Text, View, StyleSheet } from 'react-native';
import { ComponentViewWrapper } from 'react-native-island';

interface LiveActivityFooterProps {
  title: string;
}

const LiveActivityFooter = ({ title }: LiveActivityFooterProps) => {
  // parse the props as json
  //const parsedProps = JSON.parse(props);

  return (
    <ComponentViewWrapper componentId="footer">
      <View style={styles.container}>
        <Text style={styles.text}>{title}</Text>
      </View>
    </ComponentViewWrapper>
  );
};

export default LiveActivityFooter;

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
