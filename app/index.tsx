import { Redirect } from 'expo-router';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { useAuthStore } from '@/stores/authStore';
import { Colors } from '@/constants/theme';

export default function Index() {
  const { session, isInitialized } = useAuthStore();

  if (!isInitialized) {
    return (
      <View style={styles.loader}>
        <ActivityIndicator size="large" color={Colors.primary} />
      </View>
    );
  }

  if (session) {
    return <Redirect href="/(app)/dashboard" />;
  }

  return <Redirect href="/(auth)/login" />;
}

const styles = StyleSheet.create({
  loader: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: Colors.background },
});
