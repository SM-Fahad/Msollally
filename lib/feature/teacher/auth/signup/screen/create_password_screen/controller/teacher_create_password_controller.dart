import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

import 'package:msollaally/feature/teacher/auth/signup/service/tercher_auth_service.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class TeacherCreatePasswordController extends GetxController {
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  final RxString passwordStrength = "".obs;
  final RxBool isLoading = false.obs;

  String getPasswordStrength(String passwordStrength) {
    if (passwordStrength.isEmpty) return "";
    if (passwordStrength.length < 4) return "Very Weak";
    if (passwordStrength.length < 7) return "Weak";
    if (passwordStrength.length < 10) return "Medium";
    return "Strong";
  }

  int getStrengthLevel(String passwordStrength) {
    if (passwordStrength.isEmpty) return 0;
    if (passwordStrength.length < 4) return 1;
    if (passwordStrength.length < 7) return 1;
    if (passwordStrength.length < 10) return 2;
    return 3;
  }

  Future<void> setPassword({
    required String password,
    required String confirmPassword,
  }) async {
    if (password.isEmpty) {
      debugPrint('VALIDATION Password is empty');
      _showError('Please enter a password');
      return;
    }

    if (password.length < 6) {
      debugPrint('Password too short: ${password.length} chars');
      _showError('Password must be at least 6 characters');
      return;
    }

    if (confirmPassword.isEmpty) {
      debugPrint('Confirm password is empty');
      _showError('Please confirm your password');
      return;
    }

    if (password != confirmPassword) {
      debugPrint('Passwords do not match');
      _showError('Passwords do not match');
      return;
    }

    final strength = getPasswordStrength(password);
    if (strength == "Very Weak") {
      debugPrint('Password too weak: $strength');
      _showError('Password is too weak. Please use a stronger password.');
      return;
    }

    debugPrint('All validations passed. Strength: $strength');

    try {
      isLoading.value = true;

      final prefHelper = SharedPreferenceHelper();
      final accessToken = await prefHelper.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('SET PASSWORD Access token not found');
        throw Exception('Access token not found. Please signup again.');
      }

      final response = await TeacherAuthService.setPassword(
        password: password,
        accessToken: accessToken,
      );

      debugPrint('Done: ${response['message']}');

      EasyLoading.showSuccess(
        response['message'] ?? 'Password set successfully!',
        duration: const Duration(seconds: 2),
        dismissOnTap: true,
      );

      Get.offNamed(AppRoute.teacherBasicInfoScreen);
    } catch (e) {
      debugPrint('[TEACHER CREATE PASS] Error: $e');
      EasyLoading.showError(
        e.toString().replaceAll('Exception: ', ''),
        duration: const Duration(seconds: 3),
        dismissOnTap: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    EasyLoading.showError(
      message,
      duration: const Duration(seconds: 2),
      dismissOnTap: true,
    );
  }
}
