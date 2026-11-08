import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/model/job_model.dart';
import 'package:msollaally/feature/recruiter/more/profile/service/recruiter_profile_service.dart';
import 'package:msollaally/routes/app_route.dart';

class CreateJobController extends GetxController {
  CreateJobController({this.job, this.isEdit = false});

  final JobModel? job;
  final bool isEdit;

  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();
  final ImagePicker _imagePicker = ImagePicker();
  final RecruiterProfileService _uploadService = RecruiterProfileService();

  final titleController = TextEditingController();
  final companyNameController = TextEditingController();
  final departmentController = TextEditingController();
  final reportingLineController = TextEditingController();
  final locationController = TextEditingController();
  final minimumSalaryController = TextEditingController();
  final maximumSalaryController = TextEditingController();
  final descriptionController = TextEditingController();
  final minimumExperienceController = TextEditingController();
  final maximumExperienceController = TextEditingController();
  final otherExperienceLevelController = TextEditingController();

  final responsibilitiesInputController = TextEditingController();
  final requirementsInputController = TextEditingController();
  final benefitsInputController = TextEditingController();
  final professionalSkillsInputController = TextEditingController();
  final otherFacilitiesInputController = TextEditingController();

  final jobType = ''.obs;
  final salaryType = ''.obs;
  final experienceLevel = ''.obs;
  final applicationDeadline = Rxn<DateTime>();

  final responsibilities = <String>[].obs;
  final requirements = <String>[].obs;
  final benefits = <String>[].obs;
  final professionalSkills = <String>[].obs;
  final otherFacilities = <String>[].obs;

  final companyLogoFile = Rxn<File>();
  final companyLogoUrl = RxnString();
  final isUploadingLogo = false.obs;
  final isSubmitting = false.obs;

  final Map<String, String> jobTypeLabelToValue = {
    'Full Time': 'full_time',
    'Part Time': 'part_time',
    'Internship': 'internship',
    'Contract': 'contract',
    'Temporary': 'temporary',
    'Freelance': 'freelance',
  };

  final Map<String, String> salaryTypeLabelToValue = {
    'Monthly': 'monthly',
    'Yearly': 'annual',
    'Weekly': 'weekly',
    'Daily': 'daily',
    'Hourly': 'hourly',
  };

  final Map<String, String> experienceLevelLabelToValue = {
    'Entry': 'entry',
    'Mid': 'mid',
    'Senior': 'senior',
    'Expert': 'expert',
    'Other': 'other',
  };

  List<String> get jobTypeLabels => jobTypeLabelToValue.keys.toList();
  List<String> get salaryTypeLabels => salaryTypeLabelToValue.keys.toList();
  List<String> get experienceLevelLabels =>
      experienceLevelLabelToValue.keys.toList();

  String get screenTitle => isEdit ? 'Update Job' : 'Create A Job';
  String get submitButtonText => isEdit ? 'Update Job' : 'Post Job';
  String get loadingText => isEdit ? 'Updating job...' : 'Creating job...';
  String get successText =>
      isEdit ? 'Job updated successfully' : 'Job created successfully';

  @override
  void onInit() {
    super.onInit();
    if (isEdit && job != null) {
      _prefillFields(job!);
    }
  }

  String labelForValue(Map<String, String> mapping, String value) {
    for (final entry in mapping.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }
    return '';
  }

  Future<void> pickDeadline(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = applicationDeadline.value?.isAfter(now) == true
        ? applicationDeadline.value!
        : now.add(Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      applicationDeadline.value = picked;
    }
  }

