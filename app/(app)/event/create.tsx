import { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  Alert,
  StyleSheet,
  ActivityIndicator,
  Pressable,
} from 'react-native';
import { useRouter } from 'expo-router';
import { ScreenHeader } from '@/components/ScreenHeader';
import { AuthTextField } from '@/components/AuthTextField';
import { Wh3reButton } from '@/components/Wh3reButton';
import { createEvent } from '@/services/events';
import { suggestEventAmbiance } from '@/services/gemini';
import { Colors } from '@/constants/theme';

export default function CreateEventScreen() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [ambiance, setAmbiance] = useState('');
  const [loading, setLoading] = useState(false);
  const [aiLoading, setAiLoading] = useState(false);
  const [errors, setErrors] = useState<{ name?: string }>({});

  const suggestAmbiance = async () => {
    if (!name.trim()) {
      Alert.alert('Nom requis', 'Indiquez d\'abord le nom de l\'événement.');
      return;
    }
    setAiLoading(true);
    try {
      const suggestion = await suggestEventAmbiance(name, description);
      setAmbiance(suggestion);
    } finally {
      setAiLoading(false);
    }
  };

  const submit = async () => {
    if (!name.trim()) {
      setErrors({ name: 'Nom requis' });
      return;
    }
    setLoading(true);
    try {
      const event = await createEvent({
        name: name.trim(),
        description: description.trim() || undefined,
        ambiance: ambiance.trim() || undefined,
      });
      router.replace(`/(app)/event/${event.id}`);
    } catch (e) {
      Alert.alert('Erreur', e instanceof Error ? e.message : 'Impossible de créer l\'événement.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.root}>
      <ScreenHeader title="Nouvel événement" />
      <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
        <Text style={styles.lead}>Donnez vie à votre sortie de groupe</Text>
        <AuthTextField
          label="Nom de l'événement"
          placeholder="Apéro d'équipe"
          value={name}
          onChangeText={setName}
          error={errors.name}
        />
        <AuthTextField
          label="Description (optionnel)"
          placeholder="Un vendredi soir entre collègues…"
          value={description}
          onChangeText={setDescription}
          multiline
        />
        <AuthTextField
          label="Ambiance (optionnel)"
          placeholder="Cosy, festif, décontracté…"
          value={ambiance}
          onChangeText={setAmbiance}
        />
        <Pressable style={styles.aiBtn} onPress={suggestAmbiance} disabled={aiLoading}>
          {aiLoading ? (
            <ActivityIndicator color={Colors.primary} />
          ) : (
            <Text style={styles.aiBtnText}>✨ Suggérer l'ambiance avec l'IA</Text>
          )}
        </Pressable>
        <Wh3reButton label="Créer l'événement" isLoading={loading} onPress={submit} />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Colors.background },
  scroll: { padding: 24, paddingBottom: 40 },
  lead: { fontSize: 16, color: Colors.textSecondary, lineHeight: 22, marginBottom: 24 },
  aiBtn: {
    marginBottom: 24,
    padding: 14,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: Colors.primary,
    alignItems: 'center',
    backgroundColor: Colors.primarySurface,
  },
  aiBtnText: { color: Colors.primary, fontWeight: '700' },
});
