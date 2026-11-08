import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/career/cv/controller/cv_controller.dart';
import 'package:msollaally/feature/student/career/cv/screen/cv_detail_screen.dart';
import 'package:msollaally/feature/student/career/cv/screen/cv_screen.dart';
import 'package:msollaally/feature/student/career/my_career/controller/my_career_controller.dart';
import 'package:msollaally/feature/student/career/my_career/widget/action_card.dart';
import 'package:msollaally/feature/student/career/my_career/widget/career_prep_card.dart';
import 'package:msollaally/feature/student/career/my_career/widget/for_you_section.dart';
import 'mock_interview_card.dart';

class MyCareerTabView extends StatelessWidget {
  const MyCareerTabView({super.key, required this.controller});

  final CareerController controller;

  @override
  Widget build(BuildContext context) {
    final cvController = Get.isRegistered<CvController>()
        ? Get.find<CvController>()
        : Get.put(CvController());

    return RefreshIndicator(
      onRefresh: () async {
        await cvController.fetchAllCvs();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CareerPrepCard(controller: controller),
            const SizedBox(height: 16),
            _buildCvBuilderCard(cvController),
            const SizedBox(height: 16),
            _buildMyCvsSection(cvController),
            const SizedBox(height: 12),
            const MockInterviewCard(),
            const SizedBox(height: 24),
            Text(
              'For You',
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ForYouSection(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildCvBuilderCard(CvController cvController) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(12),
        ),
        child: buildActionCard(
          title: 'Dynamic CV Builder',
          subtitle:
              'Your profile is ${controller.profileCompleteness.value}% complete. Keep it up!',
          leftAction: 'Customize',
          rightAction: 'Download',
          onLeftTap: () {
            cvController.resetForm();
            Get.to(() => CvScreen());
          },
          onRightTap: () async {
            await cvController.downloadLatestCv();
          },
        ),
      ),
    );
  }

  Widget _buildMyCvsSection(CvController cvController) {
    return Obx(() {
      final cvs = cvController.myCvs;
      if (cvs.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'My Generated CVs',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cvs.length}',
                        style: getTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 20,
                    color: AppColors.secondaryTextColor,
                  ),
                  tooltip: 'Refresh CVs',
                  onPressed: () => cvController.fetchAllCvs(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cvs.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final cv = cvs[index];
                final id = cv['id']?.toString() ?? '';
                final firstName = cv['firstName'] ?? '';
                final middleName = cv['middleName'] ?? '';
                final lastName = cv['lastName'] ?? '';
                final name = [firstName, middleName, lastName]
                    .where((s) => s.toString().trim().isNotEmpty)
                    .join(' ');
                final title = name.isNotEmpty ? name : 'CV #${index + 1}';
                final email = cv['email'] ?? '';
                final createdAt = _formatDate(cv['createdAt']?.toString());

                return InkWell(
                  onTap: () {
                    if (id.isNotEmpty) {
                      Get.to(() => CvDetailScreen(cvId: id));
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: AppColors.primaryButtonColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (email.isNotEmpty) email,
                                  if (createdAt.isNotEmpty) createdAt,
                                ].join(' • '),
                                style: getTextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.primaryButtonColor,
                              ),
                              tooltip: 'View Details',
                              onPressed: () {
                                if (id.isNotEmpty) {
                                  Get.to(() => CvDetailScreen(cvId: id));
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: AppColors.primaryButtonColor,
                              ),
                              tooltip: 'Edit CV',
                              onPressed: () async {
                                if (id.isNotEmpty) {
                                  final ok = await cvController.populateForEdit(id);
                                  if (ok) {
                                    Get.to(() => CvScreen());
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.download_rounded,
                                size: 20,
                                color: AppColors.primaryButtonColor,
                              ),
                              tooltip: 'Download CV',
                              onPressed: () {
                                if (id.isNotEmpty) {
                                  cvController.downloadCvById(id);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Delete CV',
                              onPressed: () {
                                if (id.isNotEmpty) {
                                  cvController.deleteCv(cv['id']);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final date = DateTime.parse(rawDate);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return rawDate.split('T').first;
    }
  }
}
