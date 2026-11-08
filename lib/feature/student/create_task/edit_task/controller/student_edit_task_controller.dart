import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/feature/student/converter/controller/student_file_converter_controller.dart';
import 'package:msollaally/feature/student/create_task/controller/student_create_task_controller.dart';
import 'package:msollaally/feature/student/create_task/service/student_task_service.dart';

class StudentEditTaskController extends GetxController {
  //edit task controller
  TextEditingController controllerEditTaskTask = TextEditingController();
  TextEditingController controllerEditTaskNote = TextEditingController();
  final isUpdating = false.obs;
  final isDeleting = false.obs;
  final StudentFileConverteController fileController =
      Get.isRegistered<StudentFileConverteController>(tag: 'edit_task')
      ? Get.find<StudentFileConverteController>(tag: 'edit_task')
      : Get.put(StudentFileConverteController(), tag: 'edit_task');
  int? taskId;

  final Rxn<DateTime> dateTime = Rxn<DateTime>();

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
    _setInitialValuesFromArgs();
    fileController.file.value = null;
  }

  void _setInitialValuesFromArgs() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final dynamic idValue = args['taskId'];
      taskId = idValue is int
          ? idValue
          : int.tryParse(idValue?.toString() ?? '');
      controllerEditTaskTask.text = (args['task'] ?? '').toString();
      controllerEditTaskNote.text = (args['note'] ?? '').toString();

      final rawDate = args['dateTime']?.toString();
      if (rawDate != null && rawDate.isNotEmpty) {
        final parsed = DateTime.tryParse(rawDate);
        if (parsed != null) {
          dateTime.value = parsed.toLocal();
        }
      }
    }
  }

  Future<void> updateTask() async {
    final id = taskId;
    if (id == null || id <= 0) {
      EasyLoading.showError('Task id missing');
      return;
    }

    final task = controllerEditTaskTask.text.trim();
    final note = controllerEditTaskNote.text.trim();

    if (task.isEmpty) {
      EasyLoading.showError('Task cannot be empty');
      return;
    }

    if (isUpdating.value) {
      return;
    }

    try {
      isUpdating.value = true;
      EasyLoading.show(
        status: fileController.file.value != null
            ? 'Uploading file and updating...'
            : 'Updating...',
      );

      final response = await StudentTaskService.updateTaskById(
        id: id,
        task: task,
        note: note,
        dateTime: dateTime.value ?? DateTime.now(),
        file: fileController.file.value,
      );

      final message = response['message']?.toString() ?? 'Task updated';

      final createTaskController =
          Get.isRegistered<StudentCreateTaskController>()
          ? Get.find<StudentCreateTaskController>()
          : null;
      await createTaskController?.fetchAllTasks(forceRefresh: true);
      await createTaskController?.fetchTaskDetails(id, forceRefresh: true);

      await EasyLoading.dismiss();
      EasyLoading.showSuccess(message);
      Get.back();
    } catch (e) {
      await EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> deleteTask() async {
    final id = taskId;
    if (id == null || id <= 0) {
      EasyLoading.showError('Task id missing');
      return;
    }
    if (isDeleting.value) {
      return;
    }

    try {
      isDeleting.value = true;
      EasyLoading.show(status: 'Deleting...');
      final response = await StudentTaskService.deleteTaskById(id);
      final message =
          response['message']?.toString() ?? 'Task deleted successfully';

      final createTaskController =
          Get.isRegistered<StudentCreateTaskController>()
          ? Get.find<StudentCreateTaskController>()
          : null;
      createTaskController?.taskListItems.removeWhere((task) => task.id == id);
      await createTaskController?.fetchAllTasks(forceRefresh: true);

      await EasyLoading.dismiss();
      EasyLoading.showSuccess(message);
      Get.back();
      Get.back();
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

  @override
  void onClose() {
    controllerEditTaskTask.dispose();
    controllerEditTaskNote.dispose();
    super.onClose();
  }
}
