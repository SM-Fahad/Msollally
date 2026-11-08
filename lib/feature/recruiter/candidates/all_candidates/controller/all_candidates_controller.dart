import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/recruiter/chat/screen/recruiter_chat_screen.dart';
import 'package:msollaally/feature/recruiter/more/profile/controller/recruiter_profile_controller.dart';
import '../model/candidate_model.dart';

class AllCandidatesController extends GetxController {
  var searchText = ''.obs;
  var isFilterVisible = false.obs;
  var candidates = <JobApplicantModel>[].obs;
  var filteredCandidates = <JobApplicantModel>[].obs;
  var filterOptions = FilterOptions().obs;
  var isLoading = false.obs;
  var hasMorePages = false.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var universities = <String>[].obs;
  var isLoadingUniversities = false.obs;

  late final NetworkCaller _networkCaller;
  late final SharedPreferenceHelper _prefHelper;

  // Caches for universities and departments
  final Map<int, String> _universityCache = {};
  final Map<int, String> _departmentCache =
      {}; // key: departmentId, value: name
  final Set<int> _loadedProgramIds =
      {}; // track which programs have been loaded
  final RecruiterProfileController _profileController = Get.put(
    RecruiterProfileController(),
  );
  String get displayName => _profileController.displayName;

  String get profileImageUrl => _profileController.profileImageUrl;

  // Store raw application data for rebuilding with updated department names
  List<dynamic> _rawApplications = [];

