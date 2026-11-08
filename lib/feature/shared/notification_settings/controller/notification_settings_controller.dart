import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/shared/notification_settings/model/notification_preference_model.dart';

class NotificationSettingsController extends GetxController {
  final SharedPreferenceHelper _prefHelper;

  NotificationSettingsController({SharedPreferenceHelper? prefHelper})
      : _prefHelper = prefHelper ?? SharedPreferenceHelper();

  var inAppEnabled = true.obs;
  var emailEnabled = true.obs;
  var pushEnabled = true.obs;
  var isLoading = false.obs;
  var isUpdating = false.obs;
  
  NotificationPreferenceModel? currentPreference;

  @override
  void onInit() {
    super.onInit();
    fetchNotificationPreferences();
  }

  Future<void> fetchNotificationPreferences() async {
    try {
      isLoading.value = true;
      final accessToken = await _prefHelper.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        isLoading.value = false;
        return;
      }

      final Uri url = Uri.parse(Urls.notificationPreferencesMe);
      final http.Response response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final pref = NotificationPreferenceModel.fromJson(decoded.first);
          currentPreference = pref;
          inAppEnabled.value = pref.inAppEnabled;
          emailEnabled.value = pref.emailEnabled;
          pushEnabled.value = pref.pushEnabled;
        }
      } else {
        debugPrint('Failed to fetch notification preferences: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchNotificationPreferences Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePreference({
    bool? inApp,
    bool? email,
    bool? push,
  }) async {
    final accessToken = await _prefHelper.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      EasyLoading.showError('Access token not found');
      return;
    }

    final oldInApp = inAppEnabled.value;
    final oldEmail = emailEnabled.value;
    final oldPush = pushEnabled.value;

    final newInApp = inApp ?? oldInApp;
    final newEmail = email ?? oldEmail;
    final newPush = push ?? oldPush;

    // Optimistic Update
    inAppEnabled.value = newInApp;
    emailEnabled.value = newEmail;
    pushEnabled.value = newPush;

    try {
      isUpdating.value = true;
      final Map<String, dynamic> body = {
        "type": "grade_update",
        "category": "all",
        "inAppEnabled": newInApp,
        "emailEnabled": newEmail,
        "pushEnabled": newPush,
      };

      final Uri url = Uri.parse(Urls.notificationPreferences);
      final http.Response response = await http.put(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        currentPreference = NotificationPreferenceModel.fromJson(decoded);
      } else {
        // Revert Optimistic Update
        inAppEnabled.value = oldInApp;
        emailEnabled.value = oldEmail;
        pushEnabled.value = oldPush;
        
        final responseBody = jsonDecode(response.body);
        var message = responseBody['message'] ?? 'Failed to update preferences';
        debugPrint(message.toString());
      }
    } catch (e) {
      // Revert Optimistic Update
      inAppEnabled.value = oldInApp;
      emailEnabled.value = oldEmail;
      pushEnabled.value = oldPush;
      debugPrint('updatePreference Error: $e');
    } finally {
      isUpdating.value = false;
    }
  }
}
