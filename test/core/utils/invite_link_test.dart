import 'package:flutter_test/flutter_test.dart';
import 'package:wh3re/core/utils/invite_link.dart';

void main() {
  group('InviteLink', () {
    test('joinUrl builds correct Universal Link', () {
      expect(
        InviteLink.joinUrl('abc123'),
        'https://wh3re.app/join/abc123',
      );
    });

    test('parseTokenFromUri extracts token', () {
      final uri = Uri.parse('https://wh3re.app/join/secret-token');
      expect(InviteLink.parseTokenFromUri(uri), 'secret-token');
    });
  });
}
