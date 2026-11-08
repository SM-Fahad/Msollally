// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/model/job_model.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/controller/job_applicants_controller.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/widgets/applicants_stats_header.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/widgets/applicants_tab_widget.dart';

class JobApplicantsScreen extends StatelessWidget {
  final JobModel job;

  JobApplicantsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final controllerTag = 'job-applicants-${job.id}';
    final controller =
        Get.isRegistered<JobApplicantsController>(tag: controllerTag)
        ? Get.find<JobApplicantsController>(tag: controllerTag)
        : Get.put(JobApplicantsController(job), tag: controllerTag);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.aliceBlueF4F7FB,
        appBar: AppBar(
          backgroundColor: AppColors.aliceBlueF4F7FB,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job Applicants',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black0F172A,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Review candidates before making hiring decisions.',
                style: TextStyle(fontSize: 12.5, color: AppColors.slateGray64748B),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: controller.refreshCurrentTab,
          color: AppColors.royalBlue1D4ED8,
          child: ListView(
            physics: BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              ApplicantsStatsHeader(
                controllerTag: controllerTag,
                jobTitle: job.title,
              ),
              SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black0F172A.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Obx(() {
                  return TabBar(
                    onTap: controller.onTabChanged,
                    labelPadding: EdgeInsets.symmetric(horizontal: 6),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.lavenderE0ECFF,
                    ),
                    indicatorPadding: EdgeInsets.all(6),
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.royalBlue1D4ED8,
                    unselectedLabelColor: AppColors.slateGray64748B,
                    tabs: List.generate(3, (index) {
                      return Tab(
                        child: _TabChip(
                          title: controller.tabTitleForIndex(index),
                          count: controller.countForIndex(index),
                        ),
                      );
                    }),
                  );
                }),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.56,
                child: TabBarView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    ApplicantsListTab(
                      controllerTag: controllerTag,
                      tabIndex: 0,
                    ),
                    ApplicantsListTab(
                      controllerTag: controllerTag,
                      tabIndex: 1,
                    ),
                    ApplicantsListTab(
                      controllerTag: controllerTag,
                      tabIndex: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String title;
  final int count;

  _TabChip({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(width: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: AppColors.black0F172A,
            ),
          ),
        ),
      ],
    );
  }
}
