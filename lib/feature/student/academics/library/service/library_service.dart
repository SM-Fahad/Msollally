import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../core/services/end_points.dart';
import '../../../../../../core/services/share_preferrance_helper.dart';
import '../model/library_model.dart';

class LibraryService {
  static Future<List<BookModel>> getBooks() async {
    final response = await _authorizedGet(Urls.libraryBooks);
    final decodedData = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode)) {
      final books = _extractBookList(decodedData);
      return books.map(BookModel.fromMap).toList();
    }

    throw Exception(_extractErrorMessage(decodedData, 'Failed to load books'));
  }

  static Future<BookModel> getBookById(String id) async {
    final response = await _authorizedGet(Urls.bookById(id));
    final decodedData = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode)) {
      return BookModel.fromMap(decodedData);
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load book details'),
    );
  }

  static Future<http.Response> _authorizedGet(String url) async {
    final token = await SharedPreferenceHelper().getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    return http.get(
      Uri.parse(url),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  static dynamic _decodeResponse(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static List<Map<String, dynamic>> _extractBookList(dynamic decodedData) {
    if (decodedData is List) {
      return decodedData
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (decodedData is Map<String, dynamic>) {
      final candidate = _firstNonNull([
        decodedData['data'],
        decodedData['books'],
        decodedData['library'],
        decodedData['items'],
        decodedData['results'],
      ]);

      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      if (candidate is Map<String, dynamic>) {
        final nestedList = _firstNonNull([
          candidate['books'],
          candidate['items'],
          candidate['results'],
          candidate['data'],
        ]);

        if (nestedList is List) {
          return nestedList
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }

    return const [];
  }

  static String _extractErrorMessage(dynamic decodedData, String fallback) {
    if (decodedData is Map<String, dynamic>) {
      final message = decodedData['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      if (message is List && message.isNotEmpty) {
        return message.join(', ');
      }
    }

    return fallback;
  }

  static dynamic _firstNonNull(List<dynamic> values) {
    for (final value in values) {
      if (value != null) {
        return value;
      }
    }
    return null;
  }
}
