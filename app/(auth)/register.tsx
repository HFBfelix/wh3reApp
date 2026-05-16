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

export default function RegisterScreen() {
  const router = useRouter();
  const { signUp, authActionLoading, clearAuthError } = useAuthStore();
  const [firstName, setFirstName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [obscure, setObscure] = useState(true);
  const [errors, setErrors] = useState<{
    firstName?: string;
    email?: string;
    password?: string;
  }>({});

  const submit = async () => {
    clearAuthError();
    const nextErrors: typeof errors = {};
    if (!firstName.trim()) nextErrors.firstName = 'Prénom requis';
    const emailErr = validateEmail(email);
    if (emailErr) nextErrors.email = emailErr;
    if (password.length < 6) nextErrors.password = '6 caractères minimum';
    setErrors(nextErrors);
    if (Object.keys(nextErrors).length > 0) return;

    const hasSession = await signUp(email.trim(), password, firstName.trim());
    if (hasSession) {
      router.replace('/(app)/dashboard');
      return;
    }
    const message = useAuthStore.getState().authError;
    if (message) {
      Alert.alert('Inscription', message);
    } else {
      Alert.alert(
        'Vérifiez votre email',
        'Un lien de confirmation vous a été envoyé. Vous pourrez vous connecter ensuite.',
        [{ text: 'OK', onPress: () => router.replace('/(auth)/login') }],
      );
    }
  };

  return (
    <AuthScaffold
      title="Créer un compte"
      subtitle="Rejoignez Wh3re et organisez vos sorties en groupe."
      footer={
        <View style={styles.footer}>
          <Text style={styles.footerText}>Déjà inscrit ?</Text>
          <Link href="/(auth)/login" asChild>
            <Pressable>
              <Text style={styles.footerLink}>Se connecter</Text>
            </Pressable>
          </Link>
        </View>
      }
    >
      <AuthTextField
        label="Prénom"
        placeholder="Alex"
        value={firstName}
        onChangeText={setFirstName}
        autoCapitalize="words"
        error={errors.firstName}
      />
      <AuthTextField
        label="Email"
        placeholder="vous@exemple.com"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
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
      <Text style={styles.hint}>
        Votre profil est créé automatiquement via le trigger Supabase sur public.profiles.
      </Text>
      <Wh3reButton label="Créer mon compte" isLoading={authActionLoading} onPress={submit} />
    </AuthScaffold>
  );
}

const styles = StyleSheet.create({
  hint: { fontSize: 12, color: Colors.textTertiary, marginBottom: 16, lineHeight: 18 },
  footer: { flexDirection: 'row', justifyContent: 'center', gap: 6 },
  footerText: { color: Colors.textSecondary },
  footerLink: { color: Colors.primary, fontWeight: '700' },
});
