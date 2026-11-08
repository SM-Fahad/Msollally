import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/recruiter/more/profile/service/recruiter_profile_service.dart';

enum RecruiterEditProfileControllerField {
  name,
  email,
  cell,
  companyName,
  designation,
  industryType,
  bio,
}

class RecruiterEditProfileController extends GetxController {
  final RecruiterProfileService _profileService;
  final SharedPreferenceHelper _prefHelper;

  RecruiterEditProfileController({
    RecruiterProfileService? profileService,
    SharedPreferenceHelper? prefHelper,
  }) : _profileService = profileService ?? RecruiterProfileService(),
       _prefHelper = prefHelper ?? SharedPreferenceHelper();

  late final RecruiterEditProfileControllerField field;
  final RxBool isSaving = false.obs;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final valueController = TextEditingController();

  String get title {
    switch (field) {
      case RecruiterEditProfileControllerField.name:
        return 'Name';
      case RecruiterEditProfileControllerField.email:
        return 'Email';
      case RecruiterEditProfileControllerField.cell:
        return 'Cell';
      case RecruiterEditProfileControllerField.companyName:
        return 'Company Name';
      case RecruiterEditProfileControllerField.designation:
        return 'Designation';
      case RecruiterEditProfileControllerField.industryType:
        return 'Industry Type';
      case RecruiterEditProfileControllerField.bio:
        return 'Bio';
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    final rawField = args['field']?.toString() ?? 'name';
    field = RecruiterEditProfileControllerField.values.firstWhere(
      (e) => e.name == rawField,
      orElse: () => RecruiterEditProfileControllerField.name,
    );
    final initial = args['initial']?.toString() ?? '';
    if (field == RecruiterEditProfileControllerField.name) {
      final parts = initial.trim().split(RegExp(r'\\s+'));
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        firstNameController.text = parts.first;
        if (parts.length > 1) {
          lastNameController.text = parts.sublist(1).join(' ');
        }
      }
    } else {
      valueController.text = initial;
    }
  }

  Future<void> save() async {
    final accessToken = await _prefHelper.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      EasyLoading.showError('Access token not found');
      return;
    }

    final body = <String, dynamic>{};
    late final String returnValue;

    if (field == RecruiterEditProfileControllerField.name) {
      final first = firstNameController.text.trim();
      final last = lastNameController.text.trim();
      if (first.isEmpty) {
        EasyLoading.showError('First name cannot be empty');
        return;
      }
      final fullName = ('$first ${last.isNotEmpty ? last : ''}')
          .trim()
          .replaceAll(RegExp(r'\\s+'), ' ');
      body['fullName'] = fullName;
      returnValue = fullName;
    } else {
      final v = valueController.text.trim();
      if (v.isEmpty) {
        EasyLoading.showError('$title cannot be empty');
        return;
      }
      switch (field) {
        case RecruiterEditProfileControllerField.email:
          body['email'] = v;
          break;
        case RecruiterEditProfileControllerField.cell:
          body['phoneNumber'] = v;
          break;
        case RecruiterEditProfileControllerField.companyName:
          body['companyName'] = v;
          break;
        case RecruiterEditProfileControllerField.designation:
          body['designation'] = v;
          break;
        case RecruiterEditProfileControllerField.industryType:
          body['companyType'] = v;
          break;
        case RecruiterEditProfileControllerField.bio:
          body['bio'] = v;
          break;
        case RecruiterEditProfileControllerField.name:
          break;
      }
      returnValue = v;
    }

    isSaving.value = true;
    try {
      EasyLoading.show(status: 'Updating...');
      await _profileService.updateProfile(accessToken: accessToken, body: body);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Updated');
      await Future.delayed(const Duration(milliseconds: 250));
      Get.back(result: {'field': field.name, 'value': returnValue, ...body});
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('RecruiterEditProfileController -> Error: $errorMessage');

      EasyLoading.dismiss();
      EasyLoading.showError(errorMessage);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    valueController.dispose();
    super.onClose();
  }
}
