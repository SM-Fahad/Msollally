import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/union_management_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/stats_overview_grid.dart';
import 'package:msollaally/feature/student/campus/campus_union/union_management/stats_role_breakdown.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key, required this.ctrl});

  final UnionManagementController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingStats.value) {
        return Padding(
          padding: EdgeInsets.all(20.width),
          child: Column(
            children: [
              ShimmerLoading.card(height: 120.height, borderRadius: 16.radius),
              SizedBox(height: 24.height),
              ShimmerLoading.card(height: 200.height, borderRadius: 16.radius),
            ],
          ),
        );
      }
      final s = ctrl.stats.value;
      if (s == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 56.fontSize,
                color: Colors.grey[400],
              ),
              SizedBox(height: 12.height),
              Text(
                'No stats available',
                style: TextStyle(fontSize: 16.fontSize, color: Colors.grey[600]),
              ),
              SizedBox(height: 12.height),
              ElevatedButton.icon(
                onPressed: ctrl.fetchStats,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: ctrl.fetchStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatsSectionLabel(
                title: 'Overview',
                icon: Icons.dashboard_outlined,
              ),
              SizedBox(height: 12.height),
              StatsOverviewGrid(stats: s),
              SizedBox(height: 24.height),
              StatsSectionLabel(
                title: 'Members by Role',
                icon: Icons.people_outline,
              ),
              SizedBox(height: 12.height),
              StatsRoleBreakdown(membersByRole: s.membersByRole),
            ],
          ),
        ),
      );
    });
  }
}
