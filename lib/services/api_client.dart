import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthSession {
  AuthSession({required this.token, required this.user});

  final String token;
  final Map<String, dynamic> user;

  String get role => (user['role'] ?? '').toString();

  Map<String, dynamic> toJson() => {'token': token, 'user': user};

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      user: Map<String, dynamic>.from(json['user'] as Map),
    );
  }
}

class ApiClient {
  ApiClient({this.token});

  final String? token;
  static const Duration _timeout = Duration(seconds: 30);

  Map<String, String> buildHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<AuthSession> login({required String email, required String password}) async {
    final data = await _request(
      method: 'POST',
      path: '/auth/login',
      body: {'email': email.trim().toLowerCase(), 'password': password.trim()},
    );
    return AuthSession(token: data['access_token'] as String, user: Map<String, dynamic>.from(data['user'] as Map));
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? nationalId,
    String? shopName,
  }) async {
    final payload = {
      'email': email.trim().toLowerCase(),
      'password': password.trim(),
      'full_name': fullName.trim(),
      'role': role,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (nationalId != null && nationalId.isNotEmpty) 'national_id': nationalId,
      if (shopName != null && shopName.isNotEmpty) 'shop_name': shopName,
    };
    final data = await _request(method: 'POST', path: '/auth/register', body: payload);
    return AuthSession(token: data['access_token'] as String, user: Map<String, dynamic>.from(data['user'] as Map));
  }

  Future<Map<String, dynamic>> me() async => Map<String, dynamic>.from(await _request(method: 'GET', path: '/auth/me') as Map);
  Future<Map<String, dynamic>> customerProfile() async => Map<String, dynamic>.from(await _request(method: 'GET', path: '/customers/me') as Map);
  Future<Map<String, dynamic>> regenerateCustomerCode() async => Map<String, dynamic>.from(await _request(method: 'POST', path: '/customers/me/regenerate-code', body: {}) as Map);
  Future<Map<String, dynamic>> customerDashboard() async => Map<String, dynamic>.from(await _request(method: 'GET', path: '/customers/me/dashboard') as Map);
  Future<List<dynamic>> customerPendingRequests() async => List<dynamic>.from(await _request(method: 'GET', path: '/customers/purchase-requests/pending') as List);
  Future<List<dynamic>> customerTransactions() async => List<dynamic>.from(await _request(method: 'GET', path: '/customers/me/transactions') as List);
  Future<List<dynamic>> customerRepaymentPlans() async => List<dynamic>.from(await _request(method: 'GET', path: '/customers/repayment-plans') as List);
  Future<List<dynamic>> customerUpcomingPayments() async => List<dynamic>.from(await _request(method: 'GET', path: '/customers/upcoming-payments') as List);
  Future<void> acceptPurchaseRequest(int requestId) async => _request(method: 'POST', path: '/customers/purchase-requests/$requestId/accept', body: {});
  Future<void> rejectPurchaseRequest(int requestId, {String? reason}) async => _request(method: 'POST', path: '/customers/purchase-requests/$requestId/reject', body: {'reason': reason});
  Future<void> payTransaction({required int transactionId, required double amount}) async => _request(method: 'POST', path: '/customers/transactions/$transactionId/pay', body: {'amount': amount, 'payment_method': 'card'});

  Future<Map<String, dynamic>> merchantDashboard() async => Map<String, dynamic>.from(await _request(method: 'GET', path: '/merchants/me/dashboard') as Map);
  Future<List<dynamic>> merchantRequests() async => List<dynamic>.from(await _request(method: 'GET', path: '/merchants/purchase-requests') as List);
  Future<List<dynamic>> merchantTransactions() async => List<dynamic>.from(await _request(method: 'GET', path: '/merchants/transactions') as List);
  Future<List<dynamic>> merchantSettlements() async => List<dynamic>.from(await _request(method: 'GET', path: '/merchants/settlements') as List);
  Future<List<dynamic>> merchantBranches() async => List<dynamic>.from(await _request(method: 'GET', path: '/merchants/branches') as List);
  Future<Map<String, dynamic>> lookupCustomer(String customerCode) async {
    final normalizedCode = customerCode.trim().toUpperCase();
    return Map<String, dynamic>.from(await _request(method: 'GET', path: '/merchants/lookup-customer/$normalizedCode') as Map);
  }
  Future<void> sendPurchaseRequest({required int customerId, required double amount, required String description, String productName = 'Purchase', int quantity = 1}) async => _request(method: 'POST', path: '/merchants/send-purchase-request', body: {'customer_id': customerId, 'amount': amount, 'description': description, 'product_name': productName, 'quantity': quantity});
  Future<void> requestWithdrawal(double amount) async => _request(method: 'POST', path: '/merchants/request-withdrawal', body: {'amount': amount});

  Future<Map<String, dynamic>> adminStats() async => Map<String, dynamic>.from(await _request(method: 'GET', path: '/admin/dashboard/stats') as Map);
  Future<List<dynamic>> adminUsers() async => List<dynamic>.from(await _request(method: 'GET', path: '/admin/users') as List);
  Future<List<dynamic>> adminCustomers() async => List<dynamic>.from(await _request(method: 'GET', path: '/admin/customers') as List);
  Future<List<dynamic>> adminMerchants() async => List<dynamic>.from(await _request(method: 'GET', path: '/admin/merchants') as List);
  Future<List<dynamic>> adminTransactions() async => List<dynamic>.from(await _request(method: 'GET', path: '/admin/transactions') as List);
  Future<List<dynamic>> adminSettlements() async => List<dynamic>.from(await _request(method: 'GET', path: '/admin/settlements') as List);

  Future<dynamic> _request({required String method, required String path, Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final headers = buildHeaders();

    late http.Response response;
    if (method == 'GET') {
      response = await http.get(uri, headers: headers).timeout(_timeout);
    } else if (method == 'POST') {
      response = await http.post(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(_timeout);
    } else if (method == 'PATCH') {
      response = await http.patch(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(_timeout);
    } else if (method == 'PUT') {
      response = await http.put(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(_timeout);
    } else {
      throw const ApiException('Unsupported method');
    }

    final decoded = jsonDecode(response.body);
    final success = decoded is Map && decoded['success'] == true;

    if (response.statusCode == 401) {
      throw ApiException('Unauthorized', statusCode: 401);
    }

    if (response.statusCode >= 200 && response.statusCode < 300 && success) {
      return (decoded as Map<String, dynamic>)['data'];
    }

    final message = decoded is Map && decoded['message'] is String ? decoded['message'] as String : 'Request failed (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
