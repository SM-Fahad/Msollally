import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ProPartnersEditNameController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    final fullName = (Get.arguments is Map)
        ? (Get.arguments['fullName']?.toString() ?? '')
        : '';
    final parts = fullName.trim().split(RegExp(r'\\s+'));
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      firstNameController.text = parts.first;
      if (parts.length > 1) {
        lastNameController.text = parts.sublist(1).join(' ');
      }
    }
  }

  String? validate() {
    if (firstNameController.text.trim().isEmpty) {
      return 'First name cannot be empty';
    }
    return null;
  }

  Future<void> save() async {
    final error = validate();
    if (error != null) {
      EasyLoading.showError(error);
      return;
    }

    isSaving.value = true;
    try {
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final fullName = ('$firstName ${lastName.isNotEmpty ? lastName : ''}')
          .trim()
          .replaceAll(RegExp(r'\\s+'), ' ');
      Get.back(result: {'fullName': fullName});
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }
}
