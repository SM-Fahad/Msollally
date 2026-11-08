import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/firebase_messaging_service.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/more/change_password/service/pro_partners_change_password_service.dart';

class ProPartnersChangePasswordController extends GetxController {
  final ProPartnersChangePasswordService _service;
  final SharedPreferenceHelper _prefHelper;

  ProPartnersChangePasswordController({
    ProPartnersChangePasswordService? service,
    SharedPreferenceHelper? prefHelper,
  }) : _service = service ?? ProPartnersChangePasswordService(),
       _prefHelper = prefHelper ?? SharedPreferenceHelper();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final againPasswordController = TextEditingController();

  final RxBool obscureCurrent = true.obs;
  final RxBool obscureNew = true.obs;
  final RxBool obscureAgain = true.obs;

  final RxBool isSaving = false.obs;

  Future<void> save() async {
    final current = currentPasswordController.text.trim();
    final next = newPasswordController.text.trim();
    final again = againPasswordController.text.trim();

    if (current.isEmpty) {
      EasyLoading.showError('Current password is required');
      return;
    }
    if (next.isEmpty) {
      EasyLoading.showError('New password is required');
      return;
    }
    if (next.length < 6) {
      EasyLoading.showError('Password must be at least 6 characters');
      return;
    }
    if (again != next) {
      EasyLoading.showError('Passwords do not match');
      return;
    }

    final accessToken = await _prefHelper.getAccessToken();
    final refreshToken = await _prefHelper.getRefreshToken();
    if (accessToken == null || accessToken.isEmpty) {
      EasyLoading.showError('Access token not found');
      return;
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      EasyLoading.showError('Refresh token not found');
      return;
    }

    isSaving.value = true;
    try {
      EasyLoading.show(status: 'Updating...');
      await _service.changePassword(
        accessToken: accessToken,
        refreshToken: refreshToken,
        previousPassword: current,
        newPassword: next,
      );
      EasyLoading.dismiss();

      // Dispatch local security notification & alert
      await FirebaseMessagingService.showLocalSecurityNotification(
        title: 'Security Notice',
        body: 'Your account password was successfully updated. A confirmation email has been dispatched for security verification.',
      );

      EasyLoading.showSuccess(
        'Password updated.\nSecurity notification & confirmation email sent.',
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.back();
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    againPasswordController.dispose();
    super.onClose();
  }
}
