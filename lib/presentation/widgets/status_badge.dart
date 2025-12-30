import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Status badge widget for displaying active/inactive/trial states
class StatusBadge extends StatelessWidget {
  final String status;
  final bool rounded;
  final bool isActive; // For backward compatibility

  const StatusBadge({
    super.key,
    String? status,
    this.rounded = true,
    this.isActive = true,
  }) : status = status ?? (isActive ? 'Active' : 'Inactive');

  @override
  Widget build(BuildContext context) {
    final statusLower = status.toLowerCase();
    final isActiveStatus = statusLower == 'active';
    final isTrial = statusLower == 'trial';

    Color bgColor;
    Color textColor;

    if (isActiveStatus) {
      bgColor = AppColors.successLight;
      textColor = AppColors.success;
    } else if (isTrial) {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warning;
    } else {
      bgColor = AppColors.dangerLight;
      textColor = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(rounded ? 20 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
