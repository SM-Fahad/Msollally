import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';

class ProPartnersPrivacyService {
  Future<void> changePrivacySettings({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.patch(
      Uri.parse(Urls.changePrivacySettings),
      headers: <String, String>{
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final msg = decoded['message']?.toString();
          throw Exception(msg ?? 'Failed to update privacy settings');
        }
      } catch (_) {}
      throw Exception('Failed to update privacy settings');
    }
  }
}
