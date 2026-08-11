import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusBadge.stage(String stage) {
    Color color;
    switch (stage.toUpperCase()) {
      case 'NEW':
        color = AppColors.stageNew;
        break;
      case 'QUALIFIED':
        color = AppColors.stageQualified;
        break;
      case 'CONTACTED':
        color = AppColors.stageContacted;
        break;
      case 'ENGAGED':
        color = AppColors.stageEngaged;
        break;
      case 'DEMO_BOOKED':
      case 'DEMO BOOKED':
        color = AppColors.stageDemoBooked;
        break;
      case 'DEMO_COMPLETED':
      case 'DEMO COMPLETED':
        color = AppColors.stageDemoCompleted;
        break;
      case 'TRIAL':
      case 'TRIAL_ACTIVE':
        color = AppColors.stageTrial;
        break;
      case 'NEGOTIATION':
        color = AppColors.stageNegotiation;
        break;
      case 'WON':
      case 'CONVERTED':
        color = AppColors.stageWon;
        break;
      case 'LOST':
        color = AppColors.stageLost;
        break;
      default:
        color = AppColors.textMuted;
    }
    return StatusBadge(label: stage.replaceAll('_', ' '), color: color);
  }

  factory StatusBadge.priority(String priority) {
    Color color;
    IconData? icon;
    switch (priority.toUpperCase()) {
      case 'HOT':
      case 'HIGH':
        color = AppColors.danger;
        icon = Icons.local_fire_department;
        break;
      case 'WARM':
      case 'MEDIUM':
        color = AppColors.warning;
        icon = Icons.bolt;
        break;
      case 'COLD':
      case 'LOW':
        color = AppColors.info;
        icon = Icons.ac_unit;
        break;
      default:
        color = AppColors.textMuted;
    }
    return StatusBadge(label: priority.toUpperCase(), color: color, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
