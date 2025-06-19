import { useEffect, useState } from 'react';
import { Text, View, StyleSheet } from 'react-native';
import { ComponentViewWrapper } from 'react-native-island';

interface LiveActivityCompactProps {
  id: string;
}

const LiveActivityCompact = ({ id }: LiveActivityCompactProps) => {
  // parse the props as json
  //const parsedProps = JSON.parse(props);
  const [count, setCount] = useState(0);

  useEffect(() => {
    let curr = 0;
    const interval = setInterval(() => {
      setCount(curr);
      curr++;
      //   updateIslandActivity({
      //     bodyComponentId: 'body',
      //   });
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <ComponentViewWrapper componentId={id}>
      <View style={styles.container}>
        <Text style={styles.text}>{count}</Text>
      </View>
    </ComponentViewWrapper>
  );
};

export default LiveActivityCompact;

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'blue',
    padding: 10,
  },
  text: {
    color: 'white',
    fontSize: 14,
    fontWeight: 'bold',
  },
});
