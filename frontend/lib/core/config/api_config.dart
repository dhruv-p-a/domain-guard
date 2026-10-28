class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  static const String loginUrl = '$baseUrl/auth/github/login';
  static const String callbackUrl = '$baseUrl/auth/github/callback';
  static const String demoLoginUrl = '$baseUrl/auth/demo-login';
  static const String meUrl = '$baseUrl/auth/me';
  
  static const String dashboardSummaryUrl = '$baseUrl/dashboard/summary';
  static const String repositoriesUrl = '$baseUrl/github/repositories';
  static const String domainsUrl = '$baseUrl/domains';
  static const String scanUrl = '$baseUrl/monitoring/scan';
  static const String eventsUrl = '$baseUrl/events';
  static const String integrationsUrl = '$baseUrl/integrations';
  static const String notificationsUrl = '$baseUrl/notifications';
  static const String settingsUrl = '$baseUrl/settings';
}
