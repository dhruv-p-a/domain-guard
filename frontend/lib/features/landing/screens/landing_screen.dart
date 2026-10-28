import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../authentication/providers/auth_provider.dart';
import '../widgets/pricing_card.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback onSignInClicked;

  const LandingScreen({super.key, required this.onSignInClicked});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _testDomainController = TextEditingController(text: 'api.domainguard.io');
  bool _isTestingScan = false;
  Map<String, dynamic>? _testScanResult;

  // GlobalKeys for smooth section auto-scrolling
  final _scannerKey = GlobalKey();
  final _techKey = GlobalKey();
  final _architectureKey = GlobalKey();
  final _pricingKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _runQuickTestScan() async {
    setState(() {
      _isTestingScan = true;
      _testScanResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isTestingScan = false;
        _testScanResult = {
          'domain': _testDomainController.text.trim(),
          'ssl_valid': true,
          'ssl_issuer': 'Let\'s Encrypt Authority X3',
          'days_remaining': 240,
          'header_score': 'A',
          'spf_status': 'Pass',
          'dmarc_status': 'Pass',
          'findings': 2
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 1000;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Navigation Bar (Fully Interactive & Responsive)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 20 : 40,
                vertical: 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 16,
                children: [
                  // Brand Logo with Futuristic Orbitron Font & Glow
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.neonCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCyan.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: const Icon(Icons.shield_rounded, color: AppColors.neonCyan, size: 26),
                      ),
                      const SizedBox(width: 14),
                      _gradientText(
                        'DOMAINGUARD',
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.neonCyan,
                            AppColors.neonPink,
                            AppColors.neonPurple,
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Menu Items (Interactive Section Scroll Triggers)
                  if (!isCompact)
                    Wrap(
                      spacing: 24,
                      children: [
                        _navMenuItem('EXPLORE', () => _scrollToSection(_scannerKey)),
                        _navMenuItem('TECHNOLOGY', () => _scrollToSection(_techKey)),
                        _navMenuItem('ARCHITECTURE', () => _scrollToSection(_architectureKey)),
                        _navMenuItem('PRICING', () => _scrollToSection(_pricingKey)),
                      ],
                    ),

                  // Right CTA Actions
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          context.read<AuthProvider>().loginDemo();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.warning, width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        icon: const Icon(Icons.flash_on_rounded, color: AppColors.warning, size: 18),
                        label: Text(
                          'SECOPS DEMO',
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: widget.onSignInClicked,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonCyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          elevation: 8,
                          shadowColor: AppColors.neonCyan.withValues(alpha: 0.5),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                        label: Text(
                          'GET STARTED',
                          style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Futuristic Blended Multi-Color Neon Hero Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 24 : 50,
                vertical: isCompact ? 50 : 90,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.6, -0.3),
                  radius: 1.2,
                  colors: [
                    AppColors.neonPink.withValues(alpha: 0.15),
                    AppColors.neonPurple.withValues(alpha: 0.12),
                    AppColors.background,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle kicker
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.neonCyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'A SECURE TOMORROW',
                          style: GoogleFonts.orbitron(
                            color: AppColors.neonCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Giant Multi-Color Blended Neon Headline (DOMAIN GUARD)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      children: [
                        // Soft Ambient Aura Glow Layer Behind Text
                        Text(
                          'DOMAIN\nGUARD',
                          style: GoogleFonts.orbitron(
                            fontSize: isCompact ? 68 : 96,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            height: 0.95,
                            color: AppColors.neonCyan.withValues(alpha: 0.7),
                            shadows: [
                              Shadow(
                                color: AppColors.neonCyan.withValues(alpha: 0.8),
                                blurRadius: 40,
                              ),
                              Shadow(
                                color: AppColors.neonPink.withValues(alpha: 0.8),
                                blurRadius: 60,
                              ),
                              Shadow(
                                color: AppColors.neonPurple.withValues(alpha: 0.8),
                                blurRadius: 90,
                              ),
                            ],
                          ),
                        ),
                        // Foreground Multi-Color Gradient Shader
                        _gradientText(
                          'DOMAIN\nGUARD',
                          style: GoogleFonts.orbitron(
                            fontSize: isCompact ? 68 : 96,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            height: 0.95,
                          ),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00F0FF), // Neon Cyan
                              Color(0xFF3B82F6), // Electric Blue
                              Color(0xFFFF007A), // Hot Magenta Pink
                              Color(0xFFA855F7), // Neon Purple
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tagline with Blended Colors (Responsive Wrap)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'WHERE VULNERABILITY MEETS ',
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      _gradientText(
                        'INTELLIGENCE',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.neonPink,
                            AppColors.neonPurple,
                            AppColors.neonCyan,
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: Text(
                      'DomainGuard connects to your authorized GitHub repositories, DNS configuration, and cloud firewalls to continuously monitor security events, exposed secrets, dependency vulnerabilities, and SSL expiration in a unified real-time dashboard.',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Action Buttons with Responsive Wrap
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      InkWell(
                        onTap: () => _scrollToSection(_scannerKey),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.6), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: 0.25),
                                blurRadius: 20,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.neonCyan,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'EXPLORE THE FUTURE',
                                style: GoogleFonts.orbitron(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          context.read<AuthProvider>().loginDemo();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        ),
                        icon: const Icon(Icons.play_circle_outline_rounded, color: AppColors.neonPink),
                        label: Text(
                          'ENTER DEMO PLATFORM',
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Live Interactive Scanner Preview Box
            Container(
              key: _scannerKey,
              margin: EdgeInsets.symmetric(
                horizontal: isCompact ? 20 : 40,
                vertical: 20,
              ),
              padding: EdgeInsets.all(isCompact ? 20 : 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.08),
                    blurRadius: 30,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.radar_rounded, color: AppColors.neonCyan, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIVE PASSIVE DOMAIN SCANNER PREVIEW',
                              style: GoogleFonts.orbitron(
                                color: AppColors.neonCyan,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Test a non-destructive SSL and Security Header check before logging in.',
                              style: GoogleFonts.spaceGrotesk(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: isCompact ? double.infinity : 480,
                        child: TextField(
                          controller: _testDomainController,
                          style: GoogleFonts.firaCode(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Domain Target',
                            hintText: 'e.g. api.domainguard.io',
                            prefixIcon: Icon(Icons.link_rounded, color: AppColors.neonCyan),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isTestingScan ? null : _runQuickTestScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonCyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                        ),
                        icon: const Icon(Icons.search_rounded, color: Colors.black),
                        label: _isTestingScan
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : Text('RUN PREVIEW AUDIT', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14)),
                      ),
                    ],
                  ),
                  if (_testScanResult != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Audit Result for ${_testScanResult!['domain']}',
                                style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'SSL: ${_testScanResult!['ssl_issuer']} (${_testScanResult!['days_remaining']} days remaining) • Headers Score: ${_testScanResult!['header_score']}',
                                style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: widget.onSignInClicked,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPink),
                            child: Text('Claim Domain & Monitor 24/7', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, letterSpacing: 1)),
                          )
                        ],
                      ),
                    )
                  ]
                ],
              ),
            ),

            // Technology Features Grid
            Container(
              key: _techKey,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 20 : 40,
                vertical: 80,
              ),
              color: AppColors.surface,
              child: Column(
                children: [
                  Text(
                    'SECURITY ARCHITECTURE',
                    style: GoogleFonts.orbitron(
                      color: AppColors.neonCyan,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Built for Engineering & SecOps Teams',
                    style: GoogleFonts.orbitron(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildTechCard(
                        '01',
                        'GITHUB APP INTEGRATION',
                        'Deep Webhook listener for Dependabot advisories, CodeQL static code analysis, and real-time secret leak detection.',
                        AppColors.neonCyan,
                        Icons.code_rounded,
                      ),
                      _buildTechCard(
                        '02',
                        'DNS TXT VERIFICATION',
                        'Enforces cryptographic proof of ownership before allowing security audits, ensuring zero unauthorized domain scanning.',
                        AppColors.neonPink,
                        Icons.verified_user_outlined,
                      ),
                      _buildTechCard(
                        '03',
                        'CORRELATED TIMELINE',
                        'Unifies security findings from GitHub, Cloudflare WAF, and server logs into a single prioritized incident timeline.',
                        AppColors.neonPurple,
                        Icons.timeline_rounded,
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Architecture Deep-Dive Section
            Container(
              key: _architectureKey,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 20 : 40,
                vertical: 80,
              ),
              child: Column(
                children: [
                  Text(
                    'PLATFORM CAPABILITIES',
                    style: GoogleFonts.orbitron(
                      color: AppColors.neonPink,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Non-Destructive & Least-Privilege Protection',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _capabilityRow(
                            'Least-Privilege Repo Scope',
                            'DomainGuard only requests read access to webhook alerts and configuration files—never modifying your source code repository.',
                          ),
                          const Divider(height: 32),
                          _capabilityRow(
                            'DNS Ownership Challenge',
                            'Automated DNS TXT token challenge prevents unauthorized scanning of arbitrary third-party domains.',
                          ),
                          const Divider(height: 32),
                          _capabilityRow(
                            'HMAC SHA256 Webhook Verification',
                            'All incoming GitHub & Cloudflare payloads are cryptographically signed and verified before event normalization.',
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Pricing Section
            Container(
              key: _pricingKey,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 20 : 40,
                vertical: 80,
              ),
              color: AppColors.surface,
              child: Column(
                children: [
                  Text(
                    'PLANS & PRICING',
                    style: GoogleFonts.orbitron(
                      color: AppColors.neonPink,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Simple, Transparent SecOps Subscriptions',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      PricingCard(
                        title: 'Developer',
                        price: '\$0',
                        period: '/month',
                        features: const [
                          '1 Monitored Domain',
                          'Up to 3 GitHub Repositories',
                          'Passive SSL & DNS Checks',
                          'In-App Security Alerts',
                          'Community Support'
                        ],
                        onSelect: widget.onSignInClicked,
                      ),
                      PricingCard(
                        title: 'Pro SecOps',
                        price: '\$49',
                        period: '/month',
                        isPopular: true,
                        features: const [
                          '10 Monitored Domains',
                          'Unlimited GitHub Repositories',
                          'Automated Dependabot & CodeQL Sync',
                          'Cloudflare WAF Integration',
                          'Hourly Monitoring & Email Alerts',
                          'Priority Support'
                        ],
                        onSelect: widget.onSignInClicked,
                      ),
                      PricingCard(
                        title: 'Enterprise',
                        price: '\$199',
                        period: '/month',
                        features: const [
                          'Unlimited Monitored Domains',
                          'Custom Server SSH Log Agents',
                          'Custom Webhook Integrations',
                          'Dedicated Audit Log Retention',
                          '24/7 Incident Response SLA'
                        ],
                        onSelect: widget.onSignInClicked,
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 20 : 40,
                vertical: 32,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 12,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, color: AppColors.neonCyan, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'DOMAIN GUARD © 2026 — ALL RIGHTS RESERVED',
                        style: GoogleFonts.orbitron(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1),
                      ),
                    ],
                  ),
                  Text(
                    'Responsible Notice: DomainGuard performs non-destructive, authorized passive security audits.',
                    style: GoogleFonts.spaceGrotesk(color: AppColors.textMuted, fontSize: 12),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _capabilityRow(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.neonCyan, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.orbitron(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _gradientText(String text, {required TextStyle style, required Gradient gradient}) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }

  Widget _navMenuItem(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildTechCard(String num, String title, String desc, Color accentColor, IconData icon) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              Text(
                num,
                style: GoogleFonts.orbitron(
                  color: accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.orbitron(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
