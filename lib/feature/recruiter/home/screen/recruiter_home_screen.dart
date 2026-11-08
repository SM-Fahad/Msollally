import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widgets/default_recruiter_app_bar.dart';
import '../controller/recruiter_home_controller.dart';
import '../widget/quick_tools_widget.dart';
import '../widget/summary_cards_widget.dart';
import '../widget/latest_applicants_widget.dart';
import '../widget/latest_job_widget.dart';

class RecruiterHomeScreen extends StatelessWidget {
  RecruiterHomeScreen({super.key});

  final RecruiterHomeController controller = Get.put(RecruiterHomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: DefaultRecruiterAppBar(
          isHomePage: true,
          title: controller.displayName,
          profileImageUrl: controller.profileImageUrl,
        ),
        body: RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuickToolsWidget(tools: controller.quickTools),
                SizedBox(height: 42.h),
                SummaryCardsWidget(cards: controller.summaryCards),
                SizedBox(height: 40.h),
                LatestApplicantsWidget(
                  applicants: controller.latestApplicants,
                  onApplicantTap: controller.onApplicantTap,
                ),
                SizedBox(height: 45.h),
                Obx(
                  () => LatestJobWidget(
                    job: controller.latestJob.value,
                    onJobTap: controller.onJobTap,
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
