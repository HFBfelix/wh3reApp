import { Stack } from 'expo-router';

export default function AppLayout() {
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="dashboard" />
      <Stack.Screen name="event/create" />
      <Stack.Screen name="event/[id]" />
      <Stack.Screen name="event/edit/[id]" />
      <Stack.Screen name="event/invite/[id]" />
      <Stack.Screen name="polling/answer/[id]" />
      <Stack.Screen name="polling/results/[id]" />
      <Stack.Screen name="suggestions/[id]" />
    </Stack>
  );
}
