import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/campaign_stats_controller.dart';
import 'stats_metric_card.dart';
import 'stats_section_card.dart';
import 'stats_states.dart';

class StatsTabWidget extends StatelessWidget {
  final int campaignId;

  const StatsTabWidget({super.key, required this.campaignId});

  String _currency(String value) {
    final amount = double.tryParse(value) ?? 0;
    return 'TZS ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
  }

  String _date(DateTime? value) {
    if (value == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(value.toLocal());
  }

  String _majorLabel(String raw) {
    return raw
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CampaignStatsController>(
      tag: 'campaign-stats-$campaignId',
    );
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Obx(() {
      if (controller.isLoading.value) {
        return StatsLoadingState();
      }

      if (controller.errorMessage.value != null) {
        return StatsErrorState(
          message: controller.errorMessage.value!,
          onRetry: controller.fetchStats,
        );
      }

      final stats = controller.stats.value;
      if (stats == null) {
        return SizedBox.shrink();
      }

      final metrics = [
        StatsMetricItem(
          value: stats.impressions.toString(),
          label: 'Impressions',
          icon: Icons.remove_red_eye_outlined,
          color: AppColors.primaryButtonColor,
        ),
        StatsMetricItem(
          value: stats.clicks.toString(),
          label: 'Clicks',
          icon: Icons.touch_app_outlined,
          color: AppColors.mediumSeaGreen22B573,
        ),
        StatsMetricItem(
          value: '${stats.ctr.toStringAsFixed(1)}%',
          label: 'CTR',
          icon: Icons.insights_outlined,
          color: AppColors.sandyBrownFF9F43,
        ),
        StatsMetricItem(
          value: _currency(stats.spentBudget),
          label: 'Spent',
          icon: Icons.payments_outlined,
          color: AppColors.mediumPurple8B5CF6,
        ),
      ];

      return ListView(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h + bottomPad),
        children: [
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.55,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              return StatsMetricCard(item: metrics[index]);
            },
          ),
          SizedBox(height: 16.h),
          StatsSummaryCard(
            status: stats.status,
            totalBudget: _currency(stats.totalBudget),
            remainingBudget: 'TZS ${stats.remainingBudget.toStringAsFixed(0)}',
            startDate: _date(stats.startDate),
            endDate: _date(stats.endDate),
          ),
          SizedBox(height: 14.h),
          StatsAudienceCard(
            items: stats.majorPercentages
                .map(
                  (item) => StatsDemoItem(
                    label: _majorLabel(item.major),
                    fraction: (item.percentage / 100).clamp(0.0, 1.0),
                  ),
                )
                .toList(),
          ),
        ],
      );
    });
  }
}
