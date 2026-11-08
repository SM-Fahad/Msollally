import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/recruiter/more/model/recruiter_profile_options.dart';
import 'package:msollaally/feature/recruiter/more/profile/model/recruiter_me_model.dart';
import 'package:msollaally/feature/recruiter/more/profile/service/recruiter_profile_service.dart';
import 'package:msollaally/feature/recruiter/more/service/recruiter_account_service.dart';
import 'package:msollaally/routes/app_route.dart';

class RecruiterMoreController extends GetxController {
  final RecruiterProfileService _meService;
  final SharedPreferenceHelper _prefHelper;
  final RecruiterAccountService _accountService;

  RecruiterMoreController({
    RecruiterProfileService? meService,
    SharedPreferenceHelper? prefHelper,
    RecruiterAccountService? accountService,
  }) : _meService = meService ?? RecruiterProfileService(),
       _prefHelper = prefHelper ?? SharedPreferenceHelper(),
       _accountService = accountService ?? RecruiterAccountService();

  final Rxn<RecruiterMeResponse> me = Rxn<RecruiterMeResponse>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  String get displayName {
    final current = me.value;
    final fullName = current?.profile?.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    final username = current?.username?.trim();
    if (username != null && username.isNotEmpty) return username;
    return 'Partner';
  }

  String get profileImageUrl => me.value?.profile?.profilePicture ?? '';
  String get coverImageUrl => me.value?.profile?.coverPhoto ?? '';

  String? get email => me.value?.profile?.email;
  String? get phoneNumber => me.value?.phoneNumber;
  String? get memberShip => me.value?.profile?.memberShip;
  bool get isVerified => me.value?.profile?.isVerified ?? false;
  String? get referCode => me.value?.referCode;

  var options = <RecruiterProfileOptions>[
    RecruiterProfileOptions(title: "Settings"),
    RecruiterProfileOptions(title: "Help & Support"),
    RecruiterProfileOptions(title: "Send Feedback"),
    RecruiterProfileOptions(title: "About LinkYetu"),
    RecruiterProfileOptions(title: "Terms & Conditions"),
    RecruiterProfileOptions(title: "Privacy Policy"),
    RecruiterProfileOptions(title: "Logout"),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMe();
  }

  Future<void> fetchMe() async {
    try {
      errorMessage.value = null;
      isLoading.value = true;

      final accessToken = await _prefHelper.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token not found');
      }

      final response = await _meService.fetchMe(accessToken: accessToken);
      me.value = response;

      if (response.id != null) {
        await _prefHelper.saveUserId(response.id.toString());
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final accessToken = await _prefHelper.getAccessToken();
      final refreshToken = await _prefHelper.getRefreshToken();
      if (accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        await _accountService.logout(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
    } catch (_) {
      // best effort; proceed to clear local session
    }

    await _prefHelper.clearAuthSession();
    UserRoleService.clearSelectedRole();
    Get.offAllNamed(AppRoute.loginScreen);
  }
}
