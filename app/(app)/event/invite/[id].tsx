import { View, Text, Alert, StyleSheet, Share } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import * as Clipboard from 'expo-clipboard';
import QRCode from 'react-native-qrcode-svg';
import { ScreenHeader } from '@/components/ScreenHeader';
import { QueryStateView } from '@/components/QueryStateView';
import { Wh3reButton } from '@/components/Wh3reButton';
import { useEvent } from '@/hooks/useEvent';
import { buildJoinUrl } from '@/utils/inviteLink';
import { Colors, Radius } from '@/constants/theme';

export default function InviteEventScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const eventQuery = useEvent(id);
  const event = eventQuery.data;
  const inviteUrl = event?.inviteToken ? buildJoinUrl(event.inviteToken) : null;

  const copyLink = async () => {
    if (!inviteUrl) return;
    await Clipboard.setStringAsync(inviteUrl);
    Alert.alert('Copié', 'Le lien d\'invitation est dans le presse-papiers.');
  };

  const shareLink = async () => {
    if (!inviteUrl || !event) return;
    try {
      await Share.share({
        message: `Rejoins mon événement « ${event.name} » sur Wh3re : ${inviteUrl}`,
        url: inviteUrl,
      });
    } catch {
      /* annulé */
    }
  };

  return (
    <View style={styles.root}>
      <ScreenHeader title="Inviter" />
      <QueryStateView
        isLoading={eventQuery.isLoading}
        isError={eventQuery.isError}
        error={eventQuery.error}
        onRetry={() => eventQuery.refetch()}
      >
        <View style={styles.content}>
          <Text style={styles.title}>Partagez votre événement</Text>
          <Text style={styles.sub}>
            Scannez le QR code ou partagez le lien deep link wh3re.app/join/:token
          </Text>

          {inviteUrl ? (
            <View style={styles.qrWrap}>
              <QRCode value={inviteUrl} size={220} color={Colors.primary} backgroundColor="#FFFFFF" />
            </View>
          ) : (
            <Text style={styles.muted}>Token d'invitation indisponible.</Text>
          )}

          {inviteUrl ? (
            <Text style={styles.link} selectable>
              {inviteUrl}
            </Text>
          ) : null}

          <Wh3reButton label="Copier le lien" onPress={copyLink} style={styles.btn} />
          <Wh3reButton label="Partager" variant="outline" onPress={shareLink} />
        </View>
      </QueryStateView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Colors.background },
  content: { padding: 24, alignItems: 'center' },
  title: { fontSize: 22, fontWeight: '700', color: Colors.textPrimary, textAlign: 'center' },
  sub: {
    marginTop: 8,
    fontSize: 15,
    color: Colors.textSecondary,
    textAlign: 'center',
    lineHeight: 22,
  },
  qrWrap: {
    marginTop: 32,
    padding: 24,
    borderRadius: Radius.card,
    backgroundColor: Colors.surface,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  link: {
    marginTop: 24,
    fontSize: 13,
    color: Colors.primary,
    textAlign: 'center',
    paddingHorizontal: 16,
  },
  btn: { marginTop: 24, marginBottom: 12 },
  muted: { marginTop: 32, color: Colors.textTertiary },
});
