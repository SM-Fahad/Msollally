import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:msollaally/feature/recruiter/jobs/all_jobs/controller/all_jobs_controller.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/controller/job_details_controller.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/model/job_details_model.dart';
import 'package:msollaally/feature/recruiter/home/controller/recruiter_home_controller.dart';

import '../model/add_job_model.dart';
import '../model/update_job_model.dart';
import '../service/add_job_service.dart';

class AddJobController extends GetxController {
  AddJobController({this.editJob});

  final JobDetailsModel? editJob;

  final title = ''.obs;
  final organization = ''.obs;
  final department = ''.obs;
  final location = ''.obs;
  final contractType = ''.obs;
  final otherJobType = ''.obs;  // filled only when contractType == 'Other'
  final minSalary = ''.obs;
  final maxSalary = ''.obs;
  final salaryType = ''.obs;
  final currency = ''.obs;
  final minExperience = ''.obs;
  final maxExperience = ''.obs;
  final qualifications = ''.obs;
  final openDate = Rx<DateTime?>(null);
  final closeDate = Rx<DateTime?>(null);
  final skills = <String>[].obs;
  final responsibilities = ''.obs;
  final benefits = ''.obs;
  final otherFacilities = ''.obs;
  final images = <File?>[null].obs;
  final quill.QuillController quillController = quill.QuillController.basic();
  final isSubmitting = false.obs;

  final titleController = TextEditingController();
  final organizationController = TextEditingController();
  final departmentController = TextEditingController();
  final locationController = TextEditingController();
  final minSalaryController = TextEditingController();
  final maxSalaryController = TextEditingController();
  final otherJobTypeController = TextEditingController();
  final minExperienceController = TextEditingController();
  final maxExperienceController = TextEditingController();
  final qualificationsController = TextEditingController();
  final responsibilitiesController = TextEditingController();
  final benefitsController = TextEditingController();
  final otherFacilitiesController = TextEditingController();
  final skillsController = TextEditingController();

  bool get isEditMode => editJob != null;
  String get existingCompanyLogo => editJob?.companyLogo.trim() ?? '';

  final ImagePicker _picker = ImagePicker();
  final AddJobService _service = AddJobService();

  static const String _defaultDepartment = 'Engineering';
  static const String _defaultLocation = 'San Francisco, USA';
  static const String _defaultCompanyName = 'TechCorp Inc.';
  static const String _defaultCompanyLogo = 'https://example.com/logo.png';
  static const List<String> _defaultResponsibilities = [
    'Develop and maintain web applications',
    'Collaborate with senior engineers',
  ];
  static const List<String> _defaultRequirements = [
    'Currently pursuing Computer Science or related',
    'Experience with JavaScript and React',
  ];
  static const List<String> _defaultBenefits = [
    'Health insurance',
    'Flexible hours',
  ];
  static const List<String> _defaultProfessionalSkills = [
    'Multitasking',
    'Project Management',
  ];
  static const List<String> _defaultOtherFacilities = [
    'Certificate of Completion',
    'Remote option',
  ];

  @override
  void onInit() {
    super.onInit();
    if (editJob != null) {
      _prefillForEdit(editJob!);
    }
  }

  void _prefillForEdit(JobDetailsModel job) {
    _setText(titleController, title, job.title);
    _setText(organizationController, organization, job.companyName);
    _setText(departmentController, department, job.department);
    _setText(locationController, location, job.location);
    // Only prefill salary if the stored value is meaningful (non-zero)
    if (job.minimumSalary != 0) {
      _setText(minSalaryController, minSalary, job.minimumSalary.toString());
    }
    if (job.maximumSalary != 0) {
      _setText(maxSalaryController, maxSalary, job.maximumSalary.toString());
    }
    _setText(
      minExperienceController,
      minExperience,
      job.minimumExperience.toString(),
    );
    _setText(
      maxExperienceController,
      maxExperience,
      job.maximumExperience.toString(),
    );
    _setText(
      qualificationsController,
      qualifications,
      job.requirements.join(', '),
    );
    _setText(
      responsibilitiesController,
      responsibilities,
      job.responsibilities.join(', '),
    );
    _setText(benefitsController, benefits, job.benefits.join(', '));
    _setText(
      otherFacilitiesController,
      otherFacilities,
      job.otherFacilities.join(', '),
    );
    _setText(skillsController, null, job.professionalSkills.join(', '));
    skills.assignAll(job.professionalSkills);
    contractType.value = _displayJobType(job.jobType);
    // Restore the custom contract type when editing an "other" job
    if (job.jobType == 'other' && job.otherJobType != null) {
      _setText(otherJobTypeController, otherJobType, job.otherJobType!);
    }
    salaryType.value = _displaySalaryType(job.salaryType);
    closeDate.value = job.applicationDeadline;

    if (job.description.trim().isNotEmpty) {
      quillController.document.insert(0, job.description.trim());
    }
  }

