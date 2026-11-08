import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class StudentAssessmentService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<List<Map<String, dynamic>>> getAssessments(int courseId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.courseAssessments(courseId),
      token: 'Bearer $token',
    );

    return _extractListResponse(
      response,
      // fallbackMessage: 'Failed to load assessments.',
    );
  }

  Future<Map<String, dynamic>> getAssessmentDetails(int assessmentId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.assessmentById(assessmentId),
      token: 'Bearer $token',
    );

    return _extractMapResponse(
      response,
      // fallbackMessage: 'Failed to load assessment details.',
    );
  }

  Future<Map<String, dynamic>?> getMySubmission(int assessmentId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.assessmentMySubmission(assessmentId),
      token: 'Bearer $token',
    );

    if (!response.isSuccess) {
      if (response.statusCode == 404) {
        return null;
      }
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to load your submission.',
      );
    }

    return _tryExtractOptionalMap(response.responseData);
  }

  Future<List<Map<String, dynamic>>> getCourseMySubmissions(
    int courseId,
  ) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.courseMySubmissions(courseId),
      token: 'Bearer $token',
    );

    return _extractListResponse(
      response,
      // fallbackMessage: 'Failed to load your course submissions.',
    );
  }

  Future<Map<String, dynamic>> submitAssessment({
    required int assessmentId,
    required String content,
    required List<String> fileUrls,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.submitAssessment(assessmentId),
      token: 'Bearer $token',
      body: {'content': content, 'fileUrls': fileUrls},
    );

    return _extractMapResponse(
      response,
      // fallbackMessage: 'Failed to submit assessment.',
    );
  }

  Future<void> deleteMySubmission(int assessmentId) async {
    final token = await _requireToken();
    final response = await _networkCaller.deleteRequest(
      Urls.assessmentMySubmission(assessmentId),
      token: 'Bearer $token',
    );

    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to delete your submission.',
      );
    }
  }

  Future<List<String>> uploadAssessmentFiles(List<File> files) async {
    if (files.isEmpty) {
      return const <String>[];
    }

    final token = await _requireToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(Urls.uploadCloudinaryFile),
    );

    request.headers.addAll({'accept': '*/*', 'Authorization': 'Bearer $token'});
    for (final file in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload assessment file.');
    }

    final uploadedUrls = _extractUploadedFileUrls(response.body);
    if (uploadedUrls.isEmpty) {
      throw Exception('File upload succeeded but URL was missing.');
    }

    return uploadedUrls;
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
    String? fallbackMessage,
  }) {
    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : fallbackMessage,
      );
    }

    final payload = response.responseData;
    final extracted = _tryExtractOptionalMap(payload);
    if (extracted != null) {
      return extracted;
    }

    throw Exception(fallbackMessage);
  }

  Map<String, dynamic>? _tryExtractOptionalMap(dynamic payload) {
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
    return null;
  }

  List<Map<String, dynamic>> _extractListResponse(
    ResponseData response, {
    String? fallbackMessage,
  }) {
    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : fallbackMessage,
      );
    }

    final payload = response.responseData;
    final list = _extractList(payload);
    if (list.isNotEmpty) {
      return list;
    }

    if (payload is Map<String, dynamic>) {
      return _extractList(payload['data']) +
          _extractList(payload['assessments']) +
          _extractList(payload['submissions']) +
          _extractList(payload['items']);
    }

    throw Exception(fallbackMessage);
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const <Map<String, dynamic>>[];
  }

  List<String> _extractUploadedFileUrls(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      final urls = <String>[];

      if (decoded is List && decoded.isNotEmpty) {
        for (final item in decoded.whereType<Map>()) {
          final normalized = Map<String, dynamic>.from(item);
          final url =
              normalized['url'] ??
              normalized['secure_url'] ??
              normalized['fileUrl'];
          if (url != null && url.toString().isNotEmpty) {
            urls.add(url.toString());
          }
        }
        return urls;
      }

      if (decoded is Map<String, dynamic>) {
        final topLevelUrl =
            decoded['url'] ?? decoded['secure_url'] ?? decoded['fileUrl'];
        if (topLevelUrl != null) {
          urls.add(topLevelUrl.toString());
        }

        final data = decoded['data'];
        if (data is List && data.isNotEmpty) {
          for (final item in data.whereType<Map>()) {
            final first = Map<String, dynamic>.from(item);
            final dataUrl =
                first['url'] ?? first['secure_url'] ?? first['fileUrl'];
            if (dataUrl != null && dataUrl.toString().isNotEmpty) {
              urls.add(dataUrl.toString());
            }
          }
        }

        if (data is Map<String, dynamic>) {
          final dataUrl = data['url'] ?? data['secure_url'] ?? data['fileUrl'];
          if (dataUrl != null && dataUrl.toString().isNotEmpty) {
            urls.add(dataUrl.toString());
          }
        }

        return urls;
      }
    } catch (_) {}

    return const <String>[];
  }
}
