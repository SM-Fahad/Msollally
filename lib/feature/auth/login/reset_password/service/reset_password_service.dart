// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class ResetPasswordService {
  static Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
  }) async {
    debugPrint('SEND OTP Request sending...');
    debugPrint('phoneNumber : $phoneNumber');

    final response = await http.post(
      Uri.parse('${Urls.baseUrl}/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    debugPrint('SEND OTP Status Code  : ${response.statusCode}');
    debugPrint('SEND OTP Body         : ${response.body}');

    final decodedData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('SEND OTP Success!');
      debugPrint('message : ${decodedData['message']}');
      debugPrint('otp     : ${decodedData['otp']}');
      return decodedData;
    } else {
      final errorMsg = decodedData['message'] ?? 'Failed to send OTP';
      debugPrint('SEND OTP Failed: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String phoneNumber,
    required String password,
  }) async {
    debugPrint('RESET PASSWORD Request sending...');
    debugPrint('phoneNumber : $phoneNumber');

    final pref = SharedPreferenceHelper();
    final accessToken = await pref.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('RESET PASSWORD Failed: access token not found');
      throw Exception('Authentication token missing. Please verify OTP again.');
    }
    final refreshToken = await pref.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('RESET PASSWORD Failed: refresh token not found');
      throw Exception('Refresh token missing. Please verify OTP again.');
    }

    // Debug: show masked token and request body
    final masked = accessToken.length > 10
        ? '${accessToken.substring(0, 8)}...${accessToken.substring(accessToken.length - 4)}'
        : accessToken;
    debugPrint('RESET PASSWORD Using access token: $masked');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final bodyMap = {
      'password': password,
      'token': refreshToken,
      'phoneNumber': phoneNumber,
    };
    final body = jsonEncode(bodyMap);
    final maskedRefresh = refreshToken.length > 10
        ? '${refreshToken.substring(0, 8)}...${refreshToken.substring(refreshToken.length - 4)}'
        : refreshToken;
    debugPrint('RESET PASSWORD Using refresh token: $maskedRefresh');
    debugPrint('RESET PASSWORD Request headers: $headers');
    debugPrint('RESET PASSWORD Request body   : $body');

    final response = await http.post(
      Uri.parse(Urls.resetPassword),
      headers: headers,
      body: body,
    );

    debugPrint('RESET PASSWORD Status Code  : ${response.statusCode}');
    debugPrint('RESET PASSWORD Body         : ${response.body}');

    final decodedData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('RESET PASSWORD Success!');
      debugPrint('message : ${decodedData['message']}');
      return decodedData;
    } else {
      final errorMsg = decodedData['message'] ?? 'Failed to reset password';
      debugPrint('RESET PASSWORD Failed: $errorMsg');
      throw Exception(errorMsg);
    }
  }
}
