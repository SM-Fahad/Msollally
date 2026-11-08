import 'package:get/get.dart';

import '../model/campaign_stats_model.dart';
import '../service/campaign_stats_service.dart';

class CampaignStatsController extends GetxController {
  final CampaignStatsService _service;
  final int campaignId;

  CampaignStatsController({
    required this.campaignId,
    CampaignStatsService? service,
  }) : _service = service ?? CampaignStatsService();

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final stats = Rxn<CampaignStatsModel>();

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      stats.value = await _service.fetchStats(campaignId);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
