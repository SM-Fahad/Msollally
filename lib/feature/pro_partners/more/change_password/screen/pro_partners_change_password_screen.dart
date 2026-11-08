import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';
import 'package:msollaally/feature/pro_partners/more/change_password/controller/pro_partners_change_password_controller.dart';
import 'package:msollaally/feature/student/notification/widgets/custom_app_bar.dart';

class ProPartnersChangePasswordScreen extends StatelessWidget {
  ProPartnersChangePasswordScreen({super.key});

  final ProPartnersChangePasswordController controller = Get.put(
    ProPartnersChangePasswordController(),
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
              title: 'Change Password',
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.floralWhiteFFF9F4.withValues(alpha: 0.5),
              ),
              child: Column(
                children: [
                  Obx(
                    () => CustomTextFieldNodMac(
                      controller: controller.currentPasswordController,
                      lebelName: 'Current Password',
                      hinText: '••••••••',
                      obscureText: controller.obscureCurrent.value,
                      suffixIcon: IconButton(
                        onPressed: () => controller.obscureCurrent.toggle(),
                        icon: Icon(
                          controller.obscureCurrent.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      textFieldColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => CustomTextFieldNodMac(
                      controller: controller.newPasswordController,
                      lebelName: 'New Password',
                      hinText: '••••••••',
                      obscureText: controller.obscureNew.value,
                      suffixIcon: IconButton(
                        onPressed: () => controller.obscureNew.toggle(),
                        icon: Icon(
                          controller.obscureNew.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      textFieldColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => CustomTextFieldNodMac(
                      controller: controller.againPasswordController,
                      lebelName: 'Again Password',
                      hinText: '••••••••',
                      obscureText: controller.obscureAgain.value,
                      suffixIcon: IconButton(
                        onPressed: () => controller.obscureAgain.toggle(),
                        icon: Icon(
                          controller.obscureAgain.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      textFieldColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 17),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Obx(
                () => CustomButton(
                  text: controller.isSaving.value ? 'Saving...' : 'Done',
                  onPressed: controller.isSaving.value
                      ? () => EasyLoading.showInfo('Please wait...')
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