  void _setText(
    TextEditingController textController,
    RxString? observable,
    String value,
  ) {
    textController.text = value;
    if (observable != null) observable.value = value;
  }

  void addImageSlot() {
    images.add(null);
  }

  void removeImageAt(int index) {
    if (index >= 0 && index < images.length) images.removeAt(index);
  }

  Future pickImageAt(int index) async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (img != null) {
      final file = File(img.path);
      if (index >= 0 && index < images.length) {
        images[index] = file;
        images.refresh();
      }
    }
  }

  void submit() async {
    if (isSubmitting.value) return;

    final job = _buildJobModel();
    if (job.title.trim().isEmpty) {
      EasyLoading.showError('Please enter a job title');
      return;
    }
    if (job.companyName.trim().isEmpty) {
      EasyLoading.showError('Please enter a company name');
      return;
    }

    // Upload images first if any are selected
    List<String> uploadedUrls = [];
    if (images.isNotEmpty && images.any((img) => img != null)) {
      EasyLoading.show(status: 'Uploading images...');
      try {
        for (final image in images) {
          if (image != null) {
            final url = await _service.uploadImage(image);
            uploadedUrls.add(url);
          }
        }
        if (kDebugMode) {
          print(
            'All images uploaded successfully: ${uploadedUrls.length} images',
          );
        }
      } catch (e) {
        EasyLoading.showError('Failed to upload images: ${e.toString()}');
        return;
      }
    }

    _submitJob(job, imageUrls: uploadedUrls);
  }

  Future<void> _submitJob(
    AddJobModel job, {
    List<String> imageUrls = const [],
  }) async {
    isSubmitting.value = true;
    EasyLoading.show(
      status: isEditMode ? 'Updating job...' : 'Creating job...',
    );

    try {
      // Use first uploaded image as company logo if available
      final jobToCreate = imageUrls.isNotEmpty
          ? AddJobModel(
              id: job.id,
              title: job.title,
              department: job.department,
              location: job.location,
              jobType: job.jobType,
              otherJobType: job.otherJobType,
              salaryType: job.salaryType,
              minimumSalary: job.minimumSalary,
              maximumSalary: job.maximumSalary,
              description: job.description,
              responsibilities: job.responsibilities,
              requirements: job.requirements,
              benefits: job.benefits,
              professionalSkills: job.professionalSkills,
              otherFacilities: job.otherFacilities,
              experienceLevel: job.experienceLevel,
              minimumExperience: job.minimumExperience,
              maximumExperience: job.maximumExperience,
              applicationDeadline: job.applicationDeadline,
              companyName: job.companyName,
              companyLogo: imageUrls[0],
            )
          : job;

      if (isEditMode) {
        final jobId = editJob!.id;
        if (jobId == null) {
          EasyLoading.showError('Job ID not found');
          return;
        }

        if (kDebugMode) {
          print('Updating job with logo: ${jobToCreate.companyLogo}');
        }
        final updatedJob = await _service.updateJob(
          jobId,
          UpdateJobModel.fromAddJob(jobToCreate),
        );
        if (Get.isRegistered<RecruiterHomeController>()) {
          await Get.find<RecruiterHomeController>().refreshLatestJob();
        }
        if (Get.isRegistered<AllJobsController>()) {
          await Get.find<AllJobsController>().refreshJobs();
        }
        EasyLoading.showSuccess('Job updated successfully');

        // Refresh related controllers
        if (Get.isRegistered<AllJobsController>()) {
          Get.find<AllJobsController>().refreshJobs();
        }
        if (Get.isRegistered<JobDetailsController>()) {
          Get.find<JobDetailsController>().refreshJobDetails();
        }

        Get.back(result: updatedJob);
      } else {
        if (kDebugMode) {
          print('Creating job with logo: ${jobToCreate.companyLogo}');
        }
        final createdJob = await _service.createJob(jobToCreate);
        if (Get.isRegistered<RecruiterHomeController>()) {
          await Get.find<RecruiterHomeController>().refreshLatestJob();
        }
        if (Get.isRegistered<AllJobsController>()) {
          await Get.find<AllJobsController>().refreshJobs();
        }
        EasyLoading.showSuccess('Job created successfully');
        Get.back(result: createdJob);
      }
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isSubmitting.value = false;
      EasyLoading.dismiss();
    }
  }

  AddJobModel _buildJobModel() {
    final minimumExperienceValue = _parseInt(minExperience.value, 1);
    final maximumExperienceValue = _parseInt(maxExperience.value, 3);

    // Salary: only send if the user actually entered something meaningful
    final rawMin = minSalary.value.trim();
    final rawMax = maxSalary.value.trim();
    final parsedMin = num.tryParse(rawMin);
    final parsedMax = num.tryParse(rawMax);

    // A pure-numeric "0" is treated as empty (not entered)
    final resolvedMin =
        rawMin.isEmpty || (parsedMin != null && parsedMin == 0) ? null : rawMin;
    final resolvedMax =
        rawMax.isEmpty || (parsedMax != null && parsedMax == 0) ? null : rawMax;

    final description = _readDescription();

    return AddJobModel(
      title: title.value.trim(),
      department: department.value.trim().isEmpty
          ? _defaultDepartment
          : department.value.trim(),
      location: location.value.trim().isEmpty
          ? _defaultLocation
          : location.value.trim(),
      jobType: _normalizeJobType(contractType.value),
      otherJobType: contractType.value == 'Other'
          ? otherJobType.value.trim().isEmpty
              ? null
              : otherJobType.value.trim()
          : null,
      salaryType: _normalizeSalaryType(salaryType.value),
      minimumSalary: resolvedMin,
      maximumSalary: resolvedMax,
      description: description,
      responsibilities: _splitList(
        responsibilities.value,
        fallback: _defaultResponsibilities,
      ),
      requirements: _splitList(
        qualifications.value,
        fallback: _defaultRequirements,
      ),
      benefits: _splitList(benefits.value, fallback: _defaultBenefits),
      professionalSkills: skills.isNotEmpty
          ? skills.toList()
          : _defaultProfessionalSkills,
      otherFacilities: _splitList(
        otherFacilities.value,
        fallback: _defaultOtherFacilities,
      ),
      experienceLevel: _resolveExperienceLevel(
        minimumExperienceValue,
        maximumExperienceValue,
      ),
      minimumExperience: minimumExperienceValue,
      maximumExperience: maximumExperienceValue,
      applicationDeadline:
          closeDate.value ?? DateTime(DateTime.now().year, 12, 31, 23, 59, 59),
      companyName: organization.value.trim().isEmpty
          ? _defaultCompanyName
          : organization.value.trim(),
      companyLogo: isEditMode && editJob!.companyLogo.trim().isNotEmpty
          ? editJob!.companyLogo
          : _defaultCompanyLogo,
    );
  }

  List<String> _splitList(String value, {required List<String> fallback}) {
    final items = value
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return items.isEmpty ? fallback : items;
  }

  String _readDescription() {
    final text = quillController.document.toPlainText().trim();
    return text.isNotEmpty ? text : '';
  }

  int _parseInt(String value, int fallback) {
    final parsed = num.tryParse(value.trim());
    return parsed?.round() ?? fallback;
  }

  String _normalizeJobType(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('part')) return 'part_time';
    if (normalized.contains('contract')) return 'contract';
    if (normalized.contains('intern')) return 'internship';
    if (normalized.contains('temporary')) return 'temporary';
    if (normalized.contains('freelancer')) return 'freelancer';
    if (normalized == 'other') return 'other';
    return 'full_time';
  }

  /// Returns null when empty so the field is omitted from the JSON payload.
  String? _normalizeSalaryType(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized.contains('annual')) return 'annual';
    if (normalized.contains('weekly')) return 'weekly';
    if (normalized.contains('daily')) return 'daily';
    if (normalized.contains('hour')) return 'hourly';
    return 'monthly';
  }

  String _displayJobType(String value) {
    switch (value) {
      case 'part_time':
        return 'Part Time';
      case 'contract':
        return 'Contract';
      case 'internship':
        return 'Internship';
      case 'temporary':
        return 'Temporary';
      case 'freelancer':
        return 'Freelancer';
      case 'other':
        return 'Other';
      default:
        return 'Full Time';
    }
  }

  String _displaySalaryType(String value) {
    switch (value) {
      case 'annual':
        return 'Annual';
      case 'weekly':
        return 'Weekly';
      case 'daily':
        return 'Daily';
      case 'hourly':
        return 'Hourly';
      default:
        return 'Monthly';
    }
  }

  String _resolveExperienceLevel(int minimumExperience, int maximumExperience) {
    if (maximumExperience <= 1) return 'entry';
    if (maximumExperience <= 3) return 'mid';
    return 'senior';
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }

  @override
  void onClose() {
    quillController.dispose();
    titleController.dispose();
    organizationController.dispose();
    departmentController.dispose();
    locationController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    otherJobTypeController.dispose();
    minExperienceController.dispose();
    maxExperienceController.dispose();
    qualificationsController.dispose();
    responsibilitiesController.dispose();
    benefitsController.dispose();
    otherFacilitiesController.dispose();
    skillsController.dispose();
    super.onClose();
  }
}
