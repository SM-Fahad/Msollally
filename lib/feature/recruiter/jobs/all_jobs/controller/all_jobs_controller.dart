// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:msollaally/feature/recruiter/more/profile/controller/recruiter_profile_controller.dart';
import '../model/recruter_job_model.dart';
import '../model/job_status_enum.dart';
import '../model/recruiter_stats_model.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class AllJobsController extends GetxController {
  final RxList<JobModel> jobs = RxList<JobModel>([]);
  final Rx<JobStatus> statusFilter = JobStatus.published.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RecruiterProfileController _profileController = Get.put(
    RecruiterProfileController(),
  );
  String get displayName => _profileController.displayName;

  String get profileImageUrl => _profileController.profileImageUrl;

  // Stats properties
  final RxInt totalJobs = 0.obs;
  final RxInt activeJobs = 0.obs;
  final RxInt closedJobs = 0.obs;
  final RxInt draftJobs = 0.obs;
  final RxInt totalApplications = 0.obs;
  final RxInt totalViews = 0.obs;
  final RxInt appliedToday = 0.obs;

  late final NetworkCaller _networkCaller;
  late final SharedPreferenceHelper _prefHelper;

  List<JobModel> get filteredJobs {
    // Filter jobs by selected status
    return jobs
        .where((job) => job.status == statusFilter.value.apiValue)
        .toList();
  }

  void setStatusFilter(JobStatus status) {
    statusFilter.value = status;
    _fetchJobs(status);
  }

  void openFilterSheet() {}

  Future<void> refreshJobs() async {
    print('🔄 Refreshing jobs list...');
    await _fetchJobs(statusFilter.value);
  }

  @override
  void onInit() {
    super.onInit();
    _networkCaller = NetworkCaller();
    _prefHelper = SharedPreferenceHelper();
    _loadInitialJobs();
    _fetchStats();
  }

  Future<void> _loadInitialJobs() async {
    // Load jobs with default published status on initialization
    await _fetchJobs(JobStatus.published);
  }

  Future<void> _fetchJobs(JobStatus status) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get auth token
      final token = await _prefHelper.getAccessToken();
      print('Token: ${token?.substring(0, 20)}...');

      if (token == null || token.isEmpty) {
        error.value = 'Authentication token not found. Please log in again.';
        print('No auth token available');
        return;
      }

      // Make API request
      final url = Urls.getMyJobs(status.apiValue);
      print('API URL: $url');
      print('Fetching jobs with status: ${status.apiValue}');

      final response = await _networkCaller.getRequest(
        url,
        token: 'Bearer $token',
      );

      print('Response Status: ${response.statusCode}');
      print('Response Success: ${response.isSuccess}');

      if (response.isSuccess) {
        if (response.responseData is List) {
          final List<dynamic> jsonList = response.responseData as List;
          print('Received ${jsonList.length} jobs');

          jobs.value = jsonList
              .map((json) {
                try {
                  return JobModel.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing job: $e');
                  return null;
                }
              })
              .whereType<JobModel>()
              .toList();

          print('Successfully loaded ${jobs.length} jobs');
        } else {
          error.value = 'Invalid response format';
          print(
            'Response data is not a list: ${response.responseData.runtimeType}',
          );
        }
      } else {
        error.value = response.errorMessage.isEmpty
            ? 'Failed to load jobs'
            : response.errorMessage;
        print('API Error: ${response.errorMessage}');
      }
    } catch (e) {
      error.value = 'Error: ${e.toString()}';
      print('Exception in _fetchJobs: $e');
      print('Stack trace: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchStats() async {
    try {
      // Get auth token
      final token = await _prefHelper.getAccessToken();
      print('Fetching stats with token: ${token?.substring(0, 20)}...');

      if (token == null || token.isEmpty) {
        print('No auth token available for stats');
        return;
      }

      // Make API request for stats
      final url = Urls.recruterStats;
      print('Stats API URL: $url');

      final response = await _networkCaller.getRequest(
        url,
        token: 'Bearer $token',
      );

      print('Stats Response Status: ${response.statusCode}');
      print('Stats Response Success: ${response.isSuccess}');

      if (response.isSuccess) {
        if (response.responseData is Map) {
          final stats = RecruiterStatsModel.fromJson(
            response.responseData as Map<String, dynamic>,
          );

          totalJobs.value = stats.totalJobs;
          activeJobs.value = stats.activeJobs;
          closedJobs.value = stats.closedJobs;
          draftJobs.value = stats.draftJobs;
          totalApplications.value = stats.totalApplications;
          totalViews.value = stats.totalViews;
          appliedToday.value = stats.appliedToday;

          print('📊 Stats loaded successfully:');
        } else {
          print(
            '⚠️ Stats response is not a map: ${response.responseData.runtimeType}',
          );
        }
      } else {
        print('Stats API Error: ${response.errorMessage}');
      }
    } catch (e) {
      print('Exception in _fetchStats: $e');
    }
  }
}
