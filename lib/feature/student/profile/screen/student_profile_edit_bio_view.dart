import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/profile/service/profile_service.dart';

class StudentProfileEditBioView extends StatelessWidget {
  const StudentProfileEditBioView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<StudentProfileController>();
    final profileService = Get.find<ProfileService>();
    final bioController = TextEditingController(
      text: Get.arguments?['bio'] ?? '',
    );

    Future<void> saveBio() async {
      final bio = bioController.text.trim();

      if (bio.isEmpty) {
        EasyLoading.showError('Bio cannot be empty');
        return;
      }

      try {
        profileController.isLoadingEdit.value = true;
        EasyLoading.show(status: 'Updating...');

        final success = await profileService.updateProfile(bio: bio);

        if (success) {
          EasyLoading.showSuccess('Bio updated successfully!');
          await Future.delayed(const Duration(milliseconds: 500));
          Get.back(result: {'titleValue': bio});
        } else {
          EasyLoading.showError(profileService.responseMessage.value);
        }
      } catch (e) {
        EasyLoading.showError('Error: $e');
      } finally {
        profileController.isLoadingEdit.value = false;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leadingIcon: Icon(Icons.arrow_back, color: AppColors.appBarTitleColor),
              onLeadingTap: () {
                Get.back();
              },
              title: "Bio",
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.width, vertical: 17.height),
              padding: EdgeInsets.symmetric(horizontal: 15.width, vertical: 24.height),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.radius),
                color: AppColors.floralWhiteFFF9F4.withValues(alpha: 0.5),
              ),
              child: Column(
                children: [
                  CustomTextFieldNodMac(
                    controller: bioController,
                    lebelName: "Bio",
                    hinText: "e.g. Write about yourself",
                    textFieldColor: Colors.transparent,
                  ),
                ],
              ),
            ),
            SizedBox(height: 17.height),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 35.width),
              child: Obx(
                () => CustomButton(
                  text: profileController.isLoadingEdit.value
                      ? "Saving..."
                      : "Done",
                  onPressed: profileController.isLoadingEdit.value
                      ? () {}
                      : saveBio,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
