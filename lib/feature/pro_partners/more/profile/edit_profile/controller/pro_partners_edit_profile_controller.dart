import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/more/profile/service/pro_partners_profile_service.dart';

enum ProPartnersEditField {
  name,
  email,
  cell,
  companyName,
  designation,
  industryType,
  bio,
}

class ProPartnersEditProfileController extends GetxController {
  final ProPartnersProfileService _profileService;
  final SharedPreferenceHelper _prefHelper;

  ProPartnersEditProfileController({
    ProPartnersProfileService? profileService,
    SharedPreferenceHelper? prefHelper,
  }) : _profileService = profileService ?? ProPartnersProfileService(),
       _prefHelper = prefHelper ?? SharedPreferenceHelper();

  late final ProPartnersEditField field;
  final RxBool isSaving = false.obs;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final valueController = TextEditingController();

  String get title {
    switch (field) {
      case ProPartnersEditField.name:
        return 'Name';
      case ProPartnersEditField.email:
        return 'Email';
      case ProPartnersEditField.cell:
        return 'Cell';
      case ProPartnersEditField.companyName:
        return 'Company Name';
      case ProPartnersEditField.designation:
        return 'Designation';
      case ProPartnersEditField.industryType:
        return 'Industry Type';
      case ProPartnersEditField.bio:
        return 'Bio';
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    final rawField = args['field']?.toString() ?? 'name';
    field = ProPartnersEditField.values.firstWhere(
      (e) => e.name == rawField,
      orElse: () => ProPartnersEditField.name,
    );
    final initial = args['initial']?.toString() ?? '';
    if (field == ProPartnersEditField.name) {
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

    if (field == ProPartnersEditField.name) {
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
        case ProPartnersEditField.email:
          body['email'] = v;
          break;
        case ProPartnersEditField.cell:
          body['cellPhoneNumber'] = v;
          body['phoneNumber'] = v;
          break;
        case ProPartnersEditField.companyName:
          body['companyName'] = v;
          break;
        case ProPartnersEditField.designation:
          body['designation'] = v;
          break;
        case ProPartnersEditField.industryType:
          body['companyType'] = v;
          break;
        case ProPartnersEditField.bio:
          body['bio'] = v;
          break;
        case ProPartnersEditField.name:
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
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
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
