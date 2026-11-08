// lib/ui/pro_partners_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/pro_partners/widgets/default_pro_partners_app_bar.dart';
import 'package:msollaally/feature/navbar/controller/navbar_controller.dart';
import 'package:msollaally/feature/navbar/model/navbar_item.dart';

import '../../../../routes/app_route.dart';
import '../controller/pro_partners_dashboard_controller.dart';
import '../widgets/action_buttons_row_widget.dart';
import '../widgets/chart_card_widget.dart';

class ProPartnersDashboardScreen extends StatelessWidget {
  const ProPartnersDashboardScreen({super.key});

  void _changeTab(int index) {
    if (Get.isRegistered<NavbarController>(tag: UserProfile.proPartners.name)) {
      Get.find<NavbarController>(tag: UserProfile.proPartners.name).changeTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProPartnersDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Obx(() {
          final me = controller.me.value;
          final displayName = me?.profile?.fullName?.trim().isNotEmpty == true
              ? me!.profile!.fullName!
              : (me?.username ?? 'Pro Partner');
          return DefaultProPartnersAppBar(
            isHomePage: true,
            subtitle: displayName,
            title: 'Welcome Back',
            profileImageUrl: me?.profile?.profilePicture,
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDashboard,
          color: AppColors.primaryButtonColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // — Hero Engagement Banner —
                Obx(() => _HeroBanner(
                  engagementRate: controller.overallEngagementRate.value,
                  errorMessage: controller.errorMessage.value,
                )),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      // — Quick Actions —
                      _SectionHeader(title: 'Quick Actions', icon: Icons.bolt_rounded),
                      SizedBox(height: 12.h),
                      const ProPartnersActionButtonsWidget(),
                      SizedBox(height: 24.h),

                      // — Chart —
                      _SectionHeader(title: 'Impressions vs Reach', icon: Icons.bar_chart_rounded),
                      SizedBox(height: 12.h),
                      _ChartCard(controller: controller),
                      SizedBox(height: 24.h),

                      // — Key Metrics —
                      _SectionHeader(title: 'Key Metrics', icon: Icons.insights_rounded),
                      SizedBox(height: 12.h),

                      // Top Campaign Card
                      Obx(() => _MetricCard(
                        title: 'Top Campaign',
                        value: controller.topCampaignClicks.value.toString(),
                        subtitle: controller.topCampaignTitle.value.isEmpty
                            ? 'No top campaign yet'
                            : 'Clicks on "${controller.topCampaignTitle.value}"',
                        trailing: '${controller.topCampaignCtr.value} CTR  •  ${controller.topCampaignImpressions.value} impressions',
                        icon: Icons.campaign_rounded,
                        iconColor: const Color(0xFF418AFF),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEFF5FF), Color(0xFFF5F9FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => _changeTab(1),
                      )),
                      SizedBox(height: 12.h),

                      // Job Applications Card
                      Obx(() => _MetricCard(
                        title: 'Job Applications',
                        value: controller.jobApplicationsLast7Days.value.toString(),
                        subtitle: 'New applications (last 7 days)',
                        trailing: 'Live from your dashboard stats',
                        icon: Icons.work_rounded,
                        iconColor: const Color(0xFF6C63FF),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF2F0FF), Color(0xFFF8F7FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => _changeTab(3),
                      )),
                      SizedBox(height: 12.h),

                      // Event Performance Card
                      Obx(() => _EventMetricCard(
                        title: 'Event Performance',
                        value: controller.eventTotalJoined.value.toString(),
                        subtitle: controller.eventSummary.value.isEmpty
                            ? 'No event performance data'
                            : controller.eventSummary.value,
                        progress: controller.eventProgress,
                        conversionRate: controller.eventConversionRate.value,
                        onTap: () => _changeTab(2),
                      )),
                      SizedBox(height: 12.h),

                      // New Messages Card
                      Obx(() => _MetricCard(
                        title: 'New Messages',
                        value: (controller.unreadMessages.value > 0
                                ? controller.unreadMessages.value
                                : controller.newMessages.value)
                            .toString(),
                        subtitle: controller.newMessagesSummary.value.isEmpty
                            ? 'No unread messages'
                            : controller.newMessagesSummary.value,
                        trailing: controller.unreadMessages.value > 0
                            ? '${controller.unreadMessages.value} unread'
                            : (controller.newMessages.value > 0
                                ? '${controller.newMessages.value} new today'
                                : 'Up to date'),
                        icon: Icons.mark_chat_unread_rounded,
                        iconColor: const Color(0xFF00B894),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEAFBF5), Color(0xFFF4FDF9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () async {
                          await Get.toNamed(AppRoute.proPartnersInbox);
                          controller.fetchDashboard();
                        },
                      )),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Hero Banner ────────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final String engagementRate;
  final String? errorMessage;

  const _HeroBanner({required this.engagementRate, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF418AFF), Color(0xFF3056C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -20,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (errorMessage != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.white, fontSize: 11.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                Text(
                  'Overall Engagement Rate',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      engagementRate,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up_rounded, color: Colors.white, size: 13),
                            SizedBox(width: 3.w),
                            Text(
                              'Live',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primaryButtonColor, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF1A1A2E),
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ── Chart Card ─────────────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final ProPartnersDashboardController controller;

  const _ChartCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: ProPartnersChartCardWidget(getChartData: controller.chartDataList),
      ),
    );
  }
}

// ── Metric Card ────────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final Color iconColor;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trailing,
    required this.icon,
    required this.iconColor,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: iconColor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: iconColor, size: 22.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value,
                      style: TextStyle(
                        color: const Color(0xFF1A1A2E),
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        trailing,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: iconColor.withValues(alpha: 0.5),
                  size: 14.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Event Metric Card with Progress ───────────────────────────────────────────
class _EventMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double progress;
  final String conversionRate;
  final VoidCallback? onTap;

  const _EventMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.conversionRate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xFFFF7043);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF5F2), Color(0xFFFFFAF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: iconColor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: const Icon(Icons.event_rounded, color: iconColor, size: 22),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          value,
                          style: TextStyle(
                            color: const Color(0xFF1A1A2E),
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFFF7043),
                    size: 14,
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(99.r),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 7.h,
                  backgroundColor: iconColor.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(iconColor),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  const Icon(Icons.sync_alt_rounded, color: iconColor, size: 13),
                  SizedBox(width: 4.w),
                  Text(
                    '$conversionRate conversion rate',
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
