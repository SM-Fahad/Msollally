import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';

class RecruiterAccountService {
  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    final response = await http.post(
      Uri.parse(Urls.logout),
      headers: <String, String>{
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{'refreshToken': refreshToken}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractMessage(response) ?? 'Logout failed');
    }
  }

  Future<void> deleteAccount({
    required String accessToken,
    required int userId,
  }) async {
    final response = await http.delete(
      Uri.parse(Urls.userById(userId)),
      headers: <String, String>{
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractMessage(response) ?? 'Delete account failed');
    }
  }

  String? _extractMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message']?.toString();
        if (msg != null && msg.trim().isNotEmpty) return msg.trim();
      }
    } catch (_) {}
    return null;
  }
}
