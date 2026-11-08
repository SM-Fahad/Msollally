import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/career/mock_interview/model/mock_questions_repository.dart';
import 'package:msollaally/feature/student/career/mock_interview/screen/mock_interview_screen.dart';
import 'package:msollaally/feature/student/career/my_career/controller/category_selection_controller.dart';

void showCategoryBottomSheet(BuildContext context) {
  Get.bottomSheet(
    const CategorySelectionSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class CategorySelectionSheet extends StatelessWidget {
  const CategorySelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the GetX Controller for this sheet
    final c = Get.put(CategorySelectionController());

    return Container(
      padding: EdgeInsets.fromLTRB(20.width, 24.height, 20.width, 36.height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.radius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Interview Topic",
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.delete<CategorySelectionController>();
                  Get.back();
                },
                icon: Icon(Icons.close, size: 20.radius),
                color: Colors.grey.shade400,
              ),
            ],
          ),
          SizedBox(height: 4.height),
          Text(
            "Choose a topic to test your knowledge and practice your responses.",
            style: getTextStyle(
              fontSize: 13,
              color: AppColors.secondaryTextColor,
            ),
          ),
          SizedBox(height: 24.height),
          Obx(() {
            if (c.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (c.topics.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "No topics found.",
                    style: getTextStyle(color: AppColors.secondaryTextColor),
                  ),
                ),
              );
            } else {
              return Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: c.topics.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 12.height),
                  itemBuilder: (context, index) {
                    final topic = c.topics[index];
                    // Preset array of colors/icons for variety
                    final colorList = [
                      Colors.purple,
                      Colors.blue.shade700,
                      Colors.orange.shade800,
                      Colors.teal
                    ];
                    final color = colorList[index % colorList.length];
                    final icon = Icons.topic_outlined;

                    return _buildCategoryTile(
                      title: topic['title']?.toString() ?? "Unknown Topic",
                      subtitle: topic['description']?.toString() ?? "",
                      icon: icon,
                      color: color,
                      onTap: () {
                        Get.delete<CategorySelectionController>();
                        Get.back();
                        Get.to(() => MockInterviewScreen(
                              topicId: topic['id']?.toString() ?? "",
                              duration: const Duration(minutes: 5),
                              categoryTitle:
                                  topic['title']?.toString() ?? "Topic",
                            ));
                      },
                    );
                  },
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.radius),
      child: Ink(
        padding: EdgeInsets.all(14.width),
        decoration: BoxDecoration(
          color: AppColors.panelBackgroundColor,
          borderRadius: BorderRadius.circular(16.radius),
          border: Border.all(color: AppColors.sectionBorderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.radius),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 22.radius,
              ),
            ),
            SizedBox(width: 14.width),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 3.height),
                  Text(
                    subtitle,
                    style: getTextStyle(
                      color: AppColors.secondaryTextColor,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.width),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20.radius,
            ),
          ],
        ),
      ),
    );
  }
}
