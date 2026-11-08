import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/auth/signup/signup_page/screen/signUpScreen.dart';
import '../../../core/common/widgets/custom_button.dart';
import '../../../core/const/icons_path.dart';
import '../../../core/services/share_preferrance_helper.dart';
import '../../../core/services/user_role_service.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ChooseProfileScreen extends StatelessWidget {
  const ChooseProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserRoleService.init();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 26, top: 26),
                child: Row(
                  children: [
                    SvgPicture.asset(IconsPath.appIcon, width: 30, height: 30),
                    SizedBox(width: 7.5),
                    Text(
                      'LinkYetu',
                      style: getTextStyle(
                        color: AppColors.appBarTitleColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.90,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 104),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Who You Are',
                      style: getTextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 46),
                    Center(
                      child: Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        children: [
                          _buildRoleCard(
                            0,
                            'Student',
                            IconsPath.studentIcon,
                            AppColors.dodgerBlueAlpha14418AFF,
                            AppColors.primaryButtonColor,
                          ),
                          _buildRoleCard(
                            1,
                            'Faculty',
                            IconsPath.teacherIcon,
                            AppColors.mediumPurpleAlpha148757F3,
                            AppColors.mediumPurple8757F3,
                          ),
                          _buildRoleCard(
                            2,
                            'Recruiter',
                            IconsPath.recruiterIcon,
                            AppColors.mediumSeaGreenAlpha1446C882,
                            AppColors.checkBoxActiveColor,
                          ),
                          _buildRoleCard(
                            3,
                            'Pro Partners',
                            IconsPath.recruiterIcon,
                            AppColors.mediumSeaGreenAlpha1446C882,
                            AppColors.checkBoxActiveColor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 52),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      child: Obx(
                        () => CustomButton(
                          text: 'Continue',
                          vertical: 12,
                          onPressed: UserRoleService.hasSelectedRole
                              ? () async => _handleContinue()
                              : () {},
                          color: UserRoleService.hasSelectedRole
                              ? AppColors.primaryButtonColor
                              : AppColors.primaryButtonColor.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                      ),
                    ),

                    SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    int index,
    String title,
    String imagePath,
    Color backgroundColor,
    Color borderColor,
  ) {
    return Obx(() {
      final bool isSelected = UserRoleService.selectedRoleIndex == index;
      final cardWidth = 169.0;
      final cardHeight = 150.0;

      return SizedBox(
        width: index == 2 || index == 3 ? 168.0 : cardWidth,
        child: GestureDetector(
          onTap: () => UserRoleService.selectRole(index),
          child: Container(
            height: cardHeight,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: borderColor, width: 1)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: SvgPicture.asset(imagePath, width: 48, height: 48),
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _handleContinue() async {
    final selectedRole = UserRoleService.selectedRoleApiString;
    if (selectedRole != null) {
      await SharedPreferenceHelper().saveSelectedRole(selectedRole);
    }

    switch (UserRoleService.selectedRoleIndex) {
      case 0:
        Get.to(() => SignUpScreen());
        break;
      case 1:
        Get.to(() => SignUpScreen());
        break;
      case 2:
        Get.to(() => SignUpScreen());
        break;
      case 3:
        Get.to(() => SignUpScreen());
        break;
    }
  }
}
