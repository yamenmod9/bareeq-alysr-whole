import 'package:flutter/foundation.dart';

import '../services/api_client.dart';
import '../services/session_store.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.store});

  final SessionStore store;
  AuthSession? _session;
  bool _loading = true;
  String? _error;

  AuthSession? get session => _session;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _session != null;
  String get role => _session?.role ?? '';

  ApiClient get apiClient => ApiClient(token: _session?.token);

  Future<void> restore() async {
    _loading = true;
    notifyListeners();
    _session = await store.loadSession();
    _loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    notifyListeners();
    try {
      final session = await ApiClient().login(email: email, password: password);
      _session = session;
      await store.saveSession(session);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? nationalId,
    String? shopName,
  }) async {
    _error = null;
    notifyListeners();
    try {
      final session = await ApiClient().register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
        nationalId: nationalId,
        shopName: shopName,
      );
      _session = session;
      await store.saveSession(session);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _session = null;
    await store.clearSession();
    notifyListeners();
  }

  Future<void> updateProfileLocal(Map<String, dynamic> updates) async {
    if (_session == null) return;
    _session!.user.addAll(updates);
    await store.saveSession(_session!);
    notifyListeners();
  }
}
