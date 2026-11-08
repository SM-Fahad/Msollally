// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/feature/recruiter/candidates/all_candidates/controller/all_candidates_controller.dart';
import 'package:msollaally/feature/recruiter/chat/screen/recruiter_chat_screen.dart';
import '../../candidate_details/model/candidate_details_model.dart';
import '../../../../../core/services/network_caller.dart';
import '../../../../../core/services/share_preferrance_helper.dart';
import '../../../../../core/services/end_points.dart';
import '../../../../student/career/cv/service/cv_service.dart';

class CandidateDetailsController extends GetxController {
  final Rx<CandidateDetailsModel?> selectedCandidate =
      Rx<CandidateDetailsModel?>(null);
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  late final NetworkCaller _networkCaller;
  late final SharedPreferenceHelper _prefHelper;

  // Universities cache: map universityId to fullName
  final Map<int, String> _universityCache = {};

  @override
  void onInit() {
    super.onInit();
    _networkCaller = NetworkCaller();
    _prefHelper = SharedPreferenceHelper();
    _loadUniversitiesCache();
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
        final universities = response.responseData as List<dynamic>;
        for (var uni in universities) {
          if (uni is Map<String, dynamic>) {
            final id = uni['id'] as int?;
            final fullName = uni['fullName']?.toString() ?? '';
            if (id != null && fullName.isNotEmpty) {
              _universityCache[id] = fullName;
            }
          }
        }
        debugPrint(
          'Universities cache loaded: ${_universityCache.length} universities',
        );
      }
    } catch (e) {
      debugPrint('Error loading universities cache: $e');
    }
  }

  Future<void> loadCandidate(String applicationId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Authentication token not found';
        isLoading.value = false;
        return;
      }

      final response = await _networkCaller.getRequest(
        Urls.getApplicantDetails(applicationId),
        token: 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is Map) {
        // Convert dynamic map to Map<String, dynamic>
        final jsonData = Map<String, dynamic>.from(
          response.responseData as Map,
        );
        final candidateData = CandidateDetailsModel.fromJson(
          jsonData,
          universityCache: _universityCache,
        );
        selectedCandidate.value = candidateData;
        debugPrint('Loaded candidate: $applicationId');
      } else {
        errorMessage.value = 'Failed to load candidate details';
      }
    } catch (e) {
      errorMessage.value = 'Error loading candidate: $e';
      debugPrint('Error loading candidate: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> shortlist() async {
    final success = await _updateApplicationStatus(
      'shortlisted',
      showDialog: false,
    );
    if (success) {
      try {
        if (Get.isRegistered<AllCandidatesController>()) {
          await Get.find<AllCandidatesController>().loadCandidates();
        } else {
          Get.put(AllCandidatesController());
        }
      } catch (e) {
        debugPrint('Error refreshing AllCandidatesController: $e');
      }
    }
  }

  Future<void> reserve() async {
    final success = await _updateApplicationStatus(
      'accepted',
      showDialog: false,
    );
    if (success) {
      try {
        if (Get.isRegistered<AllCandidatesController>()) {
          await Get.find<AllCandidatesController>().loadCandidates();
        } else {
          Get.put(AllCandidatesController());
        }
      } catch (e) {
        debugPrint('Error refreshing AllCandidatesController: $e');
      }
    }
  }

  Future<void> decline() async {
    final success = await _updateApplicationStatus('rejected');
    if (success) {
      try {
        if (Get.isRegistered<AllCandidatesController>()) {
          await Get.find<AllCandidatesController>().loadCandidates();
        } else {
          Get.put(AllCandidatesController());
        }
      } catch (e) {
        debugPrint('Error refreshing AllCandidatesController: $e');
      }
    }
  }

  Future<void> declineWithReason(String reason) async {
    final success = await _updateApplicationStatus(
      'rejected',
      rejectionReason: reason,
    );
    if (success) {
      try {
        if (Get.isRegistered<AllCandidatesController>()) {
          await Get.find<AllCandidatesController>().loadCandidates();
        } else {
          Get.put(AllCandidatesController());
        }
      } catch (e) {
        debugPrint('Error refreshing AllCandidatesController: $e');
      }
    }
  }

  Future<void> downloadCV(String cvId) async {
    if (cvId.isEmpty) {
      Get.snackbar('Error', 'CV id not available');
      return;
    }

    try {
      EasyLoading.show(status: 'Preparing download...');
      final cvService = CvService();
      await cvService.downloadCv(cvId);
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error downloading CV for $cvId: $e');
      Get.snackbar('Error', 'Failed to download CV');
    }
  }

  void messageCandidate() {
    final candidate = selectedCandidate.value;
    if (candidate == null) {
      Get.snackbar('Error', 'Candidate is not available for chat right now.');
      return;
    }

    final applicantId = int.tryParse(candidate.applicantId);
    if (applicantId == null || applicantId <= 0) {
      Get.snackbar('Error', 'Candidate is not available for chat right now.');
      return;
    }

    Get.to(
      () => RecruiterChatScreen(),
      arguments: <String, dynamic>{
        'receiverIds': <int>[applicantId],
        'chatName': candidate.name,
        'isGroup': false,
      },
    );
  }

  Future<bool> _updateApplicationStatus(
    String status, {
    String rejectionReason = '',
    bool showDialog = true,
  }) async {
    final applicationId = selectedCandidate.value?.id;
    if (applicationId == null || applicationId.isEmpty) {
      Get.snackbar('Error', 'Application ID not found');
      return false;
    }

    try {
      final token = await _prefHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Authentication token not found');
        return false;
      }

      final body = {'status': status};
      if (rejectionReason.isNotEmpty) {
        body['rejectionReason'] = rejectionReason;
      }

      debugPrint(
        'PUT ${Urls.updateJobForApplicants(applicationId)} body: $body',
      );
      final response = await _networkCaller.putJsonRequest(
        Urls.updateJobForApplicants(applicationId),
        body: body,
        token: 'Bearer $token',
      );
      debugPrint(
        'Update application response - success: ${response.isSuccess}',
      );
      debugPrint('Response data: ${response.responseData}');
      debugPrint('Response errorMessage: ${response.errorMessage}');

      if (!response.isSuccess) {
        final msg = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to update status';
        Get.snackbar('Error', msg);
        return false;
      }

      final apiStatus = _extractStatus(response.responseData) ?? status;
      final reason = _extractRejectionReason(response.responseData);

      // Update local model so UI reflects the new status immediately
      selectedCandidate.value = selectedCandidate.value?.copyWith(
        status: apiStatus,
        rejectionReason: reason,
      );
      if (showDialog) {
        _showStatusDialog(apiStatus, reason);
      } else {
        final titleStatus = apiStatus.isNotEmpty
            ? apiStatus[0].toUpperCase() + apiStatus.substring(1)
            : 'Updated';
        EasyLoading.showSuccess(titleStatus);
      }
    } catch (e) {
      debugPrint('Error updating application status: $e');
      Get.snackbar('Error', 'Failed to update status');
      return false;
    }
    return true;
  }

  String _extractRejectionReason(dynamic data) {
    if (data is Map) {
      final direct = data['rejectionReason']?.toString();
      if (direct != null && direct.isNotEmpty) return direct;

      final nestedData = data['data'];
      if (nestedData is Map) {
        final nested = nestedData['rejectionReason']?.toString();
        if (nested != null && nested.isNotEmpty) return nested;
      }
    }
    return 'No rejection reason provided';
  }

  String? _extractStatus(dynamic data) {
    if (data is Map) {
      final direct = data['status']?.toString();
      if (direct != null && direct.isNotEmpty) return direct;

      final nestedData = data['data'];
      if (nestedData is Map) {
        final nested = nestedData['status']?.toString();
        if (nested != null && nested.isNotEmpty) return nested;
      }
    }
    return null;
  }

  void _showStatusDialog(String status, String reason) {
    final titleStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Updated';
    Get.dialog(
      AlertDialog(
        title: Text('Status: $titleStatus'),
        content: Text(reason),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
