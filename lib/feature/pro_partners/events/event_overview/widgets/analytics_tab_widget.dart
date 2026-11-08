import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import '../controller/event_overview_controller.dart';

class AnalyticsTabWidget extends StatelessWidget {
  final String controllerTag;

  const AnalyticsTabWidget({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventOverviewController>(tag: controllerTag);

    return Padding(
      padding: EdgeInsets.all(16),
      child: Obx(() {
        if (controller.isAnalyticsLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.analyticsError.value.isNotEmpty) {
          return _AnalyticsErrorState(
            message: controller.analyticsError.value,
            onRetry: controller.fetchAnalytics,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAnalytics,
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              Row(
                children: [
                  _AnalyticsStatCard(
                    label: 'Views',
                    value: controller.views.toString(),
                    icon: Icons.remove_red_eye_outlined,
                    color: AppColors.primaryButtonColor,
                  ),
                  SizedBox(width: 10),
                  _AnalyticsStatCard(
                    label: 'RSVPs',
                    value: controller.rsvps.toString(),
                    icon: Icons.person_add_alt_1_outlined,
                    color: AppColors.mediumSeaGreen22B573,
                  ),
                  SizedBox(width: 10),
                  _AnalyticsStatCard(
                    label: 'Shares',
                    value: controller.shares.toString(),
                    icon: Icons.share_outlined,
                    color: AppColors.sandyBrownFF9F43,
                  ),
                ],
              ),

              SizedBox(height: 16),

              _ConversionCard(conversion: controller.conversion.value),
            ],
          ),
        );
      }),
    );
  }
}

class _AnalyticsStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.lavenderEAEAEA),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: .12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),

            SizedBox(height: 12),

            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.darkSlateGray1F2937,
              ),
            ),

            SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray7B7B7B,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversionCard extends StatelessWidget {
  final double conversion;

  const _ConversionCard({required this.conversion});

  @override
  Widget build(BuildContext context) {
    final progress = (conversion / 100).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.ghostWhiteF5F9FF, AppColors.aliceBlueEAF2FF],
        ),
        border: Border.all(color: AppColors.lavenderDCE8FF),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryButtonColor, AppColors.royalBlue2563EB],
              ),
            ),
            child: Icon(Icons.trending_up, color: Colors.white, size: 24),
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversion Rate',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  '${conversion.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTextColor,
                  ),
                ),

                SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.lavenderDCE8FF,
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryButtonColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AnalyticsErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.whiteSmokeECECEC),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.linenFFEAEA,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColors.tomatoFF5D5D,
                size: 30,
              ),
            ),

            SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.secondaryTextColor),
            ),

            SizedBox(height: 14),

            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
