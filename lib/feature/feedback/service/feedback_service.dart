import 'package:flutter/foundation.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/feedback/model/feedback_model.dart';
import 'package:msollaally/core/models/response_data.dart';

class FeedbackService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _sharedPreferenceHelper = SharedPreferenceHelper();

  Future<String?> _getToken() async {
    final token = await _sharedPreferenceHelper.getAccessToken();
    return token != null ? 'Bearer $token' : null;
  }

  Future<List<FeedbackModel>?> getFeedbacks({
    int page = 1,
    int limit = 10,
    String? category,
    String? status,
  }) async {
    try {
      final token = await _getToken();
      String url = '${Urls.feedbacks}?page=$page&limit=$limit';
      if (category != null && category.isNotEmpty && category != 'all') {
        url += '&category=$category';
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        url += '&status=$status';
      }

      final ResponseData response = await _networkCaller.getRequest(url, token: token);
      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData['data'] as List?;
        if (data != null) {
          return data.map((e) => FeedbackModel.fromJson(e)).toList();
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting feedbacks: $e');
      return null;
    }
  }

  Future<bool> createFeedback({
    required String title,
    required String description,
    required String category,
    String? attachmentUrl,
  }) async {
    try {
      final token = await _getToken();
      final body = {
        "title": title,
        "description": description,
        "category": category,
        if (attachmentUrl != null) "attachmentUrl": attachmentUrl,
      };

      final ResponseData response = await _networkCaller.postJsonRequest(
        Urls.feedbacks,
        body: body,
        token: token,
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error creating feedback: $e');
      return false;
    }
  }

  Future<bool> updateFeedback({
    required int id,
    String? title,
    String? description,
    String? category,
    String? attachmentUrl,
  }) async {
    try {
      final token = await _getToken();
      final body = <String, dynamic>{};
      if (title != null) body["title"] = title;
      if (description != null) body["description"] = description;
      if (category != null) body["category"] = category;
      if (attachmentUrl != null) body["attachmentUrl"] = attachmentUrl;

      final ResponseData response = await _networkCaller.patchJsonRequest(
        Urls.feedbackById(id),
        body: body,
        token: token,
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error updating feedback: $e');
      return false;
    }
  }

  Future<bool> deleteFeedback(int id) async {
    try {
      final token = await _getToken();
      final ResponseData response = await _networkCaller.deleteRequest(
        Urls.feedbackById(id),
        token: token,
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error deleting feedback: $e');
      return false;
    }
  }
  Future<FeedbackModel?> getFeedbackDetails(int id) async {
    try {
      final token = await _getToken();
      final ResponseData response = await _networkCaller.getRequest(
        Urls.feedbackById(id),
        token: token,
      );
      if (response.isSuccess && response.responseData != null) {
        // The API returns the object directly, not wrapped in 'data'
        return FeedbackModel.fromJson(response.responseData);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting feedback details: $e');
      return null;
    }
  }

  Future<bool> postFeedbackReply(int id, String message) async {
    try {
      final token = await _getToken();
      final body = {"message": message};
      final ResponseData response = await _networkCaller.postJsonRequest(
        '${Urls.feedbacks}/$id/replies',
        body: body,
        token: token,
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('Error posting reply: $e');
      return false;
    }
  }
}
