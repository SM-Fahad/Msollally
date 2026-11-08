import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/service/campus_service.dart';
import 'package:msollaally/feature/student/profile/service/profile_service.dart';
import 'package:get/get.dart';

class CreateUnionController extends GetxController {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final websiteController = TextEditingController();
  final emailController = TextEditingController();
  final contactNumberController = TextEditingController();
  final tagsController = TextEditingController();

  final category = 'entertainment'.obs;
  final isPublic = true.obs;
  final allowJoinRequests = true.obs;
  final isLoading = false.obs;

  final logoPath = ''.obs;
  final coverPath = ''.obs;

  final _campusService = CampusService();
  final _profileService = ProfileService();
  final _picker = ImagePicker();

  Future<void> pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) logoPath.value = image.path;
  }

  Future<void> pickCover() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) coverPath.value = image.path;
  }

  Future<void> createUnion() async {
    if (nameController.text.isEmpty) {
      EasyLoading.showError('Name is required');
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Creating Union...');

      String? logoUrl;
      if (logoPath.value.isNotEmpty) {
        logoUrl = await _profileService.uploadProfileFile(
          file: File(logoPath.value),
        );
      }

      String? coverUrl;
      if (coverPath.value.isNotEmpty) {
        coverUrl = await _profileService.uploadProfileFile(
          file: File(coverPath.value),
        );
      }

      final tags = tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final data = {
        'name': nameController.text,
        'description': descriptionController.text,
        'category': category.value,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (coverUrl != null) 'coverImageUrl': coverUrl,
        'website': websiteController.text,
        'email': emailController.text,
        'contactNumber': contactNumberController.text,
        'tags': tags,
        'isPublic': isPublic.value,
        'allowJoinRequests': allowJoinRequests.value,
      };

      await _campusService.createUnion(data);

      EasyLoading.showSuccess('Union created successfully');

      if (Get.isRegistered<StudentCampusController>()) {
        Get.find<StudentCampusController>().fetchUnions();
      }

      Get.back();
    } catch (e) {
      debugPrint('Error creating union: $e');
      EasyLoading.showError('Failed to create union');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    websiteController.dispose();
    emailController.dispose();
    contactNumberController.dispose();
    tagsController.dispose();
    super.onClose();
  }
}

class Member {
  final String name;
  final String imageUrl;

  Member({required this.name, required this.imageUrl});
}
