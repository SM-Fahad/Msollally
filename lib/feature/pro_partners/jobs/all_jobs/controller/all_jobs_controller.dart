import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/model/job_model.dart';
import 'package:msollaally/feature/pro_partners/jobs/create_job/screen/create_job_screen.dart';

class AllJobsController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  final jobStatuses = ['draft', 'published', 'closed', 'filled', 'archived'];
  final selectedStatusIndex = 1.obs;

  final jobs = <JobModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;
  final updatingJobId = ''.obs;
  final loadingJobDetailId = ''.obs;
  final deletingJobId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllJobs();
  }

  String get selectedStatus => jobStatuses[selectedStatusIndex.value];

  Future<void> changeStatusTab(int index) async {
    if (index < 0 || index >= jobStatuses.length) {
      return;
    }
    if (selectedStatusIndex.value == index) {
      return;
    }
    selectedStatusIndex.value = index;
    await fetchAllJobs();
  }

  Future<void> fetchAllJobs({bool isLoadMore = false}) async {
    if (isLoadMore) {
      return;
    }

    hasMore.value = true;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _networkCaller.getRequest(
        Urls.getMyJobs(selectedStatus),
        token: await _bearerToken(),
      );

      if (!response.isSuccess) {
        errorMessage.value = response.errorMessage.isEmpty
            ? 'Failed to load jobs'
            : response.errorMessage;
        return;
      }

      final data = response.responseData;
      final rawJobs = data is List ? data : <dynamic>[];
      jobs.value = rawJobs
          .whereType<Map<String, dynamic>>()
          .map(JobModel.fromJson)
          .toList();
      hasMore.value = false;
    } catch (_) {
      errorMessage.value = 'Failed to load jobs';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> openCreateJob() async {
    final result = await Get.to(() => CreateJobScreen());
    if (result == true) {
      await fetchAllJobs();
      return;
    }
    await fetchAllJobs();
  }

  Future<void> openUpdateJob(String jobId) async {
    if (loadingJobDetailId.value == jobId) {
      return;
    }

    loadingJobDetailId.value = jobId;

    try {
      final response = await _networkCaller.getRequest(
        Urls.getJobById(jobId),
        token: await _bearerToken(),
      );

      if (!response.isSuccess ||
          response.responseData is! Map<String, dynamic>) {
        Get.snackbar(
          'Error',
          response.errorMessage.isEmpty
              ? 'Failed to load job details'
              : response.errorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final fullJob = JobModel.fromJson(
        response.responseData as Map<String, dynamic>,
      );
      final result = await Get.to(
        () => CreateJobScreen(job: fullJob, isEdit: true),
      );
      if (result == true) {
        await fetchAllJobs();
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to load job details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loadingJobDetailId.value = '';
    }
  }

  Future<void> confirmDeleteJob(JobModel job) async {
    await Get.dialog(
      Obx(() {
        final isDeleting = deletingJobId.value == job.id;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lavenderBlushFFF1F2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.delete_outline, color: AppColors.crimsonDC2626),
                ),
                SizedBox(height: 16),
                Text(
                  'Delete Job?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black0F172A,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete "${job.title.trim().isEmpty ? 'this job' : job.title}"? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: AppColors.slateGray64748B,
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isDeleting ? null : Get.back,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: AppColors.lavenderE2E8F0),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isDeleting ? null : () => deleteJob(job.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.crimsonDC2626,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isDeleting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> deleteJob(String jobId) async {
    if (deletingJobId.value == jobId) {
      return;
    }

    deletingJobId.value = jobId;

    try {
      final response = await _networkCaller.deleteRequest(
        Urls.updateOrdeleteAJob(jobId),
        token: await _bearerToken(),
      );

      if (!response.isSuccess) {
        Get.snackbar(
          'Error',
          response.errorMessage.isEmpty
              ? 'Failed to delete job'
              : response.errorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      jobs.removeWhere((job) => job.id == jobId);
      Get.back();
      Get.snackbar(
        'Success',
        'Job deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to delete job',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      deletingJobId.value = '';
    }
  }

  Future<void> countJobView(String jobId) async {
    try {
      await _networkCaller.getRequest(
        Urls.getJobView(jobId),
        token: await _bearerToken(),
      );
    } catch (_) {}
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      updatingJobId.value = jobId;

      final response = await _networkCaller.putJsonRequest(
        Urls.updateJobStatus(jobId),
        body: {'status': status},
        token: await _bearerToken(),
      );

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          'Job status updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchAllJobs();
        return;
      }

      Get.snackbar(
        'Error',
        response.errorMessage.isEmpty
            ? 'Failed to update job status'
            : response.errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to update job status',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      updatingJobId.value = '';
    }
  }

  Future<String?> _bearerToken() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    return 'Bearer $token';
  }
}
