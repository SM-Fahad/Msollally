import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/career/gigs/widgets/gigs/gig_card.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';

import '../controller/student_profile_controller.dart';

class StudentProfileGigsItems extends StatelessWidget {
  final StudentProfileController _controller;

  const StudentProfileGigsItems({
    super.key,
    required StudentProfileController controller,
  }) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          if (_controller.isLoadingGigs.value) {
            return Padding(
              padding: EdgeInsets.all(20.radius),
              child: ShimmerLoading.list(
                itemCount: 2,
                height: 120.height,
                borderRadius: 12.radius,
              ),
            );
          }

          var listToShow = _controller.gigs;

          if (listToShow.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 32.height),
              child: Column(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 48.fontSize,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16.height),
                  Text(
                    "No gigs found.",
                    style: appTextStyleHeading2(fontSize: 14.fontSize),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.width),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listToShow.length,
              itemBuilder: (_, index) {
                return GigCard(gig: listToShow[index]);
              },
            ),
          );
        }),
      ],
    );
  }
}
