import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const LoginScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: onBackToHome != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: onBackToHome,
                tooltip: 'Back to Landing Page',
              )
            : null,
        title: onBackToHome != null
            ? TextButton.icon(
                onPressed: onBackToHome,
                icon: const Icon(Icons.home_outlined, size: 18, color: AppColors.textSecondary),
                label: const Text('Back to Home', style: TextStyle(color: AppColors.textSecondary)),
              )
            : null,
      ),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sign In to DomainGuard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect your GitHub organization to manage website security monitoring.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),

              if (authProvider.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.critical.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.critical.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.critical, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: AppColors.critical, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                )
              ],

              ElevatedButton.icon(
                onPressed: authProvider.isLoading
                    ? null
                    : () {
                        authProvider.loginDemo();
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.code_rounded),
                label: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Continue with GitHub OAuth'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: authProvider.isLoading
                    ? null
                    : () {
                        authProvider.loginDemo();
                      },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.flash_on_rounded, color: AppColors.warning),
                label: const Text('Enter SecOps Demo Mode'),
              ),
              const SizedBox(height: 24),
              const Text(
                'By signing in, you authorize DomainGuard to perform non-destructive, least-privilege security checks on connected assets.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              )
            ],
          ),
        ),
      ),
    );
  }
}
