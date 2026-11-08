import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/feature/student/profile/service/profile_service.dart';
import 'package:logger_barta/logger_barta.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class StudentSettingsEditProfileController extends GetxController {
  final ProfileService _profileService = Get.put(ProfileService());
  final ImagePicker _picker = ImagePicker();

  // ── Text Controllers ─────────────────────────────────────────────────────
  // Personal
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final bioController = TextEditingController();
  final cellPhoneNumberController = TextEditingController();
  final designationController = TextEditingController();

  // Academic (Text fields for non-dropdowns)
  final programController = TextEditingController(); // fallback if not using ID
  final facultyController = TextEditingController(); // fallback
  final studentIdController = TextEditingController();
  final enrollmentYearController = TextEditingController();

  // ── Dropdown State ────────────────────────────────────────────────────────
  var universities = <Map<String, dynamic>>[].obs;
  var programs = <Map<String, dynamic>>[].obs;
  var departments = <Map<String, dynamic>>[].obs;

  var selectedUniversityId = Rx<int?>(null);
  var selectedProgramId = Rx<int?>(null);
  var selectedDepartmentId = Rx<int?>(null);

  // ── Observables ───────────────────────────────────────────────────────────
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Profile / cover photo
  final profileImageUrl = ''.obs;
  final coverImageUrl = ''.obs;
  final Rx<File?> profileImageFile = Rx<File?>(null);
  final Rx<File?> coverImageFile = Rx<File?>(null);

  // Gender dropdown
  final selectedGender = ''.obs;
  final genderOptions = ['Male', 'Female', 'Other'];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchUniversities();
    fetchProfileData();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    genderController.dispose();
    dateOfBirthController.dispose();
    bioController.dispose();
    cellPhoneNumberController.dispose();
    designationController.dispose();
    programController.dispose();
    facultyController.dispose();
    studentIdController.dispose();
    enrollmentYearController.dispose();
    super.onClose();
  }

  // ── GET APIs ──────────────────────────────────────────────────────────────
  Future<void> fetchUniversities() async {
    try {
      final url = Uri.parse(Urls.getUniversities);
      final response = await http.get(url, headers: {'accept': '*/*'});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = jsonDecode(response.body);
        universities.assignAll(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      BartaLog.error('fetchUniversities error', error: e);
    }
  }

  Future<void> fetchPrograms(int universityId) async {
    programs.clear();
    selectedProgramId.value = null;
    departments.clear();
    selectedDepartmentId.value = null;
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse(Urls.getProgramsByUniversity(universityId));
      final response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = jsonDecode(response.body);
        programs.assignAll(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      BartaLog.error('fetchPrograms error', error: e);
    }
  }

  Future<void> fetchDepartments(int programId) async {
    departments.clear();
    selectedDepartmentId.value = null;
    try {
      final token = await SharedPreferenceHelper().getAccessToken();
      final url = Uri.parse(Urls.getDepartmentsByProgram(programId));
      final response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = jsonDecode(response.body);
        departments.assignAll(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      BartaLog.error('fetchDepartments error', error: e);
    }
  }

  Future<void> fetchProfileData() async {
    isLoading.value = true;
    try {
      final data = await _profileService.fetchMe();
      if (data == null) return;

      BartaLog.success('fetchMe success', title: 'EditProfile');

      final profile = data['profile'] as Map<String, dynamic>? ?? {};

      fullNameController.text = profile['fullName']?.toString() ?? '';
      emailController.text = profile['email']?.toString() ?? '';
      bioController.text = profile['bio']?.toString() ?? '';
      cellPhoneNumberController.text =
          data['phoneNumber']?.toString() ?? profile['cellPhoneNumber']?.toString() ?? '';
      designationController.text = 
          data['designation']?.toString() ?? profile['designation']?.toString() ?? '';
      dateOfBirthController.text = profile['dateOfBirth']?.toString() ?? '';

      // Academic (text)
      programController.text = profile['program']?.toString() ?? '';
      facultyController.text = profile['faculty']?.toString() ?? '';
      studentIdController.text = profile['studentID']?.toString() ?? '';
      enrollmentYearController.text =
          profile['enrollmentYear']?.toString() ?? '';

      // Academic (dropdown IDs)
      if (profile['universityId'] != null) {
        final uId = int.tryParse(profile['universityId'].toString());
        if (uId != null) {
          selectedUniversityId.value = uId;
          await fetchPrograms(uId);
        }
      }
      if (profile['programId'] != null) {
        final pId = int.tryParse(profile['programId'].toString());
        if (pId != null) {
          selectedProgramId.value = pId;
          await fetchDepartments(pId);
        }
      }
      if (profile['departmentId'] != null) {
        final dId = int.tryParse(profile['departmentId'].toString());
        if (dId != null) {
          selectedDepartmentId.value = dId;
        }
      }

      // Photos
      profileImageUrl.value = profile['profilePicture']?.toString() ?? '';
      coverImageUrl.value = profile['coverPhoto']?.toString() ?? '';

      // Gender
      final g = profile['gender']?.toString() ?? '';
      selectedGender.value =
          genderOptions.contains(g) ? g : (g.isNotEmpty ? g : '');
      genderController.text = selectedGender.value;
    } catch (e) {
      BartaLog.error('fetchProfileData error', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Image Pickers ─────────────────────────────────────────────────────────
  Future<void> pickProfileImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      profileImageFile.value = File(picked.path);

      EasyLoading.show(status: 'Uploading photo…');
      final url = await _profileService.uploadProfileFile(
        file: profileImageFile.value!,
      );
      EasyLoading.dismiss();

      if (url != null && url.isNotEmpty) {
        profileImageUrl.value = url;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to upload photo');
    }
  }

  Future<void> pickCoverImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 85,
      );
      if (picked == null) return;
      coverImageFile.value = File(picked.path);

      EasyLoading.show(status: 'Uploading cover…');
      final url = await _profileService.uploadProfileFile(
        file: coverImageFile.value!,
      );
      EasyLoading.dismiss();

      if (url != null && url.isNotEmpty) {
        coverImageUrl.value = url;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to upload cover photo');
    }
  }

  // ── PATCH /profile/update ─────────────────────────────────────────────────
  Future<void> updateProfile() async {
    isSaving.value = true;
    try {
      final success = await _profileService.updateProfile(
        // Personal
        fullName: _trimOrNull(fullNameController.text),
        email: _trimOrNull(emailController.text),
        gender: _trimOrNull(genderController.text),
        dateOfBirth: _trimOrNull(dateOfBirthController.text),
        bio: _trimOrNull(bioController.text),
        cellPhoneNumber: _trimOrNull(cellPhoneNumberController.text),
        designation: _trimOrNull(designationController.text),
        // Academic
        universityId: selectedUniversityId.value,
        programId: selectedProgramId.value,
        departmentId: selectedDepartmentId.value,
        program: _trimOrNull(programController.text),
        faculty: _trimOrNull(facultyController.text),
        studentID: _trimOrNull(studentIdController.text),
        enrollmentYear: int.tryParse(enrollmentYearController.text.trim()),
        // Photos (uploaded URLs)
        profilePicture:
            profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
        coverPhoto:
            coverImageUrl.value.isNotEmpty ? coverImageUrl.value : null,
      );

      if (success) {
        BartaLog.success('Profile updated', title: 'EditProfile');
        EasyLoading.showSuccess('Profile updated successfully');
        Get.back();
      }
    } catch (e) {
      BartaLog.error('updateProfile error', error: e);
    } finally {
      isSaving.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String? _trimOrNull(String text) {
    final t = text.trim();
    return t.isNotEmpty ? t : null;
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime initial = DateTime.now();
    try {
      if (dateOfBirthController.text.isNotEmpty) {
        initial = DateTime.parse(dateOfBirthController.text.trim());
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF418AFF),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      dateOfBirthController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }
}
