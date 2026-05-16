import {
  Pressable,
  Text,
  ActivityIndicator,
  type PressableProps,
  type StyleProp,
  type ViewStyle,
  StyleSheet,
} from 'react-native';
import { Colors, Radius } from '@/constants/theme';

interface Wh3reButtonProps extends Omit<PressableProps, 'style'> {
  label: string;
  isLoading?: boolean;
  variant?: 'primary' | 'outline';
  style?: StyleProp<ViewStyle>;
}

export function Wh3reButton({
  label,
  isLoading,
  disabled,
  variant = 'primary',
  style,
  ...props
}: Wh3reButtonProps) {
  const isOutline = variant === 'outline';
  return (
    <Pressable
      style={({ pressed }) => [
        styles.base,
        isOutline ? styles.outline : styles.primary,
        (disabled || isLoading) && styles.disabled,
        pressed && styles.pressed,
        style,
      ]}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? (
        <ActivityIndicator color={isOutline ? Colors.primary : Colors.textOnPrimary} />
      ) : (
        <Text style={[styles.label, isOutline && styles.labelOutline]}>{label}</Text>
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    height: 56,
    borderRadius: Radius.card,
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
  },
  primary: { backgroundColor: Colors.primary },
  outline: {
    backgroundColor: 'transparent',
    borderWidth: 2,
    borderColor: Colors.primary,
  },
  disabled: { opacity: 0.5 },
  pressed: { opacity: 0.85 },
  label: { color: Colors.textOnPrimary, fontSize: 16, fontWeight: '600' },
  labelOutline: { color: Colors.primary },
});
