import { View, Text, Pressable, StyleSheet } from 'react-native';
import type { EventRecord } from '@/types/event';
import { Colors, Radius } from '@/constants/theme';

interface EventCardProps {
  event: EventRecord;
  isCreator: boolean;
  onPress: () => void;
}

export function EventCard({ event, isCreator, onPress }: EventCardProps) {
  const statusLabel: Record<string, string> = {
    draft: 'Brouillon',
    polling: 'Sondage',
    decided: 'Décidé',
    archived: 'Archivé',
  };

  const date = event.updatedAt ?? event.createdAt;
  const dateStr = date
    ? new Date(date).toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' })
    : '';

  return (
    <Pressable onPress={onPress} style={({ pressed }) => [styles.card, pressed && styles.pressed]}>
      <View style={styles.header}>
        <Text style={styles.title} numberOfLines={1}>
          {event.name}
        </Text>
        <View style={styles.badge}>
          <Text style={styles.badgeText}>{statusLabel[event.status] ?? event.status}</Text>
        </View>
      </View>
      {event.description ? (
        <Text style={styles.description} numberOfLines={2}>
          {event.description}
        </Text>
      ) : null}
      <View style={styles.footer}>
        <Text style={styles.meta}>{isCreator ? '✨ Ma création' : '📩 Invitation'}</Text>
        {dateStr ? <Text style={styles.date}>{dateStr}</Text> : null}
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: Colors.surface,
    borderRadius: Radius.card,
    borderWidth: 1,
    borderColor: Colors.border,
    padding: 20,
  },
  pressed: { opacity: 0.92 },
  header: { flexDirection: 'row', alignItems: 'flex-start', gap: 8 },
  title: { flex: 1, fontSize: 18, fontWeight: '700', color: Colors.textPrimary },
  badge: {
    backgroundColor: Colors.primarySurface,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  badgeText: { fontSize: 12, fontWeight: '600', color: Colors.primary },
  description: { marginTop: 8, fontSize: 14, color: Colors.textSecondary, lineHeight: 20 },
  footer: { marginTop: 12, flexDirection: 'row', justifyContent: 'space-between' },
  meta: { fontSize: 13, fontWeight: '600', color: Colors.primary },
  date: { fontSize: 12, color: Colors.textTertiary },
});
