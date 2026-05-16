import { View, Text, Pressable, StyleSheet } from 'react-native';
import * as Haptics from 'expo-haptics';
import type { WeightEnum } from '@/types/response';
import { Colors } from '@/constants/theme';

interface WeightSelectorProps {
  selected: WeightEnum;
  onChange: (weight: WeightEnum) => void;
}

const OPTIONS: { key: WeightEnum; label: string; color: string; bg: string }[] = [
  { key: 'indifferent', label: 'Indifférent', color: Colors.weightIndifferent, bg: Colors.surfaceVariant },
  { key: 'wished', label: 'Souhaité', color: Colors.weightWished, bg: Colors.primarySurface },
  { key: 'redhibitory', label: 'Rédhibitoire', color: Colors.weightRedhibitory, bg: Colors.errorLight },
];

export function WeightSelector({ selected, onChange }: WeightSelectorProps) {
  const select = async (weight: WeightEnum) => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    onChange(weight);
  };

  return (
    <View style={styles.row}>
      {OPTIONS.map((opt) => {
        const isSelected = selected === opt.key;
        const isVeto = opt.key === 'redhibitory';
        return (
          <Pressable
            key={opt.key}
            onPress={() => select(opt.key)}
            style={[
              styles.chip,
              { backgroundColor: isSelected ? opt.bg : Colors.surfaceVariant },
              isSelected && {
                borderColor: isVeto ? Colors.weightRedhibitory : opt.color,
                borderWidth: 2,
              },
            ]}
          >
            <Text
              style={[
                styles.chipText,
                { color: isSelected ? opt.color : Colors.textSecondary },
              ]}
            >
              {opt.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', gap: 8 },
  chip: {
    flex: 1,
    paddingVertical: 10,
    paddingHorizontal: 4,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: Colors.border,
    alignItems: 'center',
  },
  chipText: { fontSize: 11, fontWeight: '700', textAlign: 'center' },
});
