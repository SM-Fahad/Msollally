import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/feature/auth/login/login_page/controller/login_controller.dart';

class LoginFormFields extends StatelessWidget {
  const LoginFormFields({super.key, required this.loginController});

  final LoginController loginController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone",
          style: getTextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            letterSpacing: .02,
          ),
        ),
        SizedBox(height: 8.h),
        IntlPhoneField(
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primaryButtonColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.darkGray9DA4AE),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          initialCountryCode: 'BD',
          onChanged: (phone) {
            loginController.setPhoneNumber(phone.completeNumber);
          },
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Text(
            "Password",
            style: getTextStyle(fontSize: 14, letterSpacing: .02),
          ),
        ),
        Obx(
          () => TextField(
            controller: loginController.passwordController,
            obscureText: loginController.isPasswordHidden.value,
            decoration: InputDecoration(
              hintText: "Enter your password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  loginController.isPasswordHidden.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  loginController.isPasswordHidden.value =
                      !loginController.isPasswordHidden.value;
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => Get.toNamed(AppRoute.resetpassword),
            child: Text(
              "Forgot Password?",
              style: getTextStyle(
                color: AppColors.primaryButtonColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
