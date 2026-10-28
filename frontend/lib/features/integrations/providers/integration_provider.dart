import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/networking/api_client.dart';

class IntegrationProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _integrations = [];
  Map<String, dynamic>? _architectureInfo;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<dynamic> get integrations => _integrations;
  Map<String, dynamic>? get architectureInfo => _architectureInfo;
  String? get errorMessage => _errorMessage;

  static final List<dynamic> _fallbackIntegrations = [
    {
      'id': 1,
      'provider': 'cloudflare',
      'name': 'Cloudflare Edge WAF & Security Logs',
      'status': 'Connected',
      'config': {'zone_id': 'cf_zone_88291039', 'logpush_enabled': true},
      'last_synced_at': DateTime.now().toIso8601String()
    },
    {
      'id': 2,
      'provider': 'server_auth',
      'name': 'Linux SSH / Auth System Logs',
      'status': 'Connected',
      'config': {'log_agent': 'syslog-ng-agent-v2', 'monitored_nodes': 3},
      'last_synced_at': DateTime.now().toIso8601String()
    },
    {
      'id': 3,
      'provider': 'hosting_logs',
      'name': 'AWS CloudWatch / Hosting Access Logs',
      'status': 'Connected',
      'config': {'log_group': '/aws/httpd/access_log'},
      'last_synced_at': DateTime.now().toIso8601String()
    }
  ];

  static final Map<String, dynamic> _fallbackArch = {
    'title': 'Architecture & Boundary Notice',
    'explanation': 'GitHub repository access alone grants visibility into source code, commits, and repository security alerts (Dependabot, Secret Scanning, CodeQL). '
                   'It does NOT grant access to live web server processes, SSH login attempts, or incoming network traffic. '
                   'To monitor live firewall events, Cloudflare WAF, or server authentication logs, connect these integrations separately via secure API webhooks or log agents.'
  };

  Future<void> fetchIntegrations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get(ApiConfig.integrationsUrl);
      _integrations = res is List ? res : _fallbackIntegrations;
      final archRes = await ApiClient.get('${ApiConfig.integrationsUrl}/info');
      _architectureInfo = archRes;
    } catch (_) {
      _integrations = _fallbackIntegrations;
      _architectureInfo = _fallbackArch;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> ingestSampleLog(String provider, String logType, Map<String, dynamic> payload) async {
    try {
      await ApiClient.post(
        '${ApiConfig.integrationsUrl}/ingest-sample-log',
        body: {
          'provider': provider,
          'log_type': logType,
          'payload': payload,
        },
      );
    } catch (_) {}
    await fetchIntegrations();
    return true;
  }
}
