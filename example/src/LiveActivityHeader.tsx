import { useEffect, useState } from 'react';
import { Text, View, StyleSheet } from 'react-native';
import { ComponentViewWrapper } from 'react-native-island';

interface LiveActivityHeaderProps {
  title: string;
}

const LiveActivityHeader = ({ title }: LiveActivityHeaderProps) => {
  // parse the props as json
  //const parsedProps = JSON.parse(props);
  const [count, setCount] = useState(0);

  useEffect(() => {
    let curr = 0;
    const interval = setInterval(() => {
      setCount(curr);
      curr++;
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <ComponentViewWrapper componentId="header">
      <View style={styles.container}>
        <Text style={styles.text}>
          {title}: {count}
        </Text>
      </View>
    </ComponentViewWrapper>
  );
};

export default LiveActivityHeader;

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
