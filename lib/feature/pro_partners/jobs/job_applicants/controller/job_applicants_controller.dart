import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/model/job_model.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/model/applicant_model.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicantsController extends GetxController {
  JobApplicantsController(this.job);

  final JobModel job;
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  final selectedTabIndex = 0.obs;
  final isLoadingStats = false.obs;
  final isLoadingTab = false.obs;
  final errorMessage = ''.obs;

  final totalCount = 0.obs;
  final pendingCount = 0.obs;
  final shortlistedCount = 0.obs;
  final rejectedCount = 0.obs;
  final interviewedCount = 0.obs;
  final appliedTodayCount = 0.obs;

  final pendingApplicants = <ApplicantModel>[].obs;
  final shortlistedApplicants = <ApplicantModel>[].obs;
  final rejectedApplicants = <ApplicantModel>[].obs;
  final interviewedApplicants = <ApplicantModel>[].obs;
  final updatingApplicationIds = <String>{}.obs;
  final updatingApplicationStatuses = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    errorMessage.value = '';
    await fetchStats();
    await fetchApplicantsByStatus(
      status: statusForIndex(selectedTabIndex.value),
      tabIndex: selectedTabIndex.value,
      force: true,
    );
  }

  Future<void> fetchStats() async {
    isLoadingStats.value = true;
    try {
      final response = await _networkCaller.getRequest(
        Urls.getJobStatus(job.id),
        token: await _bearerToken(),
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final data = response.responseData as Map<String, dynamic>;
        totalCount.value = _toInt(data['total']);
        pendingCount.value = _toInt(data['pending']);
        shortlistedCount.value = _toInt(data['shortlisted']);
        rejectedCount.value = _toInt(data['rejected']);
        interviewedCount.value = _toInt(data['interviewed']);
        appliedTodayCount.value = _toInt(data['appliedToday']);
      }
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> fetchApplicantsByStatus({
    required String status,
    required int tabIndex,
    bool force = false,
  }) async {
    final targetList = listForIndex(tabIndex);
    if (!force && targetList.isNotEmpty) {
      return;
    }

    isLoadingTab.value = true;
    errorMessage.value = '';

    try {
      final url = Uri.parse(
        Urls.getJobApplicants(job.id),
      ).replace(queryParameters: {'status': status}).toString();

      final response = await _networkCaller.getRequest(
        url,
        token: await _bearerToken(),
      );

      if (response.isSuccess) {
        final items = _extractApplicantItems(response.responseData);
        targetList
          ..clear()
          ..addAll(items.map(ApplicantModel.fromJson));
        return;
      }

      errorMessage.value = response.errorMessage.isEmpty
          ? 'Failed to load applicants.'
          : response.errorMessage;
    } catch (_) {
      errorMessage.value = 'Failed to load applicants.';
    } finally {
      isLoadingTab.value = false;
    }
  }

  Future<void> onTabChanged(int index) async {
    selectedTabIndex.value = index;
    await fetchApplicantsByStatus(
      status: statusForIndex(index),
      tabIndex: index,
    );
  }

  Future<void> refreshCurrentTab() async {
    await fetchStats();
    await fetchApplicantsByStatus(
      status: statusForIndex(selectedTabIndex.value),
      tabIndex: selectedTabIndex.value,
      force: true,
    );
  }

  Future<void> openResume(ApplicantModel applicant) async {
    final resumeUrl = applicant.resumeUrl.trim();
    if (resumeUrl.isEmpty) {
      Get.snackbar('Unavailable', 'No CV uploaded');
      return;
    }

    final uri = Uri.tryParse(resumeUrl);
    if (uri == null || !uri.hasScheme) {
      Get.snackbar('Error', 'Could not open CV');
      return;
    }

    final launched = await _launchUri(uri);
    if (!launched) {
      Get.snackbar('Error', 'Could not open CV');
    }
  }

  Future<void> openLinkedIn(String url) async {
    final raw = url.trim();
    if (raw.isEmpty) {
      Get.snackbar('Unavailable', 'No LinkedIn profile provided');
      return;
    }

    final normalized = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : 'https://$raw';
    final uri = Uri.tryParse(normalized);

    if (uri == null || uri.host.trim().isEmpty) {
      Get.snackbar('Error', 'Could not open LinkedIn profile');
      return;
    }

    final launched = await _launchUri(uri);
    if (!launched) {
      Get.snackbar('Error', 'Could not open LinkedIn profile');
    }
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? rejectionReason,
    bool popAfterSuccess = false,
  }) async {
    if (updatingApplicationIds.contains(applicationId)) {
      return;
    }

    updatingApplicationIds.add(applicationId);
    updatingApplicationStatuses[applicationId] = status;
    updatingApplicationIds.refresh();
    updatingApplicationStatuses.refresh();

    try {
      final response = await _networkCaller.putJsonRequest(
        Urls.updateJobForApplicants(applicationId),
        body: {
          'status': status,
          if (rejectionReason != null && rejectionReason.trim().isNotEmpty)
            'rejectionReason': rejectionReason.trim(),
        },
        token: await _bearerToken(),
      );

      if (!response.isSuccess) {
        EasyLoading.showError(
          response.errorMessage.isEmpty
              ? 'Failed to update status'
              : response.errorMessage,
        );
        return;
      }

      await _refreshAfterStatusUpdate();
      EasyLoading.showSuccess(_successMessageForStatus(status));
      if (popAfterSuccess) {
        Get.back();
      }
    } catch (_) {
      EasyLoading.showError('Failed to update status');
    } finally {
      updatingApplicationIds.remove(applicationId);
      updatingApplicationStatuses.remove(applicationId);
      updatingApplicationIds.refresh();
      updatingApplicationStatuses.refresh();
    }
  }

  RxList<ApplicantModel> listForIndex(int index) {
    final lists = [
      pendingApplicants,
      shortlistedApplicants,
      rejectedApplicants,
    ];
    return lists[index];
  }

  String statusForIndex(int index) {
    final statuses = ['pending', 'shortlisted', 'rejected'];
    return statuses[index];
  }

  String tabTitleForIndex(int index) {
    final titles = ['Applicants', 'Shortlisted', 'Rejected'];
    return titles[index];
  }

  String emptyMessageForIndex(int index) {
    final messages = [
      'No applicants are waiting for review right now.',
      'No shortlisted applicants yet.',
      'No rejected applicants yet.',
    ];
    return messages[index];
  }

  int countForIndex(int index) {
    final counts = [
      pendingCount.value,
      shortlistedCount.value,
      rejectedCount.value,
    ];
    return counts[index];
  }

  String prettyLabel(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return 'Pending';
    }

    return text
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String formatDateTime(String value) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      return value.trim();
    }

    final local = parsed.toLocal();
    final hour = local.hour == 0 || local.hour == 12 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day} ${_month(local.month)} ${local.year}, $hour:$minute $suffix';
  }

  String formatExperience(int years) {
    if (years <= 0) {
      return 'Not specified';
    }
    return years == 1 ? '1 year' : '$years years';
  }

  String applicantInitials(ApplicantModel applicant) {
    final parts = applicant.name
        .split(' ')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'A';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  Future<void> _refreshAfterStatusUpdate() async {
    pendingApplicants.clear();
    shortlistedApplicants.clear();
    rejectedApplicants.clear();
    await fetchStats();
    await fetchApplicantsByStatus(
      status: statusForIndex(selectedTabIndex.value),
      tabIndex: selectedTabIndex.value,
      force: true,
    );
  }

  Future<bool> _launchUri(Uri uri) async {
    try {
      final external = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (external) {
        return true;
      }
      return launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      return false;
    }
  }

  Future<String?> _bearerToken() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    return 'Bearer $token';
  }

  List<Map<String, dynamic>> _extractApplicantItems(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map(_toMap).toList();
    }
    if (data is Map<String, dynamic>) {
      final nested = data['data'] ?? data['applications'] ?? data['items'];
      if (nested is List) {
        return nested.whereType<Map>().map(_toMap).toList();
      }
    }
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _successMessageForStatus(String status) {
    if (status == 'shortlisted') {
      return 'Applicant shortlisted';
    }
    if (status == 'rejected') {
      return 'Applicant rejected';
    }
    return 'Applicant moved back to pending';
  }

  String _month(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
