import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../core/const/icons_path.dart';
import '../../../../../core/const/images_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../../../profile/controller/student_profile_controller.dart';

class StudentProfilePicture extends StatelessWidget {
  const StudentProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentProfileController controller = Get.put(
      StudentProfileController(),
    );

    double size = 110.width; // ✅ use same value for both width & height

    return Obx(
      () => SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Circular Profile Image
            ClipOval(
              child: controller.profileImage.value != null
                  ? Image.file(
                      controller.profileImage.value!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      ImagesPath.profileImageSVG,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    ),
            ),

            // Camera Icon (Bottom-Right)
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: () => controller.pickImage(true),
                child: Container(
                  height: 35.width,
                  width: 35.width,
                  padding: EdgeInsets.all(6.width),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cameraBGColor,
                  ),
                  child: SvgPicture.asset(
                    IconsPath.cameraIcon,
                    height: 18.width,
                    width: 18.width,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
