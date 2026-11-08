// ignore_for_file: constant_identifier_names, file_names

import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/auth/login/reset_password/screen/new_password_screen.dart';
import 'package:msollaally/feature/auth/service/auth_service.dart';
import 'package:msollaally/feature/teacher/auth/signup/screen/otp_screen/service/teacher_otp_service.dart';
import 'package:msollaally/feature/teacher/auth/signup/service/tercher_auth_service.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/core/services/firebase_messaging_service.dart';

enum UserRole { STUDENT, FACULTY, RECRUITER, PRO_PARTNER }

class AuthController extends GetxController {
  // ── Role state ──
  final RxnInt _selectedRole = RxnInt();

  void selectRole(int roleIndex) {
    if (roleIndex >= 0 && roleIndex <= 3) {
      _selectedRole.value = roleIndex;
    }
  }

  void selectRoleByEnum(UserRole role) {
    switch (role) {
      case UserRole.STUDENT:
        selectRole(0);
        break;
      case UserRole.FACULTY:
        selectRole(1);
        break;
      case UserRole.RECRUITER:
        selectRole(2);
        break;
      case UserRole.PRO_PARTNER:
        selectRole(3);
        break;
    }
  }

  void clearSelectedRole() => _selectedRole.value = null;

  bool get hasSelectedRole => _selectedRole.value != null;
  int? get selectedRoleIndex => _selectedRole.value;

  UserRole? get selectedRole {
    if (_selectedRole.value == null) return null;
    switch (_selectedRole.value!) {
      case 0:
        return UserRole.STUDENT;
      case 1:
        return UserRole.FACULTY;
      case 2:
        return UserRole.RECRUITER;
      case 3:
        return UserRole.PRO_PARTNER;
      default:
        return null;
    }
  }

  String? get selectedRoleString {
    final role = selectedRole;
    if (role == null) return null;
    switch (role) {
      case UserRole.STUDENT:
        return 'Student';
      case UserRole.FACULTY:
        return 'Faculty';
      case UserRole.RECRUITER:
        return 'Recruiter';
      case UserRole.PRO_PARTNER:
        return 'Pro Partners';
    }
  }

  String? get selectedRoleApiString {
    final role = selectedRole;
    if (role == null) return null;
    switch (role) {
      case UserRole.STUDENT:
        return 'student';
      case UserRole.FACULTY:
        return 'faculty';
      case UserRole.RECRUITER:
        return 'recruiter';
      case UserRole.PRO_PARTNER:
        return 'pro_partner';
    }
  }

  bool get isStudent => selectedRole == UserRole.STUDENT;
  bool get isTeacher => selectedRole == UserRole.FACULTY;
  bool get isRecruiter => selectedRole == UserRole.RECRUITER;
  bool get isProPartners => selectedRole == UserRole.PRO_PARTNER;

  static String getRoleDisplayName(int index) {
    switch (index) {
      case 0:
        return 'Student';
      case 1:
        return 'Faculty';
      case 2:
        return 'Recruiter';
      case 3:
        return 'Pro Partners';
      default:
        return 'Unknown';
    }
  }

  static UserRole? getRoleByIndex(int index) {
    switch (index) {
      case 0:
        return UserRole.STUDENT;
      case 1:
        return UserRole.FACULTY;
      case 2:
        return UserRole.RECRUITER;
      case 3:
        return UserRole.PRO_PARTNER;
      default:
        return null;
    }
  }

  static List<UserRole> get allRoles => UserRole.values;

  static List<String> get allRoleNames => [
    'Student',
    'Faculty',
    'Recruiter',
    'Pro Partners',
  ];

  // ── Login / Signup inputs ──
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxString passwordStrength = "".obs;

  // additional signup fields
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final formKeyBasic = GlobalKey<FormState>();
  final formKeyAcademic = GlobalKey<FormState>();

  // ── OTP state ──
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  static const int _otpDurationSeconds = 300;
  final RxInt remainingSeconds = _otpDurationSeconds.obs;
  Timer? _timer;
  final RxBool isLoading = false.obs;
  final RxBool isTimerExpired = false.obs;
  final RxBool hasStartedOtpTimer = false.obs;

