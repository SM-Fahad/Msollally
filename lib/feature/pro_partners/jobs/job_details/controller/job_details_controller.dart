import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/model/job_model.dart';

class JobDetailsController extends GetxController {
  JobDetailsController(this.initialJob);

  final JobModel initialJob;
  final _networkCaller = NetworkCaller();
  final _prefs = SharedPreferenceHelper();

  final isLoading = true.obs;
  final updatingStatus = false.obs;
  final errorMessage = ''.obs;
  late final Rx<JobModel> details = initialJob.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJobDetails();
  }

  Future<void> fetchJobDetails() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getJob(initialJob.id),
        token: token == null || token.isEmpty ? null : 'Bearer $token',
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        details.value = JobModel.fromJson(
          response.responseData as Map<String, dynamic>,
        );
      } else {
        errorMessage.value = response.errorMessage.isEmpty
            ? 'Failed to load job details'
            : response.errorMessage;
      }
    } catch (_) {
      errorMessage.value = 'Failed to load job details';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateJobStatus(String status) async {
    try {
      updatingStatus.value = true;

      final token = await _prefs.getAccessToken();

      final response = await _networkCaller.putJsonRequest(
        Urls.updateJobStatus(details.value.id),
        body: <String, dynamic>{'status': status},
        token: token == null || token.isEmpty ? null : 'Bearer $token',
      );

      if (response.isSuccess) {
        if (response.responseData is Map<String, dynamic>) {
          details.value = JobModel.fromJson(
            response.responseData as Map<String, dynamic>,
          );
        } else {
          await fetchJobDetails();
        }

        Get.snackbar(
          'Success',
          'Job status updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage.isEmpty
              ? 'Failed to update status'
              : response.errorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to update status',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      updatingStatus.value = false;
    }
  }

  String prettyLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    return trimmed
        .replaceAll('_', ' ')
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
  }

  String formatDate(String value) {
    if (_isBlank(value)) return '';
    final dt = DateTime.tryParse(value);
    if (dt == null) return value;
    return DateFormat('dd MMM yyyy').format(dt.toLocal());
  }

  String formatSalary() {
    final job = details.value;
    final min = _parseAmount(job.minimumSalary);
    final max = _parseAmount(job.maximumSalary);
    final unit = prettyLabel(job.salaryType);

    if (min == null && max == null) return '';

    final unitSuffix = unit.isEmpty ? '' : ' / $unit';
    if (min != null && max != null) {
      return 'TZS ${_money(min)} - TZS ${_money(max)}$unitSuffix';
    }
    if (min != null) {
      return 'From TZS ${_money(min)}$unitSuffix';
    }
    return 'Up to TZS ${_money(max!)}$unitSuffix';
  }

  String formatExperience() {
    final job = details.value;
    if (job.experienceLevel.toLowerCase() == 'other' &&
        job.otherExperienceLevel.isNotEmpty) {
      return job.otherExperienceLevel;
    }
    final min = job.minimumExperience > 0 ? job.minimumExperience : null;
    final max = job.maximumExperience > 0 ? job.maximumExperience : null;

    if (min != null && max != null) {
      return '$min-$max years';
    }
    if (min != null) {
      return '$min+ years';
    }
    if (max != null) {
      return 'Up to $max years';
    }
    if (job.otherExperienceLevel.isNotEmpty) {
      return job.otherExperienceLevel;
    }
    return '';
  }

  bool hasValue(String? value) => !_isBlank(value);

  bool _isBlank(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty || text.toLowerCase() == 'n/a' || text == 'null';
  }

  int? _parseAmount(String value) {
    final cleaned = value.replaceAll(',', '').trim();
    if (_isBlank(cleaned)) return null;
    return int.tryParse(cleaned);
  }

  String _money(int value) => NumberFormat('#,###').format(value);
}
