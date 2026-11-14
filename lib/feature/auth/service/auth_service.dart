// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class AuthService {
  static const String baseUrl = Urls.baseUrl;
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Sign Up
  static Future<Map<String, dynamic>> signUp({
    required String phoneNumber,
    required String username,
    required String password,
    required String role,
    String? fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/auth/signup');

    final body = <String, dynamic>{
      'phoneNumber': phoneNumber,
      'username': username,
      'password': password,
      'role': role,
    };
    if (fcmToken != null && fcmToken.isNotEmpty) {
      body['fcmToken'] = fcmToken;
    }

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    final decodedData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return decodedData;
    } else {
      throw Exception(decodedData['message'] ?? 'Signup failed');
    }
  }

  // Send OTP
  static Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$baseUrl${Urls.sendOtp}');

    debugPrint('SEND OTP Request sending...');
    debugPrint('phoneNumber : $phoneNumber');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    final decodedData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('SEND OTP Success!');
      debugPrint('message : ${decodedData['message']}');
      debugPrint('otp     : ${decodedData['otp']}');
      return decodedData;
    } else {
      debugPrint('SEND OTP Failed: ${decodedData['message']}');
      throw Exception(decodedData['message'] ?? 'Failed to send OTP');
    }
  }
  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    String? fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');

    debugPrint('VERIFY OTP Request sending...');
    debugPrint('phoneNumber: $phoneNumber');
    debugPrint('otpCode    : $otpCode');
    debugPrint('fcmToken   : $fcmToken');

    final body = <String, dynamic>{
      'phoneNumber': phoneNumber,
      'otpCode': otpCode,
    };
    if (fcmToken != null && fcmToken.isNotEmpty) {
      body['fcmToken'] = fcmToken;
    }

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    final decodedData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('VERIFY OTP Successfully!');
      debugPrint('accessToken : ${decodedData['accessToken']}');
      debugPrint('refreshToken: ${decodedData['refreshToken']}');
      return decodedData;
    } else {
      debugPrint('VERIFY OTP Failed: ${decodedData['message']}');
      throw Exception(decodedData['message'] ?? 'OTP verification failed');
    }
  }

  // Resend OTP
  static Future<Map<String, dynamic>> resendOtp({
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$baseUrl/auth/resend-otp');

    debugPrint('RESEND OTP Request sending...');
    debugPrint('phoneNumber: $phoneNumber');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    final decodedData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('RESEND OTP Successfully!');
      debugPrint('message: ${decodedData['message']}');
      debugPrint('otp    : ${decodedData['otp']}');
      return decodedData;
    } else {
      debugPrint('RESEND OTP Failed: ${decodedData['message']}');
      throw Exception(decodedData['message'] ?? 'Resend OTP failed');
    }
  }

  // Login

  static Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
    String? fcmToken,
  }) async {
    final url = Uri.parse(Urls.login);

    debugPrint('LOGIN Request sending...');
    debugPrint('phoneNumber: $phoneNumber');
    debugPrint('password   : $password');
    debugPrint('fcmToken   : $fcmToken');

    final body = <String, dynamic>{
      'phoneNumber': phoneNumber,
      'password': password,
    };
    if (fcmToken != null && fcmToken.isNotEmpty) {
      body['fcmToken'] = fcmToken;
    }

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    final decodedData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('LOGIN Success!');
      debugPrint('accessToken : ${decodedData['accessToken']}');
      debugPrint('refreshToken: ${decodedData['refreshToken']}');
      return decodedData;
    } else {
      debugPrint('LOGIN Failed: ${decodedData['message']}');
      throw Exception(decodedData['message'] ?? 'Login failed');
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse(Urls.logout);

    final prefHelper = SharedPreferenceHelper();
    final refreshToken = await prefHelper.getRefreshToken();

    debugPrint('LOGOUT Request sending...');
    debugPrint('refreshToken: $refreshToken');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    debugPrint('LOGOUT Status Code : ${response.statusCode}');
    debugPrint('LOGOUT Body        : ${response.body}');

    final decodedData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('LOGOUT Success!');
      return decodedData;
    } else {
      debugPrint('LOGOUT Failed: ${decodedData['message']}');
      throw Exception(decodedData['message'] ?? 'Logout failed');
    }
  }

  // Get current user (auth/me) and store userId
  static Future<String?> fetchMeAndStoreUserId() async {
    final prefHelper = SharedPreferenceHelper();
    final accessToken = await prefHelper.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Access token not found');
    }

    final url = Uri.parse(Urls.authMe);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to fetch user profile');
    }

    final decoded = jsonDecode(response.body);

    String? resolvedId;
    bool? resolvedIsCr;

    if (decoded is Map<String, dynamic>) {
      final rootId = decoded['id'];
      if (rootId != null) {
        resolvedId = rootId.toString();
      }
      if (decoded['isCr'] is bool) {
        resolvedIsCr = decoded['isCr'] as bool;
      }

      final user = decoded['user'];
      if (user is Map<String, dynamic>) {
        if (resolvedId == null && user['id'] != null) {
          resolvedId = user['id'].toString();
        }
        if (resolvedIsCr == null && user['isCr'] is bool) {
          resolvedIsCr = user['isCr'] as bool;
        }
      }

      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        if (resolvedId == null && data['id'] != null) {
          resolvedId = data['id'].toString();
        }
        if (resolvedIsCr == null && data['isCr'] is bool) {
          resolvedIsCr = data['isCr'] as bool;
        }

        final dataUser = data['user'];
        if (dataUser is Map<String, dynamic>) {
          if (resolvedId == null && dataUser['id'] != null) {
            resolvedId = dataUser['id'].toString();
          }
          if (resolvedIsCr == null && dataUser['isCr'] is bool) {
            resolvedIsCr = dataUser['isCr'] as bool;
          }
        }
      }
    }

    if (resolvedIsCr != null) {
      await prefHelper.saveIsCr(resolvedIsCr);
    }

    if (resolvedId != null && resolvedId.isNotEmpty) {
      await prefHelper.saveUserId(resolvedId);
      return resolvedId;
    }

    return null;
  }
}
