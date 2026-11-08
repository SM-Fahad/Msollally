import 'package:flutter/foundation.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/recruiter/home/model/pending_applicants_model.dart';
import 'package:msollaally/feature/recruiter/more/profile/controller/recruiter_profile_controller.dart';
import 'package:msollaally/feature/recruiter/jobs/all_jobs/controller/all_jobs_controller.dart';
import 'package:msollaally/feature/recruiter/jobs/all_jobs/model/recruiter_stats_model.dart';
import 'package:msollaally/feature/recruiter/candidates/all_candidates/screen/all_candidates_screen.dart';
import 'package:msollaally/feature/recruiter/jobs/all_jobs/screen/all_jobs_screen.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/controller/job_details_controller.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/screen/job_details_screen.dart';
import 'package:msollaally/feature/recruiter/recruiter_inbox/screen/inbox_screen.dart';
import '../model/recruiter_home_model.dart';

class RecruiterHomeController extends GetxController {
  final RxList<QuickToolItem> quickTools = <QuickToolItem>[].obs;
  final RxList<SummaryCardData> summaryCards = <SummaryCardData>[].obs;
  final RxList<ApplicantData> latestApplicants = <ApplicantData>[].obs;
  final Rx<JobData?> latestJob = Rx<JobData?>(null);
  final RxBool isLoadingLatestJob = false.obs;
  final RecruiterProfileController _profileController = Get.put(
    RecruiterProfileController(),
  );
  late final NetworkCaller _networkCaller;
  late final SharedPreferenceHelper _prefHelper;

  String get displayName => _profileController.displayName;

  String get profileImageUrl => _profileController.profileImageUrl;

  @override
  void onInit() {
    super.onInit();
    _networkCaller = NetworkCaller();
    _prefHelper = SharedPreferenceHelper();
    _initializeData();
    _fetchStats();
    _fetchPendingApplicants();
    _fetchLatestJob();
  }

  void _initializeData() {
    quickTools.assignAll([
      QuickToolItem(
        title: 'Chat',
        iconColor: AppColors.mediumPurpleAlpha1E8757F3,
        iconPath: 'assets/icons/dashboard_icon.svg',
        onTap: () => navigateToDashboard(),
      ),
      QuickToolItem(
        title: 'Candidate',
        iconColor: AppColors.coralAlpha1EFF9244,
        iconPath: 'assets/icons/candidate_icon.svg',
        onTap: () => navigateToCandidates(),
      ),
      QuickToolItem(
        title: 'Jobs',
        iconColor: AppColors.dodgerBlueAlpha1E418AFF,
        iconPath: 'assets/icons/jobs_icon.svg',
        onTap: () => navigateToJobs(),
      ),
    ]);

    summaryCards.assignAll([
      SummaryCardData(
        title: '450',
        subtitle: 'Candidates',
        iconColor: AppColors.coralAlpha1EFF9244,
        iconPath: 'assets/icons/candidate_icon.svg',
      ),
      SummaryCardData(
        title: '4',
        subtitle: 'Open Jobs',
        iconColor: AppColors.mediumSeaGreenAlpha1E46C882,
        iconPath: 'assets/icons/jobs_icon.svg',
      ),
      SummaryCardData(
        title: '5',
        subtitle: 'Applied Today',
        iconColor: AppColors.dodgerBlueAlpha1E418AFF,
        iconPath: 'assets/icons/application_icon.svg',
      ),
    ]);

    latestApplicants.assignAll([]);
  }

  Future<void> _fetchPendingApplicants() async {
    try {
      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await _networkCaller.getRequest(
        Urls.seeAllPendingCandidates,
        token: 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final pendingResponse = PendingApplicationsResponse.fromJson(
          response.responseData as Map<String, dynamic>,
        );

        // Take only the first 2 applicants
        final latestTwo = pendingResponse.applications.take(2).toList();

        final applicants = latestTwo.map((app) {
          return ApplicantData(
            applicationId: app.id,
            name: app.applicantName,
            appliedTo: app.jobTitle,
            date: DateTime.now().toString().split(' ')[0],
            avatarUrl: app.profilePictureUrl.isNotEmpty
                ? app.profilePictureUrl
                : 'https://randomuser.me/api/portraits/men/${app.applicantId % 70}.jpg',
            resumeUrl: app.resumeUrl,
            nameColor: AppColors.seaGreen1E9655,
            backgroundColor: AppColors.mediumSeaGreenAlpha1446C882,
            borderColor: AppColors.mediumSeaGreenAlpha4C46C882,
          );
        }).toList();

        latestApplicants.assignAll(applicants);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching pending applicants: $e');
      }
    }
  }

  Future<void> _fetchStats() async {
    try {
      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await _networkCaller.getRequest(
        Urls.recruterStats,
        token: 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final stats = RecruiterStatsModel.fromJson(
          response.responseData as Map<String, dynamic>,
        );

        summaryCards.assignAll([
          SummaryCardData(
            title: stats.totalApplications.toString(),
            subtitle: 'Candidates',
            iconColor: AppColors.coralAlpha1EFF9244,
            iconPath: 'assets/icons/candidate_icon.svg',
          ),
          SummaryCardData(
            title: stats.activeJobs.toString(),
            subtitle: 'Open Jobs',
            iconColor: AppColors.mediumSeaGreenAlpha1E46C882,
            iconPath: 'assets/icons/jobs_icon.svg',
          ),
          SummaryCardData(
            title: stats.appliedToday.toString(),
            subtitle: 'Applied Today',
            iconColor: AppColors.dodgerBlueAlpha1E418AFF,
            iconPath: 'assets/icons/application_icon.svg',
          ),
        ]);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching stats: $e');
      }
    }
  }

  Future<void> _fetchLatestJob() async {
    try {
      isLoadingLatestJob.value = true;

      // Reuse the recruiter jobs API flow so the latest card stays API-driven.
      final allJobsController = Get.put(AllJobsController());
      await allJobsController.refreshJobs();

      if (allJobsController.jobs.isNotEmpty) {
        latestJob.value = JobData.fromJobModel(allJobsController.jobs.first);
      } else {
        latestJob.value = null;
      }
    } catch (e) {
      latestJob.value = null;
    } finally {
      isLoadingLatestJob.value = false;
    }
  }

  void navigateToDashboard() {
    Get.to(() => RecruiterInboxScreen());
    debugPrint('Navigate to chat');
  }

  void navigateToCandidates() {
    Get.to(() => RecruiterAllCandidatesScreen());
  }

  void navigateToJobs() {
    Get.to(() => RecruiterAllJobsScreen());
  }

  void onApplicantTap(ApplicantData applicant) {}

  void onJobTap(JobData job) {
    if (job.id == null) {
      debugPrint('Latest job is missing an id, cannot open details');
      return;
    }

    Get.delete<JobDetailsController>(force: true);
    Get.put(JobDetailsController(jobId: job.id));
    Get.to(() => JobDetailsScreen());
  }

  Future<void> refreshLatestJob() async {
    await _fetchLatestJob();
  }

  /// Pull-to-refresh: re-fetches all dashboard data.
  Future<void> refreshAll() async {
    await Future.wait([
      _fetchStats(),
      _fetchPendingApplicants(),
      _fetchLatestJob(),
    ]);
  }
}
