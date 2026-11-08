// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/firebase_messaging_service.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/auth/service/auth_service.dart';
import 'package:msollaally/routes/app_route.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isPasswordHidden = true.obs;
  final RxBool isLoading = false.obs;
  final RxString fullPhoneNumber = ''.obs;

  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  void setPhoneNumber(String phone) {
    fullPhoneNumber.value = phone;
    debugPrint('Set: $phone');
  }

  Future<void> login() async {
    final password = passwordController.text.trim();

    if (fullPhoneNumber.value.isEmpty) {
      debugPrint('Phone is empty');
      _showError('Please enter your phone number');
      return;
    }

    if (password.isEmpty) {
      debugPrint('Password is empty');
      _showError('Please enter your password');
      return;
    }
    if (password.length < 6) {
      debugPrint('Password too short');
      _showError('Password must be at least 6 characters');
      return;
    }

    debugPrint('Request sending...');
    debugPrint('phoneNumber: ${fullPhoneNumber.value}');
    debugPrint('password   : $password');

    try {
      isLoading.value = true;

      final fcmToken = await FirebaseMessagingService.getFcmToken();

      final response = await AuthService.login(
        phoneNumber: fullPhoneNumber.value,
        password: password,
        fcmToken: fcmToken,
      );

      final resolvedAccessToken = _extractAccessToken(response);
      final resolvedRefreshToken = _extractRefreshToken(response);
      final resolvedRole = _extractRole(response);

      debugPrint(
        '🔍 LOGIN DEBUG - Extracted role from response: "$resolvedRole"',
      );

      await _prefHelper.saveTokens(
        accessToken: resolvedAccessToken,
        refreshToken: resolvedRefreshToken,
      );

      await _prefHelper.saveLoginStatus(true);
      await _persistRole(resolvedRole);

      try {
        await AuthService.fetchMeAndStoreUserId();
      } catch (e) {
        debugPrint('FETCH ME Failed: $e');
      }

      // VERIFY what was actually saved
      final verifyRole = await _prefHelper.getSelectedRole();
      debugPrint(
        '🔍 LOGIN DEBUG - Verified saved role in SharedPrefs: "$verifyRole"',
      );

      debugPrint('LOGIN Tokens saved to SharedPreference');
      debugPrint('LOGIN Resolved role: $resolvedRole');
      debugPrint('Login successful!');

      EasyLoading.showSuccess('Logged in successfully');

      // Navigate to role-specific home screen
      final savedRole = await _prefHelper.getSelectedRole();
      debugPrint('🔍 LOGIN DEBUG - Final role before navigation: "$savedRole"');
      _navigateToRoleSpecificScreen(resolvedRole ?? savedRole);
    } catch (e) {
      debugPrint('LOGIN Error !!!');
      debugPrint('    $e');

      EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _persistRole(String? role) async {
    if (role == null || role.isEmpty) {
      debugPrint('🔍 PERSIST_ROLE DEBUG - Role is null or empty, skipping');
      return;
    }

    final normalizedRole = role.toLowerCase();
    debugPrint(
      '🔍 PERSIST_ROLE DEBUG - Input role: "$role", normalized: "$normalizedRole"',
    );

    switch (normalizedRole) {
      case 'faculty':
      case 'teacher':
        UserRoleService.selectRole(1);
        break;
      case 'recruiter':
        UserRoleService.selectRole(2);
        break;
      case 'pro_partner':
      case 'propartner':
        UserRoleService.selectRole(3);
        break;
      case 'student':
      default:
        UserRoleService.selectRole(0);
        break;
    }

    debugPrint('🔍 PERSIST_ROLE DEBUG - Role saved successfully');
  }

  String _extractAccessToken(Map<String, dynamic> response) {
    final rootToken = response['accessToken'];
    if (rootToken is String && rootToken.isNotEmpty) {
      return rootToken;
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nestedToken = data['accessToken'];
      if (nestedToken is String && nestedToken.isNotEmpty) {
        return nestedToken;
      }
    }

    throw Exception('Access token not found in login response');
  }

  String _extractRefreshToken(Map<String, dynamic> response) {
    final rootToken = response['refreshToken'];
    if (rootToken is String && rootToken.isNotEmpty) {
      return rootToken;
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nestedToken = data['refreshToken'];
      if (nestedToken is String && nestedToken.isNotEmpty) {
        return nestedToken;
      }
    }

    throw Exception('Refresh token not found in login response');
  }

  String? _extractRole(Map<String, dynamic> response) {
    debugPrint('🔍 EXTRACT_ROLE DEBUG - Full response: $response');

    final rootRole = response['role'];
    if (rootRole is String && rootRole.isNotEmpty) {
      debugPrint(
        '🔍 EXTRACT_ROLE DEBUG - Found role at root level: "$rootRole"',
      );
      return rootRole;
    }

    final user = response['user'];
    if (user is Map<String, dynamic>) {
      final userRole = user['role'];
      if (userRole is String && userRole.isNotEmpty) {
        debugPrint(
          '🔍 EXTRACT_ROLE DEBUG - Found role in user object: "$userRole"',
        );
        return userRole;
      }
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final dataRole = data['role'];
      if (dataRole is String && dataRole.isNotEmpty) {
        debugPrint(
          '🔍 EXTRACT_ROLE DEBUG - Found role in data.role: "$dataRole"',
        );
        return dataRole;
      }

      final dataUser = data['user'];
      if (dataUser is Map<String, dynamic>) {
        final nestedRole = dataUser['role'];
        if (nestedRole is String && nestedRole.isNotEmpty) {
          debugPrint(
            '🔍 EXTRACT_ROLE DEBUG - Found role in data.user.role: "$nestedRole"',
          );
          return nestedRole;
        }
      }
    }

    debugPrint(
      '🔍 EXTRACT_ROLE DEBUG - NO ROLE FOUND ANYWHERE! Returning null',
    );
    return null;
  }

  /// Navigate to role-specific home screen based on user role
  void _navigateToRoleSpecificScreen(String? userRole) {
    debugPrint('🔍 NAVIGATE DEBUG - USER ROLE RECEIVED: "$userRole"');
    debugPrint(
      '🔍 NAVIGATE DEBUG - Role lowercase: "${userRole?.toLowerCase()}"',
    );

    switch (userRole?.toLowerCase()) {
      case 'faculty':
      case 'teacher':
        debugPrint(
          '🔍 NAVIGATE DEBUG - Matched: TEACHER - Going to teacherHomeScreen',
        );
        Get.offAllNamed(AppRoute.teacherHomeScreen);
        break;
      case 'recruiter':
        debugPrint(
          '🔍 NAVIGATE DEBUG - Matched: RECRUITER - Going to recruiterHomeScreen',
        );
        Get.offAllNamed(AppRoute.recruiterHomeScreen);
        break;
      case 'pro_partner':
      case 'propartner':
        debugPrint(
          '🔍 NAVIGATE DEBUG - Matched: PRO_PARTNER - Going to proPartnersDashboard',
        );
        Get.offAllNamed(AppRoute.proPartnersDashboard);
        break;
      case 'student':
        debugPrint(
          '🔍 NAVIGATE DEBUG - Matched: STUDENT - Going to studentHomeScreen',
        );
        Get.offAllNamed(AppRoute.studentHomeScreen);
        break;
      default:
        debugPrint(
          '🔍 NAVIGATE DEBUG - NO MATCH (default) - Going to studentHomeScreen',
        );
        Get.offAllNamed(AppRoute.studentHomeScreen);
        break;
    }
  }

  /// Error toast helper
  void _showError(String message) {
    EasyLoading.showError(message);
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
