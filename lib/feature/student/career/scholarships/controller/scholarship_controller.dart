import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../model/scholarship_model.dart';
import '../model/scholarship_application_model.dart';
import '../service/scholarship_service.dart';

class ScholarshipController extends GetxController {
  final ScholarshipService _scholarshipService = ScholarshipService();

  // Data Observables
  var scholarships = <ScholarshipModel>[].obs;
  var myApplications = <ScholarshipApplicationModel>[].obs;
  var selectedApplication = Rxn<ScholarshipApplicationModel>();

  // Loading States
  var isLoading = false.obs;
  var isApplicationsLoading = false.obs;
  var isDetailLoading = false.obs;
  var uploadingField = ''.obs;

  // UI State
  var searchQuery = "".obs;
  var selectedTab = 0.obs;

  // 10 Optional Scholarship Fields (Integration Guide)
  // 1st: Motivation Letter
  final motivationController = TextEditingController();

  // 2nd: Certificates (List of URLs)
  var certificates = <String>[].obs;
  var certificateNames = <String>[].obs;

  // 3rd: Resume / CV
  var resumeUrl = ''.obs;
  var resumeFileName = ''.obs;

  // 4th: Academic Transcript
  var transcriptUrl = ''.obs;
  var transcriptFileName = ''.obs;

  // 5th: Recommendation Letters
  var recommendationLetterUrl = ''.obs;
  var recommendationLetterFileName = ''.obs;

  // 6th: Recruiter Email & URL
  final recruiterEmailController = TextEditingController();
  final recruiterUrlController = TextEditingController();

  // 7th: Insert Picture
  var photoUrl = ''.obs;

  // 8th: Proof of Identity
  var identityProofUrl = ''.obs;
  var identityProofFileName = ''.obs;

  // 9th: Application Form
  var applicationFormUrl = ''.obs;
  var applicationFormFileName = ''.obs;

  // 10th: Other Documents (List of URLs)
  var documents = <String>[].obs;
  var documentNames = <String>[].obs;

