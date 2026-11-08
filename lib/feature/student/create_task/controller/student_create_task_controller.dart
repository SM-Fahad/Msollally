import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger_barta/logger_barta.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:msollaally/feature/student/create_task/model/student_create_task_list_model.dart';
import 'package:msollaally/feature/student/create_task/model/student_create_task_upgrade_model.dart';
import 'package:msollaally/feature/student/create_task/service/student_task_service.dart';
//import 'package:msollaally/feature/student/create_task/widgets/payment_completed_dialog.dart';
import 'package:msollaally/feature/student/converter/controller/student_file_converter_controller.dart';
import 'package:msollaally/routes/app_route.dart';

class StudentCreateTaskController extends GetxController {
  TextEditingController controllerTask = TextEditingController();
  TextEditingController controllernote = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();
  final StudentFileConverteController fileController =
      Get.isRegistered<StudentFileConverteController>(tag: 'create_task')
      ? Get.find<StudentFileConverteController>(tag: 'create_task')
      : Get.put(StudentFileConverteController(), tag: 'create_task');

  var taskListItems = <StudentCreateTaskListModel>[].obs;
  var upgradeListItems = <StudentCreateTaskUpgradeModel>[].obs;
  final isTaskLoading = false.obs;
  final isUpgradeLoading = false.obs;
  final taskErrorMessage = ''.obs;
  final upgradeErrorMessage = ''.obs;
  final isTaskDetailsLoading = false.obs;
  final taskDetailsErrorMessage = ''.obs;
  final selectedTask = Rxn<StudentCreateTaskListModel>();
  final RxnInt currentPlanId = RxnInt();
  bool _hasLoadedTasks = false;
  bool _hasLoadedSubscriptions = false;
  int? _loadedTaskId;

  final Rxn<DateTime> dateTime = Rxn<DateTime>();
  final isCreating = false.obs;
  final isDeleting = false.obs;
  final RxSet<int> updatingCompletedTaskIds = <int>{}.obs;
  final RxSet<int> updatingFavouriteTaskIds = <int>{}.obs;

  var isDiscountApplied = false.obs;
  var originalAmount = 0.0.obs;
  var discountedAmount = 0.0.obs;
  var selectedPaymentMethod = ''.obs;

  String get createButtonLabel {
    if (!isCreating.value) {
      return 'Create Tasks';
    }
    return fileController.file.value != null
        ? 'Uploading file and creating...'
        : 'Creating...';
  }

