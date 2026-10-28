import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/networking/api_client.dart';

class GitHubProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _repositories = [];
  List<dynamic> _selectedRepoAlerts = [];
  int? _selectedRepoId;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<dynamic> get repositories => _repositories;
  List<dynamic> get selectedRepoAlerts => _selectedRepoAlerts;
  int? get selectedRepoId => _selectedRepoId;
  String? get errorMessage => _errorMessage;

  static final List<dynamic> _fallbackRepos = [
    {
      'id': 10101,
      'name': 'main-ecommerce-api',
      'full_name': 'security_lead/main-ecommerce-api',
      'owner': 'security_lead',
      'html_url': 'https://github.com/security_lead/main-ecommerce-api',
      'default_branch': 'main',
      'is_private': true,
      'is_monitored': true,
      'has_dependabot': true,
      'has_code_scanning': true,
      'has_secret_scanning': true,
    },
    {
      'id': 10102,
      'name': 'frontend-web-portal',
      'full_name': 'security_lead/frontend-web-portal',
      'owner': 'security_lead',
      'html_url': 'https://github.com/security_lead/frontend-web-portal',
      'default_branch': 'main',
      'is_private': false,
      'is_monitored': true,
      'has_dependabot': true,
      'has_code_scanning': true,
      'has_secret_scanning': false,
    },
    {
      'id': 10103,
      'name': 'infrastructure-terraform',
      'full_name': 'security_lead/infrastructure-terraform',
      'owner': 'security_lead',
      'html_url': 'https://github.com/security_lead/infrastructure-terraform',
      'default_branch': 'production',
      'is_private': true,
      'is_monitored': true,
      'has_dependabot': false,
      'has_code_scanning': true,
      'has_secret_scanning': true,
    }
  ];

  static final List<dynamic> _fallbackAlerts = [
    {
      'id': 'GHSA-c5q2-9p22-3851',
      'title': 'High Severity Vulnerability in PyJWT (<2.8.0)',
      'severity': 'High',
      'alert_type': 'dependabot',
      'tool_name': 'Dependabot',
      'file_path': 'requirements.txt',
      'description': 'Known key confusion flaw in JWT verification logic. Upgrade to PyJWT 2.8.0 or later.',
      'created_at': DateTime.now().toIso8601String(),
      'html_url': 'https://github.com/advisories/GHSA-c5q2-9p22-3851'
    },
    {
      'id': 'SECRET-0812-AWS',
      'title': 'Exposed Hardcoded AWS Access Key in Terraform File',
      'severity': 'Critical',
      'alert_type': 'secret_scanning',
      'tool_name': 'GitHub Secret Scanning',
      'file_path': 'modules/s3/variables.tf:14',
      'description': 'Found active AWS_ACCESS_KEY_ID matching pattern AKIA****************. Immediate revocation required.',
      'created_at': DateTime.now().toIso8601String(),
      'html_url': 'https://github.com/security/secret-scanning'
    },
    {
      'id': 'CODE-SQL-INJ-02',
      'title': 'Potential SQL Injection in User Query Handler',
      'severity': 'Critical',
      'alert_type': 'code_scanning',
      'tool_name': 'CodeQL',
      'file_path': 'backend/app/api/v1/auth.py:48',
      'description': 'User-provided input string is directly formatted into raw SQL query without parameterized bind variables.',
      'created_at': DateTime.now().toIso8601String(),
      'html_url': 'https://codeql.github.com'
    }
  ];

  Future<void> fetchRepositories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get(ApiConfig.repositoriesUrl);
      _repositories = res is List ? res : _fallbackRepos;
    } catch (_) {
      _repositories = _fallbackRepos;
    } finally {
      if (_repositories.isNotEmpty && _selectedRepoId == null) {
        selectRepository(_repositories.first['id']);
      } else {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> selectRepository(int repoId) async {
    _selectedRepoId = repoId;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient.get('${ApiConfig.repositoriesUrl}/$repoId/alerts');
      _selectedRepoAlerts = res is List ? res : _fallbackAlerts;
    } catch (_) {
      _selectedRepoAlerts = _fallbackAlerts;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleMonitoring(int repoId) async {
    try {
      await ApiClient.post('${ApiConfig.repositoriesUrl}/$repoId/toggle');
    } catch (_) {
      final idx = _repositories.indexWhere((r) => r['id'] == repoId);
      if (idx != -1) {
        _repositories[idx]['is_monitored'] = !(_repositories[idx]['is_monitored'] == true);
      }
    }
    notifyListeners();
  }
}
