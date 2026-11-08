import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/routes/app_route.dart';

class SplashController extends GetxController {
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  @override
  void onInit() {
    super.onInit();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final accessToken = await _prefHelper.getAccessToken();
      final refreshToken = await _prefHelper.getRefreshToken();

      debugPrint(
        '🔍 SPLASH DEBUG - AccessToken exists: ${accessToken != null && accessToken.isNotEmpty}',
      );
      debugPrint(
        '🔍 SPLASH DEBUG - RefreshToken exists: ${refreshToken != null && refreshToken.isNotEmpty}',
      );

      if (accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        debugPrint('🔍 SPLASH DEBUG - Both tokens found, navigating to home');
        _navigateToHome();
      } else {
        debugPrint('🔍 SPLASH DEBUG - Tokens missing, going to onboarding');
        Get.offNamed(AppRoute.signUpScreenOnboarding);
      }
    } catch (e) {
      debugPrint('Error during auth check: $e');
      Get.offNamed(AppRoute.signUpScreenOnboarding);
    }
  }

  Future<void> _navigateToHome() async {
    try {
      final selectedRole = await _prefHelper.getSelectedRole();

      debugPrint(
        '🔍 SPLASH DEBUG - Selected role from SharedPrefs: "$selectedRole"',
      );
      debugPrint(
        '🔍 SPLASH DEBUG - Role lowercase: "${selectedRole?.toLowerCase()}"',
      );

      String route;
      switch (selectedRole?.toLowerCase()) {
        case 'faculty':
        case 'teacher':
          debugPrint('🔍 SPLASH DEBUG - Matched role: TEACHER');
          UserRoleService.selectRole(1);
          route = AppRoute.teacherHomeScreen;
          break;
        case 'recruiter':
          debugPrint('🔍 SPLASH DEBUG - Matched role: RECRUITER');
          UserRoleService.selectRole(2);
          route = AppRoute.recruiterHomeScreen;
          break;
        case 'pro_partner':
        case 'propartner':
          debugPrint('🔍 SPLASH DEBUG - Matched role: PRO_PARTNER');
          UserRoleService.selectRole(3);
          route = AppRoute.proPartnersDashboard;
          break;
        case 'student':
          debugPrint('🔍 SPLASH DEBUG - Matched role: STUDENT');
          UserRoleService.selectRole(0);
          route = AppRoute.studentHomeScreen;
          break;
        default:
          debugPrint('🔍 SPLASH DEBUG - NO MATCH (Choose Profile)');
          _prefHelper.clearTokens();
          route = AppRoute.chooseProfileScreen;
      }

      debugPrint('🔍 SPLASH DEBUG - Navigating to: $route');
      Get.offNamed(route);
    } catch (e) {
      debugPrint('Error navigating to home: $e');
      _prefHelper.clearTokens();
      Get.offNamed(AppRoute.chooseProfileScreen);
    }
  }
}
