// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';

class ProPartnersProfileService {
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
    try {
      print('ProPartnersProfileService.updateProfile -> URL: $uri');
      print(
        'ProPartnersProfileService.updateProfile -> BODY: ${jsonEncode(body)}',
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
        'ProPartnersProfileService.updateProfile -> STATUS: ${response.statusCode}',
      );
      print(
        'ProPartnersProfileService.updateProfile -> RESPONSE: ${response.body}',
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
          }
          throw Exception(msg?.toString() ?? 'Failed to update profile');
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
