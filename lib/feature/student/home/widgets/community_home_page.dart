import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_home_controller.dart';

class CommunityHomePage extends StatelessWidget {
  const CommunityHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentHomeController());

    return SizedBox(
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Community", style: appTextStyleHeading2(fontSize: 16.fontSize)),
            SizedBox(height: 16.height),

            Obx(
              () => ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.community.length,
                itemBuilder: (_, index) {
                  final items = controller.community[index];

                  return InkWell(
                    onTap: items.ontap,

                    child: Container(
                      margin: EdgeInsets.symmetric(
                        // horizontal: 8.width,
                        vertical: 8.height,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.width,
                        vertical: 12.height,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.radius),
                        color: AppColors.todaysQuickPicContainerBGColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            items.icon,
                            height: 42.height,
                            width: 42.width,
                          ),
                          SizedBox(width: 12.width),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  items.text,
                                  style: appTextStyleHeading1(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2.fontSize,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      items.days.toString(),
                                      style: appTextStyleHeading1(
                                        fontSize: 12.fontSize,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2.fontSize,
                                        color: AppColors.checkBoxActiveColor,
                                      ),
                                    ),
                                    SizedBox(width: 4.width),
                                    Text(
                                      "new messages",
                                      style: appTextStyleHeading1(
                                        fontSize: 12.fontSize,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2.fontSize,
                                        color: AppColors.checkBoxActiveColor,
                                      ),
                                    ),
                                  ],
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
            SizedBox(height: 8.height),
            Container(
              height: 0.5.height,
              width: double.infinity,
              color: AppColors.black1F1F1F.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
