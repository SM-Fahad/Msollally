import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import '../controller/student_campus_student_public_profile_controller.dart';

import '../../../../../core/const/images_path.dart';
import '../../../../../core/common/widgets/fullscreen_image_view.dart';

class StudentPublicProfileCoverAndProfilePic extends StatelessWidget {
  const StudentPublicProfileCoverAndProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentPublicProfileController>();

    return Obx(() {
      return SizedBox(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Cover Photo
            GestureDetector(
              onTap: () {
                if (controller.coverPhoto.value.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => FullscreenImageView(
                        imageUrl: controller.coverPhoto.value,
                        isNetworkImage: true,
                      ),
                    ),
                  );
                }
              },
              child: SizedBox(
                child: controller.coverPhoto.value.isNotEmpty
                    ? Image.network(
                        controller.coverPhoto.value,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200.height,
                        errorBuilder: (_, __, ___) => _defaultCover(),
                      )
                    : _defaultCover(),
              ),
            ),

            /// Profile Picture
            Positioned(
              bottom: -19.height,
              left: 16.width,
              child: GestureDetector(
                onTap: () {
                  if (controller.profilePicture.value.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => FullscreenImageView(
                          imageUrl: controller.profilePicture.value,
                          isNetworkImage: true,
                        ),
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.radius),
                  child: controller.profilePicture.value.isNotEmpty
                      ? Image.network(
                          controller.profilePicture.value,
                          height: 110.height,
                          width: 110.width,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _defaultProfile(),
                        )
                      : _defaultProfile(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _defaultCover() {
    return Image.asset(
      ImagesPath.coverPhoto,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200.height,
    );
  }

  Widget _defaultProfile() {
    return Image.asset(
      ImagesPath.profilePNG,
      height: 110.height,
      width: 110.width,
      fit: BoxFit.cover,
    );
  }
}
