import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import 'package:msollaally/routes/app_route.dart';
import '../controller/student_campus_student_public_profile_controller.dart';

class StudentPublicProfileFriendsItems extends StatelessWidget {
  final StudentPublicProfileController _controller;

  const StudentPublicProfileFriendsItems({
    super.key,
    required StudentPublicProfileController controller,
  }) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Obx(() {
        if (_controller.friends.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.height),
              child: Text(
                "No friends found",
                style: appTextStyleHeading2(fontSize: 16.fontSize),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _controller.friends.length,
          itemBuilder: (_, index) {
            var iteams = _controller.friends[index];
            return Column(
              children: [
              InkWell(
                borderRadius: BorderRadius.circular(8.radius),
                onTap: () {
                  if (iteams.id != null && iteams.id! > 0) {
                    Get.toNamed(
                      AppRoute.studentCampusPublicProfile,
                      arguments: iteams.id,
                      preventDuplicates: false,
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 6.height),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100.radius),
                              child: iteams.imageUrl.startsWith('http')
                                  ? Image.network(
                                      iteams.imageUrl,
                                      height: 40.height,
                                      width: 40.width,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 40.height,
                                        width: 40.width,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : iteams.imageUrl.isNotEmpty
                                  ? Image.asset(
                                      iteams.imageUrl,
                                      height: 40.height,
                                      width: 40.width,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 40.height,
                                        width: 40.width,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 40.height,
                                      width: 40.width,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            SizedBox(width: 8.width),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    iteams.name,
                                    style: appTextStyleHeading1(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "${iteams.mutualNumber} Mutuals • ${iteams.uvName}",
                                    style: appTextStyleHeading2(
                                      fontSize: 12.fontSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (iteams.id != null && iteams.id! > 0)
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 20.fontSize,
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              ],
            );
          },
        );
      }),
    );
  }
}
