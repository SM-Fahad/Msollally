import 'package:flutter/foundation.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/recruiter/more/profile/model/recruiter_me_model.dart';
import 'package:msollaally/feature/recruiter/more/settings/model/recruiter_settings_model.dart';
import 'package:msollaally/feature/student/settings/model/device_session_model.dart';
import 'package:msollaally/routes/app_route.dart';

class RecruiterSettingsController extends GetxController {
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();
  late final NetworkCaller _networkCaller;

  RecruiterSettingsController();

  @override
  void onInit() {
    super.onInit();
    _networkCaller = NetworkCaller();
    fetchMe();
    fetchDeviceSessions();
    _seedSubscriptionItems();
  }

  final Rxn<RecruiterMeResponse> me = Rxn<RecruiterMeResponse>();
  final RxBool isLoading = false.obs;

  final List<String> privacyOptions = const ['anyone', 'friend', 'only_me'];

  final RxString profileVisibility = 'anyone'.obs;
  final RxString seePlan = 'anyone'.obs;
  final RxString sendRequest = 'anyone'.obs;
  final RxString seeClass = 'anyone'.obs;
  final RxString canMessage = 'anyone'.obs;

  // Device sessions
  final RxList<DeviceSessionModel> deviceSessionsList =
      <DeviceSessionModel>[].obs;
  final RxBool isLoadingSessions = false.obs;
  final RxBool showAllSessions = false.obs;
  final RxString currentDeviceIp = ''.obs;

  final RxList<RecruiterSettingsSubscriptionModel> subscriptionsList =
      <RecruiterSettingsSubscriptionModel>[].obs;

  Future<void> fetchMe() async {
    try {
      isLoading.value = true;
      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await _networkCaller.getRequest(
        Urls.authMe,
        token: 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final data = response.responseData as Map<String, dynamic>;
        final profile = data['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          profileVisibility.value =
              profile['profileVisibility']?.toString() ?? 'anyone';
          seePlan.value = profile['seePlan']?.toString() ?? 'anyone';
          sendRequest.value = profile['sendRequest']?.toString() ?? 'anyone';
          seeClass.value = profile['seeClass']?.toString() ?? 'anyone';
          canMessage.value = profile['canMessage']?.toString() ?? 'anyone';
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user privacy settings: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePrivacyField({
    required String field,
    required String newValue,
  }) async {
    final previousValue = _getFieldValue(field);
    if (previousValue == newValue) return;

    _setFieldValue(field, newValue);

    try {
      EasyLoading.show(status: 'Saving...');
      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        _setFieldValue(field, previousValue);
        EasyLoading.dismiss();
        EasyLoading.showError('Authentication required');
        return;
      }

      final body = {
        'profileVisibility': profileVisibility.value,
        'seePlan': seePlan.value,
        'sendRequest': sendRequest.value,
        'seeClass': seeClass.value,
        'canMessage': canMessage.value,
      };

      final response = await _networkCaller.patchJsonRequest(
        Urls.changePrivacySettings,
        body: body,
        token: 'Bearer $token',
      );

      EasyLoading.dismiss();
      if (response.isSuccess) {
        EasyLoading.showSuccess('Privacy settings updated');
      } else {
        _setFieldValue(field, previousValue);
        EasyLoading.showError(
          response.errorMessage.isEmpty
              ? 'Failed to save'
              : response.errorMessage,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating privacy settings: $e');
      }
      _setFieldValue(field, previousValue);
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to save');
    }
  }

  String _getFieldValue(String field) {
    switch (field) {
      case 'profileVisibility':
        return profileVisibility.value;
      case 'seePlan':
        return seePlan.value;
      case 'sendRequest':
        return sendRequest.value;
      case 'seeClass':
        return seeClass.value;
      case 'canMessage':
        return canMessage.value;
      default:
        return 'anyone';
    }
  }

  void _setFieldValue(String field, String value) {
    switch (field) {
      case 'profileVisibility':
        profileVisibility.value = value;
        break;
      case 'seePlan':
        seePlan.value = value;
        break;
      case 'sendRequest':
        sendRequest.value = value;
        break;
      case 'seeClass':
        seeClass.value = value;
        break;
      case 'canMessage':
        canMessage.value = value;
        break;
      default:
        break;
    }
  }

  Future<void> fetchDeviceSessions() async {
    try {
      isLoadingSessions.value = true;
      // No remote API: load cached local sessions if available
      // No remote API: keep device sessions empty (local-only app)
      deviceSessionsList.clear();
    } catch (_) {
      // ignore
    } finally {
      isLoadingSessions.value = false;
    }
  }

  Future<void> revokeSession(int sessionId) async {
    try {
      EasyLoading.show(status: 'Revoking session...');
      deviceSessionsList.removeWhere((s) => s.id == sessionId);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Session revoked');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to revoke session');
    }
  }

  Future<void> confirmDeleteAccount() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Are you want to Delete Your Account ?',
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.black26),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await deleteAccount();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tomatoEB5757,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Yes'),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _seedSubscriptionItems() {
    if (subscriptionsList.isNotEmpty) return;
    subscriptionsList.addAll(const [
      RecruiterSettingsSubscriptionModel(
        title: 'Account Status',
        valueText: 'Premium',
      ),
      RecruiterSettingsSubscriptionModel(
        title: 'Amount',
        valueText: '\$25/Month',
      ),
      RecruiterSettingsSubscriptionModel(title: 'Renew', valueText: 'Aug 25'),
    ]);
  }

  Future<void> deleteAccount() async {
    try {
      EasyLoading.show(status: 'Deleting...');
      await _prefHelper.clearAuthSession();
      UserRoleService.clearSelectedRole();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Account deleted');
      Get.offAllNamed(AppRoute.loginScreen);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to delete account');
    }
  }
}
