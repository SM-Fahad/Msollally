// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import '../model/recruiter_me_model.dart';

class RecruiterProfileService {
  Future<RecruiterMeResponse> fetchMe({required String accessToken}) async {
    final uri = Uri.parse(Urls.authMe);
    final response = await http.get(
      uri,
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

    return RecruiterMeResponse.fromJson(decoded);
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
    final uri = Uri.parse(Urls.profileUpdate);
    // Log request for debugging
    try {
      print('RecruiterProfileService.updateProfile -> URL: $uri');
      print(
        'RecruiterProfileService.updateProfile -> BODY: ${jsonEncode(body)}',
      );
    } catch (_) {}

    final response = await http.patch(
      uri,
      headers: <String, String>{
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    try {
      print(
        'RecruiterProfileService.updateProfile -> STATUS: ${response.statusCode}',
      );
      print(
        'RecruiterProfileService.updateProfile -> RESPONSE: ${response.body}',
      );
    } catch (_) {}

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final msg = decoded['message'];
          if (msg is List) {
            final joinedMsg = msg.whereType<String>().join('\n');
            throw Exception(
              joinedMsg.isNotEmpty ? joinedMsg : 'Failed to update profile',
            );
          } else {
            throw Exception(msg?.toString() ?? 'Failed to update profile');
          }
        }
      } catch (e) {
        if (e is Exception) rethrow;
      }
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
