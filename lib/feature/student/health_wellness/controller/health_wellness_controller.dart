import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/health_wellness/model/emergency_support_model.dart';
import 'package:msollaally/feature/student/health_wellness/service/emergency_support_service.dart';
import 'package:msollaally/core/utils/logging/logger.dart';

class HealthWellnessController extends GetxController {
  final EmergencySupportService _service = EmergencySupportService();

  var emergencySupportList = <EmergencySupportModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasNextPage = true.obs;
  var currentPage = 1.obs;

  var selectedSupportType = 'physical_health'.obs;
  var selectedType = 'all'.obs;

  final ScrollController scrollController = ScrollController();
  final int limit = 10;
  
  late Worker _supportTypeWorker;
  late Worker _typeWorker;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    
    _supportTypeWorker = ever(selectedSupportType, (_) => _triggerRefresh());
    _typeWorker = ever(selectedType, (_) => _triggerRefresh());
  }

  Timer? _debounceTimer;
  
  void _triggerRefresh() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      refreshData();
    });
  }

  void initForHealth() {
    // Prevent redundant fetch if it's already set and data exists
    if (selectedSupportType.value != 'physical_health' && selectedSupportType.value != 'mental_health') {
        selectedSupportType.value = 'physical_health';
        selectedType.value = 'all';
    } else {
        if (emergencySupportList.isEmpty) refreshData();
    }
  }

  void initForWellness() {
    if (selectedSupportType.value != 'emergency_support') {
        selectedSupportType.value = 'emergency_support';
        selectedType.value = 'medical';
    } else {
        if (selectedType.value == 'all') {
           selectedType.value = 'medical';
        } else if (emergencySupportList.isEmpty) {
           refreshData();
        }
    }
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> refreshData() async {
    currentPage.value = 1;
    hasNextPage.value = true;
    emergencySupportList.clear();
    await fetchData();
  }

  Future<void> fetchData() async {
    if (!hasNextPage.value || isLoading.value || isLoadingMore.value) return;

    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final List<EmergencySupportModel>? result = await _service.getEmergencySupport(
        page: currentPage.value,
        limit: limit,
        supportType: selectedSupportType.value,
        type: selectedType.value == 'all' ? null : selectedType.value,
      );

      if (result != null) {
        if (result.length < limit) {
          hasNextPage.value = false;
        }
        emergencySupportList.addAll(result);
        currentPage.value++;
      } else {
        hasNextPage.value = false;
      }
    } catch (e) {
      AppLoggerHelper.error('Error fetching health wellness data: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadMore() {
    fetchData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _supportTypeWorker.dispose();
    _typeWorker.dispose();
    super.onClose();
  }
}
