import 'package:flutter_test/flutter_test.dart';
import 'package:wh3re/providers/auth_provider.dart';

void main() {
  group('authErrorMessage', () {
    test('returns generic message for unknown errors', () {
      expect(authErrorMessage(Exception('x')), contains('erreur'));
    });
  });
}
