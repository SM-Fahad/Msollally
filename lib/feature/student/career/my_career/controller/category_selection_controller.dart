import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger_barta/logger_barta.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class CategorySelectionController extends GetxController {
  var isLoading = true.obs;
  var topics = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTopics();
  }

  Future<void> fetchTopics() async {
    isLoading.value = true;
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse(Urls.getInterviewTopics);
      final response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = jsonDecode(response.body);
        topics.assignAll(data);
      }
    } catch (e) {
      BartaLog.error('fetchTopics error', error: e);
    } finally {
      isLoading.value = false;
    }
  }
}
