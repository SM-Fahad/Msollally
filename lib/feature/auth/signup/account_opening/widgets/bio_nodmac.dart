import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controller/sign_up_screen_onboarding_controller.dart';

class BioNodMac extends StatelessWidget {
  const BioNodMac({super.key, required this.controllerNodeMac});

  final SignUpScreenOnboardingController controllerNodeMac;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bio",
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.black18181B,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 8.h),
          Stack(
            children: [
              SizedBox(
                child: TextField(
                  controller: controllerNodeMac.bioController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Enter your bio",
                    hintStyle: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.appBarTitleColor.withValues(alpha: 0.3),
                      letterSpacing: 0.2,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.darkGray9DA4AE,
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 12.h,
                right: 12.w,
                child: Row(
                  children: [
                    Text(
                      "13,",
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.appBarTitleColor.withValues(alpha: 0.3),
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      "/",
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.appBarTitleColor.withValues(alpha: 0.3),
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      "300",
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.appBarTitleColor.withValues(alpha: 0.3),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
