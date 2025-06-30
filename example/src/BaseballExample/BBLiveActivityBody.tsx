import { useEffect, useState } from 'react';
import { Text, View, StyleSheet } from 'react-native';
import { IslandWrapper } from 'react-native-island';
import Icon from 'react-native-vector-icons/FontAwesome';

const BBLiveActivityBody = () => {
  const [activeBases, setActiveBases] = useState<number[]>([]);
  const [score, setScore] = useState({
    home: 0,
    away: 0,
  });

  useEffect(() => {
    const interval = setInterval(() => {
      // randomly create an array of length 3 with values 0 or 1
      const newActiveBases = Array.from({ length: 3 }, () =>
        Math.random() < 0.5 ? 0 : 1
      );

      setActiveBases(newActiveBases);
      setScore({
        home: Math.floor(Math.random() * 10),
        away: Math.floor(Math.random() * 10),
      });
    }, 9000);

    return () => clearInterval(interval);
  }, []);

  return (
    <IslandWrapper componentId="body">
      <View style={styles.container}>
        <View style={styles.teamContainer}>
          <View style={styles.headerContainer}>
            <Text style={styles.headerText}>KC</Text>
            <Text style={styles.scoreText}>{score.home}</Text>
          </View>
          <Text style={styles.text}>LeMoine</Text>
          <Text style={styles.text}>3.07 ERA</Text>
        </View>
        <View style={styles.inningContainer}>
          <View style={styles.inningGraphicContainerRow}>
            <View
              style={[
                styles.inningGraphicContainer,
                { marginTop: 30, marginRight: -15 },
              ]}
            >
              <Icon
                name={activeBases[0] === 1 ? 'square' : 'square-o'}
                size={30}
                color="#000"
              />
            </View>
            <View
              style={[
                styles.inningGraphicContainer,
                { marginTop: 5, marginRight: 0 },
              ]}
            >
              <Icon
                name={activeBases[1] === 1 ? 'square' : 'square-o'}
                size={30}
                color="#000"
              />
            </View>
            <View style={[styles.inningGraphicContainer, { marginTop: 30 }]}>
              <Icon
                name={activeBases[2] === 1 ? 'square' : 'square-o'}
                size={30}
                color="#000"
              />
            </View>
          </View>
          <Text style={styles.inningText}>Bot 9th 3-2, 2 out</Text>
        </View>
        <View style={styles.rightTeamContainer}>
          <View style={styles.headerContainer}>
            <Text style={styles.headerText}>SF</Text>
            <Text style={styles.scoreText}>{score.away}</Text>
          </View>
          <Text style={styles.text}>Stern</Text>
          <Text style={styles.text}>.312 AVG</Text>
        </View>
      </View>
    </IslandWrapper>
  );
};

export default BBLiveActivityBody;

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'green',
    width: '100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    //alignItems: 'center',
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 10,
  },
  teamContainer: {
    flexDirection: 'column',
  },
  rightTeamContainer: {
    flexDirection: 'column',
    alignItems: 'flex-end',
  },
  headerText: {
    color: 'white',
    fontSize: 36,
    fontWeight: 'bold',
  },
  scoreText: {
    color: 'white',
    fontSize: 36,
    fontWeight: 'bold',
  },
  inningContainer: {
    backgroundColor: 'red',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  inningGraphicContainerRow: {
    flexDirection: 'row',
    gap: 5,
  },
  inningGraphicContainer: {
    //position: 'relative',
    //marginTop: 5,
    transform: [{ rotate: '45deg' }],
  },
  inningText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  text: {
    color: 'white',
    fontSize: 14,
    fontWeight: 'bold',
  },
});
