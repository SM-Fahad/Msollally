import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/feature/teacher/profile/model/teacher_model.dart';

class TeacherProfileService {
  Future<TeacherMeResponse> fetchMe({required String accessToken}) async {
    final response = await http.get(
      Uri.parse(Urls.authMe),
      headers: <String, String>{
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final dynamic decoded = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString();
        throw Exception(message ?? 'Failed to fetch profile');
      }
      throw Exception('Failed to fetch profile');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response from server');
    }

    return TeacherMeResponse.fromJson(decoded);
  }

  Future<String> uploadImage({
    required String accessToken,
    required File file,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(Urls.uploadCloudinaryFile),
    );

    request.headers.addAll({
      'accept': '*/*',
      if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
    });

    request.files.add(await http.MultipartFile.fromPath('files', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload image');
    }

    final url = _extractUploadedFileUrl(response.body);
    if (url == null || url.isEmpty) {
      throw Exception('Upload succeeded but URL not found');
    }
    return url;
  }

  Future<void> updateProfile({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.patch(
      Uri.parse(Urls.profileUpdate),
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
          throw Exception(msg ?? 'Failed to update profile');
        }
      } catch (_) {}
      throw Exception('Failed to update profile');
    }
  }

  String? _extractUploadedFileUrl(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
        final first = decoded.first as Map;
        return (first['url'] ?? first['secure_url'] ?? first['fileUrl'])
            ?.toString();
      }
      if (decoded is Map) {
        final top =
            decoded['url'] ?? decoded['secure_url'] ?? decoded['fileUrl'];
        if (top != null) return top.toString();
        final data = decoded['data'];
        if (data is List && data.isNotEmpty && data.first is Map) {
          final first = data.first as Map;
          return (first['url'] ?? first['secure_url'] ?? first['fileUrl'])
              ?.toString();
        }
        if (data is Map) {
          return (data['url'] ?? data['secure_url'] ?? data['fileUrl'])
              ?.toString();
        }
      }
    } catch (_) {}
    return null;
  }
}
