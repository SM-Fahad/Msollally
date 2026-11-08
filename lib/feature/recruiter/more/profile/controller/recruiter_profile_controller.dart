import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/recruiter/more/profile/model/recruiter_me_model.dart';
import 'package:msollaally/feature/recruiter/more/profile/service/recruiter_profile_service.dart';

class RecruiterProfileController extends GetxController {
  final RecruiterProfileService _meService;
  final SharedPreferenceHelper _prefHelper;
  final RecruiterProfileService _profileService;
  final ImagePicker _picker;

  RecruiterProfileController({
    RecruiterProfileService? meService,
    SharedPreferenceHelper? prefHelper,
    RecruiterProfileService? profileService,
    ImagePicker? picker,
  }) : _meService = meService ?? RecruiterProfileService(),
       _prefHelper = prefHelper ?? SharedPreferenceHelper(),
       _profileService = profileService ?? RecruiterProfileService(),
       _picker = picker ?? ImagePicker();

  final Rxn<RecruiterMeResponse> me = Rxn<RecruiterMeResponse>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  String get displayName {
    final profileName = me.value?.profile?.fullName?.trim();
    if (profileName != null && profileName.isNotEmpty) return profileName;
    final username = me.value?.username?.trim();
    if (username != null && username.isNotEmpty) return username;
    return '';
  }

  String get bio => me.value?.profile?.bio?.trim().isNotEmpty == true
      ? me.value!.profile!.bio!.trim()
      : '';

  String get profileImageUrl =>
      me.value?.profile?.profilePicture ?? me.value?.profilePicture ?? '';
  String get coverPhotoUrl =>
      me.value?.profile?.coverPhoto ?? me.value?.coverPhoto ?? '';

  String get email => me.value?.profile?.email ?? '';
  String get cell => me.value?.phoneNumber ?? '';
  String get companyName =>
      me.value?.profile?.companyName ?? me.value?.profile?.companyType ?? '';
  String get designation => me.value?.profile?.designation ?? '';
  String get industryType => me.value?.profile?.companyType ?? '';

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
    String? faculty,
    String? phoneNumber,
  }) {
    final current = me.value;
    final profile = current?.profile;
    if (current == null) return;
    me.value = RecruiterMeResponse(
      id: current.id,
      profile: profile == null
          ? null
          : RecruiterProfile(
              id: profile.id,
              email: email ?? profile.email,
              fullName: fullName ?? profile.fullName,
              gender: profile.gender,
              dateOfBirth: profile.dateOfBirth,
              universityId: profile.universityId,
              programId: profile.programId,
              departmentId: profile.departmentId,
              faculty: faculty ?? profile.faculty,
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
      profilePicture: profilePicture ?? current.profilePicture,
      coverPhoto: coverPhoto ?? current.coverPhoto,
      posts: current.posts,
      username: current.username,
      phoneNumber: phoneNumber ?? current.phoneNumber,
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
