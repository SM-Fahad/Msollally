import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class StudentFileUploadResponse {
  const StudentFileUploadResponse({
    required this.fileId,
    required this.originalName,
    required this.fileUrl,
    required this.fileSize,
    required this.message,
  });

  final int fileId;
  final String originalName;
  final String fileUrl;
  final String fileSize;
  final String message;

  factory StudentFileUploadResponse.fromJson(Map<String, dynamic> json) {
    return StudentFileUploadResponse(
      fileId: (json['fileId'] as num?)?.toInt() ?? 0,
      originalName: json['originalName']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      fileSize: json['fileSize']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class StudentConvertedFileResponse {
  const StudentConvertedFileResponse({
    required this.fileName,
    required this.savedPath,
    required this.contentType,
    required this.previewText,
  });

  final String fileName;
  final String savedPath;
  final String contentType;
  final String previewText;
}

class StudentFileConverterService {
  static Future<StudentFileUploadResponse> uploadFile({
    required File file,
  }) async {
    final token = await SharedPreferenceHelper().getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing access token. Please log in again.');
    }

    const maxAttempts = 2;
    Object? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(Urls.convertUpload),
        );
        request.headers.addAll({
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Connection': 'close',
        });
        request.persistentConnection = false;
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        _debugLog(
          'UPLOAD REQUEST => attempt: $attempt/$maxAttempts, url: ${Urls.convertUpload}, '
          'body: {"file":"${file.path.split('/').last}","size":"${file.lengthSync()} bytes"}',
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        final decodedResponse = _decodeJsonMap(response.body);

        _debugLog(
          'UPLOAD RESPONSE => status: ${response.statusCode}, body: ${response.body}',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return StudentFileUploadResponse.fromJson(decodedResponse);
        }

        throw Exception(
          _extractErrorMessage(
            decodedResponse,
            fallback: 'Failed to upload file for conversion.',
          ),
        );
      } on SocketException catch (e) {
        lastError = e;
        _debugLog(
          'UPLOAD SOCKET ERROR => attempt: $attempt/$maxAttempts, error: $e',
        );
        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 800));
          continue;
        }
      } catch (e) {
        lastError = e;
        _debugLog('UPLOAD ERROR => attempt: $attempt/$maxAttempts, error: $e');
        rethrow;
      }
    }

    throw Exception(
      'Upload connection failed. The server closed the connection before sending a response. Original error: $lastError',
    );
  }

  static Future<StudentConvertedFileResponse> convertFile({
    required int fileId,
    required String targetFormat,
  }) async {
    final token = await SharedPreferenceHelper().getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing access token. Please log in again.');
    }

    final requestBody = jsonEncode({'targetFormat': targetFormat});
    _debugLog(
      'CONVERT REQUEST => url: ${Urls.convertFileById(fileId)}, body: $requestBody',
    );

    final response = await http.post(
      Uri.parse(Urls.convertFileById(fileId)),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    _debugLog(
      'CONVERT RESPONSE => status: ${response.statusCode}, '
      'headers: ${response.headers}, bodyPreview: ${_buildResponsePreview(response)}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final fileName =
          _extractFileName(response.headers['content-disposition']) ??
          'converted_file.$targetFormat';
      final savedPath = await _saveFile(
        bytes: response.bodyBytes,
        fileName: fileName,
      );

      return StudentConvertedFileResponse(
        fileName: fileName,
        savedPath: savedPath,
        contentType: response.headers['content-type'] ?? '',
        previewText: _buildTextPreview(
          bytes: response.bodyBytes,
          contentType: response.headers['content-type'] ?? '',
          targetFormat: targetFormat,
        ),
      );
    }

    throw Exception(
      _extractErrorMessageFromRawBody(
        response.body,
        fallback: 'Failed to convert file.',
      ),
    );
  }

  static Map<String, dynamic> _decodeJsonMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  static String _extractErrorMessage(
    Map<String, dynamic> decoded, {
    required String fallback,
  }) {
    final message = decoded['message'];
    if (message is List && message.isNotEmpty) {
      return message.join(', ');
    }
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
    return fallback;
  }

  static String _extractErrorMessageFromRawBody(
    String body, {
    required String fallback,
  }) {
    final decoded = _decodeJsonMap(body);
    if (decoded.isNotEmpty) {
      return _extractErrorMessage(decoded, fallback: fallback);
    }
    return body.trim().isEmpty ? fallback : body.trim();
  }

  static String _buildResponsePreview(http.Response response) {
    final contentType = (response.headers['content-type'] ?? '').toLowerCase();
    final isTextLike =
        contentType.contains('text/') || contentType.contains('json');

    if (isTextLike) {
      final body = response.body;
      if (body.length <= 1000) {
        return body;
      }
      return '${body.substring(0, 1000)}... [truncated]';
    }

    return '[binary stream: ${response.bodyBytes.length} bytes]';
  }

  static String? _extractFileName(String? disposition) {
    if (disposition == null || disposition.isEmpty) {
      return null;
    }

    final utfMatch = RegExp(
      r"filename\*=UTF-8''([^;]+)",
    ).firstMatch(disposition);
    if (utfMatch != null) {
      return Uri.decodeFull(utfMatch.group(1)!);
    }

    final quotedMatch = RegExp(r'filename="([^"]+)"').firstMatch(disposition);
    if (quotedMatch != null) {
      return quotedMatch.group(1);
    }

    final plainMatch = RegExp(r'filename=([^;]+)').firstMatch(disposition);
    return plainMatch?.group(1)?.trim();
  }

  static Future<String> _saveFile({
    required List<int> bytes,
    required String fileName,
  }) async {
    final safeName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File(
      '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}_$safeName',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static String _buildTextPreview({
    required List<int> bytes,
    required String contentType,
    required String targetFormat,
  }) {
    final isTextResponse =
        targetFormat == 'txt' ||
        contentType.toLowerCase().contains('text/plain');
    if (!isTextResponse || bytes.isEmpty) {
      return '';
    }

    final previewLength = bytes.length > 6000 ? 6000 : bytes.length;
    final preview = utf8.decode(
      bytes.sublist(0, previewLength),
      allowMalformed: true,
    );
    if (bytes.length > previewLength) {
      return '$preview\n\nPreview truncated. Download the file to view the full content.';
    }
    return preview;
  }

  static void _debugLog(String message) {
    const chunkSize = 800;
    for (var i = 0; i < message.length; i += chunkSize) {
      final end = (i + chunkSize < message.length)
          ? i + chunkSize
          : message.length;
      debugPrint(message.substring(i, end));
    }
  }
}
