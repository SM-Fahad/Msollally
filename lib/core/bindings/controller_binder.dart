import 'package:get/get.dart';

import '../../feature/navbar/controller/navbar_controller.dart';
import '../../feature/navbar/model/navbar_item.dart';
import '../../feature/splash/splash_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // Splash Controller
    Get.put<SplashController>(SplashController(), permanent: true);
    //  Get.put<SessionController>(SessionController(), permanent: true);

    // Navbar Controllers for each profile
    Get.lazyPut<NavbarController>(
      () => NavbarController(userProfile: UserProfile.student),
      tag: UserProfile.student.name,
      fenix: true,
    );

    Get.lazyPut<NavbarController>(
      () => NavbarController(userProfile: UserProfile.teacher),
      tag: UserProfile.teacher.name,
      fenix: true,
    );

    Get.lazyPut<NavbarController>(
      () => NavbarController(userProfile: UserProfile.recruiter),
      tag: UserProfile.recruiter.name,
      fenix: true,
    );

    Get.lazyPut<NavbarController>(
      () => NavbarController(userProfile: UserProfile.proPartners),
      tag: UserProfile.proPartners.name,
      fenix: true,
    );

    // Add other controllers here as needed
    // Get.lazyPut<LogInController>(
    //       () => LogInController(),
    //   fenix: true,
    // );
  }
}
