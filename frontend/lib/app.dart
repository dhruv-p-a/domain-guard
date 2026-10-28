import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/responsive_layout.dart';
import 'core/widgets/sidebar_navigation.dart';

import 'features/authentication/providers/auth_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/github/providers/github_provider.dart';
import 'features/domains/providers/domain_provider.dart';
import 'features/monitoring/providers/monitoring_provider.dart';
import 'features/events/providers/event_provider.dart';
import 'features/integrations/providers/integration_provider.dart';
import 'features/notifications/providers/notification_provider.dart';

import 'features/landing/screens/landing_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/github/screens/github_integration_screen.dart';
import 'features/domains/screens/domain_management_screen.dart';
import 'features/monitoring/screens/monitoring_checks_screen.dart';
import 'features/events/screens/event_timeline_screen.dart';
import 'features/integrations/screens/integrations_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/settings/screens/settings_screen.dart';

class DomainGuardApp extends StatelessWidget {
  const DomainGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => GitHubProvider()),
        ChangeNotifierProvider(create: (_) => DomainProvider()),
        ChangeNotifierProvider(create: (_) => MonitoringProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => IntegrationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'DomainGuard Security Platform',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainAppShell(),
      ),
    );
  }
}

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedNavIndex = 0;
  bool _showLanding = true; // Landing page shown first by default!

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!auth.isAuthenticated) {
      if (_showLanding) {
        return LandingScreen(
          onSignInClicked: () {
            setState(() => _showLanding = false);
          },
        );
      }
      return LoginScreen(
        onBackToHome: () {
          setState(() => _showLanding = true);
        },
      );
    }

    // Main Authenticated Shell Screens
    final screens = <Widget>[
      DashboardScreen(onNavigate: (idx) => setState(() => _selectedNavIndex = idx)),
      const GitHubIntegrationScreen(),
      const DomainManagementScreen(),
      const MonitoringChecksScreen(),
      const EventTimelineScreen(),
      const IntegrationsScreen(),
      const NotificationsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: ResponsiveLayout.isMobile(context)
          ? Drawer(
              child: SidebarNavigation(
                selectedIndex: _selectedNavIndex,
                onItemSelected: (idx) {
                  setState(() => _selectedNavIndex = idx);
                  Navigator.of(context).pop();
                },
                onLogout: () {
                  auth.logout();
                  setState(() => _showLanding = true);
                },
              ),
            )
          : null,
      appBar: ResponsiveLayout.isMobile(context)
          ? AppBar(
              title: const Text('DomainGuard Platform'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () => setState(() => _selectedNavIndex = 6),
                )
              ],
            )
          : null,
      body: ResponsiveLayout(
        desktop: Row(
          children: [
            SidebarNavigation(
              selectedIndex: _selectedNavIndex,
              onItemSelected: (idx) => setState(() => _selectedNavIndex = idx),
              onLogout: () {
                auth.logout();
                setState(() => _showLanding = true);
              },
            ),
            const VerticalDivider(width: 1, color: AppColors.border),
            Expanded(child: screens[_selectedNavIndex]),
          ],
        ),
        mobile: screens[_selectedNavIndex],
      ),
      bottomNavigationBar: ResponsiveLayout.isMobile(context)
          ? BottomNavigationBar(
              currentIndex: _selectedNavIndex > 4 ? 0 : _selectedNavIndex,
              onTap: (idx) => setState(() => _selectedNavIndex = idx),
              backgroundColor: AppColors.surface,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.code_rounded), label: 'Repos'),
                BottomNavigationBarItem(icon: Icon(Icons.language_rounded), label: 'Domains'),
                BottomNavigationBarItem(icon: Icon(Icons.security_rounded), label: 'Scan'),
                BottomNavigationBarItem(icon: Icon(Icons.timeline_rounded), label: 'Events'),
              ],
            )
          : null,
    );
  }
}
