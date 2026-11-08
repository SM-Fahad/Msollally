import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

import '../model/jobs.model.dart';
import '../model/job_application_model.dart';
import '../service/jobs_service.dart';

class JobController extends GetxController {
  // UI Tabs State (0: Discover, 1: Applied)
  final RxInt selectedTab = 0.obs;

  // Observable variables
  final RxList<JobModel> allJobs = <JobModel>[].obs;
  final RxList<JobModel> filteredJobs = <JobModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isJobDetailsLoading = false.obs;
  final Rxn<JobModel> selectedJob = Rxn<JobModel>();
  final RxList<String> selectedFilters = <String>[].obs;
  final RxList<String> availableJobTypes = <String>[].obs;
  final RxList<String> availableLocations = <String>[].obs;

  // Applications
  final RxList<JobApplicationModel> myApplications =
      <JobApplicationModel>[].obs;
  final RxBool isApplicationsLoading = false.obs;

  final JobsService _jobsService = JobsService();
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  // CVs
  final RxList<Map<String, dynamic>> myCvs = <Map<String, dynamic>>[].obs;
  final RxInt selectedCvIndex = RxInt(-1);

  // Controllers for Apply Bottom Sheet (Persistent state for Stateless widget)
  final coverLetterController = TextEditingController();
  final resumeUrlController = TextEditingController();
  final phoneController = TextEditingController();
  final experienceController = TextEditingController();
  final educationController = TextEditingController();
  final skillsController = TextEditingController();
  final RxList<String> appliedSkills = <String>[].obs;

