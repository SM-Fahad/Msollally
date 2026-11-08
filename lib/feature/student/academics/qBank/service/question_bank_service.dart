import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../../../core/services/end_points.dart';
import '../../../../../../core/services/share_preferrance_helper.dart';
import '../model/question_bank_model.dart';

class QuestionBankService {
  static Future<List<QuestionBankItem>> getQuestionBanks() async {
    debugPrint('API Request: GET ${Urls.questionBank}');
    final response = await _authorizedGet(Urls.questionBank);
    debugPrint('API Response: ${response.statusCode} - ${response.body}');
    
    final decodedData = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode)) {
      final list = _extractList(decodedData);
      return list.map(QuestionBankItem.fromMap).toList();
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load question bank'),
    );
  }

  static Future<QuestionBankItem> getQuestionBankById(String id) async {
    debugPrint('API Request: GET ${Urls.questionBankById(id)}');
    final response = await _authorizedGet(Urls.questionBankById(id));
    debugPrint('API Response: ${response.statusCode} - ${response.body}');
    
    final decodedData = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode) &&
        decodedData is Map<String, dynamic>) {
      return QuestionBankItem.fromMap(decodedData);
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load question bank details'),
    );
  }

  static Future<List<PracticeQuestion>> getPracticeQuestions(
    String qbankId,
  ) async {
    debugPrint('API Request: GET ${Urls.practiceQuestions(qbankId)}');
    final response = await _authorizedGet(Urls.practiceQuestions(qbankId));
    debugPrint('API Response: ${response.statusCode} - ${response.body}');
    
    final decodedData = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode)) {
      final list = _extractList(decodedData);
      return list.map(PracticeQuestion.fromMap).toList();
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load practice questions'),
    );
  }

  static Future<PracticeQuestion> getPracticeQuestionById(
    String questionId,
  ) async {
    debugPrint('API Request: GET ${Urls.practiceQuestionById(questionId)}');
    final response = await _authorizedGet(
      Urls.practiceQuestionById(questionId),
    );
    debugPrint('API Response: ${response.statusCode} - ${response.body}');
    
    final decodedData = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode) &&
        decodedData is Map<String, dynamic>) {
      return PracticeQuestion.fromMap(decodedData);
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to load practice question'),
    );
  }

  static Future<PracticeSubmissionResponse> submitPracticeQuestions(
    String qbankId,
    List<Map<String, String>> answers,
  ) async {
    final token = await SharedPreferenceHelper().getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final url = Urls.practiceQuestionsSubmit(qbankId);
    final requestBody = jsonEncode({"answers": answers});
    debugPrint('API Request: POST $url\nBody: $requestBody');
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );
    
    debugPrint('API Response: ${response.statusCode} - ${response.body}');

    final decodedData = _decodeResponse(response.body);

    if (_isSuccess(response.statusCode) &&
        decodedData is Map<String, dynamic>) {
      return PracticeSubmissionResponse.fromMap(decodedData);
    }

    throw Exception(
      _extractErrorMessage(decodedData, 'Failed to submit practice questions'),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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
    if (body.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static bool _isSuccess(int statusCode) =>
      statusCode >= 200 && statusCode < 300;

  static List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final candidate = data['data'] ?? data['items'] ?? data['results'];
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    return const [];
  }

  static String _extractErrorMessage(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join(', ');
    }
    return fallback;
  }
}
