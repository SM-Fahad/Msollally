// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';

class TeacherOtpService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Teacher Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    String? fcmToken,
  }) async {
    final url = Uri.parse(Urls.verifyOtp);

    debugPrint('TEACHER VERIFY OTP Request sending...');
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

    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RAW RESPONSE: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('======= TEACHER VERIFY OTP SUCCESS =======');
      debugPrint('Full Response Data: $decodedData');
      debugPrint('Response Keys: ${decodedData.keys.toList()}');

      decodedData.forEach((key, value) {
        debugPrint('  $key: $value');
      });

      if (decodedData.containsKey('accessToken')) {
        debugPrint('ACCESS TOKEN: ${decodedData['accessToken']}');
      }
      if (decodedData.containsKey('refreshToken')) {
        debugPrint('REFRESH TOKEN: ${decodedData['refreshToken']}');
      }
      debugPrint('==========================================');

      return decodedData;
    } else {
      throw Exception(decodedData['message'] ?? 'OTP verification failed');
    }
  }
}
