import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/feature/student/campus/campus_union/model/union_management_models.dart';

class StatsOverviewGrid extends StatelessWidget {
  const StatsOverviewGrid({super.key, required this.stats});

  final UnionStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Members',
            value: stats.totalMembers,
            icon: Icons.group,
            color: AppColors.primaryButtonColor,
          ),
        ),
        SizedBox(width: 12.width),
        Expanded(
          child: _StatCard(
            label: 'Officials',
            value: stats.totalOfficials,
            icon: Icons.admin_panel_settings,
            color: AppColors.mediumPurple9B59B6,
          ),
        ),
        SizedBox(width: 12.width),
        Expanded(
          child: _StatCard(
            label: 'Pending',
            value: stats.pendingRequests,
            icon: Icons.hourglass_empty,
            color: stats.pendingRequests > 0 ? Colors.orange : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.radius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22.fontSize),
          SizedBox(height: 6.height),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22.fontSize,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 2.height),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.fontSize,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
