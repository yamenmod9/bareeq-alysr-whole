import 'package:flutter/foundation.dart';

import '../services/api_client.dart';

class LoadState<T> {
  const LoadState({this.loading = false, this.data, this.error});

  final bool loading;
  final T? data;
  final String? error;
}

class CustomerDashboardProvider extends ChangeNotifier {
  LoadState<Map<String, dynamic>> state = const LoadState(loading: true);

  Future<void> fetch(ApiClient api) async {
    state = const LoadState(loading: true);
    notifyListeners();
    try {
      final data = await api.customerDashboard();
      state = LoadState(data: data);
    } on ApiException catch (e) {
      state = LoadState(error: e.message);
    }
    notifyListeners();
  }
}

class CustomerRequestsProvider extends ChangeNotifier {
  LoadState<List<dynamic>> state = const LoadState(loading: true);

  Future<void> fetch(ApiClient api) async {
    state = const LoadState(loading: true);
    notifyListeners();
    try {
      final data = await api.customerPendingRequests();
      state = LoadState(data: data);
    } on ApiException catch (e) {
      state = LoadState(error: e.message);
    }
    notifyListeners();
  }
}

class CustomerTransactionsProvider extends ChangeNotifier {
  LoadState<List<dynamic>> state = const LoadState(loading: true);

  Future<void> fetch(ApiClient api) async {
    state = const LoadState(loading: true);
    notifyListeners();
    try {
      final data = await api.customerTransactions();
      state = LoadState(data: data);
    } on ApiException catch (e) {
      state = LoadState(error: e.message);
    }
    notifyListeners();
  }
}

class MerchantRequestsProvider extends ChangeNotifier {
  LoadState<List<dynamic>> state = const LoadState(loading: true);

  Future<void> fetch(ApiClient api) async {
    state = const LoadState(loading: true);
    notifyListeners();
    try {
      final data = await api.merchantRequests();
      state = LoadState(data: data);
    } on ApiException catch (e) {
      state = LoadState(error: e.message);
    }
    notifyListeners();
  }
}

class MerchantSettlementsProvider extends ChangeNotifier {
  LoadState<List<dynamic>> state = const LoadState(loading: true);

  Future<void> fetch(ApiClient api) async {
    state = const LoadState(loading: true);
    notifyListeners();
    try {
      final data = await api.merchantSettlements();
      state = LoadState(data: data);
    } on ApiException catch (e) {
      state = LoadState(error: e.message);
    }
    notifyListeners();
  }
}

class AdminStatsProvider extends ChangeNotifier {
  LoadState<Map<String, dynamic>> state = const LoadState(loading: true);

  Future<void> fetch(ApiClient api) async {
    state = const LoadState(loading: true);
    notifyListeners();
    try {
      final data = await api.adminStats();
      state = LoadState(data: data);
    } on ApiException catch (e) {
      state = LoadState(error: e.message);
    }
    notifyListeners();
  }
}
