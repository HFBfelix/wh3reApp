import type { ReactNode } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { ShimmerLoader } from '@/components/ShimmerLoader';
import { Wh3reButton } from '@/components/Wh3reButton';
import { Colors } from '@/constants/theme';
import { getErrorMessage } from '@/lib/errors';

interface QueryStateViewProps {
  isLoading: boolean;
  isError: boolean;
  error: unknown;
  onRetry?: () => void;
  shimmerCount?: number;
  children: ReactNode;
  emptyMessage?: string;
  isEmpty?: boolean;
}

export function QueryStateView({
  isLoading,
  isError,
  error,
  onRetry,
  shimmerCount = 3,
  children,
  emptyMessage,
  isEmpty = false,
}: QueryStateViewProps) {
  if (isLoading) return <ShimmerLoader count={shimmerCount} />;
  if (isError) {
    return (
      <View style={styles.center}>
        <Text style={styles.errorText}>{getErrorMessage(error)}</Text>
        {onRetry ? <Wh3reButton label="Réessayer" onPress={onRetry} style={styles.retryBtn} /> : null}
      </View>
    );
  }
  if (isEmpty && emptyMessage) {
    return (
      <View style={styles.center}>
        <Text style={styles.emptyText}>{emptyMessage}</Text>
      </View>
    );
  }
  return <>{children}</>;
}

const styles = StyleSheet.create({
  center: { flex: 1, padding: 32, alignItems: 'center', justifyContent: 'center' },
  errorText: { textAlign: 'center', color: Colors.textSecondary, marginBottom: 16 },
  emptyText: { textAlign: 'center', color: Colors.textTertiary, lineHeight: 22 },
  retryBtn: { maxWidth: 200 },
});
