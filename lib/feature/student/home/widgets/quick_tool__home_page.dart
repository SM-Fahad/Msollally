import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/routes/app_route.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/const/icons_path.dart';
import '../model/quick_tools_model.dart';

class QuickToolsHomePage extends StatelessWidget {
  const QuickToolsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<QuickToolsModel> quickToolsIteam = [
      QuickToolsModel(
        title: "Calender",
        image: IconsPath.calenderNodMac,
        containerColor: AppColors.aliceBlueF4F8FF,
        borderColor: AppColors.primaryButtonColor.withValues(alpha: .3),
        route: AppRoute.studentCalenderPage,
      ),

      QuickToolsModel(
        title: "Convert",
        image: IconsPath.convertFileIcon,
        containerColor: AppColors.floralWhiteFFF9F4,
        borderColor: AppColors.coralFF9244.withValues(alpha: 0.3),
        route: AppRoute.studentFileConverterPage,
      ),

      QuickToolsModel(
        title: "AI Chat",
        image: IconsPath.aiChatIcon,
        containerColor: AppColors.mediumPurple8757F3.withValues(alpha: 0.08),
        borderColor: AppColors.primaryButtonColor.withValues(alpha: 0.3),
        route: AppRoute.studentAIChatpage,
      ),
    ];

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Tools", style: appTextStyleHeading2(fontSize: 16.fontSize)),
          SizedBox(height: 16.height),

          SizedBox(
            height: 44.height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              //   shrinkWrap: true,
              itemCount: quickToolsIteam.length,
              itemBuilder: (_, index) {
                return InkWell(
                  onTap: () {
                    Get.toNamed(quickToolsIteam[index].route);

                    // if (index == 0) {
                    //   Get.to(AppRoute.studentCalenderPage);
                    // } else if (index == 1) {
                    //   Get.to(AppRoute.signUpScreenOnboarding);
                    // } else if (index == 2) {
                    //   Get.to(AppRoute.signUpScreenOnboarding);
                    // }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12.width),

                    padding: EdgeInsets.symmetric(horizontal: 8.width),
                    height: 44.height,
                    width: 109.67.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.radius),
                      color: quickToolsIteam[index].containerColor,
                      border: Border.all(
                        // ignore: deprecated_member_use, use_full_hex_values_for_flutter_colors
                        color: quickToolsIteam[index].borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          quickToolsIteam[index].image,
                          // color: AppColors.primaryButtonColor,
                          height: 24.height,
                          width: 24.width,
                        ),
                        SizedBox(width: 8.width),

                        Text(
                          quickToolsIteam[index].title,
                          style: appTextStyleHeading2(
                            fontWeight: FontWeight.w500,
                            color: AppColors.appBarTitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
