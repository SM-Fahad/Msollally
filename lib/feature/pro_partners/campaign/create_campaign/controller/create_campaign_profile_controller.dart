import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/dashboard/model/pro_partner_me_model.dart';
import 'package:msollaally/feature/pro_partners/dashboard/service/pro_partners_me_service.dart';

class CreateCampaignProfileController extends GetxController {
  final ProPartnersDashboardService _meService;
  final SharedPreferenceHelper _prefHelper;

  CreateCampaignProfileController({
    ProPartnersDashboardService? meService,
    SharedPreferenceHelper? prefHelper,
  }) : _meService = meService ?? ProPartnersDashboardService(),
       _prefHelper = prefHelper ?? SharedPreferenceHelper();

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<ProPartnerMeResponse> me = Rxn<ProPartnerMeResponse>();

  String get displayName {
    final profileName = me.value?.profile?.fullName?.trim();
    if (profileName != null && profileName.isNotEmpty) return profileName;

    final companyName = me.value?.profile?.companyName?.trim();
    if (companyName != null && companyName.isNotEmpty) return companyName;

    final username = me.value?.username?.trim();
    if (username != null && username.isNotEmpty) return username;

    return 'Partner';
  }

  String get profileImageUrl => me.value?.profile?.profilePicture?.trim() ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      errorMessage.value = null;
      isLoading.value = true;

      final accessToken = await _prefHelper.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token not found');
      }

      me.value = await _meService.fetchMe(accessToken: accessToken);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
