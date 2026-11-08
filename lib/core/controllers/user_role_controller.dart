import 'package:get/get.dart';

/// Enum representing different user roles in the application
/// Using explicit API-aligned names requested by the app:
/// STUDENT -> 'student'
/// FACULTY -> 'faculty'
/// RECRUITER -> 'recruiter'
/// PRO_PARTNER -> 'pro_partner'
// ignore: constant_identifier_names
enum UserRole { STUDENT, FACULTY, RECRUITER, PRO_PARTNER }

/// Global controller for managing user role state throughout the application
/// This controller is independent of any specific screen and can be used anywhere
class UserRoleController extends GetxController {
  /// Reactive variable to store the selected user role index
  final RxnInt _selectedRole = RxnInt();

  /// Select a user role by index (0-3)
  void selectRole(int roleIndex) {
    if (roleIndex >= 0 && roleIndex <= 3) {
      _selectedRole.value = roleIndex;
    }
  }

  /// Select a user role by enum
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

  /// Clear the selected role (useful for logout scenarios)
  void clearSelectedRole() {
    _selectedRole.value = null;
  }

  /// Check if any role is selected
  bool get hasSelectedRole => _selectedRole.value != null;

  /// Get the selected role index (0-3)
  /// Returns null if no role is selected
  int? get selectedRoleIndex => _selectedRole.value;

  /// Get the selected role as enum
  /// Returns null if no role is selected
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

  /// Get the selected role as a readable string
  /// Returns null if no role is selected
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

  /// Get the selected role as an API value
  /// Returns null if no role is selected
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

  /// Quick boolean checks for specific roles
  bool get isStudent => selectedRole == UserRole.STUDENT;
  // kept legacy getter name `isTeacher` for compatibility; maps to FACULTY
  bool get isTeacher => selectedRole == UserRole.FACULTY;
  bool get isFaculty => selectedRole == UserRole.FACULTY;
  bool get isRecruiter => selectedRole == UserRole.RECRUITER;
  bool get isProPartners => selectedRole == UserRole.PRO_PARTNER;

  /// Get role display name by index
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

  /// Get role enum by index
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

  /// Get all available roles as a list
  static List<UserRole> get allRoles => UserRole.values;

  /// Get all available role names as a list
  static List<String> get allRoleNames => [
    'Student',
    'Faculty',
    'Recruiter',
    'Pro Partners',
  ];
}
