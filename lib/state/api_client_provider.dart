import 'package:flutter/foundation.dart';

import '../services/api_client.dart';

class ApiClientProvider extends ChangeNotifier {
  ApiClientProvider(this._client);

  ApiClient _client;

  ApiClient get client => _client;

  void updateToken(String? token) {
    _client = ApiClient(token: token);
    notifyListeners();
  }
}
