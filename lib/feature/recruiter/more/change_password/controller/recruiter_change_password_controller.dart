import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/recruiter/more/change_password/service/recruiter_change_password_service.dart';

class RecruiterChangePasswordController extends GetxController {
  final RecruiterChangePasswordService _service;
  final SharedPreferenceHelper _prefHelper;

  RecruiterChangePasswordController({
    RecruiterChangePasswordService? service,
    SharedPreferenceHelper? prefHelper,
  }) : _service = service ?? RecruiterChangePasswordService(),
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
      EasyLoading.showSuccess('Password updated');
      await Future.delayed(const Duration(milliseconds: 300));
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
