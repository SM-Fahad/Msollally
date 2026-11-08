import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/services/device_download_service.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

part '../model/fusra_details_models.dart';
part '../../register/controller/fusra_details_static_registration.dart';
part '../../register/controller/fusra_details_registration_api.dart';
part 'fusra_details_api.dart';
part 'fusra_details_video.dart';
part '../widgets/fusra_details_video_fullscreen.dart';

class FusraDetailsController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  final List<String> tabs = const ['Analytics', 'Registrations', 'Details'];

  final String competitionTitle = '';
  final String competitionSubtitle = '';
  final String registeredStudentsTitle = '';
  final String searchHint = 'Search by name, ID, or university...';

  final registrationsScrollController = ScrollController();
  final registrationsSearchController = TextEditingController();
  final registrationSearchQuery = ''.obs;
  final isRegistrationsLoading = false.obs;
  final isLoadingMore = false.obs;
  final registrationsError = ''.obs;
  final totalRegistration = 0.obs;
  final currentRegistrationPage = 1.obs;
  final totalRegistrationPages = 1.obs;
  final registrationLimit = 5;
  final hasMoreRegistrations = true.obs;
  final registeredStudents = <RegistrationStudent>[].obs;
  final expandedRegistrationSections = <String>{}.obs;
  final DetailsHeaderData detailsHeader = kDetailsHeader;
  final String brochureText = '';

  final isDetailsLoading = false.obs;
  final detailsError = ''.obs;

  final competitionName = ''.obs;
  final brandSlogan = ''.obs;
  final partnerName = ''.obs;
  final promoImageLink = ''.obs;
  final promoVideoLink = ''.obs;
  final partnerInfoFileLink = ''.obs;
  final competitionId = ''.obs;

  final isLoading = false.obs;
  final isStatsLoading = false.obs;
  final isPrizesLoading = false.obs;
  final isTopSchoolsLoading = false.obs;
  final errorMessage = ''.obs;
  final statsData = <String, num>{}.obs;
  final prizes = <Map<String, dynamic>>[].obs;
  final topSchools = <Map<String, dynamic>>[].obs;
  final visiblePrizeCount = 5.obs;
  final visibleTopSchoolCount = 10.obs;

  final isYoutubeVideo = false.obs;
  final isWebVideo = false.obs;
  final hasStartedYoutubeVideo = false.obs;
  final pendingYoutubeAutoPlay = false.obs;
  final youtubeThumbnailUrl = ''.obs;
  final isVideoPlaying = false.obs;
  final isVideoMuted = false.obs;
  final isVideoInitializing = false.obs;
  final videoError = ''.obs;

  // ✅ FIX 1: Added reactive position & duration so the slider updates live
  final videoPosition = Duration.zero.obs;
  final videoDuration = Duration.zero.obs;
  final isFullscreenOpen = false.obs;
  final isFullscreenInitializing = false.obs;
  final isFullscreenPlaying = false.obs;
  final isFullscreenMuted = false.obs;
  final fullscreenPosition = Duration.zero.obs;
  final fullscreenDuration = Duration.zero.obs;

  VideoPlayerController? videoPlayerController;
  YoutubePlayerController? youtubePlayerController;
  VideoPlayerController? fullscreenVideoController;
  Worker? _registrationSearchWorker;

  List<Map<String, dynamic>> get displayedPrizes =>
      prizes.take(visiblePrizeCount.value).toList();
  List<Map<String, dynamic>> get displayedTopSchools =>
      topSchools.take(visibleTopSchoolCount.value).toList();
  bool get showPrizeLoadMore => visiblePrizeCount.value < prizes.length;
  bool get showTopSchoolLoadMore =>
      visibleTopSchoolCount.value < topSchools.length;

  String get activeRegistrationsLabel =>
      _labelFromStats(statsData['activeRegistrations']);
  String get completedLearningLabel =>
      _labelFromStats(statsData['completedLearning']);
  String get passedQualificationLabel =>
      _labelFromStats(statsData['passedQualification']);
  String get finalsPassedLabel => _labelFromStats(statsData['finalsPassed']);

  String _labelFromStats(num? value) {
    if (value == null) return '0';
    if (value is int) return value.toString();
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  Future<void> fetchAllAnalytics(String id) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';

    await Future.wait([
      fetchCompetitionStats(id),
      fetchPrizes(id),
      fetchTopSchools(id),
    ]);

    isLoading.value = false;
    if (statsData.isEmpty && prizes.isEmpty && topSchools.isEmpty) {
      errorMessage.value = errorMessage.value.isEmpty
          ? 'Unable to load analytics data'
          : errorMessage.value;
    }
  }

  Future<void> refreshAnalytics(String id) async {
    if (isLoading.value ||
        isStatsLoading.value ||
        isPrizesLoading.value ||
        isTopSchoolsLoading.value) {
      return;
    }
    visiblePrizeCount.value = 5;
    visibleTopSchoolCount.value = 10;
    await fetchAllAnalytics(id);
  }

  Future<void> retryAnalytics(String id) async {
    await refreshAnalytics(id);
  }

  Future<void> fetchCompetitionStats(String id) async {
    if (isStatsLoading.value) return;
    isStatsLoading.value = true;

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getCompetitionStats(id),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        _setAnalyticsError(
          response.errorMessage,
          fallback: 'Failed to load competition stats',
        );
        statsData.clear();
        return;
      }

      final data = _extractDataMap(response.responseData);
      statsData.value = {
        'activeRegistrations': _asNum(data['activeRegistrations']),
        'completedLearning': _asNum(data['completedLearning']),
        'passedQualification': _asNum(data['passedQualification']),
        'finalsPassed': _asNum(data['finalsPassed']),
      };
      errorMessage.value = '';
    } catch (_) {
      statsData.clear();
      _setAnalyticsError('', fallback: 'Failed to load competition stats');
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> fetchPrizes(String id) async {
    if (isPrizesLoading.value) return;
    isPrizesLoading.value = true;

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getFursaDetails(id),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        _setAnalyticsError(
          response.errorMessage,
          fallback: 'Failed to load prizes',
        );
        prizes.clear();
        return;
      }

      final data = _extractDataMap(response.responseData);
      final raw = data['prizes'];
      final parsed = raw is List
          ? raw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : <Map<String, dynamic>>[];
      prizes.value = parsed;
      visiblePrizeCount.value = 5;
      errorMessage.value = '';
    } catch (_) {
      prizes.clear();
      _setAnalyticsError('', fallback: 'Failed to load prizes');
    } finally {
      isPrizesLoading.value = false;
    }
  }

  Future<void> fetchTopSchools(String id) async {
    if (isTopSchoolsLoading.value) return;
    isTopSchoolsLoading.value = true;

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getTopSchoolPerform(id),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        _setAnalyticsError(
          response.errorMessage,
          fallback: 'Failed to load top schools',
        );
        topSchools.clear();
        return;
      }

      final data = _extractDataMap(response.responseData);
      final raw = data['topSchools'];
      final parsed = raw is List
          ? raw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : <Map<String, dynamic>>[];
      topSchools.value = parsed;
      visibleTopSchoolCount.value = 10;
      errorMessage.value = '';
    } catch (_) {
      topSchools.clear();
      _setAnalyticsError('', fallback: 'Failed to load top schools');
    } finally {
      isTopSchoolsLoading.value = false;
    }
  }

  void loadMorePrizes() {
    if (!showPrizeLoadMore) return;
    visiblePrizeCount.value = (visiblePrizeCount.value + 5).clamp(
      0,
      prizes.length,
    );
  }

  void loadMoreTopSchools() {
    if (!showTopSchoolLoadMore) return;
    visibleTopSchoolCount.value = (visibleTopSchoolCount.value + 10).clamp(
      0,
      topSchools.length,
    );
  }

  Map<String, dynamic> _extractDataMap(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map<String, dynamic>) {
      return body;
    }
    return <String, dynamic>{};
  }

  num _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse('$value') ?? 0;
  }

  void _setAnalyticsError(String message, {required String fallback}) {
    final msg = message.trim();
    errorMessage.value = msg.isNotEmpty ? msg : fallback;
  }

  @override
  void onInit() {
    super.onInit();
    _registrationSearchWorker = debounce<String>(
      registrationSearchQuery,
      (query) => fetchRegistrations(search: query),
      time: const Duration(milliseconds: 450),
    );
    final argumentId = Get.arguments?.toString();
    if (argumentId != null && argumentId.isNotEmpty) {
      competitionId.value = argumentId;
      fetchCompetitionDetails(argumentId);
      fetchAllAnalytics(argumentId);
      fetchRegistrations();
    }
    registrationsScrollController.addListener(_onRegistrationsScroll);
  }

  @override
  void onClose() {
    _registrationSearchWorker?.dispose();
    registrationsScrollController
      ..removeListener(_onRegistrationsScroll)
      ..dispose();
    registrationsSearchController.dispose();
    disposeVideoControllers();
    super.onClose();
  }

  void onRegistrationSearchChanged(String value) {
    currentRegistrationPage.value = 1;
    totalRegistrationPages.value = 1;
    hasMoreRegistrations.value = true;
    registrationsError.value = '';
    registeredStudents.clear();
    expandedRegistrationSections.clear();
    registrationSearchQuery.value = value;
  }

  void _onRegistrationsScroll() {
    if (!registrationsScrollController.hasClients) return;
    final position = registrationsScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      loadMoreRegistrations();
    }
  }

  Future<void> loadMoreRegistrations() async {
    if (isRegistrationsLoading.value ||
        isLoadingMore.value ||
        !hasMoreRegistrations.value) {
      return;
    }
    await fetchRegistrations(
      search: registrationSearchQuery.value,
      loadMore: true,
    );
  }

  bool isSectionExpanded(String studentId, String sectionKey) {
    return expandedRegistrationSections.contains('$studentId-$sectionKey');
  }

  void toggleSection(String studentId, String sectionKey) {
    final key = '$studentId-$sectionKey';
    if (expandedRegistrationSections.contains(key)) {
      expandedRegistrationSections.remove(key);
    } else {
      expandedRegistrationSections.add(key);
    }
    expandedRegistrationSections.refresh();
  }
}
