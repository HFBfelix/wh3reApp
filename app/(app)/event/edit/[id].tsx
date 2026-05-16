import { useEffect, useState } from 'react';
import { View, ScrollView, Alert, StyleSheet } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { ScreenHeader } from '@/components/ScreenHeader';
import { AuthTextField } from '@/components/AuthTextField';
import { Wh3reButton } from '@/components/Wh3reButton';
import { QueryStateView } from '@/components/QueryStateView';
import { useEvent } from '@/hooks/useEvent';
import { updateEvent } from '@/services/events';
import { Colors } from '@/constants/theme';

export default function EditEventScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const eventQuery = useEvent(id);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [ambiance, setAmbiance] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (eventQuery.data) {
      setName(eventQuery.data.name);
      setDescription(eventQuery.data.description ?? '');
      setAmbiance(eventQuery.data.ambiance ?? '');
    }
  }, [eventQuery.data]);

  const submit = async () => {
    if (!name.trim()) {
      Alert.alert('Erreur', 'Le nom est requis.');
      return;
    }
    setLoading(true);
    try {
      await updateEvent(id, {
        name: name.trim(),
        description: description.trim() || undefined,
        ambiance: ambiance.trim() || undefined,
      });
      router.back();
    } catch (e) {
      Alert.alert('Erreur', e instanceof Error ? e.message : 'Modification impossible.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.root}>
      <ScreenHeader title="Modifier l'événement" />
      <QueryStateView
        isLoading={eventQuery.isLoading}
        isError={eventQuery.isError}
        error={eventQuery.error}
        onRetry={() => eventQuery.refetch()}
      >
        <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
          <AuthTextField label="Nom" value={name} onChangeText={setName} />
          <AuthTextField
            label="Description"
            value={description}
            onChangeText={setDescription}
            multiline
          />
          <AuthTextField label="Ambiance" value={ambiance} onChangeText={setAmbiance} />
          <Wh3reButton label="Enregistrer" isLoading={loading} onPress={submit} />
        </ScrollView>
      </QueryStateView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Colors.background },
  scroll: { padding: 24 },
});
