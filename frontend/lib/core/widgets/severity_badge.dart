import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;
  final bool isCompact;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.isCompact = false,
  });

  Color get _color {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.critical;
      case 'high':
        return AppColors.warning;
      case 'medium':
        return AppColors.neonCyan;
      case 'low':
        return AppColors.low;
      case 'informational':
      case 'info':
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            severity.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
