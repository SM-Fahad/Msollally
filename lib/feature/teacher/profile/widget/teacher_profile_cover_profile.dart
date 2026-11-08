import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';
import 'package:msollaally/feature/teacher/profile/controller/teacher_profile_controller.dart';

class TeacherProfileCoverAndProfilePic extends StatelessWidget {
  const TeacherProfileCoverAndProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    final TeacherProfileController controller =
        Get.isRegistered<TeacherProfileController>()
        ? Get.find<TeacherProfileController>()
        : Get.put(TeacherProfileController());

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
                } else if (controller.coverPhotoUrl.isNotEmpty) {
                  Get.to(
                    () => FullscreenImageView(
                      imageUrl: controller.coverPhotoUrl,
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
                        height: 200.h,
                      )
                    : controller.coverPhotoUrl.isNotEmpty
                    ? Image.network(
                        controller.coverPhotoUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200.h,
                        errorBuilder: (_, _, _) => Image.asset(
                          ImagesPath.coverPhoto,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200.h,
                        ),
                      )
                    : Image.asset(
                        ImagesPath.coverPhoto,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200.h,
                      ),
              ),
            ),
            Positioned(
              bottom: -19.h,
              left: 16.w,
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
                      } else if (controller.profileImageUrl.isNotEmpty) {
                        Get.to(
                          () => FullscreenImageView(
                            imageUrl: controller.profileImageUrl,
                            isNetworkImage: true,
                          ),
                        );
                      } else {
                        Get.to(
                          () => const FullscreenImageView(
                            imageUrl: ImagesPath.teacherProfileImage,
                            isNetworkImage: false,
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.r),
                      child: controller.profileImage.value != null
                          ? Image.file(
                              controller.profileImage.value!,
                              height: 110.h,
                              width: 110.w,
                              fit: BoxFit.cover,
                            )
                          : controller.profileImageUrl.isNotEmpty
                          ? Image.network(
                              controller.profileImageUrl,
                              height: 110.h,
                              width: 110.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Image.asset(
                                ImagesPath.teacherProfileImage,
                                height: 110.h,
                                width: 110.w,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              ImagesPath.teacherProfileImage,
                              height: 110.h,
                              width: 110.w,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    left: 90.w,
                    bottom: 4.h,
                    child: InkWell(
                      onTap: () => controller.pickImage(true),
                      child: Container(
                        height: 35.h,
                        width: 35.w,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.r),
                          color: AppColors.cameraBGColor,
                        ),
                        child: Icon(Icons.camera_alt_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12.w,
              bottom: 8.h,
              child: InkWell(
                onTap: () => controller.pickImage(false),
                child: Container(
                  height: 35.h,
                  width: 35.w,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    color: AppColors.cameraBGColor,
                  ),
                  child: Icon(Icons.camera_alt_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
