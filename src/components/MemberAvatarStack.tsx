import { View, Text, StyleSheet } from 'react-native';
import type { EventMember } from '@/types/member';
import { Colors } from '@/constants/theme';

interface MemberAvatarStackProps {
  members: EventMember[];
  maxVisible?: number;
}

export function MemberAvatarStack({ members, maxVisible = 5 }: MemberAvatarStackProps) {
  const visible = members.slice(0, maxVisible);
  const extra = members.length - maxVisible;

  return (
    <View style={styles.row}>
      {visible.map((member, index) => (
        <View
          key={member.id}
          style={[styles.avatar, { marginLeft: index === 0 ? 0 : -12, zIndex: visible.length - index }]}
        >
          <Text style={styles.initial}>
            {(member.profile?.firstName ?? '?').charAt(0).toUpperCase()}
          </Text>
          {member.hasResponded ? <View style={styles.dot} /> : null}
        </View>
      ))}
      {extra > 0 ? (
        <View style={[styles.avatar, styles.extra, { marginLeft: -12 }]}>
          <Text style={styles.extraText}>+{extra}</Text>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center' },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Colors.primarySurface,
    borderWidth: 2,
    borderColor: Colors.background,
    alignItems: 'center',
    justifyContent: 'center',
  },
  initial: { fontWeight: '700', color: Colors.primary, fontSize: 16 },
  dot: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: Colors.success,
    borderWidth: 2,
    borderColor: Colors.background,
  },
  extra: { backgroundColor: Colors.primary },
  extraText: { color: Colors.textOnPrimary, fontWeight: '700', fontSize: 12 },
});
