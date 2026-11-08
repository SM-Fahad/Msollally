import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/student/settings/model/student_settings_notification_model.dart';
import 'package:msollaally/feature/student/settings/model/student_settings_subscription_model.dart';
import 'package:msollaally/feature/student/settings/model/device_session_model.dart';
import 'package:msollaally/routes/app_route.dart';

class StudentSettingsController extends GetxController {
  var notificationTypeList = <StudentSettingsNotificationModel>[].obs;
  var subscriptionsList = <StudentSettingsSubscriptionModel>[].obs;

  // Privacy Settings Observables
  var profileVisibility = 'anyone'.obs;
  var seePlan = 'anyone'.obs;
  var sendRequest = 'anyone'.obs;
  var seeClass = 'anyone'.obs;
  var canMessage = 'anyone'.obs;

  // Privacy Dropdown Options
  final List<String> privacyOptions = ['anyone', 'friend', 'only_me'];

  var isUpdatingPrivacy = false.obs;

  var isLoadingPrivacy = false.obs;

  // Device Sessions Observables
  var deviceSessionsList = <DeviceSessionModel>[].obs;
  var isLoadingSessions = false.obs;
  var showAllSessions = false.obs;
  var currentDeviceIp = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrivacySettings();
    fetchDeviceSessions();
    // for notification
    notificationTypeList.addAll([
      StudentSettingsNotificationModel(
        isTapped: false.obs,
        subTitle: "When you complete a milestone",
        title: "Milestone",
      ),
      StudentSettingsNotificationModel(
        isTapped: false.obs,
        subTitle: "When someone follows you",
        title: "Following",
      ),
      StudentSettingsNotificationModel(
        isTapped: false.obs,
        subTitle: "When you forget to workout your plan",
        title: "Reminder",
      ),
    ]);

