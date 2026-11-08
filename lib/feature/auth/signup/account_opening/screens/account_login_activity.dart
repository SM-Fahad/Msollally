import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/account_activity_section.dart';

class AccountLogInActivity extends StatelessWidget {
  const AccountLogInActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            //horizontal: 16.w,
            vertical: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.tagBackgroundColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: SvgPicture.asset(
                          IconsPath.backIconAccountLoginAC,
                          height: 24.h,
                          width: 24.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 86.h),
              AccountLogInActivitySection(),
            ],
          ),
        ),
      ),
    );
  }
}
