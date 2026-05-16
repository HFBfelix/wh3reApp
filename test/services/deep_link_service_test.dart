import 'package:flutter_test/flutter_test.dart';
import 'package:wh3re/services/deep_link_service.dart';

void main() {
  group('DeepLinkService.extractJoinToken', () {
    test('extracts token from Universal Link', () {
      final uri = Uri.parse('https://wh3re.app/join/abc123def456');
      expect(DeepLinkService.extractJoinToken(uri), 'abc123def456');
    });

    test('extracts token from internal path', () {
      final uri = Uri.parse('/join/my-token');
      expect(DeepLinkService.extractJoinToken(uri), 'my-token');
    });

    test('returns null for unrelated paths', () {
      final uri = Uri.parse('https://wh3re.app/dashboard');
      expect(DeepLinkService.extractJoinToken(uri), isNull);
    });
  });

  group('DeepLinkService.mapUriToGoRoute', () {
    test('returns null for join URIs (handled separately)', () {
      final uri = Uri.parse('https://wh3re.app/join/token');
      expect(DeepLinkService.mapUriToGoRoute(uri), isNull);
    });

    test('maps plain paths', () {
      final uri = Uri.parse('/dashboard');
      expect(DeepLinkService.mapUriToGoRoute(uri), '/dashboard');
    });
  });
}
