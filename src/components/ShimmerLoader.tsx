import { View, StyleSheet } from 'react-native';
import ShimmerPlaceholder from 'react-native-shimmer-placeholder';
import LinearGradient from 'react-native-linear-gradient';
import { Colors, Radius } from '@/constants/theme';

interface ShimmerLoaderProps {
  count?: number;
}

export function ShimmerLoader({ count = 3 }: ShimmerLoaderProps) {
  return (
    <View style={styles.container}>
      {Array.from({ length: count }).map((_, i) => (
        <ShimmerPlaceholder
          key={i}
          LinearGradient={LinearGradient}
          style={styles.item}
          shimmerColors={[Colors.border, '#F9FAFB', Colors.border]}
        />
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { padding: 16, gap: 12 },
  item: { width: '100%', height: 120, borderRadius: Radius.card },
});
