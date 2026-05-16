import { View, Text, TextInput, Pressable, StyleSheet, type TextInputProps } from 'react-native';
import { Colors, Radius } from '@/constants/theme';

interface AuthTextFieldProps extends TextInputProps {
  label: string;
  error?: string;
  secureToggle?: boolean;
  onToggleSecure?: () => void;
}

export function AuthTextField({
  label,
  error,
  secureToggle,
  onToggleSecure,
  style,
  ...props
}: AuthTextFieldProps) {
  return (
    <View style={styles.wrap}>
      <Text style={styles.label}>{label}</Text>
      <View style={styles.inputWrap}>
        <TextInput
          placeholderTextColor={Colors.textTertiary}
          style={[styles.input, error ? styles.inputError : undefined, style]}
          {...props}
        />
        {secureToggle != null && onToggleSecure ? (
          <Pressable onPress={onToggleSecure} style={styles.toggle}>
            <Text style={styles.toggleText}>{secureToggle ? '👁' : '🙈'}</Text>
          </Pressable>
        ) : null}
      </View>
      {error ? <Text style={styles.error}>{error}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { marginBottom: 20 },
  label: { fontSize: 14, fontWeight: '600', color: Colors.textPrimary, marginBottom: 8 },
  inputWrap: { position: 'relative' },
  input: {
    backgroundColor: Colors.surfaceVariant,
    borderRadius: Radius.input,
    borderWidth: 1,
    borderColor: Colors.border,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 16,
    color: Colors.textPrimary,
  },
  inputError: { borderColor: Colors.error },
  toggle: { position: 'absolute', right: 12, top: 14 },
  toggleText: { fontSize: 18 },
  error: { marginTop: 6, fontSize: 12, color: Colors.error },
});
