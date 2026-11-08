import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import '../controllers/user_role_controller.dart';

class UserRoleService {
  static UserRoleController? _controller;
  static final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  static void init() {
    try {
      _controller = Get.find<UserRoleController>();
    } catch (e) {
      _controller = Get.put(UserRoleController(), permanent: true);
    }
    _restoreSelectedRoleFromStorage();
  }

  static Future<void> initAsync() async {
    try {
      _controller = Get.find<UserRoleController>();
    } catch (e) {
      _controller = Get.put(UserRoleController(), permanent: true);
    }
    await _restoreSelectedRoleFromStorage();
  }

  static UserRoleController get controller {
    if (_controller == null) {
      init();
    }
    return _controller!;
  }

  static void selectRole(int roleIndex) {
    controller.selectRole(roleIndex);
    _persistSelectedRole(controller.selectedRoleApiString);
  }

  static void selectRoleByEnum(UserRole role) {
    controller.selectRoleByEnum(role);
    _persistSelectedRole(controller.selectedRoleApiString);
  }

  static void clearSelectedRole() {
    controller.clearSelectedRole();
    _prefHelper.saveSelectedRole('');
  }

  static bool get hasSelectedRole => controller.hasSelectedRole;
  static int? get selectedRoleIndex => controller.selectedRoleIndex;
  static UserRole? get selectedRole => controller.selectedRole;
  static String? get selectedRoleString => controller.selectedRoleString;
  static String? get selectedRoleApiString => controller.selectedRoleApiString;

  static bool get isStudent => controller.isStudent;
  static bool get isTeacher => controller.isTeacher;
  static bool get isRecruiter => controller.isRecruiter;
  static bool get isProPartners => controller.isProPartners;

  /// Static utility methods
  static String getRoleDisplayName(int index) =>
      UserRoleController.getRoleDisplayName(index);
  static UserRole? getRoleByIndex(int index) =>
      UserRoleController.getRoleByIndex(index);
  static List<UserRole> get allRoles => UserRoleController.allRoles;
  static List<String> get allRoleNames => UserRoleController.allRoleNames;

  /// Dispose the controller (call this when the app is closing)
  static void dispose() {
    if (_controller != null) {
      Get.delete<UserRoleController>(force: true);
      _controller = null;
    }
  }

  static Future<void> _persistSelectedRole(String? roleApiValue) async {
    if (roleApiValue == null || roleApiValue.isEmpty) {
      return;
    }
    await _prefHelper.saveSelectedRole(roleApiValue);
  }

  static Future<void> _restoreSelectedRoleFromStorage() async {
    final storedRole = await _prefHelper.getSelectedRole();
    if (storedRole == null || storedRole.isEmpty) {
      return;
    }

    switch (storedRole.toLowerCase()) {
      case 'student':
        controller.selectRoleByEnum(UserRole.STUDENT);
        break;
      case 'faculty':
      case 'teacher':
        controller.selectRoleByEnum(UserRole.FACULTY);
        break;
      case 'recruiter':
        controller.selectRoleByEnum(UserRole.RECRUITER);
        break;
      case 'pro_partner':
      case 'propartner':
        controller.selectRoleByEnum(UserRole.PRO_PARTNER);
        break;
      default:
        break;
    }
  }
}
