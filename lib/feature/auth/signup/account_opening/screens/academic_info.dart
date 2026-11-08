import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/auth/signup/account_opening/controller/sign_up_screen_onboarding_controller.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/academic_information.dart';

class AcademicInfoScreen extends StatelessWidget {
  const AcademicInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignUpScreenOnboardingController nodeMacController = Get.put(
      SignUpScreenOnboardingController(),
      permanent: true,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26, vertical: 26),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      IconsPath.nodmacIconNext,
                      height: 40,
                      width: 47,
                    ),
                    Text(
                      "LinkYetu",
                      style: getTextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.48,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepper(AppColors.sliderColorInboarding),
                    _buildStepper(AppColors.primaryButtonColor),
                    _buildStepper(AppColors.sliderColorInboarding),
                  ],
                ),
                SizedBox(height: 26),

                AcademicInformation(nodeMacController: nodeMacController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(Color color) {
    return Container(
      height: 6,
      width: 95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
    );
  }
}
