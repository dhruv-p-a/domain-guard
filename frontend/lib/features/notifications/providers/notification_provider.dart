import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/networking/api_client.dart';

class NotificationProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _notifications = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<dynamic> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => n['is_read'] == false).length;
  String? get errorMessage => _errorMessage;

  static final List<dynamic> _fallbackNotifications = [
    {
      'id': 1,
      'title': 'Critical: Exposed AWS Key Detected',
      'message': 'GitHub Secret Scanning identified a hardcoded AWS key in infrastructure-terraform repository.',
      'severity': 'Critical',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()
    },
    {
      'id': 2,
      'title': 'Domain Added & Monitoring Active',
      'message': 'Monitoring has been successfully enabled for api.domainguard.io.',
      'severity': 'Informational',
      'is_read': true,
      'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String()
    },
    {
      'id': 3,
      'title': 'Security Header Warning',
      'message': 'Domain api.domainguard.io is missing Content-Security-Policy header.',
      'severity': 'High',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String()
    }
  ];

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get(ApiConfig.notificationsUrl);
      _notifications = res is List ? res : _fallbackNotifications;
    } catch (_) {
      _notifications = _fallbackNotifications;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiClient.post('${ApiConfig.notificationsUrl}/mark-all-read');
    } catch (_) {
      for (var n in _notifications) {
        n['is_read'] = true;
      }
    }
    await fetchNotifications();
  }
}
