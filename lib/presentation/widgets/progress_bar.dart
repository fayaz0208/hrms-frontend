import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Progress bar widget for displaying usage statistics
class ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final String label;
  final bool showPercentage;

  const ProgressBar({
    super.key,
    required this.current,
    required this.total,
    required this.label,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (current / total * 100).clamp(0, 100) : 0.0;

    // Color based on usage
    Color barColor;
    if (percentage < 50) {
      barColor = AppColors.success;
    } else if (percentage < 80) {
      barColor = AppColors.warning;
    } else {
      barColor = AppColors.danger;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$current / $total${showPercentage ? " (${percentage.toStringAsFixed(0)}%)" : ""}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
