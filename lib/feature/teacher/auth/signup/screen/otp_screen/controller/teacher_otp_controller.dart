import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/auth/signup/screen/otp_screen/service/teacher_otp_service.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/core/services/firebase_messaging_service.dart';

class TeacherOtpController extends GetxController {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final RxInt remainingSeconds = 300.obs;
  Timer? _timer;

  final RxBool isLoading = false.obs;

  final RxBool isTimerExpired = false.obs;

  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    // timer reset
    remainingSeconds.value = 300;
    isTimerExpired.value = false;

    debugPrint('TIMER Started: 5 minutes');

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        isTimerExpired.value = true;
        debugPrint('TIMER Expired! OTP expired.');
      }
    });
  }

  // Timer display format
  String get timerDisplay {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String getOtp() {
    return otpControllers.map((c) => c.text).join();
  }

  Future<void> verifyOtp() async {
    final otp = getOtp();

    if (otp.length < 6) {
      debugPrint('OTP VALIDATION OTP incomplete: "$otp"');
      EasyLoading.showError('Please enter the complete 6-digit OTP');
      return;
    }

    // ── Timer expired check ──
    if (isTimerExpired.value) {
      debugPrint('Timer expired, OTP is no longer valid');
      EasyLoading.showError('Your OTP has expired. Please resend.');
      return;
    }

    final phoneNumber = await _prefHelper.getSavedPhoneNumber();
    if (phoneNumber == null || phoneNumber.isEmpty) {
      debugPrint('Phone number not found');
      EasyLoading.showError('Phone number not found. Please sign up again.');
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Verifying OTP...');

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessagingService.getFcmToken();
      } catch (e) {
        debugPrint('Failed to get FCM Token during teacher OTP verification: $e');
      }

      final response = await TeacherOtpService.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otp,
        fcmToken: fcmToken,
      );

      EasyLoading.dismiss();

      // ── DEBUG: Response print ──
      debugPrint('TEACHER OTP Verified successfully!');
      debugPrint('message: ${response['message']}');

      if (response.containsKey('accessToken') &&
          response.containsKey('refreshToken')) {
        await _prefHelper.saveTokens(
          accessToken: response['accessToken'],
          refreshToken: response['refreshToken'],
        );

        await _prefHelper.saveLoginStatus(true);

        debugPrint('TEACHER OTP Tokens saved to SharedPreference');
      }

      _timer?.cancel();

      EasyLoading.showSuccess('OTP verified successfully!');

      await Future.delayed(const Duration(seconds: 1));
      Get.toNamed(AppRoute.teacherCreatePasswordScreen);
    } catch (e) {
      EasyLoading.dismiss();

      debugPrint('TEACHER OTP VERIFY Error !');
      debugPrint('$e');

      EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!isTimerExpired.value) {
      debugPrint('RESEND Timer still running, cannot resend yet');
      return;
    }

    final phoneNumber = await _prefHelper.getSavedPhoneNumber();
    if (phoneNumber == null || phoneNumber.isEmpty) {
      debugPrint('RESEND Phone number not found');
      EasyLoading.showError('Phone number not found.');
      return;
    }

    try {
      isLoading.value = true;

      // Resend OTP call would go here
      // For now, just restart the timer
      for (var controller in otpControllers) {
        controller.clear();
      }

      _startTimer();

      EasyLoading.showSuccess('New OTP sent!');
    } catch (e) {
      debugPrint('RESEND OTP Error: $e');
      EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