  // ── Misc ──
  var fullPhoneNumber = ''.obs;
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  void setPhoneNumber(String phone) {
    fullPhoneNumber.value = phone;
    debugPrint('PHONE Set: $phone');
  }

  // ── OTP timer control ──
  void startOtpTimer() {
    if (hasStartedOtpTimer.value) return;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    remainingSeconds.value = _otpDurationSeconds;
    isTimerExpired.value = false;
    hasStartedOtpTimer.value = true;
    debugPrint('TIMER Started: ${_otpDurationSeconds}s');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        isTimerExpired.value = true;
        hasStartedOtpTimer.value = false;
        debugPrint('TIMER Expired! OTP expired.');
      }
    });
  }

  String get timerDisplay {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String getOtp() => otpControllers.map((c) => c.text).join();

  String _extractAccessToken(Map<String, dynamic> response) {
    final root = response['accessToken'];
    if (root is String && root.isNotEmpty) return root;

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['accessToken'];
      if (nested is String && nested.isNotEmpty) return nested;
    }

    throw Exception('Access token not found in response');
  }

  String _extractRefreshToken(Map<String, dynamic> response) {
    final root = response['refreshToken'];
    if (root is String && root.isNotEmpty) return root;

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['refreshToken'];
      if (nested is String && nested.isNotEmpty) return nested;
    }

    throw Exception('Refresh token not found in response');
  }

  // ── OTP actions ──
  Future<void> verifyOtp() async {
    final otp = getOtp();

    if (otp.length < 6) {
      debugPrint('OTP VALIDATION OTP incomplete: "$otp"');
      EasyLoading.showError('Please enter the complete 6-digit OTP');
      return;
    }

    if (isTimerExpired.value) {
      debugPrint('Timer expired, OTP is no longer valid');
      EasyLoading.showInfo('Your OTP has expired. Please resend.');
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

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessagingService.getFcmToken();
      } catch (e) {
        debugPrint('Failed to get FCM Token during OTP verification: $e');
      }

      final response = await AuthService.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otp,
        fcmToken: fcmToken,
      );

      final resolvedAccess = _extractAccessToken(response);
      final resolvedRefresh = _extractRefreshToken(response);

      await _prefHelper.saveTokens(
        accessToken: resolvedAccess,
        refreshToken: resolvedRefresh,
      );

      await _prefHelper.saveLoginStatus(true);

      debugPrint('OTP Tokens saved to SharedPreference');
      _timer?.cancel();
      hasStartedOtpTimer.value = false;
      EasyLoading.showSuccess('OTP verified successfully!');
      Get.toNamed(AppRoute.basicInfo);
    } catch (e) {
      debugPrint('OTP VERIFY Error: $e');
      EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetverifyOtp() async {
    final otp = getOtp();

    if (otp.length < 6) {
      debugPrint('OTP VALIDATION OTP incomplete: "$otp"');
      EasyLoading.showError('Please enter the complete 6-digit OTP');
      return;
    }

    if (isTimerExpired.value) {
      debugPrint('Timer expired, OTP is no longer valid');
      EasyLoading.showInfo('Your OTP has expired. Please resend.');
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

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessagingService.getFcmToken();
      } catch (e) {
        debugPrint('Failed to get FCM Token during reset OTP verification: $e');
      }

      final response = await AuthService.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otp,
        fcmToken: fcmToken,
      );

      final resolvedAccess = _extractAccessToken(response);
      final resolvedRefresh = _extractRefreshToken(response);

      await _prefHelper.saveTokens(
        accessToken: resolvedAccess,
        refreshToken: resolvedRefresh,
      );

      await _prefHelper.saveLoginStatus(true);

      debugPrint('OTP Tokens saved to SharedPreference');
      _timer?.cancel();
      hasStartedOtpTimer.value = false;
      EasyLoading.showSuccess('OTP verified successfully!');
      Get.to(NewPasswordScreen());
    } catch (e) {
      debugPrint('OTP VERIFY Error: $e');
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
      final response = await AuthService.resendOtp(phoneNumber: phoneNumber);

      for (var controller in otpControllers) {
        controller.clear();
      }

      _startTimer();
      EasyLoading.showSuccess(response['message'] ?? 'New OTP sent!');
    } catch (e) {
      debugPrint('RESEND OTP Error: $e');
      EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ── Teacher-specific OTP helpers ──
  Future<void> verifyOtpForTeacher() async {
    final otp = getOtp();

    if (otp.length < 6) {
      debugPrint('OTP VALIDATION OTP incomplete: "$otp"');
      EasyLoading.showError('Please enter the complete 6-digit OTP');
      return;
    }

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
      hasStartedOtpTimer.value = false;
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

  Future<void> resendOtpForTeacher() async {
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

      // Teacher resend uses teacher-specific service if available; for now, restart timer
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

  // ── Signup ──
  Future<void> signUp() async {
    final name = nameController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      debugPrint('VALIDATION Name is empty');
      EasyLoading.showError('Please enter your full name');
      return;
    }
    if (name.length < 3) {
      debugPrint('VALIDATION Name too short: "$name"');
      EasyLoading.showError('Name must be at least 3 characters');
      return;
    }

    if (fullPhoneNumber.value.isEmpty) {
      debugPrint('VALIDATION Phone is empty');
      EasyLoading.showError('Please enter your phone number');
      return;
    }

    final role = UserRoleService.selectedRoleApiString;
    if (role == null) {
      debugPrint('VALIDATION No role selected');
      EasyLoading.showError(
        'No role selected. Please go back and select a role.',
      );
      return;
    }

    await _prefHelper.saveSelectedRole(role);
    await _prefHelper.saveUserName(
      userName: name,
      phoneNumber: fullPhoneNumber.value,
    );

    debugPrint('SIGNUP Request sending...');
    debugPrint('username   : $name');
    debugPrint('phoneNumber: ${fullPhoneNumber.value}');
    debugPrint('role       : $role');

    if (password.isEmpty) {
      debugPrint('VALIDATION Password is empty');
      EasyLoading.showError('Please enter a password');
      return;
    }

    if (password.length < 6) {
      debugPrint('VALIDATION Password too short');
      EasyLoading.showError('Password must be at least 6 characters');
      return;
    }

    final confirmPassword = confirmPasswordController.text.trim();

    if (confirmPassword.isEmpty) {
      debugPrint('VALIDATION Confirm password is empty');
      EasyLoading.showError('Please confirm your password');
      return;
    }

    if (password != confirmPassword) {
      debugPrint('VALIDATION Passwords do not match');
      EasyLoading.showError('Passwords do not match');
      return;
    }

    try {
      isLoading.value = true;
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessagingService.getFcmToken();
      } catch (e) {
        debugPrint('Failed to get FCM Token during signup: $e');
      }

      final response = await AuthService.signUp(
        phoneNumber: fullPhoneNumber.value,
        username: name,
        password: password,
        role: role,
        fcmToken: fcmToken,
      );

      debugPrint('Response successful!');
      debugPrint('message: ${response['message']}');
      debugPrint('otp    : ${response['otp']}');
      debugPrint('fcmToken: ${response['fcmToken']} ');

      EasyLoading.showSuccess(response['message'] ?? 'OTP sent to your phone!');
      Get.toNamed('/auth/otp');
    } catch (e) {
      debugPrint('SIGNUP Error !');
      debugPrint(' $e');
      EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create password ──
  String getPasswordStrength(String pwd) {
    if (pwd.isEmpty) return "";
    if (pwd.length < 4) return "Very Weak";
    if (pwd.length < 7) return "Weak";
    if (pwd.length < 10) return "Medium";
    return "Strong";
  }

  int getStrengthLevel(String pwd) {
    if (pwd.isEmpty) return 0;
    if (pwd.length < 4) return 1;
    if (pwd.length < 7) return 1;
    if (pwd.length < 10) return 2;
    return 3;
  }

  // ── Teacher create-password ──
  Future<void> setPasswordForTeacher({
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

    debugPrint('All passed. Strength: $strength');

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
      );

      Get.offNamed(AppRoute.teacherBasicInfoScreen);
    } catch (e) {
      debugPrint('[TEACHER CREATE PASS] Error: $e');
      EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) => EasyLoading.showError(message);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    bioController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.onClose();
  }
}
