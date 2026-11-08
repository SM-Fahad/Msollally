import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/auth/login/reset_password/service/reset_password_service.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/routes/app_route.dart';

class ResetPasswordController extends GetxController {
  final RxString phoneNumber = ''.obs;
  final RxBool isLoading = false.obs;
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  void onPhoneChanged(String completeNumber) {
    phoneNumber.value = completeNumber;
  }

  Future<void> sendOtp() async {
    if (phoneNumber.value.isEmpty) {
      EasyLoading.showError('Please enter your phone number');
      return;
    }

    try {
      isLoading.value = true;

      final result = await ResetPasswordService.sendOtp(
        phoneNumber: phoneNumber.value,
      );

      await _prefHelper.savePhoneNumber(phoneNumber.value);

      Get.toNamed(
        AppRoute.resetOtpScreen,

        arguments: {'otp': result['otp'], 'phoneNumber': phoneNumber.value},
      );
    } catch (e) {
      EasyLoading.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
