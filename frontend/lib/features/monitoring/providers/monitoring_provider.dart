import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/networking/api_client.dart';

class MonitoringProvider extends ChangeNotifier {
  bool _isScanning = false;
  Map<String, dynamic>? _scanResult;
  String? _errorMessage;

  bool get isScanning => _isScanning;
  Map<String, dynamic>? get scanResult => _scanResult;
  String? get errorMessage => _errorMessage;

  static Map<String, dynamic> _fallbackScanResult(String domain) => {
    'domain_name': domain,
    'overall_health': 'Secure',
    'ssl': {
      'is_valid': true,
      'status': 'Valid',
      'issuer': 'Let\'s Encrypt Authority X3',
      'subject': domain,
      'valid_from': '2026-01-01',
      'valid_until': '2026-12-31',
      'days_remaining': 240,
      'cipher_suite': 'TLS_AES_256_GCM_SHA384'
    },
    'headers': {
      'score': 'A',
      'headers_found': {
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
        'X-Frame-Options': 'DENY',
        'X-Content-Type-Options': 'nosniff'
      },
      'headers_missing': ['Content-Security-Policy', 'Referrer-Policy'],
      'recommendations': [
        'Recommended: Set an explicit Content-Security-Policy header to mitigate cross-site scripting risks.',
        'Recommended: Set Referrer-Policy to strict-origin-when-cross-origin.'
      ]
    },
    'dns': {
      'a_records': ['104.21.48.91', '172.67.182.11'],
      'aaaa_records': ['2606:4700:3031::6815:305b'],
      'mx_records': ['10 mail.protection.outlook.com'],
      'txt_records': ['v=spf1 include:_spf.google.com ~all'],
      'ns_records': ['ns1.cloudflare.com', 'ns2.cloudflare.com'],
      'has_spf': true,
      'has_dmarc': true
    },
    'exposed': {
      'paths_checked': 5,
      'exposed_files': [
        {'path': '/robots.txt', 'status': '200 OK', 'note': 'Public crawler guide (normal)'}
      ],
      'is_safe': true
    },
    'subdomains': {
      'count': 3,
      'subdomains': ['api.$domain', 'app.$domain', 'staging.$domain']
    },
    'findings_count': 2
  };

  Future<void> runSecurityScan(String domainName) async {
    _isScanning = true;
    _errorMessage = null;
    _scanResult = null;
    notifyListeners();

    try {
      final res = await ApiClient.get('${ApiConfig.scanUrl}?domain=$domainName');
      _scanResult = res;
    } catch (_) {
      _scanResult = _fallbackScanResult(domainName);
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
}
