import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import '../model/help_resource_model.dart';

class StudentEmergencyContactService {
  Future<List<HelpResourceModel>> fetchHelpResources({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
  }) async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final url = Uri.parse(Urls.helpResources).replace(queryParameters: queryParams);

      debugPrint('Fetching help resources URL: $url');

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> list = decoded['data'] ?? [];
        return list.map((json) => HelpResourceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch help resources: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchHelpResources error: $e');
      rethrow;
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse(Urls.helpResourceCategories);

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchCategories error: $e');
      rethrow;
    }
  }
}
