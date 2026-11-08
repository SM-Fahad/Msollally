import 'dart:io';

import 'package:flutter/services.dart';

class DeviceDownloadService {
  static const MethodChannel _channel = MethodChannel('msollaally/downloads');

  static Future<String> saveToDownloads({
    required String sourcePath,
    required String fileName,
    String? mimeType,
  }) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'Saving to the public Downloads folder is currently implemented for Android only.',
      );
    }

    final result = await _invokeSaveToDownloads(
      sourcePath: sourcePath,
      fileName: fileName,
      mimeType: mimeType,
    );

    if (result == null) {
      throw Exception('Download save failed: empty platform response.');
    }

    final locationLabel = result['location']?.toString() ?? '';
    if (locationLabel.isEmpty) {
      throw Exception('Download save failed: invalid platform response.');
    }

    return locationLabel;
  }

  static Future<Map<String, dynamic>?> _invokeSaveToDownloads({
    required String sourcePath,
    required String fileName,
    String? mimeType,
  }) async {
    try {
      return await _channel.invokeMapMethod<String, dynamic>(
        'saveToDownloads',
        {'sourcePath': sourcePath, 'fileName': fileName, 'mimeType': mimeType},
      );
    } on MissingPluginException {
      throw Exception(
        'Downloads integration is not available in this app build. '
        'If you just added this feature, completely stop the app and run it again. '
        'Hot reload or hot restart will not register native Android code.',
      );
    }
  }
}
