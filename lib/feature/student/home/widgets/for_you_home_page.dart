import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_home_controller.dart';

class ForYouHomePage extends StatelessWidget {
  const ForYouHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final forYouController = Get.put(StudentHomeController());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("For You", style: appTextStyleHeading2(fontSize: 16.fontSize)),

        SizedBox(height: 16.height),

        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: forYouController.forYou.length,
          itemBuilder: (_, index) {
            final items = forYouController.forYou[index];
            return InkWell(
              onTap: items.onTap,
              child: Container(
                margin: EdgeInsets.only(bottom: 12.height),
                padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.radius),
                  color: AppColors.forYouContainerBGColor,
                  border: BoxBorder.all(
                    color: AppColors.forYouContainerBorderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Center(
                      child: Image.asset(items.icon, height: 36.height, width: 50.height),
                    ),
                    SizedBox(width: 8.width),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items.title,
                            style: appTextStyleHeading1(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2.fontSize,
                            ),
                          ),

                          Text(
                            items.subtitle,

                            style: appTextStyleHeading2(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2.fontSize,
                              color: AppColors.appBarTitleColor,
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
        SizedBox(height: 4.height),
        Container(
          height: 0.5.height,
          width: double.infinity,
          color: AppColors.black1F1F1F.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
