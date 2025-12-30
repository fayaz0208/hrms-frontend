import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Info card widget for grouping related information
class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const InfoCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Info row widget for key-value pairs
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Widget? valueWidget;

  const InfoRow({
    super.key,
    required this.label,
    String? value,
    this.icon,
    this.valueWidget,
  }) : value = value ?? '-';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child:
                valueWidget ??
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
