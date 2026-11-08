import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/profile/service/profile_service.dart';
import '../service/student_campus_campaign_service.dart';

class StudentCampusCampaignController extends GetxController {
  final isLoading = false.obs;
  final campaigns = <Map<String, String>>[].obs;
  final allCampaigns = <Map<String, String>>[].obs;
  final _campaignService = StudentCampusCampaignService();
  final _profileService = ProfileService();

  int currentPage = 1;
  int totalPages = 1;
  final isLoadMore = false.obs;
  Map<String, dynamic>? studentProfile;

  // Search state
  final isSearchOpen = false.obs;
  final searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void toggleSearch() {
    isSearchOpen.value = !isSearchOpen.value;
    if (isSearchOpen.value) {
      Future.delayed(const Duration(milliseconds: 100), () {
        searchFocusNode.requestFocus();
      });
    } else {
      clearSearch();
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilter();
  }

  void _applyFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      campaigns.value = List<Map<String, String>>.from(allCampaigns);
    } else {
      campaigns.value = allCampaigns.where((item) {
        final title = (item['title'] ?? '').toLowerCase();
        final tag = (item['tag'] ?? '').toLowerCase();
        final author = (item['authorName'] ?? '').toLowerCase();
        final desc = (item['description'] ?? '').toLowerCase();
        final uni = (item['university'] ?? '').toLowerCase();
        final major = (item['major'] ?? '').toLowerCase();
        final caption = (item['caption'] ?? '').toLowerCase();
        return title.contains(query) ||
            tag.contains(query) ||
            author.contains(query) ||
            desc.contains(query) ||
            uni.contains(query) ||
            major.contains(query) ||
            caption.contains(query);
      }).toList();
    }
  }

  Future<void> fetchCampaigns() async {
    isLoading.value = true;
    currentPage = 1;
    try {
      if (studentProfile == null) {
        final profileRes = await _profileService.fetchMe();
        if (profileRes != null) {
          studentProfile = (profileRes['data']?['profile'] ??
              profileRes['profile'] ??
              profileRes) as Map<String, dynamic>?;
        }
      }

      final response = await _campaignService.fetchCampaigns(
        page: currentPage,
        limit: 50,
      );
      final list = (response['data'] as List<Map<String, String>>)
          .where((item) => _matchesCampaign(item, studentProfile))
          .toList();
      allCampaigns.value = list;
      _applyFilter();
      totalPages = response['totalPages'] as int;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load campaigns: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreCampaigns() async {
    if (isLoadMore.value || currentPage >= totalPages) return;

    isLoadMore.value = true;
    currentPage++;
    try {
      final response = await _campaignService.fetchCampaigns(
        page: currentPage,
        limit: 20,
      );
      final newData = (response['data'] as List<Map<String, String>>)
          .where((item) => _matchesCampaign(item, studentProfile))
          .toList();
      if (newData.isNotEmpty) {
        allCampaigns.addAll(newData);
        _applyFilter();
      }
      totalPages = response['totalPages'] as int;
    } catch (e) {
      currentPage--;
    } finally {
      isLoadMore.value = false;
    }
  }

  bool _matchesCampaign(
    Map<String, String> item,
    Map<String, dynamic>? profile,
  ) {
    if (profile == null || profile.isEmpty) return true;

    // 1. Gender filter
    final gender = (item['gender'] ?? '').trim().toLowerCase();
    if (gender.isNotEmpty && gender != 'any') {
      final studGender =
          (profile['gender'] ?? '').toString().trim().toLowerCase();
      if (studGender.isNotEmpty && !gender.contains(studGender)) {
        return false;
      }
    }

    // 2. University filter
    final uni = (item['university'] ?? '').trim().toLowerCase();
    if (uni.isNotEmpty && uni != 'all' && uni != 'all universities') {
      final studUni = (profile['university'] ?? profile['universityName'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      if (studUni.isNotEmpty &&
          !uni.contains(studUni) &&
          !studUni.contains(uni)) {
        return false;
      }
    }

    // 3. Major filter
    final major = (item['major'] ?? '').trim().toLowerCase();
    if (major.isNotEmpty && major != 'all' && major != 'all departments') {
      final dept = (profile['department'] ??
              profile['departmentName'] ??
              profile['program'] ??
              '')
          .toString()
          .trim()
          .toLowerCase();
      if (dept.isNotEmpty) {
        final normMajor = major.replaceAll('_', ' ');
        final normDept = dept.replaceAll('_', ' ');
        if (!normDept.contains(normMajor) && !normMajor.contains(normDept)) {
          return false;
        }
      }
    }

    // 4. Year filter
    final year = (item['yearOfStudy'] ?? '').trim();
    if (year.isNotEmpty &&
        year != '0' &&
        year.toLowerCase() != 'all' &&
        year.toLowerCase() != 'all years') {
      final studYear = (profile['enrollmentYear'] ?? profile['year'] ?? '')
          .toString()
          .trim();
      if (studYear.isNotEmpty && studYear != year) {
        return false;
      }
    }

    return true;
  }
}
