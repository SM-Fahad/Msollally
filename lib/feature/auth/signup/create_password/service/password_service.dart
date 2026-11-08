// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:msollaally/core/services/end_points.dart';
// import 'package:msollaally/core/services/share_preferrance_helper.dart';

// class PasswordService {
//   static Future<Map<String, dynamic>> setPassword({
//     required String password,
//   }) async {
//     final connect = GetConnect();
//     final baseUrl = Urls.baseUrl;

//     final prefHelper = SharedPreferenceHelper();
//     final accessToken = await prefHelper.getAccessToken();

//     if (accessToken == null || accessToken.isEmpty) {
//       debugPrint('SET PASSWORD Access token not found');
//       throw Exception('Access token not found. Please login again.');
//     }

//     debugPrint('SET PASSWORD Request sending...');
//     debugPrint('password    : $password');
//     debugPrint('accessToken : $accessToken');

//     final response = await connect.post(
//       // ignore: unnecessary_brace_in_string_interps
//       '${baseUrl}/auth/password/set',
//       {'password': password},
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       debugPrint('SET PASSWORD Success!');
//       debugPrint('message: ${response.body['message']}');
//       return response.body;
//     } else {
//       debugPrint('SET PASSWORD Failed: ${response.body?['message']}');
//       throw Exception(response.body?['message'] ?? 'Failed to set password');
//     }
//   }
// }
