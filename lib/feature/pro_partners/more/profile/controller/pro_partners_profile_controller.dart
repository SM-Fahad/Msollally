import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/dashboard/model/pro_partner_me_model.dart';
import 'package:msollaally/feature/pro_partners/dashboard/service/pro_partners_me_service.dart';
import 'package:msollaally/feature/pro_partners/more/profile/service/pro_partners_profile_service.dart';

class ProPartnersProfileController extends GetxController {
  final ProPartnersDashboardService _meService;
  final SharedPreferenceHelper _prefHelper;
  final ProPartnersProfileService _profileService;
  final ImagePicker _picker;

  ProPartnersProfileController({
    ProPartnersDashboardService? meService,
    SharedPreferenceHelper? prefHelper,
    ProPartnersProfileService? profileService,
    ImagePicker? picker,
  }) : _meService = meService ?? ProPartnersDashboardService(),
       _prefHelper = prefHelper ?? SharedPreferenceHelper(),
       _profileService = profileService ?? ProPartnersProfileService(),
       _picker = picker ?? ImagePicker();

  final Rxn<ProPartnerMeResponse> me = Rxn<ProPartnerMeResponse>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  String get displayName =>
      me.value?.profile?.fullName?.trim().isNotEmpty == true
      ? me.value!.profile!.fullName!.trim()
      : (me.value?.username?.trim().isNotEmpty == true
            ? me.value!.username!.trim()
            : 'Partner');

  String get bio => me.value?.profile?.bio?.trim().isNotEmpty == true
      ? me.value!.profile!.bio!.trim()
      : "I am HR for the past 03 years and love teaching third graders!";

  String get profileImageUrl => me.value?.profile?.profilePicture ?? '';
  String get coverPhotoUrl => me.value?.profile?.coverPhoto ?? '';

  String get email => me.value?.profile?.email ?? 'demo01@gmail.com';
  String get cell =>
      me.value?.profile?.cellPhoneNumber ??
      me.value?.phoneNumber ??
      '+110 2516542';
  String get companyName => me.value?.profile?.companyName ?? 'Meta';
  String get designation => me.value?.profile?.designation ?? 'Hr';
  String get industryType => me.value?.profile?.companyType ?? 'Technology';

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
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void applyUpdatedProfile({
    String? fullName,
    String? email,
    String? bio,
    String? profilePicture,
    String? coverPhoto,
    String? companyName,
    String? companyType,
    String? designation,
    String? cellPhoneNumber,
    String? phoneNumber,
  }) {
    final current = me.value;
    final profile = current?.profile;
    if (current == null) return;
    me.value = ProPartnerMeResponse(
      id: current.id,
      profile: profile == null
          ? null
          : ProPartnerProfile(
              id: profile.id,
              email: email ?? profile.email,
              fullName: fullName ?? profile.fullName,
              gender: profile.gender,
              dateOfBirth: profile.dateOfBirth,
              universityId: profile.universityId,
              programId: profile.programId,
              departmentId: profile.departmentId,
              faculty: profile.faculty,
              isVerified: profile.isVerified,
              designation: designation ?? profile.designation,
              studentId: profile.studentId,
              enrollmentYear: profile.enrollmentYear,
              bio: bio ?? profile.bio,
              profilePicture: profilePicture ?? profile.profilePicture,
              coverPhoto: coverPhoto ?? profile.coverPhoto,
              isReferalEnabled: profile.isReferalEnabled,
              referalStatusLevel: profile.referalStatusLevel,
              memberShip: profile.memberShip,
              companyName: companyName ?? profile.companyName,
              companyType: companyType ?? profile.companyType,
              employeeCountRange: profile.employeeCountRange,
              cellPhoneNumber: cellPhoneNumber ?? profile.cellPhoneNumber,
              subjectTaught: profile.subjectTaught,
              location: profile.location,
              revenue: profile.revenue,
              profileVisibility: profile.profileVisibility,
              seePlan: profile.seePlan,
              sendRequest: profile.sendRequest,
              seeClass: profile.seeClass,
              canMessage: profile.canMessage,
              createdAt: profile.createdAt,
              updatedAt: profile.updatedAt,
            ),
      posts: current.posts,
      username: current.username,
      phoneNumber: phoneNumber ?? cellPhoneNumber ?? current.phoneNumber,
      role: current.role,
      referCode: current.referCode,
      referalLink: current.referalLink,
      isSuspend: current.isSuspend,
      friends: current.friends,
    );
  }

  Future<void> pickAndUpdateProfilePhoto() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;
    await _uploadAndUpdatePhoto(isCover: false, path: xFile.path);
  }

  Future<void> pickAndUpdateCoverPhoto() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;
    await _uploadAndUpdatePhoto(isCover: true, path: xFile.path);
  }

  Future<void> _uploadAndUpdatePhoto({
    required bool isCover,
    required String path,
  }) async {
    final accessToken = await _prefHelper.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      EasyLoading.showError('Access token not found');
      return;
    }

    try {
      EasyLoading.show(status: 'Uploading...');
      final url = await _profileService.uploadImage(
        accessToken: accessToken,
        file: File(path),
      );
      EasyLoading.show(status: 'Updating...');
      await _profileService.updateProfile(
        accessToken: accessToken,
        body: isCover ? {'coverPhoto': url} : {'profilePicture': url},
      );
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Updated');
      if (isCover) {
        applyUpdatedProfile(coverPhoto: url);
      } else {
        applyUpdatedProfile(profilePicture: url);
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
