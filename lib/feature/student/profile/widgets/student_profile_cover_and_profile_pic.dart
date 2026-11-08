import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/const/icons_path.dart';
import '../../../../core/const/images_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../../../../core/common/widgets/fullscreen_image_view.dart';
import '../controller/student_profile_controller.dart';

class StudentProfileCoverAndProfilePic extends StatelessWidget {
  const StudentProfileCoverAndProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentProfileController controller = Get.put(
      StudentProfileController(),
    );

    return Obx(
      () => SizedBox(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                if (controller.coverImage.value != null) {
                  Get.to(
                    () => FullscreenImageView(
                      imageUrl: controller.coverImage.value!.path,
                      isNetworkImage: false,
                      isFileImage: true,
                    ),
                  );
                } else if (controller.coverImageUrl.value.isNotEmpty) {
                  Get.to(
                    () => FullscreenImageView(
                      imageUrl: controller.coverImageUrl.value,
                      isNetworkImage: true,
                    ),
                  );
                } else {
                  Get.to(
                    () => const FullscreenImageView(
                      imageUrl: ImagesPath.coverPhoto,
                      isNetworkImage: false,
                    ),
                  );
                }
              },
              child: SizedBox(
                child: controller.coverImage.value != null
                    ? Image.file(
                        controller.coverImage.value!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200.height,
                      )
                    : controller.coverImageUrl.value.isNotEmpty
                    ? Image.network(
                        controller.coverImageUrl.value,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200.height,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              ImagesPath.coverPhoto,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200.height,
                            ),
                      )
                    : Image.asset(
                        ImagesPath.coverPhoto,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200.height,
                      ),
              ),
            ),

            Positioned(
              bottom: -19.height,
              left: 16.width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (controller.profileImage.value != null) {
                        Get.to(
                          () => FullscreenImageView(
                            imageUrl: controller.profileImage.value!.path,
                            isNetworkImage: false,
                            isFileImage: true,
                          ),
                        );
                      } else if (controller.profileImageUrl.value.isNotEmpty) {
                        Get.to(
                          () => FullscreenImageView(
                            imageUrl: controller.profileImageUrl.value,
                            isNetworkImage: true,
                          ),
                        );
                      } else {
                        Get.to(
                          () => const FullscreenImageView(
                            imageUrl: ImagesPath.profileImageSVG,
                            isNetworkImage: false,
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.radius),
                      child: controller.profileImage.value != null
                          ? Image.file(
                              controller.profileImage.value!,
                              height: 110.height,
                              width: 110.width,
                              fit: BoxFit.cover,
                            )
                          : controller.profileImageUrl.value.isNotEmpty
                          ? Image.network(
                              controller.profileImageUrl.value,
                              height: 110.height,
                              width: 110.width,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    ImagesPath.profileImageSVG,
                                    height: 110.height,
                                    width: 110.width,
                                    fit: BoxFit.cover,
                                  ),
                            )
                          : Image.asset(
                              ImagesPath.profileImageSVG,
                              height: 110.height,
                              width: 110.width,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    left: 90.width,
                    bottom: 4.height,
                    child: InkWell(
                      onTap: () => controller.pickImage(true),
                      child: Container(
                        height: 35.height,
                        width: 35.width,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.radius),
                          color: AppColors.cameraBGColor,
                        ),
                        child: SvgPicture.asset(
                          IconsPath.cameraIcon,
                          height: 15.height,
                          width: 19.width,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 12.width,
              bottom: 8.height,
              child: InkWell(
                onTap: () => controller.pickImage(false),
                child: Container(
                  height: 35.height,
                  width: 35.width,
                  padding: EdgeInsets.symmetric(horizontal: 6.width, vertical: 6.height),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.radius),
                    color: AppColors.cameraBGColor,
                  ),
                  child: SvgPicture.asset(
                    IconsPath.cameraIcon,
                    height: 15.height,
                    width: 19.width,
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
