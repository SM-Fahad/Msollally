import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/profile/model/teacher_model.dart';
import 'package:msollaally/feature/teacher/profile/service/teacher_profile_service.dart';

class TeacherProfileController extends GetxController {
  final SharedPreferenceHelper _prefHelper;
  final TeacherProfileService _profileService;
  final ImagePicker _picker;

  TeacherProfileController({
    SharedPreferenceHelper? prefHelper,
    TeacherProfileService? profileService,
    ImagePicker? picker,
  }) : _prefHelper = prefHelper ?? SharedPreferenceHelper(),
       _profileService = profileService ?? TeacherProfileService(),
       _picker = picker ?? ImagePicker();

  final Rxn<TeacherMeResponse> me = Rxn<TeacherMeResponse>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  Rx<File?> profileImage = Rx<File?>(null);
  Rx<File?> coverImage = Rx<File?>(null);

  String get displayName {
    final profileName = me.value?.profile?.fullName?.trim();
    if (profileName != null && profileName.isNotEmpty) {
      return profileName;
    }
    final username = me.value?.username?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }
    return 'Teacher';
  }

  String get email => me.value?.profile?.email ?? '';
  String get phone => me.value?.phoneNumber ?? '';
  String get cellPhone => me.value?.profile?.cellPhoneNumber ?? '';
  String get institution =>
      me.value?.profile?.university?.fullName ??
      me.value?.profile?.university?.name ??
      '';
  String get department {
    final dep = me.value?.profile?.department;
    if (dep != null && dep.trim().isNotEmpty) return dep.trim();
    final fac = me.value?.profile?.faculty;
    if (fac != null && fac.trim().isNotEmpty) return fac.trim();
    return '';
  }
  String get designation => me.value?.profile?.designation ?? '';
  String get subjects => me.value?.profile?.subjectTaught ?? '';
  String get bio => me.value?.profile?.bio ?? '';
  String get profileImageUrl => me.value?.profile?.profilePicture ?? '';
  String get coverPhotoUrl => me.value?.profile?.coverPhoto ?? '';

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

      me.value = await _profileService.fetchMe(accessToken: accessToken);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(bool isProfile) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        return;
      }

      if (isProfile) {
        profileImage.value = File(pickedFile.path);
      } else {
        coverImage.value = File(pickedFile.path);
      }

      await _uploadAndUpdatePhoto(isCover: !isProfile, path: pickedFile.path);
    } catch (e) {
      debugPrint("Error Failed to pick image: $e");
    }
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
      _applyUpdatedPhotos(
        profilePicture: isCover ? null : url,
        coverPhoto: isCover ? url : null,
      );
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _applyUpdatedPhotos({String? profilePicture, String? coverPhoto}) {
    final current = me.value;
    final profile = current?.profile;
    if (current == null || profile == null) {
      return;
    }

    me.value = TeacherMeResponse(
      id: current.id,
      profile: TeacherProfile(
        id: profile.id,
        email: profile.email,
        fullName: profile.fullName,
        gender: profile.gender,
        dateOfBirth: profile.dateOfBirth,
        universityId: profile.universityId,
        programId: profile.programId,
        departmentId: profile.departmentId,
        university: profile.university,
        faculty: profile.faculty,
        isVerified: profile.isVerified,
        designation: profile.designation,
        studentId: profile.studentId,
        enrollmentYear: profile.enrollmentYear,
        bio: profile.bio,
        profilePicture: profilePicture ?? profile.profilePicture,
        coverPhoto: coverPhoto ?? profile.coverPhoto,
        isReferalEnabled: profile.isReferalEnabled,
        referalStatusLevel: profile.referalStatusLevel,
        memberShip: profile.memberShip,
        companyType: profile.companyType,
        employeeCountRange: profile.employeeCountRange,
        location: profile.location,
        revenue: profile.revenue,
        profileVisibility: profile.profileVisibility,
        seePlan: profile.seePlan,
        sendRequest: profile.sendRequest,
        seeClass: profile.seeClass,
        canMessage: profile.canMessage,
        cellPhoneNumber: profile.cellPhoneNumber,
        companyName: profile.companyName,
        subjectTaught: profile.subjectTaught,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
      ),
      posts: current.posts,
      username: current.username,
      phoneNumber: current.phoneNumber,
      role: current.role,
      referCode: current.referCode,
      referalLink: current.referalLink,
      isSuspend: current.isSuspend,
      friends: current.friends,
    );
  }
}
