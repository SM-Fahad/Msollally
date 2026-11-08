import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/cv_model.dart';

class CvService {
  Future<bool> createCv(CvModel cv) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final payload = jsonEncode(cv.toJson());
      debugPrint('CV Create Request Payload: $payload');

      final response = await http.post(
        Uri.parse(Urls.createCv),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      debugPrint('CV Create Response Status: ${response.statusCode}');
      debugPrint('CV Create Response Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating CV exception: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchAllCvs({int page = 1, int limit = 20}) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final url = Uri.parse('${Urls.getAllCv}?page=$page&limit=$limit');
      debugPrint('Fetch All CVs URL: $url');

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Fetch All CVs Status: ${response.statusCode}');
      debugPrint('Fetch All CVs Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['data'] ?? [];
      } else {
        throw Exception('Failed to fetch CVs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching CVs: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCvById(String id) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final url = Uri.parse(Urls.getCvById(id));
      debugPrint('Get CV By ID URL: $url');

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get CV By ID Status: ${response.statusCode}');
      debugPrint('Get CV By ID Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['data'] as Map<String, dynamic>?;
      } else {
        throw Exception('Failed to get CV: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting CV by ID: $e');
      return null;
    }
  }

  Future<bool> updateCv(String id, Map<String, dynamic> payload) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final url = Uri.parse(Urls.updateCvById(id));
      final bodyString = jsonEncode(payload);
      debugPrint('Update CV URL: $url');
      debugPrint('Update CV Payload: $bodyString');

      final response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: bodyString,
      );

      debugPrint('Update CV Status: ${response.statusCode}');
      debugPrint('Update CV Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error updating CV: $e');
      return false;
    }
  }

  Future<bool> deleteCvs(List<dynamic> cvIds) async {
    try {
      final sharedPrefHelper = SharedPreferenceHelper();
      final token = await sharedPrefHelper.getAccessToken();

      final url = Uri.parse(Urls.deleteCv);
      final bodyString = jsonEncode({'cvIds': cvIds});
      debugPrint('Delete CV URL: $url');
      debugPrint('Delete CV Body: $bodyString');

      final response = await http.delete(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: bodyString,
      );

      debugPrint('Delete CV Status: ${response.statusCode}');
      debugPrint('Delete CV Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting CVs: $e');
      return false;
    }
  }

  Future<void> downloadCv(String id) async {
    try {
      final url = Uri.parse(Urls.downloadCv(id));
      debugPrint('Attempting to launch URL: $url');
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Failed to launch URL: $url');
        throw Exception('Could not launch $url');
      } else {
        debugPrint('Successfully launched URL: $url');
      }
    } catch (e, stackTrace) {
      debugPrint('Error downloading CV: $e\n$stackTrace');
      rethrow;
    }
  }
}
