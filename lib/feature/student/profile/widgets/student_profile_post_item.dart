import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart'
    show appTextStyleHeading2;
import '../controller/student_profile_controller.dart';
import 'student_profile_post_card.dart';

class StudentProfilePostsItem extends StatelessWidget {
  final StudentProfileController _controller;

  const StudentProfilePostsItem({
    super.key,
    required StudentProfileController controller,
  }) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.width),
      child: Obx(() {
        if (_controller.posts.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.height),
            child: Text("No posts yet.", style: appTextStyleHeading2()),
          );
        }

        return ListView.separated(
          itemCount: _controller.posts.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => SizedBox(height: 24.height),
          itemBuilder: (_, index) => StudentProfilePostCard(
            post: _controller.posts[index],
            controller: _controller,
          ),
        );
      }),
    );
  }
}
