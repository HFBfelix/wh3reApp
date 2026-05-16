import type { ReactNode } from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Colors } from '@/constants/theme';

interface ScreenHeaderProps {
  title: string;
  showBack?: boolean;
  rightAction?: ReactNode;
}

export function ScreenHeader({ title, showBack = true, rightAction }: ScreenHeaderProps) {
  const router = useRouter();

  return (
    <SafeAreaView edges={['top']} style={styles.safe}>
      <View style={styles.row}>
        {showBack ? (
          <Pressable onPress={() => router.back()} style={styles.backBtn} hitSlop={12}>
            <Text style={styles.backText}>←</Text>
          </Pressable>
        ) : (
          <View style={styles.backPlaceholder} />
        )}
        <Text style={styles.title} numberOfLines={1}>
          {title}
        </Text>
        <View style={styles.right}>{rightAction ?? <View style={styles.backPlaceholder} />}</View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { backgroundColor: Colors.background },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingBottom: 8,
    minHeight: 48,
  },
  backBtn: { width: 44, height: 44, alignItems: 'center', justifyContent: 'center' },
  backPlaceholder: { width: 44 },
  backText: { fontSize: 24, color: Colors.primary, fontWeight: '600' },
  title: {
    flex: 1,
    textAlign: 'center',
    fontSize: 18,
    fontWeight: '700',
    color: Colors.textPrimary,
  },
  right: { width: 44, alignItems: 'flex-end' },
});
