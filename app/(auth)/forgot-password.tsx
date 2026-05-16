import { useState } from 'react';
import { Alert, StyleSheet, Text } from 'react-native';
import { useRouter } from 'expo-router';
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

export default function ForgotPasswordScreen() {
  const router = useRouter();
  const { resetPassword, authActionLoading, clearAuthError } = useAuthStore();
  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState<string | undefined>();

  const submit = async () => {
    clearAuthError();
    const err = validateEmail(email);
    setEmailError(err);
    if (err) return;

    const ok = await resetPassword(email.trim());
    if (ok) {
      Alert.alert(
        'Email envoyé',
        'Consultez votre boîte mail pour réinitialiser votre mot de passe.',
        [{ text: 'OK', onPress: () => router.back() }],
      );
    } else {
      const message = useAuthStore.getState().authError ?? 'Impossible d\'envoyer l\'email.';
      Alert.alert('Erreur', message);
    }
  };

  return (
    <AuthScaffold
      title="Mot de passe oublié"
      subtitle="Saisissez votre email — nous vous enverrons un lien de réinitialisation via Supabase Auth."
      showLogo={false}
    >
      <AuthTextField
        label="Email"
        placeholder="vous@exemple.com"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
        error={emailError}
      />
      <Text style={styles.info}>
        La réinitialisation est gérée par Supabase Auth (resetPasswordForEmail).
      </Text>
      <Wh3reButton label="Envoyer le lien" isLoading={authActionLoading} onPress={submit} />
      <Wh3reButton
        label="Retour à la connexion"
        variant="outline"
        onPress={() => router.back()}
        style={styles.backBtn}
      />
    </AuthScaffold>
  );
}

const styles = StyleSheet.create({
  info: { fontSize: 13, color: Colors.textSecondary, marginBottom: 20, lineHeight: 20 },
  backBtn: { marginTop: 12 },
});
