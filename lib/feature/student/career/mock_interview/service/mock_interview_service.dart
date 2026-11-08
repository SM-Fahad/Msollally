import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import '../model/mock_model.dart';

class MockInterviewService {
  static Future<List<MockQuestion>> fetchQuestions(String categoryTitle) async {
    // Map category name to a lowercase slug
    String categorySlug = 'general';
    final normalized = categoryTitle.toLowerCase();
    if (normalized.contains('behavioral')) {
      categorySlug = 'behavioral';
    } else if (normalized.contains('technical') || normalized.contains('software')) {
      categorySlug = 'technical';
    } else if (normalized.contains('aptitude') || normalized.contains('logic')) {
      categorySlug = 'aptitude';
    }

    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      // Failsafe endpoint structure matching question bank / general career quiz
      final url = Uri.parse('${Urls.baseUrl}/mock-interview/questions?category=$categorySlug');

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        List<dynamic> rawQuestions = [];
        if (decoded is List) {
          rawQuestions = decoded;
        } else if (decoded is Map<String, dynamic>) {
          rawQuestions = decoded['data'] ?? decoded['questions'] ?? decoded['items'] ?? [];
        }

        if (rawQuestions.isNotEmpty) {
          return rawQuestions.map((json) {
            final questionText = json['questionText'] ?? json['question'] ?? '';
            final optionsRaw = json['options'];
            List<String> options = [];

            if (optionsRaw is List) {
              options = optionsRaw.map((opt) {
                if (opt is String) return opt;
                if (opt is Map) return (opt['text'] ?? opt['optionText'] ?? '').toString();
                return opt.toString();
              }).toList();
            }

            final correctIdx = json['correctAnswerIndex'] ?? json['correctOptionIndex'] ?? json['correctAnswer'] ?? 0;
            int correctAnswerIndex = 0;
            if (correctIdx is int) {
              correctAnswerIndex = correctIdx;
            } else if (correctIdx is String) {
              correctAnswerIndex = int.tryParse(correctIdx) ?? 0;
            }

            return MockQuestion(
              question: questionText,
              options: options,
              correctAnswerIndex: correctAnswerIndex,
            );
          }).toList();
        }
      }
      throw Exception('Backend returned empty questions list or status ${response.statusCode}');
    } catch (e) {
      // Re-throw so the controller handles the error and falls back to local questions
      rethrow;
    }
  }
}
