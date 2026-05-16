import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wh3re/services/deep_link_service.dart';

/// Instance globale du service deep links (overridée dans [main]).
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  throw UnimplementedError(
    'deepLinkServiceProvider doit être overridé dans main()',
  );
});
