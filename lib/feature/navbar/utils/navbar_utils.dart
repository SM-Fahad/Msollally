import 'package:get/get.dart';
import 'package:msollaally/routes/app_route.dart';
import '../controller/navbar_controller.dart';
import '../model/navbar_item.dart';

class NavbarUtils {
  /// Get the navbar controller for a specific profile
  static NavbarController? getController(UserProfile profile) {
    return Get.find<NavbarController>(tag: profile.name);
  }

  /// Update notification count for a specific tab
  static void updateNotification(
    UserProfile profile,
    int tabIndex,
    String? count,
  ) {
    final controller = getController(profile);
    controller?.updateNotificationCount(tabIndex, count);
  }

  /// Clear notification for a specific tab
  static void clearNotification(UserProfile profile, int tabIndex) {
    final controller = getController(profile);
    controller?.clearNotification(tabIndex);
  }

  /// Navigate to a specific tab
  static void navigateToTab(UserProfile profile, int tabIndex) {
    final controller = getController(profile);
    controller?.changeTab(tabIndex);
  }

  /// Get current active tab index
  static int? getCurrentTabIndex(UserProfile profile) {
    final controller = getController(profile);
    return controller?.currentIndex;
  }

  /// Navigate to profile home screen using GetX named routes
  static void navigateToHome(UserProfile profile) {
    switch (profile) {
      case UserProfile.student:
        Get.toNamed(AppRoute.studentHomeScreen);
        break;
      case UserProfile.teacher:
        Get.toNamed(AppRoute.teacherHomeScreen);
        break;
      case UserProfile.recruiter:
        Get.toNamed(AppRoute.recruiterHomeScreen);
        break;
      case UserProfile.proPartners:
        Get.toNamed(AppRoute.proPartnersDashboard);
        break;
    }
  }
}
