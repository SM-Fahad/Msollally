import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';

class StatsRoleBreakdown extends StatelessWidget {
  const StatsRoleBreakdown({super.key, required this.membersByRole});

  final Map<String, int> membersByRole;

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'president':
        return AppColors.sandyBrownF4B942;
      case 'official':
        return AppColors.primaryButtonColor;
      case 'member':
        return AppColors.mediumSeaGreen27AE60;
      default:
        return Colors.grey;
    }
  }

  IconData _roleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'president':
        return Icons.star;
      case 'official':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (membersByRole.isEmpty) {
      return Center(
        child: Text(
          'No role data',
          style: TextStyle(fontSize: 13.fontSize, color: Colors.grey[400]),
        ),
      );
    }
    final total = membersByRole.values.fold(0, (sum, v) => sum + v);
    return Column(
      children: membersByRole.entries.map((entry) {
        final role = entry.key;
        final count = entry.value;
        final fraction = total > 0 ? count / total : 0.0;
        final color = _roleColor(role);
        return Container(
          margin: EdgeInsets.only(bottom: 12.height),
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 14.height),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_roleIcon(role), color: color, size: 18.fontSize),
                  SizedBox(width: 8.width),
                  Text(
                    role[0].toUpperCase() + role.substring(1),
                    style: TextStyle(
                      fontSize: 14.fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black1A1A2E,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 18.fontSize,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.height),
              ClipRRect(
                borderRadius: BorderRadius.circular(6.radius),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6.height,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              SizedBox(height: 4.height),
              Text(
                '${(fraction * 100).toStringAsFixed(0)}% of total',
                style: TextStyle(fontSize: 11.fontSize, color: Colors.grey[400]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class StatsSectionLabel extends StatelessWidget {
  const StatsSectionLabel({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.fontSize, color: AppColors.primaryButtonColor),
        SizedBox(width: 8.width),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.black1A1A2E,
          ),
        ),
      ],
    );
  }
}
