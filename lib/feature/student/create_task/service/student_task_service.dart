import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/services/end_points.dart';
import '../../../../core/services/share_preferrance_helper.dart';

class StudentTaskService {
  static const Duration _requestTimeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>> createTask({
    required String task,
    required String note,
    required DateTime dateTime,
    File? file,
  }) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    String? uploadedFileUrl;
    if (file != null) {
      uploadedFileUrl = await _uploadTaskFile(token: token, file: file);
    }

    // Create task with JSON payload (task/note/dateTime/fileUrl).
    final response = await http
        .post(
          Uri.parse(Urls.createTask),
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'task': task,
            'note': note,
            'dateTime': dateTime.toUtc().toIso8601String(),
            if (uploadedFileUrl != null && uploadedFileUrl.isNotEmpty)
              'fileUrl': uploadedFileUrl,
          }),
        )
        .timeout(_requestTimeout);

    final decodedData = _decodeMap(response.body);
    if (_isSuccess(response.statusCode)) {
      return decodedData;
    }

    _throwApiError(decodedData, 'Task creation failed');
  }

  static Future<List<Map<String, dynamic>>> getAllTasks() async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http.get(
      Uri.parse(Urls.getAllTasks),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final decodedData = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final list = _extractTaskList(decodedData);
      return list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final message = decodedData['message'];
    if (message is String && message.isNotEmpty) {
      throw Exception(message);
    }
    if (message is List && message.isNotEmpty) {
      throw Exception(message.join(', '));
    }
    throw Exception('Failed to load tasks');
  }

  static Future<Map<String, dynamic>> getTaskById(int id) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http.get(
      Uri.parse(Urls.getTaskById(id)),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final decodedData = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final task = _extractTaskDetails(decodedData);
      if (task != null) {
        return task;
      }
      throw Exception('Task details not found');
    }

    final message = decodedData['message'];
    if (message is String && message.isNotEmpty) {
      throw Exception(message);
    }
    if (message is List && message.isNotEmpty) {
      throw Exception(message.join(', '));
    }
    throw Exception('Failed to load task details');
  }

  static Future<Map<String, dynamic>> updateTaskById({
    required int id,
    required String task,
    required String note,
    required DateTime dateTime,
    File? file,
  }) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    String? uploadedFileUrl;
    if (file != null) {
      uploadedFileUrl = await _uploadTaskFile(token: token, file: file);
    }

    final response = await http.patch(
      Uri.parse(Urls.getTaskById(id)),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'task': task,
        'note': note,
        'dateTime': dateTime.toUtc().toIso8601String(),
        if (uploadedFileUrl != null && uploadedFileUrl.isNotEmpty)
          'fileUrl': uploadedFileUrl,
      }),
    );

    final decodedData = _decodeMap(response.body);
    if (_isSuccess(response.statusCode)) {
      return decodedData;
    }

    _throwApiError(decodedData, 'Task update failed');
  }

  static Future<Map<String, dynamic>> deleteTaskById(int id) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    debugPrint('[TaskDelete] started -> taskId: $id');

    final attempts = <Map<String, dynamic>>[
      {
        'method': 'DELETE',
        'url': Urls.deleteTask,
        'body': {
          'taskIds': [id],
        },
      },
      {
        'method': 'POST',
        'url': Urls.deleteTask,
        'body': {
          'taskIds': [id],
        },
      },
      {'method': 'DELETE', 'url': '${Urls.deleteTask}?taskIds[]=$id'},
      {'method': 'DELETE', 'url': '${Urls.deleteTask}?taskIds=$id'},
      {'method': 'DELETE', 'url': Urls.deleteTaskById(id)},
      {'method': 'PATCH', 'url': Urls.deleteTaskById(id)},
      {'method': 'DELETE', 'url': Urls.getTaskById(id)},
      {'method': 'DELETE', 'url': '${Urls.deleteTask}?id=$id'},
      {'method': 'POST', 'url': Urls.deleteTaskById(id)},
      {
        'method': 'POST',
        'url': Urls.deleteTask,
        'body': {'id': id},
      },
      {
        'method': 'DELETE',
        'url': Urls.deleteTask,
        'body': {'id': id},
      },
      {
        'method': 'PATCH',
        'url': Urls.deleteTask,
        'body': {'id': id},
      },
    ];

    Map<String, dynamic> lastDecodedData = <String, dynamic>{};
    int? lastStatusCode;

    for (final attempt in attempts) {
      final method = attempt['method']!;
      final url = attempt['url']!;
      final body = attempt['body'];

      final response = await _sendTaskRequest(
        method: method.toString(),
        url: url.toString(),
        token: token,
        body: body is Map<String, dynamic> ? body : null,
      );

      lastStatusCode = response.statusCode;
      debugPrint(
        '[TaskDelete] $method $url -> status: ${response.statusCode}, '
        'body: ${_shortBody(response.body)}',
      );

      if (response.statusCode == 204) {
        debugPrint('[TaskDelete] success with 204');
        return <String, dynamic>{'message': 'Task deleted successfully'};
      }

      final decodedData = _decodeMap(response.body);
      if (_isSuccess(response.statusCode)) {
        debugPrint('[TaskDelete] success with status ${response.statusCode}');
        return decodedData;
      }
      lastDecodedData = decodedData;
    }

    debugPrint(
      '[TaskDelete] failed -> lastStatusCode: $lastStatusCode, '
      'decoded: $lastDecodedData',
    );
    _throwApiError(
      lastDecodedData,
      lastStatusCode == null
          ? 'Task delete failed'
          : 'Task delete failed (status: $lastStatusCode)',
    );
  }

  static Future<Map<String, dynamic>> markTaskCompleted(int id) {
    return markTasksCompleted(taskIds: [id], isCompleted: true);
  }

  static Future<Map<String, dynamic>> markTasksCompleted({
    required List<int> taskIds,
    required bool isCompleted,
  }) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final normalizedTaskIds = taskIds
        .where((value) => value > 0)
        .toSet()
        .toList(growable: false);
    if (normalizedTaskIds.isEmpty) {
      throw Exception('Task ids are missing');
    }

    final requestBody = <String, dynamic>{
      'taskIds': normalizedTaskIds,
      'isCompleted': isCompleted,
    };

    debugPrint(
      '[TaskComplete] started -> taskIds: $normalizedTaskIds, '
      'isCompleted: $isCompleted',
    );

    final attempts = <Map<String, dynamic>>[
      {
        'method': 'PATCH',
        'url': Urls.markTaskCompletedTasks,
        'body': requestBody,
      },
      {
        'method': 'POST',
        'url': Urls.markTaskCompletedTasks,
        'body': requestBody,
      },
    ];

    Map<String, dynamic> lastDecodedData = <String, dynamic>{};
    int? lastStatusCode;

    for (final attempt in attempts) {
      final method = attempt['method']!;
      final url = attempt['url']!;
      final body = attempt['body'];
      final payload = _requestPayloadForLog(body);

      final response = await _sendTaskRequest(
        method: method.toString(),
        url: url.toString(),
        token: token,
        body: body,
      );

      lastStatusCode = response.statusCode;
      debugPrint(
        '[TaskComplete] $method $url payload: $payload '
        '-> status: ${response.statusCode}, '
        'body: ${_shortBody(response.body)}',
      );

      if (response.statusCode == 204) {
        debugPrint('[TaskComplete] success with 204');
        return <String, dynamic>{'message': 'Task completion updated'};
      }

      final decodedData = _decodeMap(response.body);
      if (_isSuccess(response.statusCode)) {
        debugPrint('[TaskComplete] success with status ${response.statusCode}');
        return decodedData;
      }
      lastDecodedData = decodedData;
    }

    debugPrint(
      '[TaskComplete] failed -> lastStatusCode: $lastStatusCode, '
      'decoded: $lastDecodedData',
    );
    _throwApiError(
      lastDecodedData,
      lastStatusCode == null
          ? 'Task completion update failed'
          : 'Task completion update failed (status: $lastStatusCode)',
    );
  }

  static Future<Map<String, dynamic>> toggleTaskFavourite({
    required int id,
    required bool isFavourite,
    required String task,
    required String note,
    required DateTime dateTime,
  }) async {
    final sharedPrefHelper = SharedPreferenceHelper();
    final token = await sharedPrefHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    debugPrint('[TaskFavourite] started -> taskId: $id');

    final attempts = <Map<String, dynamic>>[
      {'method': 'PATCH', 'url': Urls.isFavoriteTaskById(id)},
      {'method': 'PUT', 'url': Urls.isFavoriteTaskById(id)},
      {'method': 'POST', 'url': Urls.isFavoriteTaskById(id)},
      {
        'method': 'PATCH',
        'url': Urls.isFavoriteTaskById(id),
        'body': <String, dynamic>{'isFavorite': isFavourite},
      },
      // Final fallback to update endpoint for compatibility.
      {
        'method': 'PATCH',
        'url': Urls.getTaskById(id),
        'body': <String, dynamic>{
          'task': task,
          'note': note,
          'dateTime': dateTime.toUtc().toIso8601String(),
          'isFavorite': isFavourite,
        },
      },
    ];

    Map<String, dynamic> lastDecodedData = <String, dynamic>{};
    int? lastStatusCode;

    for (final attempt in attempts) {
      final method = attempt['method']!;
      final url = attempt['url']!;
      final body = attempt['body'];
      final payload = _requestPayloadForLog(body);

      final response = await _sendTaskRequest(
        method: method.toString(),
        url: url.toString(),
        token: token,
        body: body,
      );

      lastStatusCode = response.statusCode;
      debugPrint(
        '[TaskFavourite] $method $url payload: $payload '
        '-> status: ${response.statusCode}, '
        'body: ${_shortBody(response.body)}',
      );

      if (response.statusCode == 204) {
        debugPrint('[TaskFavourite] success with 204');
        return <String, dynamic>{'message': 'Task favourite updated'};
      }

      final decodedData = _decodeMap(response.body);
      if (_isSuccess(response.statusCode)) {
        final responseFavourite = _extractBoolFromMap(
          decodedData,
          keys: const [
            'isFavourite',
            'isFavorite',
            'isfavourite',
            'isfavorite',
            'favourite',
            'favorite',
          ],
        );

        if (responseFavourite == isFavourite) {
          debugPrint(
            '[TaskFavourite] success with status ${response.statusCode}',
          );
          return decodedData;
        }

        // Verify from task details if response does not include the updated flag.
        try {
          final taskDetails = await getTaskById(id);
          final detailsFavourite = _extractBoolFromMap(
            taskDetails,
            keys: const [
              'isFavourite',
              'isFavorite',
              'isfavourite',
              'isfavorite',
              'favourite',
              'favorite',
            ],
          );
          if (detailsFavourite == isFavourite) {
            debugPrint(
              '[TaskFavourite] success after verification from task details',
            );
            return taskDetails;
          }
          debugPrint(
            '[TaskFavourite] response/verification mismatch for attempt '
            '$method $url: requested=$isFavourite, '
            'response=$responseFavourite, verified=$detailsFavourite',
          );
        } catch (e) {
          debugPrint('[TaskFavourite] verification failed: $e');
        }
      }
      lastDecodedData = decodedData;
    }

    debugPrint(
      '[TaskFavourite] failed -> lastStatusCode: $lastStatusCode, '
      'decoded: $lastDecodedData',
    );
    _throwApiError(
      lastDecodedData,
      lastStatusCode == null
          ? 'Task favourite update failed'
          : 'Task favourite update failed (status: $lastStatusCode)',
    );
  }

  static List<dynamic> _extractTaskList(Map<String, dynamic> decodedData) {
    final data = decodedData['data'];
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final tasks = data['tasks'];
      if (tasks is List) {
        return tasks;
      }
      final items = data['items'];
      if (items is List) {
        return items;
      }
    }
    final tasks = decodedData['tasks'];
    if (tasks is List) {
      return tasks;
    }
    return <dynamic>[];
  }

  static Map<String, dynamic>? _extractTaskDetails(
    Map<String, dynamic> decodedData,
  ) {
    final data = decodedData['data'];
    if (data is Map<String, dynamic>) {
      final nestedTask = data['task'];
      if (nestedTask is Map<String, dynamic>) {
        return nestedTask;
      }
      return data;
    }

    final task = decodedData['task'];
    if (task is Map<String, dynamic>) {
      return task;
    }

    if (decodedData.containsKey('id')) {
      return decodedData;
    }

    return null;
  }

  static bool _isSuccess(int statusCode) {
    return statusCode == 200 || statusCode == 201 || statusCode == 204;
  }

  static Map<String, dynamic> _decodeMap(String responseBody) {
    if (responseBody.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is List) {
        return <String, dynamic>{'data': decoded};
      }
    } catch (_) {
      final message = responseBody.trim();
      if (message.isNotEmpty) {
        return <String, dynamic>{'message': message};
      }
    }
    return <String, dynamic>{};
  }

  static Never _throwApiError(
    Map<String, dynamic> decodedData,
    String fallbackMessage,
  ) {
    throw Exception(
      _extractErrorMessageFromMap(
        decodedData,
        fallbackMessage: fallbackMessage,
      ),
    );
  }

  static String _extractErrorMessageFromMap(
    Map<String, dynamic> decodedData, {
    required String fallbackMessage,
  }) {
    final message = decodedData['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    if (message is List && message.isNotEmpty) {
      return message.join(', ');
    }
    return fallbackMessage;
  }

  static bool? _extractBoolFromMap(
    Map<String, dynamic> data, {
    required List<String> keys,
  }) {
    final candidates = <Map<String, dynamic>>[data];
    final rootData = data['data'];
    if (rootData is Map<String, dynamic>) {
      candidates.add(rootData);
      final task = rootData['task'];
      if (task is Map<String, dynamic>) {
        candidates.add(task);
      }
    }

    for (final map in candidates) {
      for (final key in keys) {
        final value = map[key];
        if (value is bool) {
          return value;
        }
        if (value is num) {
          return value != 0;
        }
        final normalized = value?.toString().trim().toLowerCase();
        if (normalized == 'true' || normalized == '1') {
          return true;
        }
        if (normalized == 'false' || normalized == '0') {
          return false;
        }
      }
    }
    return null;
  }

  static String _shortBody(String body, {int maxLength = 350}) {
    final sanitized = body.replaceAll('\n', ' ').trim();
    if (sanitized.isEmpty) {
      return '<empty>';
    }
    if (sanitized.length <= maxLength) {
      return sanitized;
    }
    return '${sanitized.substring(0, maxLength)}...';
  }

  static String _requestPayloadForLog(Object? body) {
    if (body == null) {
      return '<none>';
    }
    try {
      return _shortBody(jsonEncode(body));
    } catch (_) {
      return body.toString();
    }
  }

  static Future<http.Response> _sendTaskRequest({
    required String method,
    required String url,
    required String token,
    Object? body,
    bool rawBody = false,
    String? contentType,
  }) {
    final resolvedContentType = contentType ?? 'application/json';
    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': resolvedContentType,
    };
    final encodedBody = body == null
        ? null
        : (rawBody ? body.toString() : jsonEncode(body));

    switch (method.toUpperCase()) {
      case 'DELETE':
        return http.delete(Uri.parse(url), headers: headers, body: encodedBody);
      case 'PATCH':
        return http.patch(Uri.parse(url), headers: headers, body: encodedBody);
      case 'PUT':
        return http.put(Uri.parse(url), headers: headers, body: encodedBody);
      case 'POST':
        return http.post(Uri.parse(url), headers: headers, body: encodedBody);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  static Future<String> _uploadTaskFile({
    required String token,
    required File file,
  }) async {
    String? lastError;
    const candidateFields = ['file', 'files'];

    for (final fileFieldName in candidateFields) {
      const maxAttempts = 2;

      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          final request = http.MultipartRequest(
            'POST',
            Uri.parse(Urls.uploadFile),
          );
          request.headers.addAll({
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Connection': 'close',
          });
          request.persistentConnection = false;
          request.files.add(
            await http.MultipartFile.fromPath(fileFieldName, file.path),
          );

          debugPrint(
            '[TaskUpload] request -> field: $fileFieldName, '
            'attempt: $attempt/$maxAttempts, '
            'file: ${file.path.split('/').last}, size: ${file.lengthSync()}',
          );

          final streamedResponse = await request.send().timeout(
            _requestTimeout,
          );
          final response = await http.Response.fromStream(
            streamedResponse,
          ).timeout(_requestTimeout);
          final decodedData = _decodeMap(response.body);

          debugPrint(
            '[TaskUpload] response -> field: $fileFieldName, '
            'attempt: $attempt/$maxAttempts, status: ${response.statusCode}, '
            'body: ${_shortBody(response.body)}',
          );

          if (_isSuccess(response.statusCode)) {
            final fileUrl = _extractUploadedFileUrl(decodedData, response.body);
            if (fileUrl != null && fileUrl.isNotEmpty) {
              return fileUrl;
            }
            lastError = 'Upload succeeded but file URL not found in response';
          } else {
            lastError = _extractErrorMessageFromMap(
              decodedData,
              fallbackMessage: 'Failed to upload file',
            );
          }
        } on SocketException catch (e) {
          lastError = e.toString();
          debugPrint(
            '[TaskUpload] socket error -> field: $fileFieldName, '
            'attempt: $attempt/$maxAttempts, error: $e',
          );
          if (attempt < maxAttempts) {
            await Future.delayed(const Duration(milliseconds: 800));
            continue;
          }
        } on TimeoutException catch (e) {
          lastError = 'Request timed out. Please try again.';
          debugPrint(
            '[TaskUpload] timeout -> field: $fileFieldName, '
            'attempt: $attempt/$maxAttempts, error: $e',
          );
          if (attempt < maxAttempts) {
            await Future.delayed(const Duration(milliseconds: 800));
            continue;
          }
        } catch (e) {
          lastError = e.toString();
          debugPrint(
            '[TaskUpload] error -> field: $fileFieldName, '
            'attempt: $attempt/$maxAttempts, error: $e',
          );
          if (attempt < maxAttempts) {
            await Future.delayed(const Duration(milliseconds: 800));
            continue;
          }
        }
      }
    }

    throw Exception(
      lastError ??
          'Upload connection failed. The server closed the connection before sending a response.',
    );
  }

  static String? _extractUploadedFileUrl(
    Map<String, dynamic> decodedData,
    String rawBody,
  ) {
    final candidates = <dynamic>[
      decodedData['fileUrl'],
      decodedData['url'],
      decodedData['secure_url'],
    ];

    final data = decodedData['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) {
        candidates.add(first['fileUrl']);
        candidates.add(first['url']);
        candidates.add(first['secure_url']);
      }
    }
    if (data is Map<String, dynamic>) {
      candidates.add(data['fileUrl']);
      candidates.add(data['url']);
      candidates.add(data['secure_url']);
      final file = data['file'];
      if (file is Map<String, dynamic>) {
        candidates.add(file['fileUrl']);
        candidates.add(file['url']);
        candidates.add(file['secure_url']);
      }
    }
    if (decodedData.isEmpty) {
      try {
        final decoded = jsonDecode(rawBody);
        if (decoded is List && decoded.isNotEmpty) {
          final first = decoded.first;
          if (first is Map<String, dynamic>) {
            candidates.add(first['fileUrl']);
            candidates.add(first['url']);
            candidates.add(first['secure_url']);
          }
        }
      } catch (_) {}
    }

    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value != null &&
          value.isNotEmpty &&
          Uri.tryParse(value)?.hasScheme == true) {
        return value;
      }
    }

    final urlRegex = RegExp(r'https?://[^\s"\\]+');
    final match = urlRegex.firstMatch(rawBody);
    return match?.group(0);
  }
}
