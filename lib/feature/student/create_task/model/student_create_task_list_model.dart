import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/services/end_points.dart';

class StudentCreateTaskListModel {
  final int? id;
  final String title;
  final String date;
  final String? rawDateTime;
  final String note;
  final File? file;
  final String? fileUrl;

  final RxBool isTappedFavorite;
  final RxBool isTapCheckBox;

  StudentCreateTaskListModel({
    this.id,
    this.file,
    this.fileUrl,
    this.rawDateTime,
    required this.note,
    required this.title,
    required this.date,
    bool isTappedFavorite = false,
    bool isTapCheckBox = false,
  }) : isTappedFavorite = isTappedFavorite.obs,
       isTapCheckBox = isTapCheckBox.obs;

  factory StudentCreateTaskListModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id'];
    return StudentCreateTaskListModel(
      id: idValue is int ? idValue : int.tryParse(idValue?.toString() ?? ''),
      title: (json['task'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      date: _formatDate((json['dateTime'] ?? '').toString()),
      rawDateTime: json['dateTime']?.toString(),
      fileUrl: _extractFileUrl(json),
      isTappedFavorite:
          _extractBool(
            json,
            keys: const [
              'isFavourite',
              'isFavorite',
              'is_favourite',
              'is_favorite',
              'favourite',
              'favorite',
              'isfavourite',
              'isfavorite',
            ],
          ) ??
          false,
      isTapCheckBox:
          _extractBool(
            json,
            keys: const [
              'isCompleted',
              'isComplete',
              'is_completed',
              'completed',
              'iscompleted',
            ],
          ) ??
          false,
    );
  }

  static bool? _extractBool(
    Map<String, dynamic> json, {
    required List<String> keys,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      final normalized = value?.toString().trim().toLowerCase();
      if (normalized == null || normalized.isEmpty) {
        continue;
      }
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }
    return null;
  }

  static String? _extractFileUrl(Map<String, dynamic> json) {
    final List<dynamic> candidates = [
      json['fileUrl'],
      json['fileURL'],
      json['file_url'],
      json['imageUrl'],
      json['image_url'],
      json['attachmentUrl'],
      json['attachment_url'],
      json['url'],
      json['filePath'],
      json['file_path'],
    ];

    final file = json['file'];
    if (file is String) {
      candidates.add(file);
    } else if (file is Map<String, dynamic>) {
      candidates.add(file['url']);
      candidates.add(file['fileUrl']);
      candidates.add(file['path']);
    }

    final attachments = json['attachments'];
    if (attachments is List && attachments.isNotEmpty) {
      final firstAttachment = attachments.first;
      if (firstAttachment is String) {
        candidates.add(firstAttachment);
      } else if (firstAttachment is Map<String, dynamic>) {
        candidates.add(firstAttachment['url']);
        candidates.add(firstAttachment['fileUrl']);
        candidates.add(firstAttachment['path']);
      }
    }

    for (final candidate in candidates) {
      final normalized = _normalizeUrl(candidate?.toString());
      if (normalized != null) {
        return normalized;
      }
    }
    return null;
  }

  static String? _normalizeUrl(String? rawUrl) {
    if (rawUrl == null) {
      return null;
    }

    final url = rawUrl.trim();
    if (url.isEmpty || url.toLowerCase() == 'null') {
      return null;
    }

    if (url.startsWith('//')) {
      return 'https:$url';
    }

    final parsed = Uri.tryParse(url);
    if (parsed != null && parsed.hasScheme) {
      return url;
    }

    if (url.startsWith('/')) {
      return '${Urls.baseUrl}$url';
    }

    return '${Urls.baseUrl}/$url';
  }

  static String _formatDate(String input) {
    if (input.isEmpty) {
      return '-';
    }
    try {
      final parsedDate = DateTime.parse(input).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (_) {
      return input;
    }
  }
}
