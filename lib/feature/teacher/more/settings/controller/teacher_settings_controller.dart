import 'dart:convert';
import 'package:msollaally/core/const/appcolors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/pro_partners/more/settings/service/pro_partners_privacy_service.dart';
import 'package:msollaally/feature/student/settings/model/device_session_model.dart';
import 'package:msollaally/feature/teacher/more/settings/model/teacher_settings_model.dart';
import 'package:msollaally/feature/teacher/profile/model/teacher_model.dart';
import 'package:msollaally/feature/teacher/profile/service/teacher_profile_service.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/routes/app_route.dart';

class TeacherSettingsController extends GetxController {
  final SharedPreferenceHelper _prefHelper;
  final TeacherProfileService _profileService;
  final ProPartnersPrivacyService _privacyService;

  TeacherSettingsController({
    SharedPreferenceHelper? prefHelper,
    TeacherProfileService? profileService,
    ProPartnersPrivacyService? privacyService,
  }) : _prefHelper = prefHelper ?? SharedPreferenceHelper(),
       _profileService = profileService ?? TeacherProfileService(),
       _privacyService = privacyService ?? ProPartnersPrivacyService();

  final Rxn<TeacherMeResponse> me = Rxn<TeacherMeResponse>();
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

  final RxList<TeacherSettingsSubscriptionModel> subscriptionsList =
      <TeacherSettingsSubscriptionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMe();
    fetchDeviceSessions();
    _seedSubscriptionItems();
  }

  Future<void> fetchMe() async {
    try {
      isLoading.value = true;
      final accessToken = await _prefHelper.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token not found');
      }

      final response = await _profileService.fetchMe(accessToken: accessToken);
      me.value = response;

      profileVisibility.value =
          _normalizePrivacy(response.profile?.profileVisibility) ?? 'anyone';
      seePlan.value = _normalizePrivacy(response.profile?.seePlan) ?? 'anyone';
      sendRequest.value =
          _normalizePrivacy(response.profile?.sendRequest) ?? 'anyone';
      seeClass.value =
          _normalizePrivacy(response.profile?.seeClass) ?? 'anyone';
      canMessage.value =
          _normalizePrivacy(response.profile?.canMessage) ?? 'anyone';
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  String? _normalizePrivacy(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = value.trim().toLowerCase();
    if (v.contains('friend')) return 'friend';
    if (v.contains('only') || v.contains('me')) return 'only_me';
    if (v.contains('any')) return 'anyone';
    return null;
  }

  Future<void> updatePrivacyField({
    required String field,
    required String newValue,
  }) async {
    final accessToken = await _prefHelper.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      EasyLoading.showError('Access token not found');
      return;
    }

    final previousValue = _getFieldValue(field);
    if (previousValue == newValue) return;

    _setFieldValue(field, newValue);

    try {
      EasyLoading.show(status: 'Saving...');
      await _privacyService.changePrivacySettings(
        accessToken: accessToken,
        body: {
          'profileVisibility': profileVisibility.value,
          'seePlan': seePlan.value,
          'sendRequest': sendRequest.value,
          'seeClass': seeClass.value,
          'canMessage': canMessage.value,
        },
      );
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Saved');
    } catch (e) {
      _setFieldValue(field, previousValue);
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
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

      final accessToken = await _prefHelper.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        deviceSessionsList.clear();
        return;
      }

      final response = await http.get(
        Uri.parse(Urls.sessions),
        headers: <String, String>{
          'accept': '*/*',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic parsed = jsonDecode(response.body);
        if (parsed is List) {
          deviceSessionsList.assignAll(
            parsed.map((e) => DeviceSessionModel.fromJson(e)).toList(),
          );
        }
      }
    } catch (_) {
      deviceSessionsList.clear();
    } finally {
      isLoadingSessions.value = false;
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
      TeacherSettingsSubscriptionModel(
        title: 'Account Status',
        valueText: 'Premium',
      ),
      TeacherSettingsSubscriptionModel(
        title: 'Amount',
        valueText: '\$25/Month',
      ),
      TeacherSettingsSubscriptionModel(title: 'Renew', valueText: 'Aug 25'),
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