  // Additional Applicant Profile Fields
  final gpaController = TextEditingController();
  final applicantEmailController = TextEditingController();
  final applicantAddressController = TextEditingController();
  final studyFieldController = TextEditingController();
  final institutionController = TextEditingController();
  final yearOfStudyController = TextEditingController();
  final countryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchScholarships();
    fetchMyApplications();
  }

  @override
  void onClose() {
    motivationController.dispose();
    recruiterEmailController.dispose();
    recruiterUrlController.dispose();
    gpaController.dispose();
    applicantEmailController.dispose();
    applicantAddressController.dispose();
    studyFieldController.dispose();
    institutionController.dispose();
    yearOfStudyController.dispose();
    countryController.dispose();
    super.onClose();
  }

  void clearForm() {
    motivationController.clear();
    certificates.clear();
    certificateNames.clear();
    resumeUrl.value = '';
    resumeFileName.value = '';
    transcriptUrl.value = '';
    transcriptFileName.value = '';
    recommendationLetterUrl.value = '';
    recommendationLetterFileName.value = '';
    recruiterEmailController.clear();
    recruiterUrlController.clear();
    photoUrl.value = '';
    identityProofUrl.value = '';
    identityProofFileName.value = '';
    applicationFormUrl.value = '';
    applicationFormFileName.value = '';
    documents.clear();
    documentNames.clear();

    gpaController.clear();
    applicantEmailController.clear();
    applicantAddressController.clear();
    studyFieldController.clear();
    institutionController.clear();
    yearOfStudyController.clear();
    countryController.clear();
    uploadingField.value = '';
  }

  void populateForm(ScholarshipApplicationModel app) {
    clearForm();
    motivationController.text = app.motivationLetter;
    if (app.certificates.isNotEmpty) {
      certificates.assignAll(app.certificates);
      certificateNames.assignAll(
        app.certificates.map((u) => u.split('/').last).toList(),
      );
    }
    if (app.resumeUrl.isNotEmpty) {
      resumeUrl.value = app.resumeUrl;
      resumeFileName.value = app.resumeUrl.split('/').last;
    }
    if (app.transcriptUrl.isNotEmpty) {
      transcriptUrl.value = app.transcriptUrl;
      transcriptFileName.value = app.transcriptUrl.split('/').last;
    }
    if (app.recommendationLetterUrl.isNotEmpty) {
      recommendationLetterUrl.value = app.recommendationLetterUrl;
      recommendationLetterFileName.value =
          app.recommendationLetterUrl.split('/').last;
    }
    recruiterEmailController.text = app.recruiterEmail;
    recruiterUrlController.text = app.recruiterUrl;
    photoUrl.value = app.photoUrl;
    if (app.identityProofUrl.isNotEmpty) {
      identityProofUrl.value = app.identityProofUrl;
      identityProofFileName.value = app.identityProofUrl.split('/').last;
    }
    if (app.applicationFormUrl.isNotEmpty) {
      applicationFormUrl.value = app.applicationFormUrl;
      applicationFormFileName.value = app.applicationFormUrl.split('/').last;
    }
    if (app.documents.isNotEmpty) {
      documents.assignAll(app.documents);
      documentNames.assignAll(
        app.documents.map((u) => u.split('/').last).toList(),
      );
    }

    gpaController.text = app.gpa;
    applicantEmailController.text = app.applicantEmail;
    applicantAddressController.text = app.applicantAddress;
    studyFieldController.text = app.fieldOfStudy;
    institutionController.text = app.institution;
    yearOfStudyController.text = app.yearOfStudy;
    countryController.text = app.countryOfResidence;
  }

  Future<void> pickAndUploadFile({
    required String fieldKey,
    List<String> allowedExtensions = const [
      'pdf',
    ],
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      uploadingField.value = fieldKey;
      EasyLoading.show(status: 'Uploading $fileName...');

      final url = await _scholarshipService.uploadFile(file);
      EasyLoading.dismiss();
      uploadingField.value = '';

      if (url != null && url.isNotEmpty) {
        switch (fieldKey) {
          case 'resume':
            resumeUrl.value = url;
            resumeFileName.value = fileName;
            break;
          case 'transcript':
            transcriptUrl.value = url;
            transcriptFileName.value = fileName;
            break;
          case 'recommendation':
            recommendationLetterUrl.value = url;
            recommendationLetterFileName.value = fileName;
            break;
          case 'identity':
            identityProofUrl.value = url;
            identityProofFileName.value = fileName;
            break;
          case 'applicationForm':
            applicationFormUrl.value = url;
            applicationFormFileName.value = fileName;
            break;
          case 'certificate':
            certificates.add(url);
            certificateNames.add(fileName);
            break;
          case 'document':
            documents.add(url);
            documentNames.add(fileName);
            break;
        }
        EasyLoading.showSuccess('Uploaded successfully');
      } else {
        EasyLoading.showError('Upload failed. Please try again.');
      }
    } catch (e) {
      uploadingField.value = '';
      EasyLoading.dismiss();
      EasyLoading.showError('Error selecting file: $e');
    }
  }

  Future<void> pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      uploadingField.value = 'photo';
      EasyLoading.show(status: 'Uploading photo...');

      final url = await _scholarshipService.uploadFile(file);
      EasyLoading.dismiss();
      uploadingField.value = '';

      if (url != null && url.isNotEmpty) {
        photoUrl.value = url;
        EasyLoading.showSuccess('Photo uploaded');
      } else {
        EasyLoading.showError('Photo upload failed');
      }
    } catch (e) {
      uploadingField.value = '';
      EasyLoading.dismiss();
      EasyLoading.showError('Error picking photo');
    }
  }

  void removeCertificate(int index) {
    if (index >= 0 && index < certificates.length) {
      certificates.removeAt(index);
      if (index < certificateNames.length) {
        certificateNames.removeAt(index);
      }
    }
  }

  void removeDocument(int index) {
    if (index >= 0 && index < documents.length) {
      documents.removeAt(index);
      if (index < documentNames.length) {
        documentNames.removeAt(index);
      }
    }
  }

  void clearFile(String fieldKey) {
    switch (fieldKey) {
      case 'resume':
        resumeUrl.value = '';
        resumeFileName.value = '';
        break;
      case 'transcript':
        transcriptUrl.value = '';
        transcriptFileName.value = '';
        break;
      case 'recommendation':
        recommendationLetterUrl.value = '';
        recommendationLetterFileName.value = '';
        break;
      case 'identity':
        identityProofUrl.value = '';
        identityProofFileName.value = '';
        break;
      case 'applicationForm':
        applicationFormUrl.value = '';
        applicationFormFileName.value = '';
        break;
      case 'photo':
        photoUrl.value = '';
        break;
    }
  }

  Future<void> fetchScholarships() async {
    isLoading.value = true;
    try {
      final fetchedScholarships = await _scholarshipService.fetchScholarships();
      scholarships.assignAll(fetchedScholarships);
    } catch (e) {
      EasyLoading.showError('Failed to load scholarships');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyApplications() async {
    isApplicationsLoading.value = true;
    try {
      final fetchedApplications = await _scholarshipService
          .fetchMyApplications();
      myApplications.assignAll(fetchedApplications);
    } catch (e) {
      // Background fetch error
    } finally {
      isApplicationsLoading.value = false;
    }
  }

  Future<void> fetchApplicationDetails(int id) async {
    isDetailLoading.value = true;
    selectedApplication.value = null;
    try {
      final detail = await _scholarshipService.fetchApplicationById(id);
      selectedApplication.value = detail;
    } catch (e) {
      EasyLoading.showError('Failed to load application details');
    } finally {
      isDetailLoading.value = false;
    }
  }

  List<ScholarshipModel> get filteredScholarships {
    if (searchQuery.isEmpty) return scholarships;
    return scholarships
        .where(
          (s) =>
              s.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              s.foundationName.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    if (index == 1) {
      fetchMyApplications();
    } else {
      fetchScholarships();
    }
  }

  Map<String, dynamic> _buildApplicationPayload() {
    final Map<String, dynamic> data = {};

    if (motivationController.text.trim().isNotEmpty) {
      data["motivationLetter"] = motivationController.text.trim();
    }
    if (certificates.isNotEmpty) {
      data["certificates"] = certificates.toList();
    }
    if (resumeUrl.value.isNotEmpty) {
      data["resumeUrl"] = resumeUrl.value;
    }
    if (transcriptUrl.value.isNotEmpty) {
      data["transcriptUrl"] = transcriptUrl.value;
    }
    if (recommendationLetterUrl.value.isNotEmpty) {
      data["recommendationLetterUrl"] = recommendationLetterUrl.value;
    }
    if (recruiterEmailController.text.trim().isNotEmpty) {
      data["recruiterEmail"] = recruiterEmailController.text.trim();
    }
    if (recruiterUrlController.text.trim().isNotEmpty) {
      data["recruiterUrl"] = recruiterUrlController.text.trim();
    }
    if (photoUrl.value.isNotEmpty) {
      data["photoUrl"] = photoUrl.value;
    }
    if (identityProofUrl.value.isNotEmpty) {
      data["identityProofUrl"] = identityProofUrl.value;
    }
    if (applicationFormUrl.value.isNotEmpty) {
      data["applicationFormUrl"] = applicationFormUrl.value;
    }
    if (documents.isNotEmpty) {
      data["documents"] = documents.toList();
    }
    if (gpaController.text.trim().isNotEmpty) {
      final parsedGpa = double.tryParse(gpaController.text.trim());
      if (parsedGpa != null) data["gpa"] = parsedGpa;
    }
    if (applicantEmailController.text.trim().isNotEmpty) {
      data["applicantEmail"] = applicantEmailController.text.trim();
    }
    if (applicantAddressController.text.trim().isNotEmpty) {
      data["applicantAddress"] = applicantAddressController.text.trim();
    }
    if (studyFieldController.text.trim().isNotEmpty) {
      data["fieldOfStudy"] = studyFieldController.text.trim();
    }
    if (institutionController.text.trim().isNotEmpty) {
      data["institution"] = institutionController.text.trim();
    }
    if (yearOfStudyController.text.trim().isNotEmpty) {
      data["yearOfStudy"] = yearOfStudyController.text.trim();
    }
    if (countryController.text.trim().isNotEmpty) {
      data["countryOfResidence"] = countryController.text.trim();
    }
    // Set status to Submitted on apply
    data["status"] = "Submitted";
    data["applicationStatus"] = "Submitted";

    return data;
  }

  Future<bool> applyForScholarship(int id) async {
    EasyLoading.show(status: 'Submitting Application...');
    try {
      final data = _buildApplicationPayload();
      final result = await _scholarshipService.applyScholarship(
        scholarshipId: id,
        body: data,
      );
      EasyLoading.dismiss();
      if (result['success']) {
        EasyLoading.showSuccess(
          result['message'] ?? 'Application Submitted successfully!',
        );
        fetchMyApplications();
        return true;
      } else {
        EasyLoading.showError(result['message'] ?? 'Failed to apply.');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Something went wrong. Please try again.');
      return false;
    }
  }

  Future<bool> updateApplication(int applicationId) async {
    EasyLoading.show(status: 'Updating Application...');
    try {
      final data = _buildApplicationPayload();
      final result = await _scholarshipService.updateScholarshipApplication(
        applicationId: applicationId,
        body: data,
      );
      EasyLoading.dismiss();
      if (result['success']) {
        EasyLoading.showSuccess(result['message'] ?? 'Updated successfully!');
        fetchMyApplications();
        if (selectedApplication.value?.applicationId == applicationId) {
          fetchApplicationDetails(applicationId);
        }
        return true;
      } else {
        EasyLoading.showError(result['message'] ?? 'Failed to update.');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Something went wrong. Please try again.');
      return false;
    }
  }
}
