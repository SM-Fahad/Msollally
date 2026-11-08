import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

import '../../details/controller/fusra_details_controller.dart';
import '../widgets/analytics_stat_card.dart';
import '../widgets/top_school_card.dart';
import '../widgets/weekly_winner_card.dart';

class AnalyticsScreen extends GetView<FusraDetailsController> {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = controller.competitionId.value;

    return Obx(() {
      final initialLoading =
          controller.isLoading.value &&
          controller.statsData.isEmpty &&
          controller.prizes.isEmpty &&
          controller.topSchools.isEmpty;

      if (initialLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.statsData.isEmpty &&
          controller.prizes.isEmpty &&
          controller.topSchools.isEmpty) {
        return _AnalyticsErrorState(
          message: controller.errorMessage.value,
          onRetry: () => controller.retryAnalytics(id),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshAnalytics(id),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          children: [
            Row(
              children: [
                Text(
                  'Competition Overview',
                  style: getTextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => controller.refreshAnalytics(id),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (controller.isStatsLoading.value && controller.statsData.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.38,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AnalyticsStatCard(
                    title: 'Total Registered',
                    value: controller.activeRegistrationsLabel,
                    icon: Icons.groups_rounded,
                    backgroundColor: AppColors.aliceBlueEAF3FF,
                    borderColor: AppColors.lightSkyBlue97C2FF,
                    iconColor: AppColors.royalBlue2F6BFF,
                  ),
                  AnalyticsStatCard(
                    title: 'CTA',
                    value: controller.completedLearningLabel,
                    icon: Icons.trending_up_rounded,
                    backgroundColor: AppColors.oldLaceFFF5E7,
                    borderColor: AppColors.lightSalmonFFC27A,
                    iconColor: AppColors.darkOrangeFF6B1A,
                  ),
                  AnalyticsStatCard(
                    title: 'Qualified',
                    value: controller.passedQualificationLabel,
                    icon: Icons.check_circle_outline_rounded,
                    backgroundColor: AppColors.honeydewEFFFF2,
                    borderColor: AppColors.mediumAquamarine81E7A4,
                    iconColor: AppColors.mediumSeaGreen25B75C,
                  ),
                  AnalyticsStatCard(
                    title: 'Finals Passed',
                    value: controller.finalsPassedLabel,
                    icon: Icons.emoji_events_outlined,
                    backgroundColor: AppColors.ghostWhiteF6ECFF,
                    borderColor: AppColors.plumD8AFFF,
                    iconColor: AppColors.blueVioletA127FF,
                  ),
                ],
              ),
            const SizedBox(height: 18),
            Text(
              'Prizes',
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            if (controller.isPrizesLoading.value && controller.prizes.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (controller.prizes.isEmpty)
              const _SectionEmptyState(text: 'No prizes available')
            else ...[
              ...controller.displayedPrizes.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: WeeklyWinnerCard(prize: entry.value, index: entry.key),
                ),
              ),
              if (controller.showPrizeLoadMore)
                _LoadMoreButton(onTap: controller.loadMorePrizes),
            ],
            const SizedBox(height: 16),
            Text(
              'Top Performing Schools',
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            if (controller.isTopSchoolsLoading.value &&
                controller.topSchools.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (controller.topSchools.isEmpty)
              const _SectionEmptyState(text: 'No top schools available')
            else ...[
              ...controller.displayedTopSchools.map(
                (school) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TopSchoolCard(school: school),
                ),
              ),
              if (controller.showTopSchoolLoadMore)
                _LoadMoreButton(onTap: controller.loadMoreTopSchools),
            ],
            if (controller.errorMessage.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  controller.errorMessage.value,
                  style: getTextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(onPressed: onTap, child: const Text('Load More')),
    );
  }
}

class _SectionEmptyState extends StatelessWidget {
  const _SectionEmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: getTextStyle(color: AppColors.secondaryTextColor)),
    );
  }
}

class _AnalyticsErrorState extends StatelessWidget {
  const _AnalyticsErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
