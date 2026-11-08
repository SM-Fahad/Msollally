import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../controller/student_profile_controller.dart';

class StudentProfileAboutItem extends StatelessWidget {
  const StudentProfileAboutItem({
    super.key,
    required StudentProfileController controller,
  }) : _controller = controller;

  final StudentProfileController _controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35.width),

      child: SizedBox(
        height: 340.height,
        child: Obx(
          () => ListView.builder(
            itemCount: _controller.aboutItem.length,
            itemBuilder: (_, index) {
              final items = _controller.aboutItem[index];
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
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                items.titleValue,
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
                              child: Icon(
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
          ),
        ),
      ),
    );
  }
}
