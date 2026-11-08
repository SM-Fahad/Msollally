import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';
import 'package:msollaally/feature/pro_partners/more/profile/edit_profile/controller/pro_partners_edit_profile_controller.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

class ProPartnersEditProfileScreen extends StatelessWidget {
  ProPartnersEditProfileScreen({super.key});

  final ProPartnersEditProfileController controller = Get.put(
    ProPartnersEditProfileController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leadingIcon: const Icon(
                Icons.arrow_back,
                color: AppColors.appBarTitleColor,
              ),
              onLeadingTap: () => Get.back(),
              title: controller.title,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.floralWhiteFFF9F4.withValues(alpha: 0.5),
              ),
              child: controller.field == ProPartnersEditField.name
                  ? Column(
                      children: [
                        CustomTextFieldNodMac(
                          controller: controller.firstNameController,
                          lebelName: 'First Name',
                          hinText: 'e.g. name',
                          textFieldColor: Colors.transparent,
                        ),
                        const SizedBox(height: 16),
                        CustomTextFieldNodMac(
                          controller: controller.lastNameController,
                          lebelName: 'Last Name',
                          hinText: 'e.g. name',
                          textFieldColor: Colors.transparent,
                        ),
                      ],
                    )
                  : CustomTextFieldNodMac(
                      controller: controller.valueController,
                      lebelName: controller.title,
                      hinText: 'e.g. value',
                      textFieldColor: Colors.transparent,
                    ),
            ),
            const SizedBox(height: 17),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Obx(
                () => CustomButton(
                  text: controller.isSaving.value ? 'Saving...' : 'Done',
                  onPressed: controller.isSaving.value
                      ? () {}
                      : controller.save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