  Future<void> subscribeToPackage() async {
    final plan = getSelectedPlan();
    if (plan == null || plan.id == null) {
      EasyLoading.showError('Please select a plan');
      return;
    }

    final planId = plan.id!;
    final billingInterval = plan.selectedPrice.value?.billingInterval ?? 'monthly';

    if (isUpgradeLoading.value) return;

    try {
      isUpgradeLoading.value = true;
      upgradeErrorMessage.value = '';

      final pref = SharedPreferenceHelper();
      final token = await pref.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('Authentication token not found. Please log in.');
        return;
      }

      final url = Urls.subscribeToPackage;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'planId': planId,
          'billingInterval': billingInterval,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final paymentUrl = body['payment_url'] ?? body['paymentUrl'];
        if (paymentUrl == null || paymentUrl.toString().isEmpty) {
          EasyLoading.showError('Payment URL not found in response');
          return;
        }

        // Navigate to the custom premium webview screen
        Get.toNamed(AppRoute.premiumPaymentWebview, arguments: paymentUrl.toString());
      } else {
        upgradeErrorMessage.value = response.body;
        EasyLoading.showError('Failed to initiate subscription');
      }
    } catch (e) {
      upgradeErrorMessage.value = _extractErrorMessage(e);
      EasyLoading.showError(upgradeErrorMessage.value);
    } finally {
      isUpgradeLoading.value = false;
    }
  }

  Future<void> claimFreeTrial() async {
    if (isUpgradeLoading.value) return;
    try {
      isUpgradeLoading.value = true;
      final pref = SharedPreferenceHelper();
      final token = await pref.getAccessToken();
      if (token == null || token.isEmpty) return;

      final url = Urls.claimFreeTrial;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess(body['message'] ?? 'Free trial claimed successfully!');
        await fetchMySubscription();
      } else {
        EasyLoading.showError(body['message'] ?? 'Failed to claim free trial');
      }
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isUpgradeLoading.value = false;
    }
  }

  Future<void> cancelSubscription() async {
    if (isUpgradeLoading.value) return;
    try {
      isUpgradeLoading.value = true;
      final pref = SharedPreferenceHelper();
      final token = await pref.getAccessToken();
      if (token == null || token.isEmpty) return;

      final url = Urls.cancelSubscription;
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess(body['message'] ?? 'Subscription cancelled successfully.');
        currentPlanId.value = null;
        await fetchMySubscription();
      } else {
        EasyLoading.showError(body['message'] ?? 'Failed to cancel subscription');
      }
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isUpgradeLoading.value = false;
    }
  }

  String get formattedDateTime {
    if (dateTime.value == null) {
      return DateFormat("EEEE, dd MMMM yyyy HH:mm").format(DateTime.now());
    }
    return DateFormat("EEEE, dd MMMM yyyy HH:mm").format(dateTime.value!);
  }

  Future<void> pickDateTime(BuildContext context) async {
    // Pick date
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: dateTime.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    // Pick time
    final TimeOfDay? time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.fromDateTime(dateTime.value ?? DateTime.now()),
    );

    if (time == null) return;

    // Combine date + time
    final DateTime selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    dateTime.value = selectedDateTime;
  }

  @override
  void onInit() {
    super.onInit();
    fileController.removeFile();
    fetchSubscriptionPackages();
  }

  Future<void> fetchSubscriptionPackages({bool forceRefresh = false}) async {
    if (isUpgradeLoading.value) {
      return;
    }
    if (_hasLoadedSubscriptions && !forceRefresh) {
      return;
    }

    try {
      isUpgradeLoading.value = true;
      upgradeErrorMessage.value = '';

      final response = await http.get(
        Uri.parse(Urls.allSubscriptions),
        headers: const {'accept': '*/*'},
      );

      BartaLog.success("Subscription Packages Response: ${response.body}");

      await fetchMySubscription();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final packages = _extractSubscriptionPackages(response.body);
        final plans = packages.asMap().entries.map((entry) {
          return StudentCreateTaskUpgradeModel.fromJson(
            entry.value,
            initializedChecked: entry.key == 0,
          );
        }).toList();

        upgradeListItems.assignAll(plans);
        _hasLoadedSubscriptions = true;
        return;
      }

      throw Exception('Failed to load subscription packages');
    } catch (e) {
      upgradeErrorMessage.value = _extractErrorMessage(e);
      upgradeListItems.clear();
    } finally {
      isUpgradeLoading.value = false;
    }
  }

  Future<void> fetchMySubscription() async {
    try {
      final pref = SharedPreferenceHelper();
      final token = await pref.getAccessToken();
      if (token == null || token.isEmpty) return;

      final url = Urls.mySubscription;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['plan'] != null && body['plan']['id'] != null) {
          currentPlanId.value = body['plan']['id'] as int;
        }
      }
    } catch (e) {
      BartaLog.error("Error fetching current subscription: $e");
    }
  }

  Future<void> fetchAllTasks({bool forceRefresh = false}) async {
    if (isTaskLoading.value) {
      return;
    }
    if (_hasLoadedTasks && !forceRefresh) {
      return;
    }

    try {
      isTaskLoading.value = true;
      taskErrorMessage.value = '';

      final apiTasks = await StudentTaskService.getAllTasks();
      taskListItems.assignAll(
        apiTasks.map(StudentCreateTaskListModel.fromJson).toList(),
      );
      _hasLoadedTasks = true;
    } catch (e) {
      taskErrorMessage.value = _extractErrorMessage(e);
      taskListItems.clear();
    } finally {
      isTaskLoading.value = false;
    }
  }

  Future<void> fetchTaskDetails(int taskId, {bool forceRefresh = false}) async {
    debugPrint('fetchTaskDetails called with taskId: $taskId');
    if (taskId <= 0) {
      taskDetailsErrorMessage.value = 'Invalid task id';
      selectedTask.value = null;
      return;
    }
    if (isTaskDetailsLoading.value) {
      return;
    }
    if (!forceRefresh &&
        _loadedTaskId == taskId &&
        selectedTask.value?.id == taskId &&
        taskDetailsErrorMessage.value.isEmpty) {
      return;
    }

    try {
      isTaskDetailsLoading.value = true;
      taskDetailsErrorMessage.value = '';

      final taskDetails = await StudentTaskService.getTaskById(taskId);
      selectedTask.value = StudentCreateTaskListModel.fromJson(taskDetails);
      _loadedTaskId = taskId;
      debugPrint('Task details loaded for id: ${selectedTask.value?.id}');
    } catch (e) {
      selectedTask.value = null;
      taskDetailsErrorMessage.value = _extractErrorMessage(e);
      debugPrint('Task details load failed for id $taskId: $e');
    } finally {
      isTaskDetailsLoading.value = false;
    }
  }

  bool isFavouriteUpdating(int taskId) =>
      updatingFavouriteTaskIds.contains(taskId);

  bool isCompletedUpdating(int taskId) =>
      updatingCompletedTaskIds.contains(taskId);

  Future<void> toggleFavorite(int index) async {
    if (index < 0 || index >= taskListItems.length) {
      return;
    }

    final item = taskListItems[index];
    final taskId = item.id;
    if (taskId == null || taskId <= 0) {
      EasyLoading.showError('Task id is missing');
      return;
    }
    if (updatingFavouriteTaskIds.contains(taskId)) {
      return;
    }

    final previousValue = item.isTappedFavorite.value;
    final optimisticValue = !previousValue;
    item.isTappedFavorite.value = optimisticValue;
    _syncSelectedTaskFavourite(taskId, optimisticValue);

    updatingFavouriteTaskIds.add(taskId);
    updatingFavouriteTaskIds.refresh();

    try {
      final parsedDateTime = DateTime.tryParse(item.rawDateTime ?? '');
      final response = await StudentTaskService.toggleTaskFavourite(
        id: taskId,
        isFavourite: optimisticValue,
        task: item.title,
        note: item.note,
        dateTime: parsedDateTime ?? DateTime.now(),
      );
      final serverFavourite = _extractBoolFromResponse(
        response,
        keys: const [
          'isFavourite',
          'isfavourite',
          'isFavorite',
          'isfavorite',
          'favourite',
          'favorite',
        ],
      );
      if (serverFavourite != null) {
        item.isTappedFavorite.value = serverFavourite;
        _syncSelectedTaskFavourite(taskId, serverFavourite);
      } else {
        await fetchAllTasks(forceRefresh: true);
      }
    } catch (e) {
      item.isTappedFavorite.value = previousValue;
      _syncSelectedTaskFavourite(taskId, previousValue);
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      updatingFavouriteTaskIds.remove(taskId);
      updatingFavouriteTaskIds.refresh();
    }
  }

  Future<void> toggleCheckBox(int index) async {
    if (index < 0 || index >= taskListItems.length) {
      return;
    }

    final item = taskListItems[index];
    final taskId = item.id;
    if (taskId == null || taskId <= 0) {
      EasyLoading.showError('Task id is missing');
      return;
    }
    if (updatingCompletedTaskIds.contains(taskId)) {
      return;
    }

    final previousValue = item.isTapCheckBox.value;
    if (previousValue) {
      return;
    }

    item.isTapCheckBox.value = true;
    _syncSelectedTaskCompletion(taskId, true);

    updatingCompletedTaskIds.add(taskId);
    updatingCompletedTaskIds.refresh();

    try {
      final response = await StudentTaskService.markTaskCompleted(taskId);
      final serverCompleted = _extractBoolFromResponse(
        response,
        keys: const ['isCompleted', 'isComplete', 'completed'],
      );
      if (serverCompleted != null) {
        item.isTapCheckBox.value = serverCompleted;
        _syncSelectedTaskCompletion(taskId, serverCompleted);
      }
    } catch (e) {
      item.isTapCheckBox.value = previousValue;
      _syncSelectedTaskCompletion(taskId, previousValue);
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      updatingCompletedTaskIds.remove(taskId);
      updatingCompletedTaskIds.refresh();
    }
  }

  //upgrade

  void selectUpgradeItem(int index) {
    for (int i = 0; i < upgradeListItems.length; i++) {
      upgradeListItems[i].isChecked.value = (i == index);
    }
  }

  // for popup screen

  StudentCreateTaskUpgradeModel? getSelectedPlan() {
    try {
      return upgradeListItems.firstWhere((item) => item.isChecked.value);
    } catch (e) {
      return null;
    }
  }

  // Apply referral code

  void applyReferralCode(String code) {
    if (code == '') {
      isDiscountApplied.value = true;

      var selectedPlan = getSelectedPlan();
      if (selectedPlan != null) {
        double amount = extractAmount(selectedPlan.charge);
        originalAmount.value = amount;
        discountedAmount.value = amount * 0.5;
      }

      EasyLoading.showSuccess('50% Discount Applied ✅');
    } else {
      EasyLoading.showError('The referral code is invalid');
    }
  }

  double extractAmount(String charge) {
    final value = charge.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(value) ?? 0;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  // void processPayment() {
  //   if (selectedPaymentMethod.value.isEmpty) {
  //     EasyLoading.showError('Please select a payment method');
  //     return;
  //   }

  //   Get.back();

  //   Future.delayed(Duration(milliseconds: 500), () {
  //showPaymentCompletedDialog();
  //   });
  // }

  Future<void> createTask() async {
    final task = controllerTask.text.trim();
    final note = controllernote.text.trim();

    if (task.isEmpty) {
      EasyLoading.showError('Task cannot be empty');
      return;
    }

    if (isCreating.value) {
      return;
    }

    try {
      isCreating.value = true;

      final response = await StudentTaskService.createTask(
        task: task,
        note: note,
        dateTime: dateTime.value ?? DateTime.now(),
        file: fileController.file.value,
      );

      final message =
          response['message']?.toString() ?? 'Task created successfully';

      controllerTask.clear();
      controllernote.clear();
      dateTime.value = null;
      fileController.removeFile();

      EasyLoading.showSuccess(message);
      Get.offNamed(AppRoute.studentAllTaskList);
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> deleteTaskById(
    int taskId, {
    bool closeCurrentScreen = true,
  }) async {
    if (taskId <= 0) {
      EasyLoading.showError('Invalid task id');
      return;
    }
    if (isDeleting.value) {
      return;
    }

    try {
      isDeleting.value = true;
      EasyLoading.show(status: 'Deleting...');

      final response = await StudentTaskService.deleteTaskById(taskId);
      final message =
          response['message']?.toString() ?? 'Task deleted successfully';

      taskListItems.removeWhere((task) => task.id == taskId);
      if (selectedTask.value?.id == taskId) {
        selectedTask.value = null;
      }
      if (_loadedTaskId == taskId) {
        _loadedTaskId = null;
      }

      await fetchAllTasks(forceRefresh: true);

      await EasyLoading.dismiss();
      EasyLoading.showSuccess(message);
      if (closeCurrentScreen) {
        Get.back();
      }
    } catch (e) {
      await EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isDeleting.value = false;
    }
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  List<Map<String, dynamic>> _extractSubscriptionPackages(String responseBody) {
    if (responseBody.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final decoded = jsonDecode(responseBody);
    final dynamic packages = decoded is List ? decoded : decoded['data'];

    if (packages is! List) {
      return <Map<String, dynamic>>[];
    }

    return packages
        .whereType<Map>()
        .map((package) => Map<String, dynamic>.from(package))
        .toList(growable: false);
  }

  void _syncSelectedTaskCompletion(int taskId, bool value) {
    final detailsTask = selectedTask.value;
    if (detailsTask != null && detailsTask.id == taskId) {
      detailsTask.isTapCheckBox.value = value;
    }
  }

  void _syncSelectedTaskFavourite(int taskId, bool value) {
    final detailsTask = selectedTask.value;
    if (detailsTask != null && detailsTask.id == taskId) {
      detailsTask.isTappedFavorite.value = value;
    }
  }

  bool? _extractBoolFromResponse(
    Map<String, dynamic> response, {
    required List<String> keys,
  }) {
    final candidates = <Map<String, dynamic>>[response];
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      candidates.add(data);
      final task = data['task'];
      if (task is Map<String, dynamic>) {
        candidates.add(task);
      }
    }

    for (final map in candidates) {
      for (final key in keys) {
        final value = map[key];
        if (value is bool) {
          return value;
        }
        if (value is num) {
          return value != 0;
        }
        final asString = value?.toString().toLowerCase();
        if (asString == 'true') {
          return true;
        }
        if (asString == 'false') {
          return false;
        }
      }
    }
    return null;
  }

  @override
  void onClose() {
    controllerTask.dispose();
    controllernote.dispose();
    referralCodeController.dispose();
    super.onClose();
  }
}
