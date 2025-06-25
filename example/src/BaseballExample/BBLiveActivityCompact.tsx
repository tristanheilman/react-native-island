import { useEffect, useState } from 'react';
import { Text, View, StyleSheet } from 'react-native';
import { IslandWrapper } from 'react-native-island';

interface BBLiveActivityCompactProps {
  id: string;
}

const BBLiveActivityCompact = ({ id }: BBLiveActivityCompactProps) => {
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
    <IslandWrapper componentId={id}>
      <View style={styles.container}>
        <Text style={styles.headerText}>KC</Text>
        <Text style={styles.scoreText}>{count}</Text>
      </View>
    </IslandWrapper>
  );
};

export default BBLiveActivityCompact;

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'blue',
    flexDirection: 'row',
    gap: 5,
  },
  headerText: {
    color: 'red',
    fontSize: 12,
    fontWeight: 'bold',
  },
  scoreText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
});
