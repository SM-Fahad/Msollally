import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';

class AccountLogInActivitySection extends StatelessWidget {
  const AccountLogInActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Account Login Activity",
              style: getTextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "You are currently logged in on another device. You can’t login on more than one device.",
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
                color: AppColors.uiDangerColor,
              ),
            ),

            SizedBox(height: 24.h),
            Container(
              decoration: BoxDecoration(
                //   color:Colors.amber,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  // ignore: use_full_hex_values_for_flutter_colors
                  color: Color(0xff0000001f).withValues(alpha: .12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            IconsPath.phoneIcon,
                            height: 24.h,
                            width: 24.w,
                          ),
                          SizedBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Samsung Galaxy A35",
                                  style: getTextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Dhaka",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.2.sp,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),

                                    Text(
                                      ".",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.2.sp,
                                      ),
                                    ),

                                    SizedBox(width: 4.w),

                                    Text(
                                      "Active Now",
                                      style: getTextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.2,
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
                    Container(
                      height: 32.h,
                      width: 76.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.sp),
                        border: Border.all(color: AppColors.uiDangerColor),
                      ),
                      child: Center(
                        child: Text(
                          "Remove",
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                            color: AppColors.uiDangerColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
