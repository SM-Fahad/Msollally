import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/career/find_jobs/controller/jobs.controller.dart';
import 'package:msollaally/feature/student/career/my_career/controller/my_career_controller.dart';

import '../model/cv_model.dart';
import '../service/cv_service.dart';

class CvController extends GetxController {
  final CvService _cvService = CvService();

  final Map<String, TextEditingController> personalControllers = {
    'firstName': TextEditingController(),
    'middleName': TextEditingController(),
    'lastName': TextEditingController(),
    'nationality': TextEditingController(),
    'contactAddress': TextEditingController(),
    'email': TextEditingController(),
    'personalSummery': TextEditingController(),
    'languageProficiency': TextEditingController(),
    'hobbies': TextEditingController(),
  };

  final phoneController = TextEditingController();
  final otherMaritalStatusController = TextEditingController();
  final phoneValue = ''.obs;
  final selectedSex = 'male'.obs;
  final selectedMaritalStatus = 'single'.obs;
  final isLoading = false.obs;
  final isFetchingCvs = false.obs;

  // CV List state
  final myCvs = <Map<String, dynamic>>[].obs;
  final editingCvId = Rxn<String>();

  final selectedDates = <String, DateTime>{}.obs;
  final educations = <CvEducationForm>[CvEducationForm()].obs;
  final experiences = <CvExperienceForm>[CvExperienceForm()].obs;
  final referrers = <CvReferrerForm>[CvReferrerForm()].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCvs();
  }

  void setDate(String label, DateTime date) {
    selectedDates[label] = date;
  }

  String getFormattedDate(String label) {
    final date = selectedDates[label];
    if (date == null) return '';
    return _formatDateOnly(date);
  }

  String getIsoDate(String label) {
    final date = selectedDates[label];
    if (date == null) return '';
    return date.toUtc().toIso8601String();
  }

  void addEducation() => educations.add(CvEducationForm());

  void removeEducation(int index) {
    if (educations.length == 1) return;
    educations.removeAt(index).dispose();
  }

  void addExperience() => experiences.add(CvExperienceForm());

  void removeExperience(int index) {
    if (experiences.length == 1) return;
    experiences.removeAt(index).dispose();
  }

  void addReferrer() => referrers.add(CvReferrerForm());

  void removeReferrer(int index) {
    if (referrers.length == 1) return;
    referrers.removeAt(index).dispose();
  }

  void resetForm() {
    for (final controller in personalControllers.values) {
      controller.clear();
    }
    phoneController.clear();
    otherMaritalStatusController.clear();
    phoneValue.value = '';
    selectedSex.value = 'male';
    selectedMaritalStatus.value = 'single';
    selectedDates.clear();

    for (final edu in educations) {
      edu.dispose();
    }
    educations.assignAll([CvEducationForm()]);

    for (final exp in experiences) {
      exp.dispose();
    }
    experiences.assignAll([CvExperienceForm()]);

    for (final ref in referrers) {
      ref.dispose();
    }
    referrers.assignAll([CvReferrerForm()]);

    editingCvId.value = null;
  }

  Future<void> fetchAllCvs({int page = 1, int limit = 20}) async {
    isFetchingCvs.value = true;
    try {
      final list = await _cvService.fetchAllCvs(page: page, limit: limit);
      final parsed = list.whereType<Map<String, dynamic>>().toList();
      myCvs.assignAll(parsed);

      if (Get.isRegistered<JobController>()) {
        final jobController = Get.find<JobController>();
        jobController.myCvs.assignAll(parsed);
        if (parsed.isNotEmpty && jobController.selectedCvIndex.value < 0) {
          jobController.selectedCvIndex.value = 0;
        }
      }

      if (Get.isRegistered<CareerController>()) {
        Get.find<CareerController>().updateDynamicData();
      }
    } catch (e) {
      debugPrint('Error fetching all CVs in controller: $e');
    } finally {
      isFetchingCvs.value = false;
    }
  }

  Future<Map<String, dynamic>?> getCvById(String id) async {
    try {
      return await _cvService.getCvById(id);
    } catch (e) {
      debugPrint('Error fetching CV by id $id: $e');
      return null;
    }
  }

  Future<bool> populateForEdit(String id) async {
    EasyLoading.show(status: 'Loading CV details...');
    try {
      final data = await _cvService.getCvById(id);
      if (data == null) {
        EasyLoading.showError('Could not load CV details');
        return false;
      }

      resetForm();
      editingCvId.value = id;

      personalControllers['firstName']?.text = data['firstName']?.toString() ?? '';
      personalControllers['middleName']?.text = data['middleName']?.toString() ?? '';
      personalControllers['lastName']?.text = data['lastName']?.toString() ?? '';
      personalControllers['nationality']?.text = data['nationality']?.toString() ?? '';
      personalControllers['contactAddress']?.text = data['contactAddress']?.toString() ?? '';
      personalControllers['email']?.text = data['email']?.toString() ?? '';
      personalControllers['personalSummery']?.text = data['personalSummery']?.toString() ?? '';

      final langs = data['languageProficiency'];
      if (langs is List) {
        personalControllers['languageProficiency']?.text = langs.join(', ');
      }

      final hobbies = data['hobbies'] ?? data['hobbiesAndInterest'];
      if (hobbies is List) {
        personalControllers['hobbies']?.text = hobbies.join(', ');
      }

      final mobile = data['mobileNo']?.toString() ?? '';
      phoneController.text = mobile;
      phoneValue.value = mobile;

      final sexStr = data['sex']?.toString().toLowerCase();
      if (sexStr == 'female' || sexStr == 'male') {
        selectedSex.value = sexStr!;
      }

      final statusStr = data['maritalStatus']?.toString().toLowerCase();
      if (statusStr != null && ['single', 'married', 'divorced', 'widowed'].contains(statusStr)) {
        selectedMaritalStatus.value = statusStr;
      }

      if (data['otherMaritalStatus'] != null) {
        otherMaritalStatusController.text = data['otherMaritalStatus'].toString();
      }

      final rawDob = data['dob']?.toString();
      if (rawDob != null && rawDob.isNotEmpty) {
        try {
          final dt = DateTime.parse(rawDob);
          setDate('dob', dt);
        } catch (_) {}
      }

      final eduList = data['educations'];
      if (eduList is List && eduList.isNotEmpty) {
        for (final edu in educations) {
          edu.dispose();
        }
        educations.clear();
        for (var i = 0; i < eduList.length; i++) {
          final edu = eduList[i];
          if (edu is Map) {
            final form = CvEducationForm();
            form.id = edu['id'] is int ? edu['id'] : int.tryParse(edu['id']?.toString() ?? '');
            form.institution.text = edu['institution']?.toString() ?? '';
            form.degree.text = edu['degree']?.toString() ?? '';
            form.startDate.text = edu['startDate']?.toString() ?? '';
            form.endDate.text = edu['endDate']?.toString() ?? '';
            form.gpa.text = edu['gpa']?.toString() ?? '';
            form.description.text = edu['description']?.toString() ?? '';
            educations.add(form);
          }
        }
        if (educations.isEmpty) educations.add(CvEducationForm());
      }

      final expList = data['experiences'];
      if (expList is List && expList.isNotEmpty) {
        for (final exp in experiences) {
          exp.dispose();
        }
        experiences.clear();
        for (var i = 0; i < expList.length; i++) {
          final exp = expList[i];
          if (exp is Map) {
            final form = CvExperienceForm();
            form.id = exp['id'] is int ? exp['id'] : int.tryParse(exp['id']?.toString() ?? '');
            form.companyName.text = exp['companyName']?.toString() ?? '';
            form.position.text = exp['position']?.toString() ?? '';
            form.startDate.text = exp['startDate']?.toString() ?? '';
            form.endDate.text = exp['endDate']?.toString() ?? '';
            form.description.text = exp['description']?.toString() ?? '';
            experiences.add(form);
          }
        }
        if (experiences.isEmpty) experiences.add(CvExperienceForm());
      }

      final refList = data['referrers'];
      if (refList is List && refList.isNotEmpty) {
        for (final ref in referrers) {
          ref.dispose();
        }
        referrers.clear();
        for (var i = 0; i < refList.length; i++) {
          final ref = refList[i];
          if (ref is Map) {
            final form = CvReferrerForm();
            form.id = ref['id'] is int ? ref['id'] : int.tryParse(ref['id']?.toString() ?? '');
            form.name.text = ref['name']?.toString() ?? '';
            form.role.text = ref['role']?.toString() ?? '';
            form.organization.text = ref['organization']?.toString() ?? '';
            form.address1.text = ref['address1']?.toString() ?? '';
            form.address2.text = ref['address2']?.toString() ?? '';
            form.phone.text = ref['phone']?.toString() ?? '';
            referrers.add(form);
          }
        }
        if (referrers.isEmpty) referrers.add(CvReferrerForm());
      }

      EasyLoading.dismiss();
      return true;
    } catch (e) {
      debugPrint('Error populating CV for edit: $e');
      EasyLoading.showError('Failed to load CV.');
      return false;
    }
  }

  Future<void> createCv() async {
    final cv = _buildCvModel();
    if (cv.firstName == null || cv.lastName == null) {
      EasyLoading.showError('First name and last name are required.');
      return;
    }

    isLoading.value = true;
    EasyLoading.show(status: 'Creating CV...');
    try {
      final success = await _cvService.createCv(cv);
      if (success) {
        EasyLoading.showSuccess('CV created successfully!');
        await fetchAllCvs();
        Get.back();
      } else {
        EasyLoading.showError('Failed to create CV.');
      }
    } catch (e, stackTrace) {
      debugPrint('Error creating CV in controller: $e\n$stackTrace');
      EasyLoading.showError('An error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCv() async {
    final id = editingCvId.value;
    if (id == null) {
      EasyLoading.showError('No CV selected for edit.');
      return;
    }

    final firstName = _value('firstName');
    final lastName = _value('lastName');
    if (firstName == null || lastName == null) {
      EasyLoading.showError('First name and last name are required.');
      return;
    }

    isLoading.value = true;
    EasyLoading.show(status: 'Updating CV...');
    try {
      final payload = <String, dynamic>{
        'firstName': firstName,
        if (_value('middleName') != null) 'middleName': _value('middleName'),
        'lastName': lastName,
        'sex': selectedSex.value,
        if (getIsoDate('dob').isNotEmpty) 'dob': getIsoDate('dob'),
        if (_value('nationality') != null) 'nationality': _value('nationality'),
        'maritalStatus': selectedMaritalStatus.value,
        if (otherMaritalStatusController.text.trim().isNotEmpty)
          'otherMaritalStatus': otherMaritalStatusController.text.trim(),
        'languageProficiency': _splitList(_value('languageProficiency')),
        if (_value('contactAddress') != null)
          'contactAddress': _value('contactAddress'),
        if (phoneValue.value.trim().isNotEmpty || phoneController.text.trim().isNotEmpty)
          'mobileNo': phoneValue.value.trim().isNotEmpty
              ? phoneValue.value.trim()
              : phoneController.text.trim(),
        if (_value('email') != null) 'email': _value('email'),
        if (_value('personalSummery') != null)
          'personalSummery': _value('personalSummery'),
        'educations': educations
            .map((e) => {
                  if (e.id != null) 'id': e.id,
                  if (_val(e.institution) != null) 'institution': _val(e.institution),
                  if (_val(e.degree) != null) 'degree': _val(e.degree),
                  if (_val(e.startDate) != null) 'startDate': _val(e.startDate),
                  if (_val(e.endDate) != null) 'endDate': _val(e.endDate),
                  if (_val(e.gpa) != null) 'gpa': _val(e.gpa),
                  if (_val(e.description) != null) 'description': _val(e.description),
                })
            .where((e) => e['institution'] != null || e['degree'] != null)
            .toList(),
        'experiences': experiences
            .map((e) => {
                  if (e.id != null) 'id': e.id,
                  if (_val(e.companyName) != null) 'companyName': _val(e.companyName),
                  if (_val(e.position) != null) 'position': _val(e.position),
                  if (_val(e.startDate) != null) 'startDate': _val(e.startDate),
                  if (_val(e.endDate) != null) 'endDate': _val(e.endDate),
                  if (_val(e.description) != null) 'description': _val(e.description),
                })
            .where((e) => e['companyName'] != null || e['position'] != null)
            .toList(),
        'hobbies': _splitList(_value('hobbies')),
        'referrers': referrers
            .map((e) => {
                  if (e.id != null) 'id': e.id,
                  if (_val(e.name) != null) 'name': _val(e.name),
                  if (_val(e.role) != null) 'role': _val(e.role),
                  if (_val(e.organization) != null) 'organization': _val(e.organization),
                  if (_val(e.address1) != null) 'address1': _val(e.address1),
                  if (_val(e.address2) != null) 'address2': _val(e.address2),
                  if (_val(e.phone) != null) 'phone': _val(e.phone),
                })
            .where((e) => e['name'] != null || e['role'] != null)
            .toList(),
      };

      final success = await _cvService.updateCv(id, payload);
      if (success) {
        EasyLoading.showSuccess('CV updated successfully!');
        await fetchAllCvs();
        Get.back();
      } else {
        EasyLoading.showError('Failed to update CV.');
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating CV in controller: $e\n$stackTrace');
      EasyLoading.showError('An error occurred.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCv(dynamic cvId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete CV'),
        content: const Text('Are you sure you want to delete this CV? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    EasyLoading.show(status: 'Deleting CV...');
    try {
      final targetId = int.tryParse(cvId.toString()) ?? cvId.toString();
      final success = await _cvService.deleteCvs([targetId]);
      if (success) {
        EasyLoading.showSuccess('CV deleted successfully!');
        await fetchAllCvs();
      } else {
        EasyLoading.showError('Failed to delete CV.');
      }
    } catch (e) {
      debugPrint('Error deleting CV: $e');
      EasyLoading.showError('Failed to delete CV.');
    }
  }

  Future<void> downloadCvById(String id) async {
    EasyLoading.show(status: 'Downloading CV...');
    try {
      await _cvService.downloadCv(id);
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError('Failed to download CV.');
    }
  }

  Future<void> downloadLatestCv() async {
    isLoading.value = true;
    EasyLoading.show(status: 'Fetching CV...');
    try {
      final cvs = myCvs.isNotEmpty ? myCvs : await _cvService.fetchAllCvs();
      if (cvs.isNotEmpty) {
        final latestCvId = cvs.first['id'].toString();
        await _cvService.downloadCv(latestCvId);
        EasyLoading.dismiss();
      } else {
        EasyLoading.showInfo('No CV found. Please create one first.');
      }
    } catch (e) {
      EasyLoading.showError('Failed to download CV.');
    } finally {
      isLoading.value = false;
    }
  }

  CvModel _buildCvModel() {
    return CvModel(
      firstName: _value('firstName'),
      middleName: _value('middleName'),
      lastName: _value('lastName'),
      sex: selectedSex.value,
      dob: getIsoDate('dob'),
      nationality: _value('nationality'),
      maritalStatus: selectedMaritalStatus.value,
      otherMaritalStatus: otherMaritalStatusController.text.trim().isNotEmpty
          ? otherMaritalStatusController.text.trim()
          : null,
      languageProficiency: _splitList(_value('languageProficiency')),
      contactAddress: _value('contactAddress'),
      mobileNo: phoneValue.value.trim().isNotEmpty
          ? phoneValue.value.trim()
          : phoneController.text.trim(),
      email: _value('email'),
      personalSummery: _value('personalSummery'),
      educations: educations
          .map((education) => education.toModel())
          .where((education) => education.hasData)
          .toList(),
      experiences: experiences
          .map((experience) => experience.toModel())
          .where((experience) => experience.hasData)
          .toList(),
      hobbies: _splitList(_value('hobbies')),
      referrers: referrers
          .map((referrer) => referrer.toModel())
          .where((referrer) => referrer.hasData)
          .toList(),
    );
  }

  String? _value(String key) {
    final value = personalControllers[key]?.text.trim();
    return value == null || value.isEmpty ? null : value;
  }

  List<String> _splitList(String? value) {
    if (value == null || value.trim().isEmpty) return [];
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _formatDateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    for (final controller in personalControllers.values) {
      controller.dispose();
    }
    phoneController.dispose();
    otherMaritalStatusController.dispose();
    for (final education in educations) {
      education.dispose();
    }
    for (final experience in experiences) {
      experience.dispose();
    }
    for (final referrer in referrers) {
      referrer.dispose();
    }
    super.onClose();
  }
}

class CvEducationForm {
  int? id;
  final institution = TextEditingController();
  final degree = TextEditingController();
  final startDate = TextEditingController();
  final endDate = TextEditingController();
  final gpa = TextEditingController();
  final description = TextEditingController();

  CvEducation toModel() {
    return CvEducation(
      id: id,
      institution: _val(institution),
      degree: _val(degree),
      startDate: _val(startDate),
      endDate: _val(endDate),
      gpa: _val(gpa),
      description: _val(description),
    );
  }

  void dispose() {
    institution.dispose();
    degree.dispose();
    startDate.dispose();
    endDate.dispose();
    gpa.dispose();
    description.dispose();
  }
}

class CvExperienceForm {
  int? id;
  final companyName = TextEditingController();
  final position = TextEditingController();
  final startDate = TextEditingController();
  final endDate = TextEditingController();
  final description = TextEditingController();

  CvExperience toModel() {
    return CvExperience(
      id: id,
      companyName: _val(companyName),
      position: _val(position),
      startDate: _val(startDate),
      endDate: _val(endDate),
      description: _val(description),
    );
  }

  void dispose() {
    companyName.dispose();
    position.dispose();
    startDate.dispose();
    endDate.dispose();
    description.dispose();
  }
}

class CvReferrerForm {
  int? id;
  final name = TextEditingController();
  final role = TextEditingController();
  final organization = TextEditingController();
  final address1 = TextEditingController();
  final address2 = TextEditingController();
  final phone = TextEditingController();

  CvReferrer toModel() {
    return CvReferrer(
      id: id,
      name: _val(name),
      role: _val(role),
      organization: _val(organization),
      address1: _val(address1),
      address2: _val(address2),
      phone: _val(phone),
    );
  }

  void dispose() {
    name.dispose();
    role.dispose();
    organization.dispose();
    address1.dispose();
    address2.dispose();
    phone.dispose();
  }
}

String? _val(TextEditingController controller) {
  final value = controller.text.trim();
  return value.isEmpty ? null : value;
}