    // fetch subscription package from API and populate list
    fetchMySubscription();
  }

  var isLoadingSubscriptions = false.obs;

  Future<void> fetchMySubscription() async {
    try {
      isLoadingSubscriptions.value = true;
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      if (token == null || token.isEmpty) return;

      final Uri url = Uri.parse(Urls.mySubscription);
      final http.Response response = await http.get(
        url,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        subscriptionsList.clear();

        if (decoded is Map<String, dynamic> && decoded['plan'] != null) {
          final plan = decoded['plan'];
          final name = (plan['name'] ?? 'Unknown Plan').toString();
          final description = (plan['description'] ?? '').toString();
          final premiumUntil = decoded['premiumUntil'] != null 
              ? DateTime.tryParse(decoded['premiumUntil']) 
              : null;
          
          final isPremium = decoded['isPremium'] == true;
          final planFeatures = plan['planFeatures'] as Map<String, dynamic>? ?? {};
          final planConfig = plan['planConfiguration'] as Map<String, dynamic>? ?? {};

          List<Widget> details = [];
          
          // Build description
          if (description.isNotEmpty) {
            details.add(Text(description, textAlign: TextAlign.end, style: appTextStyleHeading1(fontWeight: FontWeight.w400, color: Colors.grey.shade600, fontSize: 12.fontSize)));
            details.add(SizedBox(height: 8.height));
          }

          // Build Features
          if (planFeatures['features'] != null && planFeatures['features'] is List) {
            for (var feature in planFeatures['features']) {
              details.add(Text("• $feature", textAlign: TextAlign.end, style: appTextStyleHeading1(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 12.fontSize)));
            }
          }

          // Build Configurations
          final configLabels = {
            'bookAccessLimit': 'Book Access',
            'jobApplicationLimit': 'Job Applications',
            'questionBankLimit': 'Question Bank',
            'conversionLimit': 'File Conversions',
            'cvGenerationLimit': 'CV Generation'
          };

          configLabels.forEach((key, label) {
            if (planConfig[key] != null) {
              final limit = planConfig[key];
              final periodKey = key.replaceAll('Limit', 'Period');
              final period = planConfig[periodKey] ?? 'per period';
              details.add(Text("• $label: $limit ($period)", textAlign: TextAlign.end, style: appTextStyleHeading1(fontWeight: FontWeight.w400, color: Colors.grey.shade700, fontSize: 12.fontSize)));
            }
          });

          details.add(SizedBox(height: 12.height));
          
          // Status
          details.add(Text(
            isPremium ? "Status: Active" : "Status: Inactive",
            style: appTextStyleHeading1(
              fontWeight: FontWeight.w600,
              color: isPremium ? Colors.green : Colors.orange,
              fontSize: 12.fontSize,
            ),
          ));
          
          if (premiumUntil != null) {
            details.add(Text(
              "Expires: ${premiumUntil.toLocal().toString().split(' ')[0]}",
              style: appTextStyleHeading1(
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
                fontSize: 12.fontSize,
              ),
            ));
          }

          final subtitleWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: details,
          );

          subscriptionsList.add(StudentSettingsSubscriptionModel(
            title: name,
            subTitle: subtitleWidget,
          ));
        }
      } else {
        debugPrint('Failed to fetch my subscription: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchMySubscription Error: $e');
    } finally {
      isLoadingSubscriptions.value = false;
    }
  }

  Future<void> cancelSubscription() async {
    try {
      EasyLoading.show(status: 'Canceling subscription...');
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showError('Authentication token not found.');
        return;
      }

      final Uri url = Uri.parse(Urls.cancelSubscription);
      final http.Response response = await http.patch(
        url,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      EasyLoading.dismiss();
      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess(responseBody['message'] ?? 'Subscription canceled successfully');
        fetchMySubscription(); // Refresh to update UI
      } else {
        var message = responseBody['message'] ?? 'Failed to cancel subscription';
        EasyLoading.showError(message.toString());
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('cancelSubscription Error: $e');
      EasyLoading.showError('Error: $e');
    }
  }

  Future<void> fetchPrivacySettings() async {
    try {
      isLoadingPrivacy.value = true;
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      if (token != null && token.isNotEmpty) {
        final Uri url = Uri.parse(Urls.authMe);
        final http.Response response = await http.get(
          url,
          headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> && decoded['profile'] != null) {
            final profile = decoded['profile'];
            if (profile['profileVisibility'] != null) {
              profileVisibility.value = profile['profileVisibility'];
            }
            if (profile['seePlan'] != null) seePlan.value = profile['seePlan'];
            if (profile['sendRequest'] != null) {
              sendRequest.value = profile['sendRequest'];
            }
            if (profile['seeClass'] != null) {
              seeClass.value = profile['seeClass'];
            }
            if (profile['canMessage'] != null) {
              canMessage.value = profile['canMessage'];
            }
          }
        }
      }
    } catch (e) {
      debugPrint('fetchPrivacySettings Error: $e');
    } finally {
      isLoadingPrivacy.value = false;
    }
  }

  Future<void> fetchDeviceSessions() async {
    try {
      isLoadingSessions.value = true;
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      if (token != null && token.isNotEmpty) {
        final Uri url = Uri.parse(Urls.sessions);
        final http.Response response = await http.get(
          url,
          headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final decoded = jsonDecode(response.body);
          if (decoded is List) {
            deviceSessionsList.value = decoded
                .map((session) => DeviceSessionModel.fromJson(session))
                .toList();
          }
        }
      }

      // Also fetch the current device public IP
      try {
        final ipResponse = await http.get(
          Uri.parse('https://api.ipify.org?format=json'),
        );
        if (ipResponse.statusCode == 200) {
          final ipDecoded = jsonDecode(ipResponse.body);
          if (ipDecoded['ip'] != null) {
            currentDeviceIp.value = ipDecoded['ip'];
          }
        }
      } catch (e) {
        debugPrint('fetch current IP Error: $e');
      }
    } catch (e) {
      debugPrint('fetchDeviceSessions Error: $e');
    } finally {
      isLoadingSessions.value = false;
    }
  }

  Future<void> revokeSession(int id) async {
    try {
      EasyLoading.show(status: 'Revoking session...');
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showError('Authentication token not found.');
        return;
      }

      final Uri url = Uri.parse(Urls.sessionById(id));
      final http.Response response = await http.delete(
        url,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      EasyLoading.dismiss();
      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess('Session revoked successfully');
        deviceSessionsList.removeWhere((session) => session.id == id);
      } else {
        final responseBody = jsonDecode(response.body);
        var message = responseBody['message'] ?? 'Failed to revoke session';
        EasyLoading.showError(message.toString());
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('revokeSession Error: $e');
      EasyLoading.showError('Error: $e');
    }
  }

  Future<void> updatePrivacySettings() async {
    try {
      isUpdatingPrivacy.value = true;
      EasyLoading.show(status: 'Saving...');

      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          'Authentication token not found. Please login again.',
        );
        return;
      }

      final Uri url = Uri.parse(Urls.changePrivacySettings);
      final Map<String, dynamic> body = {
        "profileVisibility": profileVisibility.value,
        "seePlan": seePlan.value,
        "sendRequest": sendRequest.value,
        "seeClass": seeClass.value,
        "canMessage": canMessage.value,
      };

      debugPrint('--- updatePrivacySettings Request ---');
      debugPrint('URL: $url');
      debugPrint('Body: $body');

      final http.Response response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('--- updatePrivacySettings Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess('Privacy Settings Changed.');
      } else {
        final responseBody = jsonDecode(response.body);
        var message =
            responseBody['message'] ?? 'Failed to update privacy settings';
        EasyLoading.showError(message.toString());
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('updatePrivacySettings Error: $e');
      EasyLoading.showError('Error: $e');
    } finally {
      isUpdatingPrivacy.value = false;
    }
  }

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }

  Future<void> changePassword() async {
    final currentPass = currentPasswordController.text;
    final newPass = newPasswordController.text;
    if (currentPass.isEmpty || newPass.isEmpty) {
      EasyLoading.showError("Please fill all fields");
      return;
    }
    
    try {
      EasyLoading.show(status: 'Updating password...');
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();
      
      final Uri url = Uri.parse(Urls.changePassword);
      final body = {
        "previousPassword": currentPass,
        "password": newPass,
        "token": "token"
      };
      
      final http.Response response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );
      
      EasyLoading.dismiss();
      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess("Password changed successfully");
        currentPasswordController.clear();
        newPasswordController.clear();
        Get.back(); // close bottomsheet
      } else {
        final respBody = jsonDecode(response.body);
        EasyLoading.showError(respBody['message'] ?? "Failed to change password");
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('changePassword Error: $e');
      EasyLoading.showError("Error: $e");
    }
  }

  Future<void> deleteAccount() async {
    try {
      EasyLoading.show(status: 'Deleting account...');
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();
      final userId = await sharedPrefHelper.getUserId();
      
      if (userId == null) {
        EasyLoading.dismiss();
        EasyLoading.showError("User ID not found");
        return;
      }
      
      final Uri url = Uri.parse(Urls.userById(int.parse(userId)));
      
      final http.Response response = await http.delete(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );
      
      EasyLoading.dismiss();
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        EasyLoading.showSuccess("Account deleted");
        await sharedPrefHelper.clearAuthSession();
        Get.offAllNamed(AppRoute.loginScreen);
      } else {
        final respBody = jsonDecode(response.body);
        EasyLoading.showError(respBody['message'] ?? "Failed to delete account");
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('deleteAccount Error: $e');
      EasyLoading.showError("Error: $e");
    }
  }
}
