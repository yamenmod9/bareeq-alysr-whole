import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bareeq_alysr/services/api_client.dart';
import 'package:bareeq_alysr/services/session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Auth state persistence', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SessionStore();
    final session = AuthSession(
      token: 'jwt-token',
      user: {'role': 'customer', 'email': 'user@test.com'},
    );

    await store.saveSession(session);
    final loaded = await store.loadSession();

    expect(loaded, isNotNull);
    expect(loaded!.token, 'jwt-token');
    expect(loaded.role, 'customer');
  });

  test('API client auth header behavior', () {
    final client = ApiClient(token: 'abc123');
    final headers = client.buildHeaders();

    expect(headers['Authorization'], 'Bearer abc123');
    expect(headers['Content-Type'], 'application/json');
  });
}
