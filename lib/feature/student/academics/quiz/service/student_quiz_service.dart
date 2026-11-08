import 'package:flutter/material.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/quiz_question_model.dart';

class StudentQuizService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<String> _requireToken() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }
    return token;
  }

  Future<List<QuizQuestionModel>> fetchQuizQuestions({
    required int competitionId,
    required String quizType,
    required int weekNumber,
  }) async {
    try {
      final token = await _requireToken();
      final url = Urls.getAdminQuizQuestions(
        competitionId: competitionId,
        quizType: quizType,
        weekNumber: weekNumber,
      );

      final response = await _networkCaller.getRequest(
        url,
        token: 'Bearer $token',
      );

      if (response.isSuccess) {
        final payload = response.responseData;
        final List<dynamic> data = payload is List 
            ? payload 
            : (payload is Map ? (payload['data'] ?? []) : []);
        return data.map((e) => QuizQuestionModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('🔍 DEBUG: Admin quiz fetch failed: $e, falling back to student endpoint...');
    }

    try {
      final token = await _requireToken();
      final url = Urls.getQuizQuestions(
        competitionId: competitionId,
        quizType: quizType,
        weekNumber: weekNumber,
      );

      final response = await _networkCaller.getRequest(
        url,
        token: 'Bearer $token',
      );

      if (response.isSuccess) {
        final payload = response.responseData;
        final List<dynamic> data = payload is List 
            ? payload 
            : (payload is Map ? (payload['data'] ?? []) : []);
        return data.map((e) => QuizQuestionModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in fetchQuizQuestions student fallback: $e');
      return [];
    }
  }

  Future<bool> submitQuizResult({
    required int competitionId,
    required int registrationId,
    required int userId,
    required String quizType,
    required int weekNumber,
    required List<Map<String, dynamic>> answers,
    required int timeTaken,
  }) async {
    try {
      final token = await _requireToken();
      final url = Urls.submitQuizResult;

      final body = {
        'competitionId': competitionId,
        'registrationId': registrationId,
        'userId': userId,
        'quizType': quizType,
        'weekNumber': weekNumber,
        'answers': answers,
        'timeTaken': timeTaken,
      };

      final response = await _networkCaller.postJsonRequest(
        url,
        token: 'Bearer $token',
        body: body,
      );

      return response.isSuccess;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error submitting quiz results: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuizHistory({
    required int userId,
    required int competitionId,
  }) async {
    try {
      final token = await _requireToken();
      final url = Urls.getQuizHistory(
        userId: userId,
        competitionId: competitionId,
      );

      final response = await _networkCaller.getRequest(
        url,
        token: 'Bearer $token',
      );

      if (response.isSuccess) {
        final data = response.responseData;
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (data is Map && data.containsKey('data')) {
          final list = data['data'];
          if (list is List) {
            return list.map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('🔍 DEBUG: Error fetching quiz history: $e');
      return [];
    }
  }
}
