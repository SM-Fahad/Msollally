import 'dart:convert';
import 'package:msollaally/core/const/appcolors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/pro_partners/dashboard/model/pro_partner_me_model.dart';
import 'package:msollaally/feature/pro_partners/dashboard/service/pro_partners_me_service.dart';
import 'package:msollaally/feature/pro_partners/more/service/pro_partners_account_service.dart';
import 'package:msollaally/feature/pro_partners/more/settings/service/pro_partners_privacy_service.dart';
import 'package:msollaally/feature/pro_partners/more/settings/model/pro_partners_settings_subscription_model.dart';
import 'package:msollaally/feature/student/settings/model/device_session_model.dart';
import 'package:msollaally/routes/app_route.dart';

class ProPartnersSettingsController extends GetxController {
  final ProPartnersDashboardService _meService;
  final SharedPreferenceHelper _prefHelper;
  final ProPartnersPrivacyService _privacyService;
  final ProPartnersAccountService _accountService;

  ProPartnersSettingsController({
    ProPartnersDashboardService? meService,
    SharedPreferenceHelper? prefHelper,
    ProPartnersPrivacyService? privacyService,
    ProPartnersAccountService? accountService,
  }) : _meService = meService ?? ProPartnersDashboardService(),
       _prefHelper = prefHelper ?? SharedPreferenceHelper(),
       _privacyService = privacyService ?? ProPartnersPrivacyService(),
       _accountService = accountService ?? ProPartnersAccountService();

  final Rxn<ProPartnerMeResponse> me = Rxn<ProPartnerMeResponse>();
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

  // Subscription (UI only for now)
  final RxList<ProPartnersSettingsSubscriptionModel> subscriptionsList =
      <ProPartnersSettingsSubscriptionModel>[].obs;

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

      final response = await _meService.fetchMe(accessToken: accessToken);
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
      // keep defaults
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
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          deviceSessionsList.value = decoded
              .map((e) => DeviceSessionModel.fromJson(e))
              .toList();
        }
      }

      // Fetch current device public IP (best effort)
      try {
        final ipResponse = await http.get(
          Uri.parse('https://api.ipify.org?format=json'),
        );
        if (ipResponse.statusCode == 200) {
          final ipDecoded = jsonDecode(ipResponse.body);
          final ip = ipDecoded is Map<String, dynamic> ? ipDecoded['ip'] : null;
          if (ip != null) currentDeviceIp.value = ip.toString();
        }
      } catch (_) {}
    } catch (_) {
      // ignore
    } finally {
      isLoadingSessions.value = false;
    }
  }

  Future<void> revokeSession(int sessionId) async {
    try {
      EasyLoading.show(status: 'Revoking session...');
      final accessToken = await _prefHelper.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showError('Access token not found');
        return;
      }

      final response = await http.delete(
        Uri.parse(Urls.sessionById(sessionId)),
        headers: <String, String>{
          'accept': '*/*',
          'Authorization': 'Bearer $accessToken',
        },
      );

      EasyLoading.dismiss();
      if (response.statusCode == 200 || response.statusCode == 201) {
        deviceSessionsList.removeWhere((s) => s.id == sessionId);
        EasyLoading.showSuccess('Session revoked');
      } else {
        try {
          final decoded = jsonDecode(response.body);
          final msg = decoded is Map<String, dynamic>
              ? decoded['message']
              : null;
          EasyLoading.showError(msg?.toString() ?? 'Failed to revoke session');
        } catch (_) {
          EasyLoading.showError('Failed to revoke session');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
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
      ProPartnersSettingsSubscriptionModel(
        title: 'Account Status',
        valueText: 'Approved',
      ),
      ProPartnersSettingsSubscriptionModel(
        title: 'Registration Mode',
        valueText: 'App Initiated',
      ),
      ProPartnersSettingsSubscriptionModel(
        title: 'Verification',
        valueText: 'Admin Portal Approved',
      ),
      ProPartnersSettingsSubscriptionModel(
        title: 'Access Level',
        valueText: 'Verified Pro-Partner',
      ),
    ]);
  }

  Future<void> deleteAccount() async {
    final accessToken = await _prefHelper.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      EasyLoading.showError('Access token not found');
      return;
    }

    final userIdStr = await _prefHelper.getUserId();
    final userId = int.tryParse((userIdStr ?? '').trim());
    if (userId == null) {
      EasyLoading.showError('User id not found');
      return;
    }

    try {
      EasyLoading.show(status: 'Deleting...');
      await _accountService.deleteAccount(
        accessToken: accessToken,
        userId: userId,
      );
      await _prefHelper.clearAuthSession();
      UserRoleService.clearSelectedRole();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Account deleted');
      Get.offAllNamed(AppRoute.loginScreen);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
