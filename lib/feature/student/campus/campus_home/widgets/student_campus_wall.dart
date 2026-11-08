import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'student_campus_post_card.dart';

class StudentCampusWall extends StatelessWidget {
  const StudentCampusWall({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentCampusController());
    return Obx(() {
      if (controller.isLoadingPosts.value && controller.postsList.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ShimmerLoading.list(
            itemCount: 3,
            height: 180,
            borderRadius: 16,
          ),
        );
      }
      if (controller.postsList.isEmpty) {
        return const Center(child: Text("No posts found"));
      }
      return Column(
        children: [
          if (controller.isBackgroundUploadingPost.value)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Posting...",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.postsList.length,
            itemBuilder: (_, index) => StudentCampusPostCard(
              post: controller.postsList[index],
              controller: controller,
            ),
          ),
          if (controller.isLoadingMorePosts.value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const CircularProgressIndicator(),
            ),
        ],
      );
    });
  }
}
