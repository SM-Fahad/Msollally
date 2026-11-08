import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/services/end_points.dart';
import '../../../../../core/services/share_preferrance_helper.dart';

class CreatePlanService {
  Future<bool> createAiPlan(Map<String, dynamic> data) async {
    try {
      EasyLoading.show(status: 'Generating AI Plan...');
      final token = await SharedPreferenceHelper().getAccessToken();

      debugPrint('Create AI Plan Request URL: ${Urls.createAiPlan}');
      debugPrint('Create AI Plan Request Payload: ${jsonEncode(data)}');

      final response = await http.post(
        Uri.parse(Urls.createAiPlan),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      EasyLoading.dismiss();

      debugPrint('Create AI Plan Response Status: ${response.statusCode}');
      debugPrint('Create AI Plan Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess('Plan created successfully');
        return true;
      } else {
        EasyLoading.showError('Failed to create plan');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Create AI Plan Error: $e');
      EasyLoading.showError('Error: $e');
      return false;
    }
  }
}
