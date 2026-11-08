import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/campus_union_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/campus/create_post/screen/create_post.dart';
import 'package:msollaally/feature/student/campus/campus_union/widgets/union_detail_header.dart';
import 'package:msollaally/feature/student/campus/campus_union/widgets/union_post_list.dart';

class StudentUnion extends StatelessWidget {
  const StudentUnion({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CampusUnionController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final union = controller.union.value;

          if (controller.isLoading.value && union == null) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
              child: Column(
                children: [
                  ShimmerLoading.card(height: 200.height, borderRadius: 16.radius),
                  SizedBox(height: 20.height),
                  ShimmerLoading.card(height: 50.height, borderRadius: 12.radius),
                  SizedBox(height: 10.height),
                  ShimmerLoading.list(
                    itemCount: 2,
                    height: 120.height,
                    borderRadius: 16.radius,
                  ),
                ],
              ),
            );
          }

          if (union == null) {
            return const Center(child: Text("No union details found"));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                UnionDetailHeader(union: union),
                SizedBox(height: 20.height),
                _buildCreatePostField(controller),
                SizedBox(height: 10.height),
                UnionPostList(controller: controller),
                SizedBox(height: 35.height),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCreatePostField(CampusUnionController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.width),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final unionId = controller.union.value?.id ?? 1;
            final result = await Get.to(
              () => CreatePost(postableType: 'Union', postableId: unionId),
            );
            if (result == true) {
              controller.fetchUnionPosts(unionId);
            }
          },
          icon: Icon(Icons.add_circle_outline, size: 20.fontSize),
          label: Text(
            'Create Post',
            style: TextStyle(fontSize: 16.fontSize, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.radius),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
