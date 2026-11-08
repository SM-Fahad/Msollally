import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/jobs.controller.dart';
import 'job_application_card.dart';

class MyJobApplicationsView extends StatelessWidget {
  final JobController controller;

  const MyJobApplicationsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isApplicationsLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryButtonColor),
        );
      }

      final list = controller.myApplications;
      if (list.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        color: AppColors.primaryButtonColor,
        onRefresh: () => controller.fetchMyApplications(),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 24, top: 8),
          itemCount: list.length,
          itemBuilder: (context, index) => JobApplicationCard(
            application: list[index],
            controller: controller,
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: AppColors.primaryButtonColor,
      onRefresh: () => controller.fetchMyApplications(),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.work_history_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Job Applications Yet',
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jobs you apply for will appear here',
                      textAlign: TextAlign.center,
                      style: getTextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
