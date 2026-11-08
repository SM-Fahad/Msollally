import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/events/all_events/model/event_model.dart';

class StudentCampusEventService {
  Future<List<EventModel>> fetchEvents({int page = 1, int limit = 50}) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/events').replace(
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> eventsList = decoded['events'] ?? [];
        return eventsList.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch events: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchEvents error: $e');
      rethrow;
    }
  }

  Future<EventModel> fetchEventById(String eventId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/events/$eventId');

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return EventModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch event detail: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchEventById error: $e');
      rethrow;
    }
  }

  Future<bool> registerForEvent(String eventId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/events/$eventId/register');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('registerForEvent statusCode: ${response.statusCode}');
      debugPrint('registerForEvent body: ${response.body}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('registerForEvent error: $e');
      return false;
    }
  }

  Future<bool> cancelRegistration(String eventId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse(
        '${Urls.baseUrl}/events/$eventId/cancel-registration',
      );

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      debugPrint('cancelRegistration statusCode: ${response.statusCode}');
      debugPrint('cancelRegistration body: ${response.body}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('cancelRegistration error: $e');
      return false;
    }
  }

  Future<bool> likeEvent(String eventId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/events/$eventId/like');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('likeEvent error: $e');
      return false;
    }
  }

  Future<bool> unlikeEvent(String eventId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/events/$eventId/unlike');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('unlikeEvent error: $e');
      return false;
    }
  }

  Future<void> trackEventView(String eventId) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/events/$eventId/view');

      await http.post(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      debugPrint('trackEventView error: $e');
    }
  }

  Future<bool> checkInEvent(String eventId, String code) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/events/$eventId/check-in');

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'code': code}),
      );
      debugPrint('checkInEvent statusCode: ${response.statusCode}');
      debugPrint('checkInEvent body: ${response.body}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('checkInEvent error: $e');
      return false;
    }
  }
}
