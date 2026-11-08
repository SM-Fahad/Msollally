// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/auth/login/login_page/controller/login_controller.dart';
import 'package:msollaally/feature/auth/login/login_page/widgets/login_header.dart';
import 'package:msollaally/feature/auth/login/login_page/widgets/login_form_fields.dart';
import 'package:msollaally/feature/auth/login/login_page/widgets/login_footer.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController loginController = Get.put(
    LoginController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoginHeader(),
              SizedBox(height: 70.h),
              LoginFormFields(loginController: loginController),
              SizedBox(height: 50.h),
              LoginFooter(loginController: loginController),
            ],
          ),
        ),
      ),
    );
  }
}
