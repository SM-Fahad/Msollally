import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/teacher/auth/signup/controller/teacher_sign_up_controller.dart';

class TeacherUploadYourPhoto extends StatelessWidget {
  TeacherUploadYourPhoto({super.key});

  final TeacherSignupController controller = Get.put(TeacherSignupController());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            controller.profileImage.value == null
                ? GestureDetector(
                    onTap: () {
                      controller.pickImage();
                    },
                    child: Image.asset(
                      ImagesPath.teacherUploadPhotoPng,
                      scale: 2,
                    ),
                  )
                : CircleAvatar(
                    radius: 42,
                    backgroundImage: FileImage(controller.profileImage.value!),
                  ),
            SizedBox(height: 13.h),
            Text(
              "Upload Your Photo",
              style: TextStyle(
                color: AppColors.black000000,
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