  Future<void> pickCompanyLogo() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile == null) {
      return;
    }

    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      EasyLoading.showError('Unauthorized. Please login again.');
      return;
    }

    companyLogoFile.value = File(pickedFile.path);
    isUploadingLogo.value = true;

    try {
      EasyLoading.show(status: 'Uploading...');
      final url = await _uploadService.uploadImage(
        accessToken: token,
        file: File(pickedFile.path),
      );
      companyLogoUrl.value = url;
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Company logo uploaded');
    } catch (e) {
      companyLogoFile.value = null;
      companyLogoUrl.value = isEdit ? job?.companyLogo ?? '' : null;
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isUploadingLogo.value = false;
    }
  }

  void removeCompanyLogo() {
    companyLogoFile.value = null;
    companyLogoUrl.value = '';
  }

  void addListItem(TextEditingController controller, RxList<String> items) {
    final text = controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    final lines = text.split(RegExp(r'\r?\n'));
    for (final rawLine in lines) {
      var line = rawLine.trim();
      if (line.isEmpty) continue;
      // Strip common bullet markers from the start of the line
      line = line.replaceFirst(RegExp(r'^[\u2022\u25E6\u2023\u2219\*\-\–\—\+]\s*'), '').trim();
      // Also strip numbered list prefixes if present (e.g. "1. ", "1) ")
      line = line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').trim();
      if (line.isNotEmpty) {
        items.add(line);
      }
    }
    controller.clear();
  }

  void removeListItem(RxList<String> items, int index) {
    if (index < 0 || index >= items.length) {
      return;
    }
    items.removeAt(index);
  }

  Future<void> submitJob() async {
    if (isSubmitting.value) return;

    final validationMessage = _validate();
    if (validationMessage != null) {
      EasyLoading.showError(validationMessage);
      Get.snackbar(
        'Required Field',
        validationMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      EasyLoading.showError('Unauthorized. Please login again.');
      return;
    }

    try {
      isSubmitting.value = true;
      final payload = _buildPayload();

      EasyLoading.show(status: loadingText);
      final response = isEdit
          ? await _networkCaller.putJsonRequest(
              Urls.updateOrdeleteAJob(job!.id),
              token: 'Bearer $token',
              body: payload,
            )
          : await _networkCaller.postJsonRequest(
              Urls.createJob,
              token: 'Bearer $token',
              body: payload,
            );
      EasyLoading.dismiss();

      if (!response.isSuccess) {
        EasyLoading.showError(response.errorMessage);
        Get.snackbar(
          'Error',
          response.errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return;
      }

      EasyLoading.showSuccess(successText);
      await Future.delayed(const Duration(milliseconds: 500));

      if (isEdit) {
        Get.back(result: true);
        return;
      }

      Get.offAllNamed(AppRoute.proPartnersDashboard);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }

  String? _validate() {
    if (titleController.text.trim().isEmpty) {
      return 'Title is required';
    }
    if (companyNameController.text.trim().isEmpty) {
      return 'Company name is required';
    }
    // Department and Location are optional as per feedback
    if (!jobTypeLabelToValue.containsValue(jobType.value)) {
      return 'Job type is required';
    }

    final minimumSalaryText = minimumSalaryController.text.trim();
    final maximumSalaryText = maximumSalaryController.text.trim();
    if (minimumSalaryText.isNotEmpty && maximumSalaryText.isNotEmpty) {
      final minimumSalary = int.tryParse(minimumSalaryText);
      final maximumSalary = int.tryParse(maximumSalaryText);
      if (minimumSalary != null && maximumSalary != null && maximumSalary < minimumSalary) {
        return 'Maximum salary must be greater than or equal to minimum salary';
      }
    }

    if (descriptionController.text.trim().isEmpty) {
      return 'Description is required';
    }

    if (!experienceLevelLabelToValue.containsValue(experienceLevel.value)) {
      return 'Experience level is required';
    }

    if (experienceLevel.value == 'other' && otherExperienceLevelController.text.trim().isEmpty) {
      return 'Please specify custom experience level';
    }

    final minExp = int.tryParse(minimumExperienceController.text.trim());
    final maxExp = int.tryParse(maximumExperienceController.text.trim());
    if (minExp != null && maxExp != null && maxExp < minExp) {
      return 'Maximum experience must be greater than or equal to minimum experience';
    }

    if (applicationDeadline.value == null) {
      applicationDeadline.value = DateTime.now().add(const Duration(days: 30));
    }

    final deadline = applicationDeadline.value!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(deadline.year, deadline.month, deadline.day);
    if (!selected.isAfter(today) && !isEdit) {
      return 'Application deadline must be a future date';
    }

    return null;
  }

  Map<String, dynamic> _buildPayload() {
    var deadline = applicationDeadline.value;
    if (deadline == null) {
      deadline = DateTime.now().add(const Duration(days: 30));
      applicationDeadline.value = deadline;
    }

    final minSalary = int.tryParse(minimumSalaryController.text.trim());
    final maxSalary = int.tryParse(maximumSalaryController.text.trim());
    final minExp = int.tryParse(minimumExperienceController.text.trim());
    final maxExp = int.tryParse(maximumExperienceController.text.trim());
    final logo = (companyLogoUrl.value ?? '').trim();

    var desc = descriptionController.text.trim();
    final repLine = reportingLineController.text.trim();
    if (repLine.isNotEmpty && !desc.contains('Reporting Line:')) {
      desc = '$desc\n\nReporting Line: $repLine';
    }

    final reqList = requirements.toList();
    final customExp = otherExperienceLevelController.text.trim();

    String expLevelToSend = experienceLevel.value;
    if (expLevelToSend == 'other') {
      if (maxExp != null && maxExp > 0) {
        if (maxExp <= 1) {
          expLevelToSend = 'entry';
        } else if (maxExp <= 3) {
          expLevelToSend = 'mid';
        } else if (maxExp <= 6) {
          expLevelToSend = 'senior';
        } else {
          expLevelToSend = 'expert';
        }
      } else {
        expLevelToSend = 'mid';
      }
    }

    if (customExp.isNotEmpty) {
      if (!reqList.any((r) => r.toLowerCase().contains(customExp.toLowerCase()))) {
        reqList.insert(0, 'Experience Level: $customExp');
      }
      if (!desc.contains('Experience Level:')) {
        desc = '$desc\n\nExperience Level: $customExp';
      }
    }

    return {
      'title': titleController.text.trim(),
      'companyName': companyNameController.text.trim(),
      'department': departmentController.text.trim(),
      'location': locationController.text.trim(),
      'jobType': jobType.value,
      if (salaryType.value.isNotEmpty) 'salaryType': salaryType.value,
      if (minSalary != null) 'minimumSalary': minSalary,
      if (maxSalary != null) 'maximumSalary': maxSalary,
      'description': desc,
      'responsibilities': responsibilities.toList(),
      'requirements': reqList,
      'benefits': benefits.toList(),
      'professionalSkills': professionalSkills.toList(),
      'otherFacilities': otherFacilities.toList(),
      'experienceLevel': expLevelToSend,
      if (customExp.isNotEmpty) 'otherExperienceLevel': customExp,
      'minimumExperience': minExp ?? 0,
      'maximumExperience': maxExp ?? 0,
      'applicationDeadline': DateTime.utc(
        deadline.year,
        deadline.month,
        deadline.day,
        23,
        59,
        59,
      ).toIso8601String(),
      if (logo.isNotEmpty) 'companyLogo': logo,
    };
  }

  void _prefillFields(JobModel source) {
    titleController.text = source.title;
    companyNameController.text = source.companyName;
    departmentController.text = source.department;
    locationController.text = source.locationType;
    minimumSalaryController.text = source.minimumSalary;
    maximumSalaryController.text = source.maximumSalary;

    var desc = source.description;
    final repMatch = RegExp(r'Reporting Line:\s*(.+)$', multiLine: true).firstMatch(desc);
    if (repMatch != null) {
      reportingLineController.text = repMatch.group(1)?.trim() ?? '';
      desc = desc.replaceAll(RegExp(r'\n*Reporting Line:\s*.+$', multiLine: true), '').trim();
    }
    descriptionController.text = desc;

    minimumExperienceController.text = source.minimumExperience > 0
        ? source.minimumExperience.toString()
        : '';
    maximumExperienceController.text = source.maximumExperience > 0
        ? source.maximumExperience.toString()
        : '';

    jobType.value = source.jobType;
    salaryType.value = source.salaryType;
    experienceLevel.value = source.experienceLevel;
    otherExperienceLevelController.text = source.otherExperienceLevel;
    responsibilities.assignAll(source.responsibilities);
    requirements.assignAll(source.requirements);
    benefits.assignAll(source.benefits);
    professionalSkills.assignAll(source.professionalSkills);
    otherFacilities.assignAll(source.otherFacilities);
    companyLogoUrl.value = source.companyLogo.trim().isEmpty
        ? null
        : source.companyLogo.trim();

    final deadline = DateTime.tryParse(source.applicationDeadline);
    if (deadline != null) {
      applicationDeadline.value = deadline.toLocal();
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    companyNameController.dispose();
    departmentController.dispose();
    reportingLineController.dispose();
    locationController.dispose();
    minimumSalaryController.dispose();
    maximumSalaryController.dispose();
    descriptionController.dispose();
    minimumExperienceController.dispose();
    maximumExperienceController.dispose();
    otherExperienceLevelController.dispose();
    responsibilitiesInputController.dispose();
    requirementsInputController.dispose();
    benefitsInputController.dispose();
    professionalSkillsInputController.dispose();
    otherFacilitiesInputController.dispose();
    super.onClose();
  }
}
