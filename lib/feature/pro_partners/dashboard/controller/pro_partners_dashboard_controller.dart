// lib/controller/pro_partners_dashboard_controller.dart
import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import '../model/pro_partner_me_model.dart';
import '../model/pro_partners_dashboard_model.dart';
import '../service/pro_partners_me_service.dart';
import '../../chat/repository/pro_partners_chat_repository.dart';
import '../../chat/service/chat_badge_service.dart';

class ProPartnersDashboardController extends GetxController {
  final ProPartnersDashboardService _dashboardService = ProPartnersDashboardService();
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  // Profile Observables
  final me = Rxn<ProPartnerMeResponse>();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  
  // Dashboard Stats Observables
  final overallEngagementRate = '0.00%'.obs;
  final chartData = <DashboardChartData>[].obs;
  final topCampaignClicks = 0.obs;
  final topCampaignTitle = ''.obs;
  final topCampaignCtr = '0.00'.obs;
  final topCampaignImpressions = 0.obs;
  final jobApplicationsLast7Days = 0.obs;
  final eventTotalJoined = 0.obs;
  final eventTotalViews = 0.obs;
  final eventConversionRate = '0.00%'.obs;
  final eventSummary = ''.obs;
  final unreadMessages = 0.obs;
  final newMessages = 0.obs;
  final newMessagesSummary = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(ChatBadgeService.unreadCount, (int count) {
      unreadMessages.value = count;
      if (count > 0) {
        newMessagesSummary.value =
            '$count unread conversation${count > 1 ? 's' : ''}';
      } else {
        newMessagesSummary.value = 'No unread messages';
      }
    });
    fetchDashboard();
  }

  // Calculate event progress safely
  double get eventProgress {
    if (eventTotalViews.value <= 0) return 0;
    return (eventTotalJoined.value / eventTotalViews.value).clamp(0, 1);
  }

  // Ensure chart always has 7 days of data even if empty
  List<DashboardChartData> chartDataList() {
    if (chartData.isEmpty) {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
          .map((day) => DashboardChartData(day, 0, 0))
          .toList();
    }
    return chartData;
  }

  // Main fetch function
  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final accessToken = await _prefHelper.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token not found');
      }

      // Fetch Profile
      final response = await _dashboardService.fetchMe(accessToken: accessToken);
      me.value = response;

      if (response.id != null) {
        await _prefHelper.saveUserId(response.id.toString());
      }

      // Fetch Stats
      final statsData = await _dashboardService.fetchOverviewStats(accessToken: accessToken);
      if (statsData != null) {
        _assignStatsToObservables(statsData);
      }

      // Ensure real-time chat stats are always accurate and updated
      try {
        final chatRepo = ProPartnersChatRepository();
        final chatRooms = await chatRepo.getChats();
        final storedIdStr = await _prefHelper.getUserId();
        final currentId = response.id ?? int.tryParse(storedIdStr ?? '');
        if (currentId != null) {
          final unreadRooms = chatRooms.where((room) {
            final me = room.participants.where((p) => p.user.id == currentId);
            return me.isNotEmpty && me.first.lastReadMessageId == null;
          }).length;
          unreadMessages.value = unreadRooms;
          ChatBadgeService.unreadCount.value = unreadRooms;
          if (unreadRooms > 0) {
            newMessagesSummary.value = '$unreadRooms unread conversation${unreadRooms > 1 ? 's' : ''}';
          } else {
            newMessagesSummary.value = 'No unread messages';
          }
        }
        chatRepo.socket.connect(token: accessToken);
      } catch (_) {}

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to keep parsing clean
  void _assignStatsToObservables(Map<String, dynamic> data) {
    overallEngagementRate.value = data['overallEngagementRate']?.toString() ?? '0.00%';
    jobApplicationsLast7Days.value = _toInt(data['jobApplicationsLast7Days']);

    if (data['impressionsVsReach'] is List) {
      chartData.value = (data['impressionsVsReach'] as List).map((item) => DashboardChartData(
        item['day']?.toString() ?? '',
        _toDouble(item['impressions']),
        _toDouble(item['reach']),
      )).toList();
    }

    if (data['topCampaign'] is Map) {
      final campaign = data['topCampaign'];
      topCampaignClicks.value = _toInt(campaign['clicks']);
      topCampaignTitle.value = campaign['title']?.toString() ?? '';
      topCampaignCtr.value = campaign['ctr']?.toString() ?? '0.00';
      topCampaignImpressions.value = _toInt(campaign['impressions']);
    }

    if (data['eventPerformance'] is Map) {
      final event = data['eventPerformance'];
      eventTotalJoined.value = _toInt(event['totalJoined']);
      eventTotalViews.value = _toInt(event['totalViews']);
      eventConversionRate.value = event['conversionRate']?.toString() ?? '0.00%';
      eventSummary.value = event['summary']?.toString() ?? '';
    }

    if (data['newMessages'] is Map) {
      final msg = data['newMessages'];
      unreadMessages.value = _toInt(msg['unread']);
      newMessages.value = _toInt(msg['new']);
      newMessagesSummary.value = msg['summary']?.toString() ?? '';
    }
  }

  int _toInt(dynamic value) => value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
  double _toDouble(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0.0;
}