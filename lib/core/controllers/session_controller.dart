
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';

import '../../routes/app_route.dart';
import '../services/share_preferrance_helper.dart';

class SessionController extends FullLifeCycleController
    with FullLifeCycleMixin {
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  bool _isChecking = false;
  bool _isRedirecting = false;

  @override
  void onReady() {
    super.onReady();
    _scheduleSessionCheck(showMessage: false);
  }

  Future<void> verifySession({bool showMessage = true}) async {
    final currentRoute = Get.currentRoute;

    if (_isChecking || _isRedirecting || currentRoute.isEmpty) {
      return;
    }

    if (_isPublicRoute(currentRoute)) {
      return;
    }

    _isChecking = true;

    try {
      final accessToken = await _prefHelper.getAccessToken();
      final refreshToken = await _prefHelper.getRefreshToken();

      final hasValidSession =
          accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty;

      if (hasValidSession) {
        return;
      }

      _isRedirecting = true;
    //  await _prefHelper.clearAll();

      if (Get.currentRoute != AppRoute.loginScreen) {
        await Get.offAllNamed(AppRoute.loginScreen);
      }

      if (showMessage) {
        EasyLoading.instance
          ..backgroundColor =
              AppColors.firebrickC0392B // deep red
          ..textColor =
              AppColors.buttonColorOnboarding // white
          ..indicatorColor = AppColors.buttonColorOnboarding
          ..loadingStyle = EasyLoadingStyle.custom;

        EasyLoading.showToast(
          '⚠️  Invalid session. Please login again.',
          duration: const Duration(seconds: 3),
          toastPosition: EasyLoadingToastPosition.top,
          maskType: EasyLoadingMaskType.none,
        );
      }
    } finally {
      _isChecking = false;
      _isRedirecting = false;
    }
  }

  void _scheduleSessionCheck({bool showMessage = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        verifySession(showMessage: showMessage);
      }
    });
  }

  @override
  void onResumed() {
    _scheduleSessionCheck();
  }

  @override
  void onPaused() {}

  @override
  void onInactive() {}

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  bool _isPublicRoute(String route) {
    if (route == AppRoute.splashScreen ||
        route == AppRoute.chooseProfileScreen) {
      return true;
    }

    return route.startsWith('/auth') || route.startsWith('/teacher/auth');
  }
}