  // New fields according to JOB_APPLICATION_API_DOC.md
  final RxList<String> certificates = <String>[].obs;
  final RxString identityProofUrl = ''.obs;
  final RxString photoUrl = ''.obs;
  final RxList<String> otherDocuments = <String>[].obs;
  final recruiterEmailController = TextEditingController();
  final recruiterUrlController = TextEditingController();
  final linkedInController = TextEditingController();
  final portfolioController = TextEditingController();
  final RxBool isUploadingFile = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadJobs();
    setupFilters();
    loadMyCvs();
    fetchMyApplications();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    if (index == 1) {
      fetchMyApplications();
    }
  }

  @override
  void onClose() {
    coverLetterController.dispose();
    resumeUrlController.dispose();
    phoneController.dispose();
    experienceController.dispose();
    educationController.dispose();
    skillsController.dispose();
    recruiterEmailController.dispose();
    recruiterUrlController.dispose();
    linkedInController.dispose();
    portfolioController.dispose();
    super.onClose();
  }

  void clearApplyFields() {
    coverLetterController.clear();
    resumeUrlController.clear();
    phoneController.clear();
    experienceController.clear();
    educationController.clear();
    skillsController.clear();
    appliedSkills.clear();
    certificates.clear();
    identityProofUrl.value = '';
    photoUrl.value = '';
    otherDocuments.clear();
    recruiterEmailController.clear();
    recruiterUrlController.clear();
    linkedInController.clear();
    portfolioController.clear();
    selectedCvIndex.value = myCvs.isNotEmpty ? 0 : -1;
  }

  // Add a skill tag
  void addSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isNotEmpty && !appliedSkills.contains(trimmed)) {
      appliedSkills.add(trimmed);
    }
    skillsController.clear();
  }

  // Remove a skill tag
  void removeSkill(String skill) {
    appliedSkills.remove(skill);
  }

  // Load jobs from API
  Future<void> loadJobs() async {
    isLoading.value = true;
    try {
      final jobs = await _jobsService.fetchJobs();
      allJobs.value = jobs;
      filterJobs();
    } catch (e) {
      EasyLoading.showError('Failed to load jobs');
    } finally {
      isLoading.value = false;
    }
  }

  // Setup filter options
  void setupFilters() {
    availableJobTypes.value = [
      'Full-Time',
      'Part-Time',
      'Internship',
      'Contract',
    ];
    availableLocations.value = [
      'Remote',
      'New York',
      'San Francisco',
      'London',
      'Toronto',
    ];
  }

  // Search functionality
  void searchJobs(String query) {
    searchQuery.value = query;
    filterJobs();
  }

  // Filter jobs based on search and selected filters
  void filterJobs() {
    filteredJobs.value = allJobs.where((job) {
      bool matchesSearch =
          searchQuery.value.isEmpty ||
          job.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          job.company.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          job.professionalSkills.any(
            (skill) =>
                skill.toLowerCase().contains(searchQuery.value.toLowerCase()),
          );

      bool matchesFilters =
          selectedFilters.isEmpty ||
          selectedFilters.contains(job.jobTypeLabel) ||
          selectedFilters.contains(job.location);

      return matchesSearch && matchesFilters;
    }).toList();
  }

  // Toggle filter
  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    filterJobs();
  }

  // Get job by ID
  JobModel? getJobById(int jobId) {
    try {
      return allJobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  // Clear all filters
  void clearFilters() {
    selectedFilters.clear();
    searchQuery.value = '';
    filteredJobs.value = allJobs;
  }

  // Refresh jobs
  Future<void> refreshJobs() async {
    await loadJobs();
  }

  // Load user's CVs
  Future<void> loadMyCvs() async {
    try {
      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await _networkCaller.getRequest(
        Urls.getAllCv,
        token: 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is Map) {
        final data = response.responseData as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>? ?? [];
        final parsed = list
            .whereType<Map<String, dynamic>>()
            .map((e) => e)
            .toList(growable: false);
        myCvs.assignAll(parsed);
        if (myCvs.isNotEmpty) selectedCvIndex.value = 0;
      }
    } catch (e) {
      debugPrint('Error loading CVs: $e');
    }
  }

  // Fetch job details
  Future<void> fetchJobDetails(int jobId) async {
    isJobDetailsLoading.value = true;
    selectedJob.value = null; // Clear previous selection
    try {
      final job = await _jobsService.fetchJobDetails(jobId);
      selectedJob.value = job;
    } catch (e) {
      EasyLoading.showError('Failed to load job details');
    } finally {
      isJobDetailsLoading.value = false;
    }
  }

  // File Picker & Upload Methods for Job Application
  Future<void> pickAndUploadCertificate() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        EasyLoading.show(status: 'Uploading certificate...');
        isUploadingFile.value = true;
        final url = await _jobsService.uploadFile(
          File(result.files.single.path!),
          fileName: result.files.single.name,
        );
        EasyLoading.dismiss();
        if (url != null && url.isNotEmpty) {
          certificates.add(url);
          EasyLoading.showSuccess('Certificate uploaded!');
        } else {
          EasyLoading.showError('Failed to upload certificate.');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error picking certificate: $e');
    } finally {
      isUploadingFile.value = false;
    }
  }

  Future<void> pickAndUploadIdentityProof() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        EasyLoading.show(status: 'Uploading identity document...');
        isUploadingFile.value = true;
        final url = await _jobsService.uploadFile(
          File(result.files.single.path!),
          fileName: result.files.single.name,
        );
        EasyLoading.dismiss();
        if (url != null && url.isNotEmpty) {
          identityProofUrl.value = url;
          EasyLoading.showSuccess('Identity document uploaded!');
        } else {
          EasyLoading.showError('Failed to upload identity document.');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error picking identity doc: $e');
    } finally {
      isUploadingFile.value = false;
    }
  }

  Future<void> pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        EasyLoading.show(status: 'Uploading photo...');
        isUploadingFile.value = true;
        final url = await _jobsService.uploadFile(
          File(image.path),
          fileName: image.name,
        );
        EasyLoading.dismiss();
        if (url != null && url.isNotEmpty) {
          photoUrl.value = url;
          EasyLoading.showSuccess('Photo uploaded!');
        } else {
          EasyLoading.showError('Failed to upload photo.');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error picking photo: $e');
    } finally {
      isUploadingFile.value = false;
    }
  }

  Future<void> pickAndUploadOtherDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        EasyLoading.show(status: 'Uploading document...');
        isUploadingFile.value = true;
        final url = await _jobsService.uploadFile(
          File(result.files.single.path!),
          fileName: result.files.single.name,
        );
        EasyLoading.dismiss();
        if (url != null && url.isNotEmpty) {
          otherDocuments.add(url);
          EasyLoading.showSuccess('Document uploaded!');
        } else {
          EasyLoading.showError('Failed to upload document.');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error picking other document: $e');
    } finally {
      isUploadingFile.value = false;
    }
  }

  Future<void> pickAndUploadResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.single.path != null) {
        EasyLoading.show(status: 'Uploading resume...');
        isUploadingFile.value = true;
        final url = await _jobsService.uploadFile(
          File(result.files.single.path!),
          fileName: result.files.single.name,
        );
        EasyLoading.dismiss();
        if (url != null && url.isNotEmpty) {
          resumeUrlController.text = url;
          EasyLoading.showSuccess('Resume uploaded!');
        } else {
          EasyLoading.showError('Failed to upload resume.');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error picking resume: $e');
    } finally {
      isUploadingFile.value = false;
    }
  }

  // Apply for job
  Future<void> applyForJob(int jobId, Map<String, dynamic> applyData) async {
    EasyLoading.show(status: 'Applying...');

    // Fallback if resumeUrl is missing or empty but cvId is provided
    if ((applyData['resumeUrl'] == null ||
            applyData['resumeUrl'].toString().trim().isEmpty) &&
        applyData['cvId'] != null) {
      applyData['resumeUrl'] = Urls.downloadCv(applyData['cvId'].toString());
    }

    try {
      final result = await _jobsService.applyJob(jobId: jobId, body: applyData);
      EasyLoading.dismiss();
      if (result['success'] == true) {
        EasyLoading.showSuccess(result['message'] ?? 'Successfully applied!');
        clearApplyFields();
        fetchMyApplications();
      } else {
        EasyLoading.showError(result['message'] ?? 'Failed to apply.');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Something went wrong.');
    }
  }

  // Fetch student's submitted applications
  Future<void> fetchMyApplications() async {
    isApplicationsLoading.value = true;
    try {
      final apps = await _jobsService.fetchMyApplications();
      myApplications.assignAll(apps);
    } catch (e) {
      debugPrint('Error loading my applications: $e');
    } finally {
      isApplicationsLoading.value = false;
    }
  }

  // Withdraw an application
  Future<void> withdrawJobApplication(int applicationId) async {
    EasyLoading.show(status: 'Withdrawing...');
    try {
      final success = await _jobsService.withdrawApplication(applicationId);
      EasyLoading.dismiss();
      if (success) {
        EasyLoading.showSuccess('Application withdrawn successfully');
        myApplications.removeWhere((app) => app.id == applicationId);
      } else {
        EasyLoading.showError('Failed to withdraw application');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error withdrawing application');
    }
  }
}
