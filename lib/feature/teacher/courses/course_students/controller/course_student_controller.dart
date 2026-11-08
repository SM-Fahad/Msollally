import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/teacher/courses/course_module/controller/course_module_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_students/model/course_group_model.dart';
import 'package:msollaally/feature/teacher/courses/course_students/model/course_student_chat_model.dart';
import 'package:msollaally/feature/teacher/courses/course_students/service/course_student_service.dart';
import 'package:msollaally/feature/teacher/courses/model/teacher_course_model.dart';

class CourseStudentController extends GetxController {
  final selectedTab = 0.obs;
  final currentCourseId = 0.obs;
  final isLoading = false.obs;
  final isSavingGroup = false.obs;
  final searchQuery = ''.obs;
  final allChats = <CourseStudentChatModel>[].obs;
  final studentChats = <CourseStudentChatModel>[].obs;
  final groupChats = <CourseStudentChatModel>[].obs;
  final groups = <CourseGroupModel>[].obs;

  final CourseStudentService _studentService = CourseStudentService();

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void initialize(dynamic args) {
    final nextCourseId = _resolveCourseId(args);
    if (nextCourseId == 0) {
      return;
    }

    final hasCourseChanged = currentCourseId.value != nextCourseId;
    currentCourseId.value = nextCourseId;

    if (hasCourseChanged) {
      allChats.clear();
      studentChats.clear();
      groupChats.clear();
      groups.clear();
    }

    if (hasCourseChanged || allChats.isEmpty) {
      fetchCourseStudents();
    }
  }

  Future<void> fetchCourseStudents() async {
    if (currentCourseId.value == 0 || isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final students = await _studentService.getCourseStudents(
        currentCourseId.value,
      );
      studentChats.assignAll(students);

      try {
        final fetchedGroups = await _studentService.getCourseGroups(
          currentCourseId.value,
        );
        groups.assignAll(fetchedGroups);
        groupChats.assignAll(fetchedGroups.map(_mapGroupToChatModel).toList());
      } catch (_) {
        groups.clear();
        groupChats.clear();
      }

      allChats.assignAll([...studentChats, ...groupChats]);
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  List<CourseStudentChatModel> get filteredChats {
    final selected = selectedTab.value;
    final source = selected == 0
        ? allChats
        : selected == 1
        ? studentChats
        : groupChats;
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return source.toList();
    }
    return source
        .where(
          (chat) =>
              chat.name.toLowerCase().contains(query) ||
              chat.lastMessage.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<bool> createGroup({
    required String name,
    required List<int> memberIds,
  }) async {
    if (currentCourseId.value == 0 || isSavingGroup.value) {
      return false;
    }

    isSavingGroup.value = true;
    try {
      await _studentService.createCourseGroup(
        courseId: currentCourseId.value,
        name: name,
        memberIds: memberIds,
      );
      EasyLoading.showSuccess('Group created');
      await fetchCourseStudents();
      changeTab(2);
      return true;
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
      return false;
    } finally {
      isSavingGroup.value = false;
    }
  }

  Future<CourseGroupModel?> getGroupById(int groupId) async {
    try {
      return await _studentService.getCourseGroupById(groupId);
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
      return null;
    }
  }

  Future<bool> updateGroup({
    required int groupId,
    required String name,
    required List<int> memberIds,
  }) async {
    if (isSavingGroup.value) {
      return false;
    }

    isSavingGroup.value = true;
    try {
      await _studentService.updateCourseGroup(
        groupId: groupId,
        name: name,
        memberIds: memberIds,
      );
      EasyLoading.showSuccess('Group updated');
      await fetchCourseStudents();
      return true;
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
      return false;
    } finally {
      isSavingGroup.value = false;
    }
  }

  Future<void> deleteGroup(int groupId) async {
    if (isSavingGroup.value) {
      return;
    }

    isSavingGroup.value = true;
    try {
      await _studentService.deleteCourseGroup(groupId);
      EasyLoading.showSuccess('Group deleted');
      await fetchCourseStudents();
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isSavingGroup.value = false;
    }
  }

  CourseGroupModel? findGroupByChat(CourseStudentChatModel chat) {
    if (!chat.isGroup) {
      return null;
    }

    return groups.firstWhereOrNull(
      (group) =>
          group.id == chat.id ||
          (chat.chatId != null && group.chatId == chat.chatId),
    );
  }

  CourseStudentChatModel _mapGroupToChatModel(CourseGroupModel group) {
    final updatedAt = group.updatedAt ?? group.createdAt;
    return CourseStudentChatModel(
      id: group.id,
      chatId: group.chatId,
      courseId: group.courseId,
      studentId: 0,
      name: group.name,
      phoneNumber: '',
      status: 'group',
      progress: 0,
      grade: null,
      enrolledAt: updatedAt,
      lastMessage: group.memberLabel,
      time: CourseStudentChatModel.formatDisplayTime(updatedAt),
      avatar: group.avatar,
      isGroup: true,
      recieverId: group.id,
    );
  }

  int _resolveCourseId(dynamic args) {
    final moduleController = Get.isRegistered<CourseModuleController>()
        ? Get.find<CourseModuleController>()
        : null;

    final selectedCourseId = moduleController?.selectedCourse.value?.id ?? 0;
    if (selectedCourseId != 0) {
      return selectedCourseId;
    }

    if (args is TeacherCourseModel) {
      return args.id;
    }

    if (args is Map<String, dynamic>) {
      if (args['course'] is TeacherCourseModel) {
        return (args['course'] as TeacherCourseModel).id;
      }
      return _parseInt(args['courseId']);
    }

    return 0;
  }

  int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Failed to load students.';
    }
    return message;
  }
}
