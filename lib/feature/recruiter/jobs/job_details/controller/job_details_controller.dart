// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/recruiter/home/controller/recruiter_home_controller.dart';
import 'package:msollaally/feature/recruiter/jobs/all_jobs/controller/all_jobs_controller.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/model/candidate_model.dart';
import 'package:msollaally/feature/recruiter/jobs/job_details/model/candidate_status_enum.dart';
import '../model/job_details_model.dart';

class JobDetailsController extends GetxController {
  final int? _jobId;

  var selectedIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isCandidatesLoading = false.obs;
  final RxBool isShortlistedLoading = false.obs;
  final RxBool isReservedLoading = false.obs;
  final RxBool isRejectedLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isUpdatingStatus = false.obs;
  final RxString error = ''.obs;
  final Rx<JobDetailsModel?> jobDetails = Rx<JobDetailsModel?>(null);
  final RxList<CandidateModel> candidates = <CandidateModel>[].obs;
  final RxList<CandidateModel> shortlistedCandidates = <CandidateModel>[].obs;
  final RxList<CandidateModel> reservedCandidates = <CandidateModel>[].obs;
  final RxList<CandidateModel> rejectedCandidates = <CandidateModel>[].obs;
  late final NetworkCaller _networkCaller;
  late final SharedPreferenceHelper _prefHelper;

  JobDetailsController({int? jobId}) : _jobId = jobId;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  Future<void> refreshJobDetails() async {
    if (_jobId == null) return;
    await _fetchJobDetails(_jobId);
  }

  @override
  void onInit() {
    super.onInit();
    print('JobDetailsController.onInit() called');

    _networkCaller = NetworkCaller();
    _prefHelper = SharedPreferenceHelper();

    // Get job ID from constructor parameter
    print('Job ID from constructor: $_jobId (type: ${_jobId.runtimeType})');

    if (_jobId != null) {
      print('Calling _fetchJobDetails with jobId: $_jobId');
      _fetchJobDetails(_jobId);
      _fetchJobCandidates(_jobId);
      _fetchShortlistedCandidates(_jobId);
      _fetchReservedCandidates(_jobId);
      _fetchRejectedCandidates(_jobId);
    } else {
      error.value = 'No job ID provided';
      print('Job ID is null!');
    }
  }

