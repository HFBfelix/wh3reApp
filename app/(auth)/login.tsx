import { useState } from 'react';
import { View, Text, Pressable, Alert, StyleSheet } from 'react-native';
import { Link, useRouter } from 'expo-router';
import { AuthScaffold } from '@/components/AuthScaffold';
import { AuthTextField } from '@/components/AuthTextField';
import { Wh3reButton } from '@/components/Wh3reButton';
import { useAuthStore } from '@/stores/authStore';
import { Colors } from '@/constants/theme';

function validateEmail(email: string): string | undefined {
  if (!email.trim()) return 'Email requis';
  if (!/^[^@]+@[^@]+\.[^@]+$/.test(email.trim())) return 'Email invalide';
  return undefined;
}

export default function LoginScreen() {
  const router = useRouter();
  const { signIn, authActionLoading, clearAuthError } = useAuthStore();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [obscure, setObscure] = useState(true);
  const [errors, setErrors] = useState<{ email?: string; password?: string }>({});

  const submit = async () => {
    clearAuthError();
    const nextErrors: typeof errors = {};
    const emailErr = validateEmail(email);
    if (emailErr) nextErrors.email = emailErr;
    if (!password) nextErrors.password = 'Mot de passe requis';
    setErrors(nextErrors);
    if (Object.keys(nextErrors).length > 0) return;

    const ok = await signIn(email.trim(), password);
    if (ok) {
      router.replace('/(app)/dashboard');
    } else {
      const message = useAuthStore.getState().authError;
      if (message) Alert.alert('Connexion impossible', message);
    }
  };

  return (
    <AuthScaffold
      title="Bon retour"
      subtitle="Connectez-vous pour planifier vos sorties de groupe."
      footer={
        <View style={styles.footer}>
          <Text style={styles.footerText}>Pas encore de compte ?</Text>
          <Link href="/(auth)/register" asChild>
            <Pressable>
              <Text style={styles.footerLink}>Créer un compte</Text>
            </Pressable>
          </Link>
        </View>
      }
    >
      <AuthTextField
        label="Email"
        placeholder="vous@exemple.com"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
        autoCorrect={false}
        error={errors.email}
      />
      <AuthTextField
        label="Mot de passe"
        placeholder="••••••••"
        value={password}
        onChangeText={setPassword}
        secureTextEntry={obscure}
        autoCapitalize="none"
        secureToggle={obscure}
        onToggleSecure={() => setObscure((v) => !v)}
        error={errors.password}
      />
      <Pressable
        onPress={() => router.push('/(auth)/forgot-password')}
        style={styles.forgot}
        disabled={authActionLoading}
      >
        <Text style={styles.forgotText}>Mot de passe oublié ?</Text>
      </Pressable>
      <Wh3reButton label="Se connecter" isLoading={authActionLoading} onPress={submit} />
    </AuthScaffold>
  );
}

const styles = StyleSheet.create({
  forgot: { alignSelf: 'flex-end', marginBottom: 16, marginTop: -8 },
  forgotText: { color: Colors.primary, fontWeight: '600', fontSize: 14 },
  footer: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 6 },
  footerText: { color: Colors.textSecondary },
  footerLink: { color: Colors.primary, fontWeight: '700' },
});
