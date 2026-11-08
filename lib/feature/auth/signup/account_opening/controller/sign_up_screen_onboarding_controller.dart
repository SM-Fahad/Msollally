import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/auth/signup/account_opening/model/sign_up_onboading_model.dart';
import '../service/signup_onboarding_service.dart';
import 'package:msollaally/core/services/user_role_service.dart';

class SignUpScreenOnboardingController extends GetxController {
  //onboarding
  var currentTextIndex = 0.obs;

  var currentImageIndex = 0.obs;
  final List<String> onboardingImages = [
    ImagesPath.onboarding1,
    ImagesPath.onboarding2,
    ImagesPath.onboarding3,
  ];

  final List<String> onboardingText = [
    "Study Smarter, Not Harder",
    "Connect, Collaborate, and Thrive",
    "Your Entire Campus, In Your Pocket",
  ];

  @override
  void onInit() {
    super.onInit();
    _startImageRotation();
    _loadUniversities();
  }

  void _startImageRotation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (currentImageIndex.value < onboardingImages.length - 1) {
        currentImageIndex.value++;
      } else {
        currentImageIndex.value = 0;
      }
      _startImageRotation();
    });
  }

  //image pic for profile update
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from the gallery. Returns the picked file or null.
  Future<XFile?> pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        selectedImagePath.value = file.path;
      }
      return file;
    } catch (_) {
      return null;
    }
  }

  /// Capture an image using the camera. Returns the picked file or null.
  // Camera capture removed — only gallery selection is supported.

  // selected profile image path (observable)
  final RxnString selectedImagePath = RxnString();

  /// Submit collected profile data to backend. Returns true on success.
  Future<bool> submitProfile() async {
    try {
      final fullName = nameController.text.trim();
      final gender = selectedGender.value ?? '';
      final dob = dateOfBirthController.text.trim();
      final uniId = selectedUniversityId.value ?? 0;
      final progId = selectedProgramId.value ?? 0;
      final deptId = selectedDepartmentId.value ?? 0;
      final program = programController.text.trim();
      final faculty = facultyController.text.trim();
      final studentId = studentIDController.text.trim();
      final enrollmentYear = int.tryParse(enrollmentYearController.text) ?? 0;
      final bio = bioController.text.trim();
      final email = emailController.text.trim();

      // ---- Validation for teacher role ----
      if (UserRoleService.isTeacher) {
        if (faculty.isEmpty || faculty.length < 2) {
          errorMessage.value = 'Faculty must be at least 2 characters';
          return false;
        }

        final allowedDesignations = [
          'lecturer',
          'senior lecturer',
          'assistant professor',
          'associate professor',
          'professor',
          'distinguished professor',
        ];

        final inputDesignation = designationTeacherController.text.trim();
        String? matchedDesignation;
        for (final d in allowedDesignations) {
          if (d.toLowerCase() == inputDesignation.toLowerCase()) {
            matchedDesignation = d;
            break;
          }
        }

        if (matchedDesignation == null || matchedDesignation.isEmpty) {
          errorMessage.value =
              'Designation must be one of: ${allowedDesignations.join(', ')}';
          return false;
        }

        // Ensure subject taught is present (optional but recommended)
        final subject = subjectsTaughtTeacherController.text.trim();
        if (subject.isEmpty) {
          errorMessage.value = 'Please enter at least one subject taught';
          return false;
        }
      }

      // ---- Validation for recruiter / pro-partner role ----
      String? mappedCompanyType;
      if (UserRoleService.isRecruiter || UserRoleService.isProPartners) {
        final allowedCompanyTypes = [
          'Technology',
          'Finance',
          'Healthcare',
          'Education',
          'Manufacturing',
          'Retail',
          'Consulting',
          'Other',
        ];

        final inputCompany = recruiterIndustryController.text.trim();
        if (inputCompany.isEmpty) {
          errorMessage.value = 'Please enter company type';
          return false;
        }

        for (final t in allowedCompanyTypes) {
          if (t.toLowerCase() == inputCompany.toLowerCase()) {
            mappedCompanyType = t;
            break;
          }
        }

        if (mappedCompanyType == null) {
          errorMessage.value =
              'Company type must be one of: ${allowedCompanyTypes.join(', ')}';
          return false;
        }

        // companyName and location required
        if (companyNameController.text.trim().isEmpty) {
          errorMessage.value = 'Company name is required';
          return false;
        }

        if (recruiterLocationController.text.trim().isEmpty) {
          errorMessage.value = 'Location is required';
          return false;
        }
      }

      final resp = await _service.completeProfile(
        fullName: fullName,
        gender: gender,
        dateOfBirth: dob,
        universityId: uniId,
        programId: progId,
        departmentId: deptId,
        program: program,
        faculty: faculty,
        studentID: studentId,
        enrollmentYear: enrollmentYear,
        profilePictureUrl: selectedImagePath.value,
        email: email,
        bio: bio,
        isTeacher: UserRoleService.isTeacher,
        designation: designationTeacherController.text.trim().toLowerCase(),
        subjectTaught: subjectsTaughtTeacherController.text
            .trim()
            .toLowerCase(),
        // Treat Pro Partners the same as Recruiters for profile payload
        isRecruiter:
            UserRoleService.isRecruiter || UserRoleService.isProPartners,
        companyType:
            mappedCompanyType ?? recruiterIndustryController.text.trim(),
        location: recruiterLocationController.text.trim(),
        companyName: companyNameController.text.trim(),
      );
      // Print response for debugging
      debugPrint('completeProfile response: ${resp.statusCode}');
      debugPrint('completeProfile body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        errorMessage.value = '';
        return true;
      }

      try {
        final Map<String, dynamic> decoded =
            json.decode(resp.body) as Map<String, dynamic>;
        errorMessage.value = decoded['message']?.toString() ?? resp.body;
      } catch (_) {
        errorMessage.value = resp.body.isNotEmpty
            ? resp.body
            : 'Failed to complete profile.';
      }

      return false;
    } catch (e) {
      debugPrint('submitProfile error: $e');
      return false;
    }
  }

  // ------------------ NODMAC SIGNUP ------------------

  // Basic information
  final formKeyBasic = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  // Calendar
  final Rxn<DateTime> dateTime = Rxn<DateTime>();

  String get formattedDateTime {
    if (dateTime.value == null) return "";
    return DateFormat("yyyy-MM-dd").format(dateTime.value!);
  }

  Future<void> pickDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: dateTime.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    dateTime.value = date;

    // Update controller text
    dateOfBirthController.text = DateFormat("yyyy-MM-dd").format(date);

    dateOfBirthController.selection = TextSelection.fromPosition(
      TextPosition(offset: dateOfBirthController.text.length),
    );
  }

  // Gender
  final RxnString selectedGender = RxnString();
  final List<String> genderOptions = ['Male', 'Female'];

  // Academic Information
  final formKeyAcademic = GlobalKey<FormState>();

  final TextEditingController universitynameController =
      TextEditingController();
  final TextEditingController programController = TextEditingController();
  final TextEditingController facultyController = TextEditingController();
  // Teacher-specific fields
  // final TextEditingController departmentTeacherController = TextEditingController();
  final TextEditingController designationTeacherController =
      TextEditingController();
  final TextEditingController subjectsTaughtTeacherController =
      TextEditingController();
  // Recruiter-specific fields
  final TextEditingController recruiterIndustryController =
      TextEditingController();
  final TextEditingController recruiterLocationController =
      TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController studentIDController = TextEditingController();
  final TextEditingController enrollmentYearController =
      TextEditingController();

  // University name
  final RxnString selectuniversity = RxnString();
  final RxList<String> universityNameOption = <String>[].obs;
  final List<University> _universities = [];
  final RxnInt selectedUniversityId = RxnInt();

  final SignupOnboardingService _service = SignupOnboardingService();
  final RxString errorMessage = ''.obs;

  Future<void> _loadUniversities() async {
    try {
      final list = await _service.fetchUniversities();
      _universities.clear();
      _universities.addAll(list);
      universityNameOption.clear();
      final uniNames = _universities.map((e) => e.name).toList();
      final uniqueUniNames = <String>[];
      for (final n in uniNames) {
        if (!uniqueUniNames.contains(n)) uniqueUniNames.add(n);
      }
      universityNameOption.addAll(uniqueUniNames);
    } catch (e) {
      // ignore: avoid_print
      print('Error loading universities: $e');
    }
  }

  void selectUniversityByName(String? name) {
    selectuniversity.value = name;
    universitynameController.text = name ?? ' ';
    if (name == null) {
      selectedUniversityId.value = null;
      // clear dependent lists and selections
      programOption.clear();
      facultyOption.clear();
      selectProgram.value = null;
      programController.text = ' ';
      selectedProgramId.value = null;
      selectFaculty.value = null;
      facultyController.text = ' ';
      selectedDepartmentId.value = null;
      return;
    }

    final found = _universities.firstWhere(
      (u) => u.name == name,
      orElse: () => University(id: -1, name: ''),
    );
    selectedUniversityId.value = found.id == -1 ? null : found.id;
    if (selectedUniversityId.value != null) {
      _loadUniversityDetail(selectedUniversityId.value!);
    }
  }

  // Program
  final RxnString selectProgram = RxnString();
  final RxList<String> programOption = <String>[].obs;
  final List<Program> _programs = [];
  final RxnInt selectedProgramId = RxnInt();

  // Faculty (departments)
  final RxnString selectFaculty = RxnString();
  final RxList<String> facultyOption = <String>[].obs;
  final List<Department> _departments = [];
  final RxnInt selectedDepartmentId = RxnInt();

  Future<void> _loadUniversityDetail(int universityId) async {
    try {
      final detail = await _service.fetchUniversityById(universityId);
      _programs.clear();
      _programs.addAll(detail.programs);
      programOption.clear();
      final progNames = _programs.map((p) => p.name).toList();
      final uniqueProgNames = <String>[];
      for (final n in progNames) {
        if (!uniqueProgNames.contains(n)) uniqueProgNames.add(n);
      }
      programOption.addAll(uniqueProgNames);
      // clear departments until a program is selected
      _departments.clear();
      facultyOption.clear();
      // reset selections
      selectProgram.value = null;
      programController.text = ' ';
      selectedProgramId.value = null;
      selectFaculty.value = null;
      facultyController.text = ' ';
      selectedDepartmentId.value = null;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading university detail: $e');
      programOption.clear();
      facultyOption.clear();
    }
  }

  void selectProgramByName(String? name) {
    selectProgram.value = name;
    programController.text = name ?? ' ';
    if (name == null) {
      selectedProgramId.value = null;
      // clear departments when program cleared
      _departments.clear();
      facultyOption.clear();
      selectFaculty.value = null;
      facultyController.text = ' ';
      selectedDepartmentId.value = null;
      return;
    }

    final found = _programs.firstWhere(
      (p) => p.name == name,
      orElse: () => Program(id: -1, name: '', departments: []),
    );
    selectedProgramId.value = found.id == -1 ? null : found.id;
    // populate departments for the selected program
    if (found.id != -1) {
      _departments.clear();
      _departments.addAll(found.departments);
      facultyOption.clear();
      final deptNames = _departments.map((d) => d.name).toList();
      final uniqueDeptNames = <String>[];
      for (final n in deptNames) {
        if (!uniqueDeptNames.contains(n)) uniqueDeptNames.add(n);
      }
      facultyOption.addAll(uniqueDeptNames);
      // reset department selection
      selectFaculty.value = null;
      facultyController.text = ' ';
      selectedDepartmentId.value = null;
    }
  }

  void selectDepartmentByName(String? name) {
    selectFaculty.value = name;
    facultyController.text = name ?? ' ';
    if (name == null) {
      selectedDepartmentId.value = null;
      return;
    }

    final found = _departments.firstWhere(
      (d) => d.name == name,
      orElse: () => Department(id: -1, name: ''),
    );
    selectedDepartmentId.value = found.id == -1 ? null : found.id;
  }

  // Bio
  final TextEditingController bioController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    genderController.dispose();
    dateOfBirthController.dispose();
    universitynameController.dispose();
    programController.dispose();
    facultyController.dispose();
    designationTeacherController.dispose();
    subjectsTaughtTeacherController.dispose();
    recruiterIndustryController.dispose();
    recruiterLocationController.dispose();
    companyNameController.dispose();
    studentIDController.dispose();
    enrollmentYearController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