  static const int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _networkCaller = NetworkCaller();
    _prefHelper = SharedPreferenceHelper();
    _loadUniversitiesCache();
    loadUniversities();
    loadCandidates();
  }

  Future<void> _loadUniversitiesCache() async {
    try {
      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await _networkCaller.getRequest(
        Urls.getUniversities,
        token: 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is List) {
        final universitiesList = response.responseData as List<dynamic>;
        for (var uni in universitiesList) {
          if (uni is Map<String, dynamic>) {
            final id = uni['id'] as int?;
            final name =
                uni['fullName']?.toString() ?? uni['name']?.toString() ?? '';
            if (id != null && name.isNotEmpty) {
              _universityCache[id] = name;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading universities cache: $e');
    }
  }

  Future<void> loadUniversities() async {
    try {
      isLoadingUniversities.value = true;
      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        isLoadingUniversities.value = false;
        return;
      }

      final response = await _networkCaller.getRequest(
        Urls.getUniversities,
        token: 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is List) {
        final universitiesList = response.responseData as List<dynamic>;
        final uniNames = <String>[];

        for (var uni in universitiesList) {
          if (uni is Map<String, dynamic>) {
            final fullName =
                uni['fullName']?.toString() ?? uni['name']?.toString() ?? '';
            if (fullName.isNotEmpty) {
              uniNames.add(fullName);
            }
          }
        }

        universities.assignAll(uniNames);
      }
    } catch (e) {
      debugPrint('Error loading universities: $e');
    } finally {
      isLoadingUniversities.value = false;
    }
  }

  Future<void> _loadDepartmentsCache(int programId) async {
    try {
      // Skip if already loaded
      if (_loadedProgramIds.contains(programId)) return;

      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await _networkCaller.getRequest(
        Urls.getUniDepartments(programId),
        token: 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is List) {
        final departments = response.responseData as List<dynamic>;
        for (var dept in departments) {
          if (dept is Map<String, dynamic>) {
            final id = dept['id'] as int?;
            final name = dept['name']?.toString() ?? '';
            if (id != null && name.isNotEmpty) {
              _departmentCache[id] = name;
            }
          }
        }
        _loadedProgramIds.add(programId);

        // Trigger UI update after loading departments
        _updateCandidateDepartmentNames();
      }
    } catch (e) {
      debugPrint('Error loading departments cache for program $programId: $e');
    }
  }

  Future<void> loadCandidates() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      candidates.clear();

      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await _networkCaller.getRequest(
        Urls.getAllRecruiterCandidates(currentPage.value, pageSize),
        token: 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final jobResponse = JobApplicationsResponse.fromJson(
          response.responseData as Map<String, dynamic>,
        );

        totalPages.value = jobResponse.totalPages;
        hasMorePages.value = currentPage.value < jobResponse.totalPages;

        _rawApplications = jobResponse.applications;
        final applicants = _parseApplications(jobResponse.applications);
        candidates.assignAll(applicants);
        filteredCandidates.assignAll(applicants);

        // Update department names after a short delay to allow fetching
        Future.delayed(Duration(milliseconds: 500), () {
          _updateCandidateDepartmentNames();
        });
      }
    } catch (e) {
      debugPrint('Error loading candidates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreCandidates() async {
    try {
      if (!hasMorePages.value || isLoading.value) return;

      isLoading.value = true;
      currentPage.value++;

      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await _networkCaller.getRequest(
        Urls.getAllRecruiterCandidates(currentPage.value, pageSize),
        token: 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final jobResponse = JobApplicationsResponse.fromJson(
          response.responseData as Map<String, dynamic>,
        );

        hasMorePages.value = currentPage.value < jobResponse.totalPages;

        final applicants = _parseApplications(jobResponse.applications);
        candidates.addAll(applicants);
        applyFilters();
      }
    } catch (e) {
      debugPrint('Error loading more candidates: $e');
    } finally {
      isLoading.value = false;
    }

    // Update department names after loading
    _updateCandidateDepartmentNames();
  }

  void _updateCandidateDepartmentNames() {
    // Rebuild candidates with updated department names from cache
    if (_rawApplications.isNotEmpty) {
      final updatedCandidates = _parseApplications(_rawApplications);
      candidates.assignAll(updatedCandidates);
      applyFilters();
    }
  }

  List<JobApplicantModel> _parseApplications(List<dynamic> applications) {
    return applications.map((app) {
      final appMap = app as Map<String, dynamic>;
      final applicant = appMap['applicant'] as Map<String, dynamic>? ?? {};
      final profile = applicant['profile'] as Map<String, dynamic>?;

      String fullName = 'Unknown';
      if (profile != null && profile['fullName'] != null) {
        fullName = profile['fullName'].toString();
      } else if (applicant['username'] != null) {
        fullName = applicant['username'].toString();
      }

      String profileImageUrl = '';
      if (profile != null && profile['profilePicture'] != null) {
        profileImageUrl = profile['profilePicture'].toString();
      }

      final job = appMap['job'] as Map<String, dynamic>? ?? {};
      final skills =
          (appMap['skills'] as List?)?.map((e) => e.toString()).toList() ?? [];

      // Extract university and department names from profile
      String universityName = '';
      String departmentName = '';
      if (profile != null) {
        final universityId = profile['universityId'] as int?;
        final programId = profile['programId'] as int?;
        final departmentId = profile['departmentId'] as int?;

        // Get university name from cache
        if (universityId != null &&
            _universityCache.containsKey(universityId)) {
          universityName = _universityCache[universityId]!;
        }

        // Load department cache for this program (non-blocking)
        if (programId != null && !_loadedProgramIds.contains(programId)) {
          _loadDepartmentsCache(programId);
        }

        // Get department name from cache if available
        if (departmentId != null &&
            _departmentCache.containsKey(departmentId)) {
          departmentName = _departmentCache[departmentId]!;
        }
      }

      return JobApplicantModel(
        id: appMap['id'] as int? ?? 0,
        applicantId: appMap['applicantId'] as int? ?? 0,
        name: fullName,
        jobTitle: job['title']?.toString() ?? 'Job Title',
        profileImageUrl: profileImageUrl.isNotEmpty
            ? profileImageUrl
            : 'https://randomuser.me/api/portraits/men/${(appMap['applicantId'] as int? ?? 0) % 70}.jpg',
        skills: skills,
        resumeUrl: appMap['resumeUrl']?.toString() ?? '',
        coverLetter: appMap['coverLetter']?.toString() ?? '',
        universityName: universityName,
        departmentName: departmentName,
      );
    }).toList();
  }

  void updateSearchText(String text) {
    searchText.value = text;
    applyFilters();
  }

  void toggleFilter() {
    isFilterVisible.value = !isFilterVisible.value;
  }

  void applyFilters() {
    var filtered = candidates.where((candidate) {
      bool matchesSearch =
          searchText.value.isEmpty ||
          candidate.name.toLowerCase().contains(
            searchText.value.toLowerCase(),
          ) ||
          candidate.jobTitle.toLowerCase().contains(
            searchText.value.toLowerCase(),
          ) ||
          candidate.skills.any(
            (skill) =>
                skill.toLowerCase().contains(searchText.value.toLowerCase()),
          );

      bool matchesSkills =
          filterOptions.value.skills == null ||
          filterOptions.value.skills!.isEmpty ||
          candidate.skills.any(
            (skill) => skill.toLowerCase().contains(
              filterOptions.value.skills!.toLowerCase(),
            ),
          );

      bool matchesUniversity =
          filterOptions.value.universityName == null ||
          filterOptions.value.universityName!.isEmpty ||
          candidate.universityName.toLowerCase().contains(
            filterOptions.value.universityName!.toLowerCase(),
          );

      return matchesSearch && matchesSkills && matchesUniversity;
    }).toList();

    filteredCandidates.value = filtered;
  }

  void clearFilters() {
    filterOptions.value.clear();
    filterOptions.refresh();
    applyFilters();
  }

  void updateFilter({String? university, String? grade, String? skills}) {
    if (university != null && university.isNotEmpty) {
      filterOptions.value.universityName = university;
    }
    if (grade != null && grade.isNotEmpty) {
      filterOptions.value.grade = grade;
    }
    if (skills != null && skills.isNotEmpty) {
      filterOptions.value.skills = skills;
    }
    filterOptions.refresh();
    applyFilters();
  }

  void onMessageTap(JobApplicantModel candidate) {
    if (candidate.applicantId <= 0) {
      Get.snackbar('Error', 'Candidate is not available for chat right now.');
      return;
    }

    Get.to(
      () => RecruiterChatScreen(),
      arguments: <String, dynamic>{
        'receiverIds': <int>[candidate.applicantId],
        'chatName': candidate.name,
        'isGroup': false,
      },
    );
  }

  void onMenuTap(int candidateId) {
    debugPrint('Menu tapped for candidate: $candidateId');
  }
}
