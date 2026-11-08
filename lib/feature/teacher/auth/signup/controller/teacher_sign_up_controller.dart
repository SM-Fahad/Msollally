import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/teacher/auth/signup/service/tercher_auth_service.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/core/services/firebase_messaging_service.dart';

class TeacherSignupController extends GetxController {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  String otp = '';
  String password = '';
  String fullName = '';
  String email = '';
  String gender = '';
  String university = '';
  String faculty = '';
  String designation = '';
  String subjectTaught = '';

  var isLoading = false.obs;
  var fullPhoneNumber = ''.obs;
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  void setPhoneNumber(String phone) {
    fullPhoneNumber.value = phone;
    debugPrint('PHONE Set: $phone');
  }

  Map<String, dynamic> getAllSignUpInfo() {
    return {
      'fullName': fullName,
      'email': email,
      'gender': gender,
      'password': password,
      'otp': otp,
    };
  }

  Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
      }
    } catch (e) {
      debugPrint("Error Failed to pick image: $e");
    }
  }

  Future<void> signUp() async {
    final name = fullNameController.text.trim();

    if (name.isEmpty) {
      debugPrint('VALIDATION Name is empty');
      _showError('Please enter your full name');
      return;
    }
    if (name.length < 3) {
      debugPrint('VALIDATION Name too short: "$name"');
      _showError('Name must be at least 3 characters');
      return;
    }

    if (fullPhoneNumber.value.isEmpty) {
      debugPrint('VALIDATION Phone is empty');
      _showError('Please enter your phone number');
      return;
    }
    final role = UserRoleService.selectedRoleApiString;
    if (role == null) {
      debugPrint('VALIDATION No role selected');
      _showError('No role selected. Please go back and select a role.');
      return;
    }

    await _prefHelper.saveSelectedRole(role);

    // Save phone number BEFORE API call
    await _prefHelper.saveUserName(
      userName: name,
      phoneNumber: fullPhoneNumber.value,
    );

    debugPrint('SIGNUP Request sending...');
    debugPrint('username   : $name');
    debugPrint('phoneNumber: ${fullPhoneNumber.value}');
    debugPrint('role       : faculty');

    try {
      isLoading.value = true;

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessagingService.getFcmToken();
      } catch (e) {
        debugPrint('Failed to get FCM Token during teacher signup: $e');
      }

      final response = await TeacherAuthService.teacherSignUp(
        phoneNumber: fullPhoneNumber.value,
        username: name,
        role: 'faculty',
        fcmToken: fcmToken,
      );

      debugPrint('Response successful!');
      debugPrint('message: ${response['message']}');
      debugPrint('otp    : ${response['otp']}');

      // Store otp
      if (response.containsKey('otp')) {
        otp = response['otp'].toString();
      }

      // ── Success EasyLoading ──
      EasyLoading.showSuccess(response['message'] ?? 'OTP sent to your phone!');

      await Future.delayed(const Duration(seconds: 1));
      Get.toNamed(AppRoute.teacherOtpScreen);
    } catch (e) {
      // ── DEBUG: Error print ──
      debugPrint('SIGNUP Error !');
      debugPrint(' $e');

      EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    EasyLoading.showError(message);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
