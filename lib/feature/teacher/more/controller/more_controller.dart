import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/auth/service/auth_service.dart';
import 'package:msollaally/feature/teacher/more/model/profile_option.dart';
import 'package:msollaally/routes/app_route.dart';

class MoreController extends GetxController {
  final isLoggingOut = false.obs;

  var options = <ProfileOption>[
    ProfileOption(title: "Settings"),
    ProfileOption(title: "Session"),
    ProfileOption(title: "Edit Profile"),
    ProfileOption(title: "Help & Support"),
    ProfileOption(title: "Send Feedback"),
    ProfileOption(title: "About LinkYetu"),
    ProfileOption(title: "Terms & Conditions"),
    ProfileOption(title: "Privacy Policy"),
    ProfileOption(title: "Logout"),
  ].obs;

  Future<void> logout() async {
    if (isLoggingOut.value) {
      return;
    }

    try {
      isLoggingOut.value = true;

      await AuthService.logout();

      final prefHelper = SharedPreferenceHelper();
      await prefHelper.clearTokens();

      Get.back();
      Get.offAllNamed(AppRoute.loginScreen);
    } catch (_) {
      final prefHelper = SharedPreferenceHelper();
      await prefHelper.clearTokens();

      Get.back();
      Get.offAllNamed(AppRoute.loginScreen);
    } finally {
      isLoggingOut.value = false;
    }
  }
}
