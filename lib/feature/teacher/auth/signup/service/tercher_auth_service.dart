// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';

class TeacherAuthService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Teacher Sign Up
  static Future<Map<String, dynamic>> teacherSignUp({
    required String phoneNumber,
    required String username,
    required String role,
    String? fcmToken,
  }) async {
    final url = Uri.parse(Urls.signUp);

    debugPrint('TEACHER SIGNUP Request sending...');
    debugPrint('phoneNumber: $phoneNumber');
    debugPrint('username   : $username');
    debugPrint('role       : $role');
    debugPrint('fcmToken   : $fcmToken');

    final body = <String, dynamic>{
      'phoneNumber': phoneNumber,
      'username': username,
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

    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RAW RESPONSE: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
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
      return decodedData;
    } else {
      throw Exception(decodedData['message'] ?? 'Signup failed');
    }
  }

  // Teacher Set Password
  static Future<Map<String, dynamic>> setPassword({
    required String password,
    required String accessToken,
  }) async {
    final url = Uri.parse(Urls.setPassword);

    debugPrint('TEACHER SET PASSWORD Request sending...');
    debugPrint('password    : $password');
    debugPrint('accessToken : $accessToken');

    final response = await http.post(
      url,
      headers: {..._headers, 'Authorization': 'Bearer $accessToken'},
      body: jsonEncode({'password': password}),
    );

    final decodedData = jsonDecode(response.body);

    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RAW RESPONSE: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('SET PASSWORD Success!');
      debugPrint('message: ${decodedData['message']}');
      return decodedData;
    } else {
      debugPrint('SET PASSWORD Failed: ${decodedData['message']}');
      throw Exception(decodedData['message'] ?? 'Failed to set password');
    }
  }

  // Teacher Complete Profile
  static Future<Map<String, dynamic>> completeProfile({
    required String email,
    required String fullName,
    required String gender,
    String? dateOfBirth,
    int? universityId,
    int? programId,
    int? departmentId,
    String? program,
    String? faculty,
    String? studentID,
    int? enrollmentYear,
    String? profilePicture,
    String? bio,
    required String accessToken,
  }) async {
    final url = Uri.parse(Urls.profile);

    debugPrint('TEACHER COMPLETE PROFILE Request sending...');
    debugPrint('email       : $email');
    debugPrint('fullName    : $fullName');
    debugPrint('gender      : $gender');
    debugPrint('accessToken : $accessToken');

    final Map<String, dynamic> body = {
      'email': email,
      'fullName': fullName,
      'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (universityId != null) 'universityId': universityId,
      if (programId != null) 'programId': programId,
      if (departmentId != null) 'departmentId': departmentId,
      if (program != null) 'program': program,
      if (faculty != null) ...{
        'faculty': faculty,
        'department': faculty,
      },
      if (studentID != null) 'studentID': studentID,
      if (enrollmentYear != null) 'enrollmentYear': enrollmentYear,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (bio != null) 'bio': bio,
    };

    final response = await http.post(
      url,
      headers: {..._headers, 'Authorization': 'Bearer $accessToken'},
      body: jsonEncode(body),
    );

    final decodedData = jsonDecode(response.body);

    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RAW RESPONSE: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('COMPLETE PROFILE Success!');
      debugPrint('message: ${decodedData['message']}');
      return decodedData;
    } else {
      debugPrint('COMPLETE PROFILE Failed: ${decodedData['message']}');
      throw Exception(decodedData['message'] ?? 'Failed to complete profile');
    }
  }
}
