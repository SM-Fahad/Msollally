import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/controller/student_quiz_competition_controller.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/screen/three_tabs/analytics_tab.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/screen/three_tabs/details_tab.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/screen/three_tabs/registrations_tab.dart';

class StudentQuizCompetition extends StatelessWidget {
  const StudentQuizCompetition({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentQuizCompetitionController());
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerLoading.circle(radius: 20),
                    const SizedBox(width: 16),
                    ShimmerLoading.line(height: 24, width: 180),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLoading.line(height: 18, width: 80),
                    ShimmerLoading.line(height: 18, width: 80),
                    ShimmerLoading.line(height: 18, width: 80),
                  ],
                ),
                const SizedBox(height: 24),
                ShimmerLoading.card(height: 180, borderRadius: 16),
                const SizedBox(height: 24),
                ShimmerLoading.list(
                  itemCount: 2,
                  height: 100,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        );
      }
      final comp = controller.competition.value;
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          title: Text(comp?.competitionName ?? 'Quiz Competition'),
          bottom: TabBar(
            controller: controller.tabController,
            tabs: controller.myTabs,
            labelColor: AppColors.primaryButtonColor,
            unselectedLabelColor: AppColors.appBarTitleColor,
            indicatorColor: AppColors.primaryButtonColor,
            labelStyle: getTextStyle(fontSize: 14),
            unselectedLabelStyle: getTextStyle(fontSize: 14),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              return states.contains(WidgetState.focused)
                  ? null
                  : Colors.transparent;
            }),
          ),
        ),
        body: TabBarView(
          controller: controller.tabController,
          children: [DetailsTab(), AnalyticsTab(), RegistrationsTab()],
        ),
      );
    });
  }
}
