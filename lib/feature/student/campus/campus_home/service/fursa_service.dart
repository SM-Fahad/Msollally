import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/student_campus_fursa_zone_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/leaderboard_model.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/controller/dialogbox_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/quiz_question_model.dart';

class FursaService {
  Future<List<FursaTask>> fetchFursaTasks() async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(Urls.getAllCampaigns(page: 1, limit: 20)),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data.map((e) => FursaTask.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<CompetitionModel>> fetchCompetitions() async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(Urls.getActiveCompetitions),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('🔍 DEBUG: fetchCompetitions status: ${response.statusCode}');
      debugPrint('🔍 DEBUG: fetchCompetitions body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body is List
            ? body
            : (body is Map ? (body.containsKey('data') ? body['data'] : [body]) : []);
        return data.map((e) => CompetitionModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in fetchCompetitions: $e');
      return [];
    }
  }

  Future<CompetitionModel?> fetchCompetitionById(int id) async {
    try {
      final url = Urls.getCompetitionById(id);
      debugPrint('🔍 DEBUG: Fetching competition by ID from: $url');
      final token = await SharedPreferenceHelper().getAccessToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '🔍 DEBUG: Competition detail response status: ${response.statusCode}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final dynamic data = (body is Map && body.containsKey('data') && body['data'] is Map)
            ? body['data']
            : body;
        if (data is Map<String, dynamic>) {
          return CompetitionModel.fromJson(data);
        } else if (data is Map) {
          return CompetitionModel.fromJson(Map<String, dynamic>.from(data));
        }
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in fetchCompetitionById: $e');
      return null;
    }
  }

  Future<List<WinnerModel>> fetchWinners({
    required int competitionId,
    required bool isWeekly,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = isWeekly
          ? Urls.thisWeekWinners(competitionId)
          : Urls.lastWeekWinners(competitionId);

      debugPrint('🔍 DEBUG: Fetching winners from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('🔍 DEBUG: Winners response status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = (body is Map && body.containsKey('winners'))
            ? body['winners']
            : (body is Map && body.containsKey('data'))
            ? body['data']
            : (body is List ? body : []);
        return data.map((e) => WinnerModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔍 DEBUG: Error fetching winners: $e');
      return [];
    }
  }

  Future<List<TopSchoolModel>> fetchTopSchools(int competitionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Urls.topSchools(competitionId);

      debugPrint('🔍 DEBUG: Fetching top schools from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '🔍 DEBUG: Top schools response status: ${response.statusCode}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final List<dynamic> data =
            (body is Map && body.containsKey('topSchools'))
            ? body['topSchools']
            : (body is Map && body.containsKey('data'))
            ? body['data']
            : (body is List ? body : []);
        return data.map((e) => TopSchoolModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔍 DEBUG: Error fetching top schools: $e');
      return [];
    }
  }

  Future<List<StudentCampusLeaderboardModel>> fetchLeaderboard({
    required int competitionId,
    required bool isWeekly,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final filter = isWeekly ? 'weekly' : 'all-time';
      final url = Urls.getLeaderboard(
        competitionId: competitionId,
        filter: filter,
      );

      debugPrint('🔍 DEBUG: Fetching leaderboard from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '🔍 DEBUG: Leaderboard response status: ${response.statusCode}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = (body is Map && body.containsKey('data'))
            ? body['data']
            : (body is List ? body : []);

        int currentRank = 1;
        return data.map((e) {
          final model = StudentCampusLeaderboardModel.fromJson(e);
          final rankValue = model.rank > 0 ? model.rank : currentRank++;
          return model.copyWith(rank: rankValue);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('🔍 DEBUG: Error fetching leaderboard: $e');
      return [];
    }
  }

  Future<StudentCampusLeaderboardModel?> fetchUserRank({
    required int userId,
    required int competitionId,
    required bool isWeekly,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final filter = isWeekly ? 'weekly' : 'all-time';
      final url = Urls.getUserRank(
        userId: userId,
        competitionId: competitionId,
        filter: filter,
      );

      debugPrint('🔍 DEBUG: Fetching user own rank from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('🔍 DEBUG: User rank response status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return StudentCampusLeaderboardModel.fromJson(body);
      }
      return null;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error fetching user rank: $e');
      return null;
    }
  }

  Future<bool> trackTaskAction(int campaignId, String action) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      String url;
      if (action == 'view') {
        url = Urls.countCampaignViews(campaignId);
      } else if (action == 'impression') {
        url = Urls.countCampaignImpressions(campaignId);
      } else {
        return false;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registerCompetition({
    required int competitionId,
    required UserRegistrationData data,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final body = {
        "competitionId": competitionId,
        "fullName": data.fullName,
        "email": data.email,
        "studentId": data.studentId,
        "university": data.university,
        "program": data.program,
        "programm": data.program,
      };

      debugPrint('🔍 DEBUG: Sending registerCompetition Payload -> ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(Urls.registrations),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('🔍 DEBUG: registerCompetition status: ${response.statusCode}');
      debugPrint('🔍 DEBUG: registerCompetition response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final bodyDecoded = jsonDecode(response.body);
        debugPrint('registerCompetition error message: ${bodyDecoded['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('registerCompetition error: $e');
      return false;
    }
  }

  Future<bool> recordLearningProgress({
    required dynamic competitionId,
    required String activityType,
    required int timeSpent,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final body = {
        "competitionId": competitionId,
        "activityType": activityType,
        "timeSpent": timeSpent,
      };

      debugPrint('🔍 DEBUG: Sending API Payload -> ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(Urls.recordLearningProgress),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint(
        '🔍 DEBUG: recordLearningProgress status: ${response.statusCode}',
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('🔍 DEBUG: recordLearningProgress response body: ${response.body}');
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in recordLearningProgress: $e');
      return false;
    }
  }

  Future<bool> claimBonusPoints({
    required dynamic competitionId,
    required String bonusType,
    required String metadata,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final body = {
        "competitionId": competitionId,
        "bonusType": bonusType,
        "metadata": metadata,
      };

      debugPrint('🔍 DEBUG: Sending claimBonus Payload -> ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(Urls.claimBonus),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('🔍 DEBUG: claimBonus status: ${response.statusCode}');
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('🔍 DEBUG: claimBonus response body: ${response.body}');
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in claimBonus: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchLearningProgress(int registrationId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Urls.getLearningProgress(registrationId);
      debugPrint('🔍 DEBUG: Fetching learning progress from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('🔍 DEBUG: fetchLearningProgress status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return body as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in fetchLearningProgress: $e');
      return null;
    }
  }



  Future<bool> addLearningCoins({
    required int competitionId,
    required int coins,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final body = {"competitionId": competitionId, "coins": coins};

      final response = await http.post(
        Uri.parse(Urls.addLearningCoins),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('🔍 DEBUG: addLearningCoins status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in addLearningCoins: $e');
      return false;
    }
  }

  Future<bool> addQuizCoins({
    required int userId,
    required int competitionId,
    required int coins,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final body = {
        "userId": userId,
        "competitionId": competitionId,
        "coins": coins,
      };

      final response = await http.post(
        Uri.parse(Urls.addQuizCoins),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('🔍 DEBUG: addQuizCoins status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in addQuizCoins: $e');
      return false;
    }
  }

  Future<bool> updateQualificationQuizResult({
    required int userId,
    required int competitionId,
    required bool passed,
    required int score,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final body = {
        "userId": userId,
        "competitionId": competitionId,
        "passed": passed,
        "score": score,
      };

      final response = await http.post(
        Uri.parse(Urls.updateQualification),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint(
        '🔍 DEBUG: updateQualificationQuizResult status: ${response.statusCode}',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in updateQualificationQuizResult: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchBonusStatus(int competitionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Urls.getBonusStatus(competitionId);

      debugPrint('🔍 DEBUG: Fetching bonus status from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('🔍 DEBUG: getBonusStatus status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in fetchBonusStatus: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> claimBonus({
    required int competitionId,
    required String bonusType,
    String? metadata,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final body = {
        "competitionId": competitionId,
        "bonusType": bonusType,
        if (metadata != null) "metadata": metadata,
      };

      debugPrint('🔍 DEBUG: Claiming bonus with body: $body');
      final response = await http.post(
        Uri.parse(Urls.claimBonus),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('🔍 DEBUG: claimBonus status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in claimBonus: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> performBonusCheckIn(int competitionId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final body = {"competitionId": competitionId};

      debugPrint(
        '🔍 DEBUG: Performing daily check-in for competition ID: $competitionId',
      );
      final response = await http.post(
        Uri.parse(Urls.bonusCheckIn),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint(
        '🔍 DEBUG: performBonusCheckIn status: ${response.statusCode}',
      );
      debugPrint(
        '🔍 DEBUG: performBonusCheckIn body: ${response.body}',
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error in performBonusCheckIn: $e');
      return null;
    }
  }

  Future<List<QuizQuestionModel>> fetchQuizQuestions({
    required int competitionId,
    required String quizType,
    required int weekNumber,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Urls.getAdminQuizQuestions(
        competitionId: competitionId,
        quizType: quizType,
        weekNumber: weekNumber,
      );

      debugPrint('🔍 DEBUG: Fetching quiz questions from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '🔍 DEBUG: fetchQuizQuestions admin status: ${response.statusCode}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> body = jsonDecode(response.body) as List<dynamic>;
        return body.map((e) => QuizQuestionModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint(
        '🔍 DEBUG: Admin quiz fetch failed: $e, falling back to student endpoint...',
      );
    }

    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Urls.getQuizQuestions(
        competitionId: competitionId,
        quizType: quizType,
        weekNumber: weekNumber,
      );

      debugPrint(
        '🔍 DEBUG: Fetching student quiz questions fallback from: $url',
      );
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '🔍 DEBUG: fetchQuizQuestions student fallback status: ${response.statusCode}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> body = jsonDecode(response.body) as List<dynamic>;
        return body.map((e) => QuizQuestionModel.fromJson(e)).toList();
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
      final token = await SharedPreferenceHelper().getAccessToken();
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

      debugPrint(
        '🔍 DEBUG: Submitting quiz results to: $url with body: ${jsonEncode(body)}',
      );
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('🔍 DEBUG: submitQuizResult status: ${response.statusCode}');
      debugPrint('🔍 DEBUG: submitQuizResult body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      if (response.statusCode == 400) {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final msg = errorBody['message'] ?? 'Bad Request';
        EasyLoading.showError(msg);
      }

      return false;
    } catch (e) {
      debugPrint('🔍 DEBUG: Error submitting quiz results: $e');
      return false;
    }
  }
}
