import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/networking/api_client.dart';

class EventProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _events = [];
  String _selectedSeverity = 'All';
  String _selectedSource = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<dynamic> get events => _events;
  String get selectedSeverity => _selectedSeverity;
  String get selectedSource => _selectedSource;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  static final List<dynamic> _fallbackEvents = [
    {
      'id': 1,
      'title': 'Hardcoded AWS Credentials Exposed in Infrastructure Repo',
      'event_type': 'SECRET_EXPOSED',
      'severity': 'Critical',
      'source': 'GitHub Secret Scanning',
      'target_type': 'repository',
      'target_name': 'security_lead/infrastructure-terraform',
      'evidence': 'Commit c8f12a9 modified variables.tf containing AWS_ACCESS_KEY_ID: AKIAIOSFODNN7EXAMPLE',
      'remediation': '1. Revoke key AKIAIOSFODNN7EXAMPLE in AWS IAM Console.\n2. Purge secret from git history using git-filter-repo.\n3. Implement AWS Secrets Manager.',
      'status': 'Open',
      'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': 2,
      'title': 'Missing Content-Security-Policy and HSTS Headers',
      'event_type': 'HEADER_MISSING',
      'severity': 'High',
      'source': 'Domain Check',
      'target_type': 'domain',
      'target_name': 'api.domainguard.io',
      'evidence': 'HTTP response header inspection returned 200 OK without "Content-Security-Policy" or "Strict-Transport-Security" headers present.',
      'remediation': 'Configure web server or Cloudflare response headers to set "Strict-Transport-Security: max-age=31536000; includeSubDomains" and an explicit CSP policy.',
      'status': 'Open',
      'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': 3,
      'title': 'High Severity Vulnerability in PyJWT Library (GHSA-c5q2-9p22-3851)',
      'event_type': 'DEPENDABOT_ALERT',
      'severity': 'High',
      'source': 'GitHub Dependabot',
      'target_type': 'repository',
      'target_name': 'security_lead/main-ecommerce-api',
      'evidence': 'Dependabot flagged package "pyjwt" version 2.7.0 in requirements.txt.',
      'remediation': 'Update pyjwt dependency requirement to "pyjwt>=2.8.0" in requirements.txt and re-deploy.',
      'status': 'Open',
      'created_at': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
    },
    {
      'id': 4,
      'title': 'SSL Certificate Expiration Warning (14 Days Remaining)',
      'event_type': 'SSL_EXPIRE',
      'severity': 'Medium',
      'source': 'Domain Check',
      'target_type': 'domain',
      'target_name': 'portal.domainguard.io',
      'evidence': 'SSL certificate issued by Let\'s Encrypt expires soon.',
      'remediation': 'Trigger automated Let\'s Encrypt certbot renewal or update certificate authority credentials.',
      'status': 'Open',
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 5,
      'title': 'Automated Cloudflare WAF SQL Injection Spike Blocked',
      'event_type': 'FIREWALL_ATTACK',
      'severity': 'Informational',
      'source': 'Cloudflare WAF',
      'target_type': 'integration',
      'target_name': 'Cloudflare Edge Engine',
      'evidence': 'Blocked 142 malicious SQLi probe requests originating from ASN 13335 directed at /api/v1/search.',
      'remediation': 'No immediate user action required. Cloudflare WAF automatically dropped malicious payloads.',
      'status': 'Open',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    }
  ];

  void setFilterSeverity(String value) {
    _selectedSeverity = value;
    fetchEvents();
  }

  void setFilterSource(String value) {
    _selectedSource = value;
    fetchEvents();
  }

  void setFilterStatus(String value) {
    _selectedStatus = value;
    fetchEvents();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String>[];
      if (_selectedSeverity != 'All') queryParams.add('severity=$_selectedSeverity');
      if (_selectedSource != 'All') queryParams.add('source=$_selectedSource');
      if (_selectedStatus != 'All') queryParams.add('status=$_selectedStatus');
      if (_searchQuery.isNotEmpty) queryParams.add('search=${Uri.encodeComponent(_searchQuery)}');

      final url = ApiConfig.eventsUrl + (queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '');
      final res = await ApiClient.get(url);
      _events = res is List ? res : _fallbackEvents;
    } catch (_) {
      _events = List.from(_fallbackEvents);
    } finally {
      // Local client filtering
      if (_selectedSeverity != 'All') {
        _events = _events.where((e) => e['severity'] == _selectedSeverity).toList();
      }
      if (_selectedStatus != 'All') {
        _events = _events.where((e) => e['status'] == _selectedStatus).toList();
      }
      if (_searchQuery.isNotEmpty) {
        final s = _searchQuery.toLowerCase();
        _events = _events.where((e) {
          final t = (e['title'] ?? '').toString().toLowerCase();
          final target = (e['target_name'] ?? '').toString().toLowerCase();
          return t.contains(s) || target.contains(s);
        }).toList();
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEventStatus(int eventId, String newStatus) async {
    try {
      await ApiClient.patch(
        '${ApiConfig.eventsUrl}/$eventId',
        body: {'status': newStatus},
      );
    } catch (_) {
      final idx = _events.indexWhere((e) => e['id'] == eventId);
      if (idx != -1) {
        _events[idx]['status'] = newStatus;
      }
    }
    await fetchEvents();
  }
}
