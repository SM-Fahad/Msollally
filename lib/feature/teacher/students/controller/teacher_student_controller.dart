import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/teacher/students/model/teacher_student_enrollment_model.dart';
import 'package:msollaally/feature/teacher/students/service/teacher_student_service.dart';

class TeacherStudentController extends GetxController {
  final groupName = ''.obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final students = <TeacherStudentEnrollmentModel>[].obs;

  final TeacherStudentService _studentService = TeacherStudentService();

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetchedStudents = await _studentService.getMyStudents();
      students.assignAll(fetchedStudents);
    } catch (error) {
      students.clear();
      errorMessage.value = _extractErrorMessage(error);
      EasyLoading.showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  List<TeacherStudentEnrollmentModel> get filteredUsers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return students.toList();
    }

    return students
        .where((student) => student.searchLabel.contains(query))
        .toList();
  }

  void toggleSelection(TeacherStudentEnrollmentModel student) {
    student.isSelected.toggle();
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message;
  }
}
