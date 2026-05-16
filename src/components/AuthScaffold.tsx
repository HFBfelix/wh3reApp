import type { ReactNode } from 'react';
import { View, Text, ScrollView, StyleSheet, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Colors, Radius } from '@/constants/theme';

interface AuthScaffoldProps {
  title: string;
  subtitle: string;
  children: ReactNode;
  footer?: ReactNode;
  showLogo?: boolean;
}

export function AuthScaffold({
  title,
  subtitle,
  children,
  footer,
  showLogo = true,
}: AuthScaffoldProps) {
  return (
    <SafeAreaView style={styles.safe}>
      <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
        {showLogo ? (
          <Image source={require('../../assets/icon.png')} style={styles.logo} />
        ) : null}
        <Text style={styles.title}>{title}</Text>
        <Text style={styles.subtitle}>{subtitle}</Text>
        <View style={styles.card}>{children}</View>
        {footer ? <View style={styles.footer}>{footer}</View> : null}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  scroll: { padding: 24, paddingBottom: 40 },
  logo: {
    width: 88,
    height: 88,
    borderRadius: Radius.card,
    alignSelf: 'center',
    marginBottom: 32,
    marginTop: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: Colors.textPrimary,
    letterSpacing: -0.5,
  },
  subtitle: { fontSize: 16, lineHeight: 22, color: Colors.textSecondary, marginTop: 8 },
  card: {
    marginTop: 32,
    padding: 24,
    borderRadius: Radius.card,
    backgroundColor: 'rgba(255,255,255,0.95)',
    borderWidth: 1,
    borderColor: Colors.border,
  },
  footer: { marginTop: 24 },
});
