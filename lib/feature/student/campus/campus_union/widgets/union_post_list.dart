import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_union/controller/campus_union_controller.dart';
import 'package:msollaally/feature/student/campus/campus_union/widgets/custom_post_content.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/comment_bottom_sheet.dart';

class UnionPostList extends StatelessWidget {
  const UnionPostList({super.key, required this.controller});

  final CampusUnionController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: List.generate(controller.posts.length, (index) {
          final post = controller.posts[index];
          return Column(
            children: [
              Divider(color: Colors.grey.shade200, thickness: 15),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.width,
                  vertical: 10.height,
                ),
                child: PostContent(
                  post: post,
                  onLike: () => controller.toggleLike(post),
                  onComment: () => _showCommentBottomSheet(context, post.id),
                  onShare: () => debugPrint(
                    "Share tapped on ${post.id}",
                  ),
                  onEdit: (content) => controller.updatePost(post.id, content),
                  onDelete: () => controller.deletePost(post.id),
                ),
              ),
            ],
          );
        }),
      );
    });
  }

  void _showCommentBottomSheet(BuildContext context, int postId) {
    showCommentSheet(context, postId);
  }
}
