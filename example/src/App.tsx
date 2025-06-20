import { useEffect, useState } from 'react';
import {
  Text,
  View,
  StyleSheet,
  Pressable,
  ActivityIndicator,
} from 'react-native';
import {
  registerComponent,
  startIslandActivity,
  endIslandActivity,
  updateIslandActivity,
  getIslandList,
} from 'react-native-island';
import BBLiveActivityBody from './BaseballExample/BBLiveActivityBody';
import BBLiveActivityLockScreen from './BaseballExample/BBLiveActivityLockScreen';
import BBLiveActivityCompact from './BaseballExample/BBLiveActivityCompact';

export default function App() {
  // const [isActivityActive, setIsActivityActive] = useState(false);
  // const [activityId, setActivityId] = useState('');
  const [activityList, setActivityList] = useState<string[]>([]);
  const [startingActivity, setStartingActivity] = useState(false);
  const [updatingActivity, setUpdatingActivity] = useState(false);
  const [endingActivity, setEndingActivity] = useState(false);
  const [gettingActivities, setGettingActivities] = useState(false);

  useEffect(() => {
    registerComponent('lockScreen', 'BBLiveActivityLockScreen');
    registerComponent('body', 'BBLiveActivityBody');
    registerComponent('compactLeading', 'BBLiveActivityCompact');
    registerComponent('compactTrailing', 'BBLiveActivityCompact');
    registerComponent('minimal', 'BBLiveActivityCompact');
  }, []);

  useEffect(() => {
    const interval = setInterval(async () => {
      const list = await getIslandList();

      if (list.length > 0) {
        const activityId = list[0];
        await updateIslandActivity({
          id: activityId,
          compactLeadingComponentId: 'compactLeading',
          compactTrailingComponentId: 'compactTrailing',
          minimalComponentId: 'minimal',
          bodyComponentId: 'body',
          lockScreenComponentId: 'lockScreen',
        });
      } else {
        console.log('no activity');
      }
    }, 10000);

    return () => clearInterval(interval);
  }, []);

  const startActivity = async () => {
    setStartingActivity(true);
    const activityId = await startIslandActivity({
      lockScreenComponentId: 'lockScreen',
      bodyComponentId: 'body',
    });

    console.log('New Island Activity ID: ', activityId);

    const list = await getIslandList();
    setActivityList(list);
    setStartingActivity(false);
  };

  const updateActivity = async () => {
    setUpdatingActivity(true);
    const list = await getIslandList();
    setActivityList(list);

    const activityId = activityList[0];
    const updatedId = await updateIslandActivity({
      id: activityId,
      lockScreenComponentId: 'lockScreen',
      bodyComponentId: 'body',
      compactLeadingComponentId: 'compactLeading',
      compactTrailingComponentId: 'compactTrailing',
      minimalComponentId: 'minimal',
    });

    console.log('Updated Island Activity ID: ', updatedId);
    setUpdatingActivity(false);
  };

  const endActivity = async () => {
    setEndingActivity(true);
    await endIslandActivity();
    const list = await getIslandList();
    setActivityList(list);
    setEndingActivity(false);
  };

  const getActivities = async () => {
    setGettingActivities(true);
    const list = await getIslandList();
    setActivityList(list);
    setGettingActivities(false);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.headerText}>react-native-island Example</Text>
      <Pressable style={styles.button} onPress={startActivity}>
        {startingActivity && <ActivityIndicator size="small" color="white" />}
        <Text style={styles.buttonText}>
          {startingActivity ? 'Starting...' : 'Start Activity'}
        </Text>
      </Pressable>

      <Pressable style={styles.button} onPress={updateActivity}>
        {updatingActivity && <ActivityIndicator size="small" color="white" />}
        <Text style={styles.buttonText}>
          {updatingActivity ? 'Updating...' : 'Update Activity'}
        </Text>
      </Pressable>

      <Pressable style={styles.button} onPress={endActivity}>
        {endingActivity && <ActivityIndicator size="small" color="white" />}
        <Text style={styles.buttonText}>
          {endingActivity ? 'Ending...' : 'End Activity'}
        </Text>
      </Pressable>

      <Pressable style={styles.button} onPress={getActivities}>
        {gettingActivities && <ActivityIndicator size="small" color="white" />}
        <Text style={styles.buttonText}>
          {gettingActivities ? 'Getting...' : 'Get Activities'}
        </Text>
      </Pressable>

      <View style={styles.spacer} />
      <BBLiveActivityLockScreen />
      <BBLiveActivityBody />
      <BBLiveActivityCompact id="compactLeading" />
      <BBLiveActivityCompact id="compactTrailing" />
      <BBLiveActivityCompact id="minimal" />

      <View style={styles.spacer} />

      <Text style={styles.subHeaderText}>Activity List</Text>
      {activityList.map((activity) => (
        <Text key={activity}>{activity}</Text>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'flex-start',
    backgroundColor: '#fff',
    paddingTop: 100,
    gap: 10,
  },
  headerText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#CD8987',
    marginBottom: 20,
  },
  button: {
    paddingHorizontal: 20,
    paddingVertical: 12,
    backgroundColor: '#CD8987',
    borderRadius: 5,
    flexDirection: 'row',
    gap: 10,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  subHeaderText: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  spacer: {
    height: 2,
    width: '100%',
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    marginVertical: 20,
  },
});