  Future<void> _fetchJobDetails(dynamic jobId) async {
    try {
      isLoading.value = true;
      error.value = '';

      print('_fetchJobDetails started with jobId: $jobId');

      // Get auth token
      final token = await _prefHelper.getAccessToken();
      print('Token: $token');

      if (token == null || token.isEmpty) {
        error.value = 'Authentication token not found. Please log in again.';
        print('No auth token available');
        return;
      }

      // Make API request
      final jobIdInt = jobId is int
          ? jobId
          : int.tryParse(jobId.toString()) ?? 0;
      print('Converted jobId: $jobIdInt (from $jobId)');

      final url = Urls.jobById(jobIdInt);
      print('Job Details API URL: $url');

      final response = await _networkCaller.getRequest(
        url,
        token: 'Bearer $token',
      );

      print('Response Status: ${response.statusCode}');
      print('Response Success: ${response.isSuccess}');

      if (response.isSuccess) {
        if (response.responseData is Map<String, dynamic>) {
          final job = JobDetailsModel.fromJson(
            response.responseData as Map<String, dynamic>,
          );
          jobDetails.value = job;
          print('Job details loaded successfully: ${job.title}');
        } else {
          error.value = 'Invalid response format';
          print(
            'Response data is not a map: ${response.responseData.runtimeType}',
          );
        }
      } else {
        error.value = response.errorMessage.isEmpty
            ? 'Failed to load job details'
            : response.errorMessage;
        print('API Error: ${response.errorMessage}');
      }
    } catch (e) {
      error.value = 'Error: ${e.toString()}';
      print('Exception in _fetchJobDetails: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchJobCandidates(dynamic jobId) async {
    try {
      isCandidatesLoading.value = true;

      print('_fetchJobCandidates started with jobId: $jobId');

      // Get auth token
      final token = await _prefHelper.getAccessToken();
      print('Token: $token');

      if (token == null || token.isEmpty) {
        print('No auth token available for candidates');
        return;
      }

      // Make API request
      final jobIdStr = jobId.toString();
      final url = Urls.getJobCandidates(jobIdStr);
      print('Job Candidates API URL: $url');

      final response = await _networkCaller.getRequest(
        url,
        token: 'Bearer $token',
      );

      print('Candidates Response Status: ${response.statusCode}');
      print('Candidates Response Success: ${response.isSuccess}');

      if (response.isSuccess) {
        if (response.responseData is List) {
          final candidatesList = (response.responseData as List)
              .map((e) => CandidateModel.fromJson(e as Map<String, dynamic>))
              .toList();
          candidates.value = candidatesList;
          print(
            'Candidates loaded successfully: ${candidatesList.length} candidates',
          );
        } else {
          print(
            'Response data is not a list: ${response.responseData.runtimeType}',
          );
        }
      } else {
        print('API Error: ${response.errorMessage}');
      }
    } catch (e) {
      print('Exception in _fetchJobCandidates: $e');
    } finally {
      isCandidatesLoading.value = false;
    }
  }

  Future<void> _fetchShortlistedCandidates(dynamic jobId) async {
    try {
      isShortlistedLoading.value = true;

      print('_fetchShortlistedCandidates started with jobId: $jobId');

      // Get auth token
      final token = await _prefHelper.getAccessToken();
      print('Token: $token');

      if (token == null || token.isEmpty) {
        print('No auth token available for shortlisted candidates');
        return;
      }

      // Make API request
      final jobIdStr = jobId.toString();
      final url = Urls.getShortlistedCandidates(jobIdStr);
      print('Shortlisted Candidates API URL: $url');

      final response = await _networkCaller.getRequest(
        url,
        token: 'Bearer $token',
      );

      print('Shortlisted Response Status: ${response.statusCode}');
      print('Shortlisted Response Success: ${response.isSuccess}');

      if (response.isSuccess) {
        if (response.responseData is List) {
          final shortlistedList = (response.responseData as List)
              .map((e) => CandidateModel.fromJson(e as Map<String, dynamic>))
              .toList();
          shortlistedCandidates.value = shortlistedList;
          print(
            'Shortlisted candidates loaded successfully: ${shortlistedList.length} candidates',
          );
        } else {
          print(
            'Response data is not a list: ${response.responseData.runtimeType}',
          );
        }
      } else {
        print('API Error: ${response.errorMessage}');
      }
    } catch (e) {
      print('Exception in _fetchShortlistedCandidates: $e');
    } finally {
      isShortlistedLoading.value = false;
    }
  }

  Future<void> updateCandidateStatus(
    int candidateId,
    CandidateStatus newStatus, {
    String? rejectionReason,
  }) async {
    try {
      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final url = Urls.updateCandidateStatus(candidateId.toString());
      final body = {
        'status': newStatus.apiValue,
        'rejectionReason': newStatus == CandidateStatus.rejected
            ? rejectionReason
            : '',
      };

      final response = await _networkCaller.putJsonRequest(
        url,
        body: body,
        token: 'Bearer $token',
      );

      if (response.isSuccess) {
        // Build the updated candidate object with the new status.
        final source =
            candidates.firstWhereOrNull((c) => c.id == candidateId) ??
            shortlistedCandidates.firstWhereOrNull((c) => c.id == candidateId) ??
            reservedCandidates.firstWhereOrNull((c) => c.id == candidateId) ??
            rejectedCandidates.firstWhereOrNull((c) => c.id == candidateId);

        if (source == null) return;

        final updatedCandidate = CandidateModel(
          id: source.id,
          jobId: source.jobId,
          applicantId: source.applicantId,
          name: source.name,
          phoneNumber: source.phoneNumber,
          education: source.education,
          experience: source.experience,
          linkedIn: source.linkedIn,
          coverLetter: source.coverLetter,
          resumeUrl: source.resumeUrl,
          skills: source.skills,
          status: newStatus.apiValue,
          rejectionReason: newStatus == CandidateStatus.rejected
              ? rejectionReason ?? source.rejectionReason
              : source.rejectionReason,
          isShortlisted: newStatus == CandidateStatus.shortlisted,
        );

        // ── Update the main candidates list in-place (triggers Obx) ──
        final mainIndex = candidates.indexWhere((c) => c.id == candidateId);
        if (mainIndex != -1) {
          candidates[mainIndex] = updatedCandidate;
        }

        // ── Keep the secondary lists in sync ──
        final shortIndex =
            shortlistedCandidates.indexWhere((c) => c.id == candidateId);
        if (newStatus == CandidateStatus.shortlisted) {
          if (shortIndex == -1) {
            shortlistedCandidates.add(updatedCandidate);
          } else {
            shortlistedCandidates[shortIndex] = updatedCandidate;
          }
        } else if (shortIndex != -1) {
          shortlistedCandidates.removeAt(shortIndex);
        }

        final reserveIndex =
            reservedCandidates.indexWhere((c) => c.id == candidateId);
        if (newStatus == CandidateStatus.accepted) {
          if (reserveIndex == -1) {
            reservedCandidates.add(updatedCandidate);
          } else {
            reservedCandidates[reserveIndex] = updatedCandidate;
          }
        } else if (reserveIndex != -1) {
          reservedCandidates.removeAt(reserveIndex);
        }

        final rejectIndex =
            rejectedCandidates.indexWhere((c) => c.id == candidateId);
        if (newStatus == CandidateStatus.rejected) {
          if (rejectIndex == -1) {
            rejectedCandidates.add(updatedCandidate);
          } else {
            rejectedCandidates[rejectIndex] = updatedCandidate;
          }
        } else if (rejectIndex != -1) {
          rejectedCandidates.removeAt(rejectIndex);
        }

        Get.snackbar(
          'Success',
          'Candidate ${newStatus.displayLabel.toLowerCase()}',
        );
      } else {
        Get.snackbar('Error', response.errorMessage);
      }
    } catch (e) {
      print('Error updating candidate status: $e');
      Get.snackbar('Error', 'Failed to update candidate');
    }
  }

  Future<void> openResumeUrl(String resumeUrl) async {
    try {
      var url = resumeUrl;
      if (url.isEmpty) return;

      if (!url.startsWith('http')) url = 'https://$url';

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      print('Error opening resume URL: $e');
      Get.snackbar('Error', 'Could not open resume URL');
    }
  }

  Future<void> deleteJob() async {
    try {
      if (_jobId == null) {
        error.value = 'Job ID not available';
        return;
      }

      isDeleting.value = true;

      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        error.value = 'Authentication token not found. Please log in again.';
        return;
      }

      print('🗑️ Deleting job with ID: $_jobId');

      final url = Urls.jobById(_jobId);
      print('Delete API URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        print('✅ Job deleted successfully');

        if (Get.isRegistered<AllJobsController>()) {
          await Get.find<AllJobsController>().refreshJobs();
        }

        if (Get.isRegistered<RecruiterHomeController>()) {
          await Get.find<RecruiterHomeController>().refreshLatestJob();
        }

        Get.back(result: 'deleted');
      } else {
        error.value = 'Failed to delete job';
        print('❌ Delete failed with status: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Error deleting job: ${e.toString()}';
      print('❌ Exception during delete: $e');
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> updateJobStatus(String status) async {
    try {
      if (_jobId == null) {
        error.value = 'Job ID not available';
        return;
      }

      isUpdatingStatus.value = true;

      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        error.value = 'Authentication token not found. Please log in again.';
        return;
      }

      final url = Urls.updateJobStatus(_jobId.toString());
      print('Updating job status: $status -> $url');

      final response = await _networkCaller.putJsonRequest(
        url,
        body: {'status': status},
        token: 'Bearer $token',
      );

      if (response.isSuccess) {
        print('Job status updated successfully');
        await refreshJobDetails();
        Get.snackbar('Success', 'Job status updated to $status');
      } else {
        print('Failed to update job status: ${response.errorMessage}');
        Get.snackbar(
          'Error',
          response.errorMessage.isEmpty
              ? 'Failed to update job status'
              : response.errorMessage,
        );
      }
    } catch (e) {
      print('Exception updating job status: $e');
      Get.snackbar('Error', 'Could not update job status');
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<void> _fetchReservedCandidates(dynamic jobId) async {
    try {
      isReservedLoading.value = true;

      print('_fetchReservedCandidates started with jobId: $jobId');

      // Get auth token
      final token = await _prefHelper.getAccessToken();
      print('Token: $token');

      if (token == null || token.isEmpty) {
        print('No auth token available for reserved candidates');
        return;
      }

      // Make API request
      final jobIdStr = jobId.toString();
      final url = Urls.getReservedCandidates(jobIdStr);
      print('Reserved Candidates API URL: $url');

      final response = await _networkCaller.getRequest(
        url,
        token: 'Bearer $token',
      );

      print('Reserved Response Status: ${response.statusCode}');
      print('Reserved Response Success: ${response.isSuccess}');

      if (response.isSuccess) {
        if (response.responseData is List) {
          final reservedList = (response.responseData as List)
              .map((e) => CandidateModel.fromJson(e as Map<String, dynamic>))
              .toList();
          reservedCandidates.value = reservedList;
          print(
            'Reserved candidates loaded successfully: ${reservedList.length} candidates',
          );
        } else {
          print(
            'Response data is not a list: ${response.responseData.runtimeType}',
          );
        }
      } else {
        print('API Error: ${response.errorMessage}');
      }
    } catch (e) {
      print('Exception in _fetchReservedCandidates: $e');
    } finally {
      isReservedLoading.value = false;
    }
  }

  Future<void> _fetchRejectedCandidates(dynamic jobId) async {
    try {
      isRejectedLoading.value = true;

      print('_fetchRejectedCandidates started with jobId: $jobId');

      // Get auth token
      final token = await _prefHelper.getAccessToken();
      print('Token: $token');

      if (token == null || token.isEmpty) {
        print('No auth token available for rejected candidates');
        return;
      }

      // Make API request
      final jobIdStr = jobId.toString();
      final url = Urls.getRejectedCandidates(jobIdStr);
      print('Rejected Candidates API URL: $url');

      final response = await _networkCaller.getRequest(
        url,
        token: 'Bearer $token',
      );

      print('Rejected Response Status: ${response.statusCode}');
      print('Rejected Response Success: ${response.isSuccess}');

      if (response.isSuccess) {
        if (response.responseData is List) {
          final rejectedList = (response.responseData as List)
              .map((e) => CandidateModel.fromJson(e as Map<String, dynamic>))
              .toList();
          rejectedCandidates.value = rejectedList;
          print(
            'Rejected candidates loaded successfully: ${rejectedList.length} candidates',
          );
        } else {
          print(
            'Response data is not a list: ${response.responseData.runtimeType}',
          );
        }
      } else {
        print('API Error: ${response.errorMessage}');
      }
    } catch (e) {
      print('Exception in _fetchRejectedCandidates: $e');
    } finally {
      isRejectedLoading.value = false;
    }
  }
}
