import { useEffect, useState } from 'react';
import { Text, View, StyleSheet, Pressable } from 'react-native';
import {
  registerComponent,
  startIslandActivity,
  endIslandActivity,
  updateIslandActivity,
  getIslandList,
} from 'react-native-island';
import LiveActivityHeader from './LiveActivityHeader';
import LiveActivityBody from './LiveActivityBody';
import LiveActivityFooter from './LiveActivityFooter';

export default function App() {
  // const [isActivityActive, setIsActivityActive] = useState(false);
  // const [activityId, setActivityId] = useState('');
  const [activityList, setActivityList] = useState<string[]>([]);

  useEffect(() => {
    registerComponent('header', 'Header', LiveActivityHeader);
    registerComponent('body', 'Body', LiveActivityBody);
    registerComponent('footer', 'Footer', LiveActivityFooter);
  }, []);

  const startActivity = async () => {
    await startIslandActivity({
      headerComponentId: 'header',
      headerProps: `{ title: 'Hello World' }`,
      bodyComponentId: 'body',
      bodyProps: `{ title: 'Hello World Body' }`,
      footerComponentId: 'footer',
      footerProps: `{ title: 'Hello World Footer' }`,
    });

    const list = await getIslandList();
    setActivityList(list);
  };

  const updateActivity = async () => {
    await updateIslandActivity({
      headerComponentId: 'header',
      headerProps: `{ title: 'Hello World Updated' }`,
      bodyComponentId: 'body',
      bodyProps: `{ title: 'Hello World Body Updated' }`,
    });
  };

  const endActivity = async () => {
    await endIslandActivity();

    const list = await getIslandList();
    setActivityList(list);
  };

  const getActivities = async () => {
    const list = await getIslandList();
    setActivityList(list);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.headerText}>react-native-island Example</Text>
      <Pressable style={styles.button} onPress={startActivity}>
        <Text style={styles.buttonText}>Start Activity</Text>
      </Pressable>

      <Pressable style={styles.button} onPress={updateActivity}>
        <Text style={styles.buttonText}>Update Activity</Text>
      </Pressable>

      <Pressable style={styles.button} onPress={endActivity}>
        <Text style={styles.buttonText}>End Activity</Text>
      </Pressable>

      <Pressable style={styles.button} onPress={getActivities}>
        <Text style={styles.buttonText}>Get Activities</Text>
      </Pressable>

      <LiveActivityHeader title="Hello World Header" />
      <LiveActivityBody title="Hello World Body" />
      <LiveActivityFooter title="Hello World Footer" />

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
