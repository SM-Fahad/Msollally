import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/services/end_points.dart';
import '../../../../../core/services/share_preferrance_helper.dart';
import '../model/student_plan_model.dart';

class StudentPlanService {
  static Future<List<StudentPlanModel>> getAllPlans({String? id}) async {
    final userId = id ?? await SharedPreferenceHelper().getUserId() ?? '';
    final response = await _authorizedGet(Urls.getAllPlans(userId));
    final decodedData = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode)) {
      final plans = _extractPlanList(decodedData);
      return plans.map(StudentPlanModel.fromMap).toList();
    }

    throw Exception(_extractErrorMessage(decodedData, 'Failed to load plans'));
  }

  static Future<StudentPlanDetailsModel> getPlanById(String id) async {
    try {
      final response = await _authorizedGet(Urls.getPlanById(id));
      final decodedData = _decodeResponse(response.body);

      if (_isSuccess(response.statusCode)) {
        final planMap = _extractPlanDetails(decodedData);
        return StudentPlanDetailsModel.fromMap(planMap);
      }
    } catch (_) {}

    // Fallback attempt via main baseUrl
    try {
      final fallbackUrl = '${Urls.baseUrl}/plans/$id';
      final response = await _authorizedGet(fallbackUrl);
      final decodedData = _decodeResponse(response.body);

      if (_isSuccess(response.statusCode)) {
        final planMap = _extractPlanDetails(decodedData);
        return StudentPlanDetailsModel.fromMap(planMap);
      }
    } catch (_) {}

    throw Exception('Failed to load plan details');
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
    return statusCode == 200 || statusCode == 201;
  }

  static List<Map<String, dynamic>> _extractPlanList(dynamic decodedData) {
    if (decodedData is List) {
      return decodedData
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (decodedData is Map<String, dynamic>) {
      final candidate = _firstNonNull([
        decodedData['data'],
        decodedData['plans'],
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
          candidate['plans'],
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

  static Map<String, dynamic> _extractPlanDetails(dynamic decodedData) {
    if (decodedData is Map<String, dynamic>) {
      final candidate = _firstNonNull([
        decodedData['data'],
        decodedData['plan'],
        decodedData['item'],
      ]);

      if (candidate is Map<String, dynamic>) {
        return Map<String, dynamic>.from(candidate);
      }

      return decodedData;
    }

    return <String, dynamic>{};
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
