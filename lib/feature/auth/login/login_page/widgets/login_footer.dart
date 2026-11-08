import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/feature/auth/login/login_page/controller/login_controller.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key, required this.loginController});

  final LoginController loginController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Obx(() {
              final loading = loginController.isLoading.value;
              return CustomButton(
                text: loading ? "Logging in..." : "Login",
                onPressed: loading ? () {} : () => loginController.login(),
              );
            }),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: getTextStyle(
                  color: AppColors.appBarTitleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: 0.20,
                ),
              ),
              InkWell(
                onTap: () => Get.toNamed(AppRoute.chooseProfileScreen),
                child: Text(
                  " Sign Up",
                  style: getTextStyle(
                    color: AppColors.primaryButtonColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 0.20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
