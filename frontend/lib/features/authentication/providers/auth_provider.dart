import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/networking/api_client.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await ApiClient.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          final userData = await ApiClient.get(ApiConfig.meUrl);
          _user = userData;
          _isAuthenticated = true;
        } catch (_) {
          // If backend offline, use local demo user session
          _user = _demoUser;
          _isAuthenticated = true;
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (_) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static final Map<String, dynamic> _demoUser = {
    'id': 1,
    'email': 'secops@domainguard.io',
    'username': 'security_lead',
    'full_name': 'Alex Rivera (SecOps Lead)',
    'avatar_url': 'https://avatars.githubusercontent.com/u/583231?v=4',
    'plan_tier': 'Enterprise',
    'is_active': true,
    'is_admin': true,
    'notification_settings': {
      'email_alerts': true,
      'critical_only': false,
      'weekly_summary': true,
      'min_severity': 'Low'
    },
    'created_at': DateTime.now().toIso8601String()
  };

  Future<bool> loginDemo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      try {
        final res = await ApiClient.post(ApiConfig.demoLoginUrl);
        final token = res['access_token'];
        await ApiClient.saveToken(token);
        _user = res['user'];
      } catch (_) {
        // Fallback for offline/network issues: Save local demo token & session
        await ApiClient.saveToken('demo_bearer_token_local');
        _user = _demoUser;
      }
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _user = _demoUser;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('${ApiConfig.baseUrl}/auth/logout');
    } catch (_) {}
    await ApiClient.clearToken();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
