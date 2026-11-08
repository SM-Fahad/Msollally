import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';

import '../../../../../core/common/styles/global_text_style.dart';
import '../controller/student_campus_student_public_profile_controller.dart';
import 'package:get/get.dart';

class StudentPublicProfileAboutItem extends StatelessWidget {
  const StudentPublicProfileAboutItem({
    super.key,
    required StudentPublicProfileController controller,
  }) : _controller = controller;

  final StudentPublicProfileController _controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35.width),

      child: SizedBox(
        height: 340.height,
        child: Obx(() {
          return ListView.builder(
            itemCount: _controller.aboutItems.length,
            itemBuilder: (_, index) {
              final items = _controller.aboutItems[index];
              return Padding(
                padding: EdgeInsetsGeometry.only(bottom: 34.height),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        items.title,
                        style: appTextStyleHeading1(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0.fontSize,
                        ),
                      ),
                      SizedBox(width: 16.width),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                items.titleValue,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: appTextStyleHeading2(
                                  fontSize: 16.fontSize,
                                  letterSpacing: 0.0.fontSize,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.width),
                            InkWell(
                              onTap: items.ontap,
                              child: const Icon(
                                Icons.chevron_right,
                                color: AppColors.gray797979,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
