import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/networking/api_client.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _summary;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get summary => _summary;
  String? get errorMessage => _errorMessage;

  static final Map<String, dynamic> _fallbackSummary = {
    'connected_repositories_count': 3,
    'monitored_domains_count': 2,
    'open_findings_count': 5,
    'critical_alerts_count': 1,
    'high_alerts_count': 2,
    'medium_alerts_count': 1,
    'low_alerts_count': 1,
    'informational_alerts_count': 1,
    'security_score': 84,
    'security_status': 'Attention Required',
    'recent_events': [
      {
        'id': 101,
        'title': 'Hardcoded AWS Credentials Exposed in Infrastructure Repo',
        'severity': 'Critical',
        'source': 'GitHub Secret Scanning',
        'target': 'security_lead/infrastructure-terraform',
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'status': 'Open'
      },
      {
        'id': 102,
        'title': 'Missing Content-Security-Policy and HSTS Headers',
        'severity': 'High',
        'source': 'Domain Check',
        'target': 'api.domainguard.io',
        'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'status': 'Open'
      },
      {
        'id': 103,
        'title': 'High Severity Vulnerability in PyJWT Library (GHSA-c5q2-9p22-3851)',
        'severity': 'High',
        'source': 'GitHub Dependabot',
        'target': 'security_lead/main-ecommerce-api',
        'created_at': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
        'status': 'Open'
      },
      {
        'id': 104,
        'title': 'SSL Certificate Expiration Warning (14 Days Remaining)',
        'severity': 'Medium',
        'source': 'Domain Check',
        'target': 'portal.domainguard.io',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'status': 'Open'
      },
      {
        'id': 105,
        'title': 'Automated Cloudflare WAF SQL Injection Spike Blocked',
        'severity': 'Informational',
        'source': 'Cloudflare WAF',
        'target': 'Cloudflare Edge Engine',
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'status': 'Open'
      }
    ],
    'event_trends': [
      {'date': 'Mar 01', 'critical': 1, 'high': 2, 'medium': 3, 'total': 6},
      {'date': 'Mar 02', 'critical': 0, 'high': 1, 'medium': 2, 'total': 3},
      {'date': 'Mar 03', 'critical': 1, 'high': 2, 'medium': 3, 'total': 6},
      {'date': 'Mar 04', 'critical': 2, 'high': 1, 'medium': 2, 'total': 5},
      {'date': 'Mar 05', 'critical': 1, 'high': 2, 'medium': 3, 'total': 6},
      {'date': 'Mar 06', 'critical': 0, 'high': 1, 'medium': 2, 'total': 3},
      {'date': 'Mar 07', 'critical': 1, 'high': 2, 'medium': 1, 'total': 4},
    ],
    'is_demo_data': true
  };

  Future<void> fetchSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get(ApiConfig.dashboardSummaryUrl);
      _summary = res;
    } catch (_) {
      _summary = _fallbackSummary;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
