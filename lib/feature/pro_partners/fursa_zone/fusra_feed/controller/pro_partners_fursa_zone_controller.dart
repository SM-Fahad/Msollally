import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/fursa_zone/fusra_feed/model/pro_partners_fursa_zone_model.dart';

class ProPartnersFursaZoneController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();
  final ScrollController scrollController = ScrollController();

  final competitions = <ProPartnersFursaZoneModel>[].obs;
  final isInitialLoading = true.obs;
  final isLoadingMore = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;
  static const int pageLimit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchCompetitions(isRefresh: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients ||
        isInitialLoading.value ||
        isLoadingMore.value) {
      return;
    }

    final trigger = scrollController.position.maxScrollExtent - 120;
    if (scrollController.position.pixels >= trigger) {
      loadMore();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || isInitialLoading.value) return;
    if (currentPage.value >= totalPages.value && competitions.isNotEmpty) {
      return;
    }

    await fetchCompetitions(page: currentPage.value + 1);
  }

  Future<void> fetchCompetitions({bool isRefresh = false, int? page}) async {
    if (isRefresh) {
      isLoadingMore.value = false;
      isInitialLoading.value = true;
      competitions.clear();
      currentPage.value = 1;
      totalPages.value = 1;
      totalItems.value = 0;
    } else {
      if (isLoadingMore.value || isInitialLoading.value) return;
      if (currentPage.value >= totalPages.value && competitions.isNotEmpty) {
        return;
      }
      isLoadingMore.value = true;
    }

    final nextPage = page ?? 1;

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getProFusraFeed(page: nextPage, limit: pageLimit),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        if (isRefresh) {
          competitions.clear();
        }
        EasyLoading.showError(response.errorMessage);
        return;
      }

      final body = response.responseData;
      final rawData = body is Map<String, dynamic> && body['data'] is List
          ? List<dynamic>.from(body['data'] as List)
          : <dynamic>[];

      final mappedItems = rawData
          .whereType<Map<String, dynamic>>()
          .map(ProPartnersFursaZoneModel.fromJson)
          .toList();

      final apiPage = _toInt(
        body is Map<String, dynamic> ? body['page'] : null,
      );
      final apiTotalPages = _toInt(
        body is Map<String, dynamic> ? body['totalPages'] : null,
      );
      totalItems.value = _toInt(
        body is Map<String, dynamic> ? body['total'] : null,
      );

      if (mappedItems.isEmpty) {
        totalPages.value = apiTotalPages > 0
            ? apiTotalPages
            : (apiPage > 0 ? apiPage : nextPage);
        currentPage.value = apiPage > 0 ? apiPage : nextPage;
        return;
      }

      if (isRefresh || nextPage <= 1) {
        competitions.assignAll(mappedItems);
      } else {
        final existingIds = competitions.map((item) => item.id).toSet();
        competitions.addAll(
          mappedItems.where((item) => !existingIds.contains(item.id)),
        );
      }

      currentPage.value = apiPage > 0 ? apiPage : nextPage;
      totalPages.value = apiTotalPages > 0 ? apiTotalPages : currentPage.value;
    } catch (e) {
      if (isRefresh) {
        competitions.clear();
      }
      EasyLoading.showError('Failed to load competitions');
    } finally {
      isInitialLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  String getTagText(ProPartnersFursaZoneModel competition) {
    final normalized = competition.rawStatus.trim().toLowerCase();
    return normalized.isEmpty ? 'unknown' : normalized;
  }

  String getEndText(ProPartnersFursaZoneModel competition) {
    final date = competition.endDate ?? competition.startDate;
    if (date == null) return '';

    final prefix = competition.status == ProPartnersQuizStatus.completed
        ? 'Final'
        : 'Ends';
    return '$prefix: ${DateFormat('dd MMM yyyy').format(date.toLocal())}';
  }

  int _toInt(dynamic value) => int.tryParse('$value') ?? 0;
}
