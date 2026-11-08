import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';

class ModuleService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<CourseModule> createModule({
    required int courseId,
    required String title,
    required String description,
    DateTime? startDate,
  }) async {
    final token = await _requireToken();
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
    };

    final response = await _networkCaller.postJsonRequest(
      Urls.courseModules(courseId),
      token: 'Bearer $token',
      body: body,
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to create module.',
    );

    return CourseModule.fromJson(data);
  }

  Future<CourseModule> getModuleDetails(int moduleId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.moduleDetails(moduleId),
      token: 'Bearer $token',
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to load module details.',
    );

    return CourseModule.fromJson(data);
  }

  Future<CourseModule> updateModule({
    required int moduleId,
    required String title,
    required String description,
    required int orderIndex,
    DateTime? startDate,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.putJsonRequest(
      Urls.moduleById(moduleId),
      token: 'Bearer $token',
      body: {
        'title': title,
        'description': description,
        'orderIndex': orderIndex,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
      },
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to update module.',
    );

    return CourseModule.fromJson(data);
  }

  Future<CourseModule> updateModuleProgress({
    required int moduleId,
    required double progress,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.putJsonRequest(
      Urls.moduleProgress(moduleId),
      token: 'Bearer $token',
      body: {'progress': progress.clamp(0, 100).round()},
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to update module progress.',
    );

    return CourseModule.fromJson(data);
  }

  Future<ModuleFile> addModuleFile({
    required int moduleId,
    required String name,
    required String fileUrl,
    required String type,
    required int size,
    required String mimeType,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.moduleFiles(moduleId),
      token: 'Bearer $token',
      body: {
        'name': name,
        'fileUrl': fileUrl,
        'type': type,
        'size': size,
        'mimeType': mimeType,
      },
    );

    final data = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to add module file.',
    );
    return ModuleFile.fromJson(data);
  }

  Future<String> uploadModuleFile(File file, {String? fileName}) async {
    final token = await _requireToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(Urls.uploadCloudinaryFile),
    );

    request.headers.addAll({'accept': '*/*', 'Authorization': 'Bearer $token'});
    request.files.add(
      await http.MultipartFile.fromPath('files', file.path, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload module file.');
    }

    final uploadedUrl = _extractUploadedFileUrl(response.body);
    if (uploadedUrl == null || uploadedUrl.isEmpty) {
      throw Exception('File upload succeeded but URL was missing.');
    }

    return uploadedUrl;
  }

  Future<void> deleteModule(int moduleId) async {
    final token = await _requireToken();
    final response = await _networkCaller.deleteRequest(
      Urls.moduleById(moduleId),
      token: 'Bearer $token',
    );

    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to delete module.',
      );
    }
  }

  Future<void> deleteModuleFile(int fileId) async {
    final token = await _requireToken();
    final response = await _networkCaller.deleteRequest(
      Urls.moduleFileById(fileId),
      token: 'Bearer $token',
    );

    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to delete module file.',
      );
    }
  }

  Future<String> _requireToken() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }
    return token;
  }

  Map<String, dynamic> _extractMapResponse(
    ResponseData response, {
    required String fallbackMessage,
  }) {
    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : fallbackMessage,
      );
    }

    final payload = response.responseData;
    if (payload is Map<String, dynamic>) {
      final nestedData = payload['data'];
      if (nestedData is Map<String, dynamic>) {
        return nestedData;
      }
      if (nestedData is Map) {
        return Map<String, dynamic>.from(nestedData);
      }
      return payload;
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }

    throw Exception(fallbackMessage);
  }

  String? _extractUploadedFileUrl(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);

      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) {
          final url = first['url'] ?? first['secure_url'] ?? first['fileUrl'];
          return url?.toString();
        }
      }

      if (decoded is Map<String, dynamic>) {
        final topLevelUrl =
            decoded['url'] ?? decoded['secure_url'] ?? decoded['fileUrl'];
        if (topLevelUrl != null) {
          return topLevelUrl.toString();
        }

        final data = decoded['data'];
        if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is Map<String, dynamic>) {
            final dataUrl =
                first['url'] ?? first['secure_url'] ?? first['fileUrl'];
            return dataUrl?.toString();
          }
        }

        if (data is Map<String, dynamic>) {
          final dataUrl = data['url'] ?? data['secure_url'] ?? data['fileUrl'];
          return dataUrl?.toString();
        }
      }
    } catch (_) {}

    return null;
  }
}
