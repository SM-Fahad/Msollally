import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';

class ProPartnersChangePasswordService {
  Future<void> changePassword({
    required String accessToken,
    required String refreshToken,
    required String previousPassword,
    required String newPassword,
  }) async {
    final response = await http.patch(
      Uri.parse(Urls.changePassword),
      headers: <String, String>{
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'password': newPassword,
        'token': refreshToken,
        'previousPassword': previousPassword,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final msg = decoded['message']?.toString();
          throw Exception(msg ?? 'Failed to change password');
        }
      } catch (_) {}
      throw Exception('Failed to change password');
    }
  }
}
