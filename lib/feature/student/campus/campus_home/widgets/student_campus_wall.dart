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
    return Column(
      children: [
        // _buildFeedSearchAndFilterBar(controller),
        Obx(() {
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
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text("No posts found")),
            );
          }
          return Column(
            children: [
              if (controller.isBackgroundUploadingPost.value)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        }),
      ],
    );
  }

  //   Widget _buildFeedSearchAndFilterBar(StudentCampusController controller) {
  //     return Padding(
  //       padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
  //       child: Column(
  //         children: [
  //           TextField(
  //             controller: controller.feedSearchController,
  //             onChanged: controller.onFeedSearchChanged,
  //             decoration: InputDecoration(
  //               hintText: 'Search posts...',
  //               hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade500),
  //               prefixIcon: Icon(
  //                 Icons.search,
  //                 size: 20,
  //                 color: Colors.grey.shade600,
  //               ),
  //               suffixIcon: Obx(
  //                 () => controller.feedSearchQuery.value.isNotEmpty
  //                     ? IconButton(
  //                         icon: const Icon(Icons.clear, size: 18),
  //                         onPressed: controller.clearFeedSearch,
  //                       )
  //                     : const SizedBox.shrink(),
  //               ),
  //               isDense: true,
  //               filled: true,
  //               fillColor: Colors.grey.shade100,
  //               contentPadding: const EdgeInsets.symmetric(
  //                 horizontal: 14,
  //                 vertical: 10,
  //               ),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //                 borderSide: BorderSide.none,
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Obx(
  //             () => Row(
  //               children: [
  //                 ChoiceChip(
  //                   label: const Text('All Posts'),
  //                   selected: !controller.filterAnnouncementsOnly.value,
  //                   onSelected: (_) => controller.setAnnouncementFilter(false),
  //                   visualDensity: VisualDensity.compact,
  //                 ),
  //                 const SizedBox(width: 8),
  //                 ChoiceChip(
  //                   label: const Text('Announcements'),
  //                   selected: controller.filterAnnouncementsOnly.value,
  //                   onSelected: (_) => controller.setAnnouncementFilter(true),
  //                   visualDensity: VisualDensity.compact,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
}
