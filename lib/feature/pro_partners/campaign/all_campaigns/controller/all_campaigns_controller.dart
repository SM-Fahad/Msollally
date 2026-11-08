import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/campaign/all_campaigns/model/campaign_model.dart';
import 'package:msollaally/feature/pro_partners/campaign/create_campaign/screen/create_campaign_screen.dart';

class ProPartnersAllCampaignsController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();
  final ScrollController scrollController = ScrollController();

  final campaigns = <CampaignModel>[].obs;
  final isInitialLoading = true.obs;
  final isLoadingMore = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  static const int pageLimit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns(isRefresh: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients ||
        isLoadingMore.value ||
        isInitialLoading.value) {
      return;
    }
    final trigger = scrollController.position.maxScrollExtent - 120;
    if (scrollController.position.pixels >= trigger &&
        currentPage.value < totalPages.value) {
      fetchCampaigns(page: currentPage.value + 1);
    }
  }

  Future<void> fetchCampaigns({bool isRefresh = false, int? page}) async {
    if (isRefresh) {
      isLoadingMore.value = false;
    } else {
      if (isLoadingMore.value || isInitialLoading.value) return;
      if (currentPage.value >= totalPages.value && campaigns.isNotEmpty) return;
    }

    if (isRefresh) {
      isInitialLoading.value = true;
      campaigns.clear();
      currentPage.value = 1;
      totalPages.value = 1;
    } else {
      isLoadingMore.value = true;
    }

    final nextPage = page ?? 1;
    final token = await _prefs.getAccessToken();
    final response = await _networkCaller.getRequest(
      Urls.getAllCampaigns(page: nextPage, limit: pageLimit),
      token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
    );

    if (!response.isSuccess) {
      final message = response.errorMessage.trim().toLowerCase();
      final isEmptyCampaignState =
          response.statusCode == 404 &&
          message.contains('not any campaign running now');

      if (isEmptyCampaignState) {
        campaigns.clear();
      } else {
        EasyLoading.showError(response.errorMessage);
      }
      isInitialLoading.value = false;
      isLoadingMore.value = false;
      return;
    }

    final body = response.responseData;
    final List<dynamic> rawData =
        body is Map<String, dynamic> && body['data'] is List
        ? body['data'] as List<dynamic>
        : <dynamic>[];
    final Map<String, dynamic> meta =
        body is Map<String, dynamic> && body['meta'] is Map
        ? Map<String, dynamic>.from(body['meta'] as Map)
        : <String, dynamic>{};

    final mappedCampaigns = rawData.map(_mapCampaign).toList();
    if (isRefresh || nextPage <= 1) {
      campaigns.assignAll(mappedCampaigns);
    } else {
      final existingIds = campaigns.map((e) => e.id).toSet();
      campaigns.addAll(
        mappedCampaigns.where((campaign) => !existingIds.contains(campaign.id)),
      );
    }
    currentPage.value = (meta['currentPage'] as int?) ?? nextPage;
    totalPages.value = (meta['totalPages'] as int?) ?? currentPage.value;
    isInitialLoading.value = false;
    isLoadingMore.value = false;
  }

  CampaignModel _mapCampaign(dynamic e) {
    final map = e is Map ? e : <String, dynamic>{};
    final impressions = _toDouble(map['impressions']);
    final clicks = _toInt(map['clickCount']);
    final ctr = _toDouble(map['ctr']) > 0
        ? _toDouble(map['ctr'])
        : impressions > 0
        ? (clicks / impressions) * 100
        : 0.0;

    final author = map['author'] ?? map['creator'] ?? map['user'] ?? map['company'];
    String companyName = (map['companyName'] ?? map['company'] ?? '').toString();
    String companyLogo = (map['companyLogo'] ?? map['logo'] ?? '').toString();
    if (author is Map) {
      if (companyName.isEmpty) {
        companyName = (author['proPartnerName'] ?? author['companyName'] ?? author['fullName'] ?? author['name'] ?? '').toString();
      }
      final profile = author['profile'] is Map ? author['profile'] : null;
      if (companyLogo.isEmpty) {
        companyLogo = (profile?['profilePicture'] ?? profile?['companyLogo'] ?? author['profilePicture'] ?? author['avatar'] ?? author['logo'] ?? '').toString();
      }
    }

    return CampaignModel(
      id: _toInt(map['id']),
      title: (map['campaignTitle'] ?? 'Untitled Campaign').toString(),
      status: (map['status'] ?? 'inactive').toString(),
      clicks: clicks,
      ctr: ctr,
      spent: _toDouble(map['spentBudget']),
      imageOrVideoLink: _toText(map['imageOrVideoLink']),
      description: _toText(map['description']),
      caption: _toText(map['caption']),
      destinationUrl: _toText(map['destinationUrl']),
      callToAction: _toText(map['callToAction']),
      totalBudget: _toDouble(map['totalBudget']),
      startDate: _toDate(map['startDate']),
      endDate: _toDate(map['endDate']),
      university: _toText(map['university']),
      gender: _toText(map['gender']),
      major: _toText(map['major']),
      yearOfStudy: _toText(map['yearOfStudy']),
      isSponsored: _toBool(map['isSponsored']),
      createdAt: _toDate(map['createdAt']),
      updatedAt: _toDate(map['updatedAt']),
      companyName: companyName,
      companyLogo: companyLogo,
    );
  }

  Future<void> goToUpdateCampaign(CampaignModel campaign) async {
    final result = await Get.to<bool>(
      () => CreateCampaignScreen(campaignId: campaign.id),
    );
    if (result == true) {
      await fetchCampaigns(isRefresh: true);
    }
  }

  Future<bool> deleteCampaign(int campaignId) async {
    try {
      EasyLoading.show(status: 'Deleting campaign...');
      final token = await _prefs.getAccessToken();
      var response = await _networkCaller.deleteRequest(
        Urls.deleteCampaign('$campaignId'),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess && response.statusCode == 404) {
        response = await _networkCaller.deleteRequest(
          '${Urls.baseUrl}/campaigns/$campaignId',
          token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
        );
      }

      if (!response.isSuccess) {
        EasyLoading.showError(response.errorMessage);
        return false;
      }

      campaigns.removeWhere((item) => item.id == campaignId);
      EasyLoading.showSuccess('Campaign deleted successfully');
      return true;
    } catch (e) {
      EasyLoading.showError(e.toString());
      return false;
    }
  }

  Future<bool> confirmAndDeleteCampaign(
    BuildContext context,
    CampaignModel campaign,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Delete Campaign',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "${campaign.title}"? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      return await deleteCampaign(campaign.id);
    }
    return false;
  }


  Future<void> updateCampaignStatus(CampaignModel campaign) async {
    final nextStatus = campaign.status.toLowerCase() == 'active'
        ? 'paused'
        : 'active';

    try {
      EasyLoading.show(status: 'Updating status...');
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.patchJsonRequest(
        Urls.updateCampaignStatus('${campaign.id}', nextStatus),
        body: const <String, dynamic>{},
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        EasyLoading.showError(response.errorMessage);
        return;
      }

      final index = campaigns.indexWhere((item) => item.id == campaign.id);
      if (index != -1) {
        final current = campaigns[index];
        campaigns[index] = CampaignModel(
          id: current.id,
          title: current.title,
          status: nextStatus,
          clicks: current.clicks,
          ctr: current.ctr,
          spent: current.spent,
          imageOrVideoLink: current.imageOrVideoLink,
          description: current.description,
          caption: current.caption,
          destinationUrl: current.destinationUrl,
          callToAction: current.callToAction,
          totalBudget: current.totalBudget,
          startDate: current.startDate,
          endDate: current.endDate,
          university: current.university,
          gender: current.gender,
          major: current.major,
          yearOfStudy: current.yearOfStudy,
          isSponsored: current.isSponsored,
          createdAt: current.createdAt,
          updatedAt: current.updatedAt,
        );
      }

      EasyLoading.showSuccess(
        nextStatus == 'active'
            ? 'Campaign activated successfully'
            : 'Campaign paused successfully',
      );
      await fetchCampaigns(isRefresh: true);
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  int _toInt(dynamic value) => int.tryParse('$value') ?? 0;

  double _toDouble(dynamic value) => double.tryParse('$value') ?? 0;

  String _toText(dynamic value) => value?.toString().trim() ?? '';

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    final normalized = value?.toString().toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }

  DateTime? _toDate(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '');
}
