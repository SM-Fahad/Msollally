import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/auth/signup/account_opening/controller/sign_up_screen_onboarding_controller.dart';

class UploadYourPhoto extends StatelessWidget {
  final SignUpScreenOnboardingController controller;

  const UploadYourPhoto({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              final file = await controller.pickFromGallery();
              if (file != null) {
                debugPrint('Picked image: ${file.path}');
              }
            },
            child: Stack(
              children: [
                Obx(() {
                  final path = controller.selectedImagePath.value;
                  if (path != null && path.isNotEmpty) {
                    return Container(
                      height: 64.h,
                      width: 64,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(color: Colors.transparent),
                    height: 64.h,
                    width: 64,
                    child: Image.asset(ImagesPath.teacherUploadPhotoPng),
                  );
                }),
                Positioned(
                  bottom: 0.h,
                  left: 13.5.w,

                  child: InkWell(
                    onTap: () async {
                      final file = await controller.pickFromGallery();
                      if (file != null) {
                        debugPrint('Picked image: ${file.path}');
                      }
                    },
                    child: SvgPicture.asset(
                      IconsPath.addIconIconNodmac,
                      height: 23.27.h,
                      width: 23.27.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 13.h),
          UserRoleService.isRecruiter || UserRoleService.isProPartners
              ? Text(
                  "Upload Your Company Logo",
                  style: getTextStyle(
                    color: AppColors.black000000,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                )
              : Text(
                  "Upload Your Photo",
                  style: getTextStyle(
                    color: AppColors.black000000,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
        ],
      ),
    );
  }
}
