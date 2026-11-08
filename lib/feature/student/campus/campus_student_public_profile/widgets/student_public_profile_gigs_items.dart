import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/career/gigs/widgets/gigs/gig_card.dart';
import '../controller/student_campus_student_public_profile_controller.dart';

class StudentPublicProfileGigsItems extends StatelessWidget {
  const StudentPublicProfileGigsItems({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentPublicProfileController controller =
        Get.find<StudentPublicProfileController>();

    return Column(
      children: [
        Obx(() {
          if (controller.isLoadingGigs.value) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          var listToShow = controller.gigs;

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

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listToShow.length,
            itemBuilder: (_, index) {
              return GigCard(gig: listToShow[index]);
            },
          );
        }),
      ],
    );
  }
}
