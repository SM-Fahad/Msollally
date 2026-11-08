import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../../../../routes/app_route.dart';
import '../../../navbar/controller/navbar_controller.dart';
import '../../../navbar/model/navbar_item.dart';
import '../../academics/courses/academic_courses/model/academic_course_model.dart';
import '../../academics/courses/academic_courses/service/academic_course_service.dart';
import 'package:msollaally/feature/teacher/schedule_classes/model/class_schedule_model.dart';
import 'package:msollaally/feature/teacher/schedule_classes/service/class_schedule_service.dart';
import '../../campus/chat/repository/student_chat_repository.dart';
import '../../campus/chat/screen/chat_screen.dart';
import '../../create_task/controller/student_create_task_controller.dart';
import '../model/community_model.dart';
import '../model/for_you_model.dart';
import '../model/todays_quick_picks_model.dart';
import '../model/upcomming_reminder.dart';
import 'package:msollaally/feature/student/career/find_jobs/controller/jobs.controller.dart';
import 'package:msollaally/feature/student/career/find_jobs/screen/job_details_screen.dart';
import 'package:msollaally/feature/student/campus/event/controller/student_campus_event_controller.dart';


class StudentHomeController extends GetxController {
  final StudentCreateTaskController _taskController =
      Get.isRegistered<StudentCreateTaskController>()
      ? Get.find<StudentCreateTaskController>()
      : Get.put(StudentCreateTaskController());

  var dashboardClasses = <StudentCourseDashboardItem>[].obs;
  var upcomingClass = Rxn<ClassScheduleModel>();
  var isLoadingDashboard = false.obs;

  //community
  var community = <CommunityModel>[].obs;

  //for you
  var forYou = <ForYouModel>[].obs;

  late final JobController _jobController;
  late final StudentCampusEventController _eventController;

  //todays quick pics
  List<TodaysQuickPicksModel> todaysQuickPick = <TodaysQuickPicksModel>[].obs;

  //up comming reminder
  List<UpcommingReminderModel> upcommingReminder =
      <UpcommingReminderModel>[].obs;

  // enrolled courses
  var enrolledCourses = <AcademicCourse>[].obs;
  var isLoadingCourses = false.obs;
  var isLoadingAll = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initForYouList();

    // Fetch real tasks from backend
    _taskController.fetchAllTasks(forceRefresh: true);

    // Listen to changes in task list to update todaysQuickPick dynamically
    ever(_taskController.taskListItems, (_) {
      _updateTodaysQuickPicks();
    });

    // Initial sync
    refreshAll();
  }

  /// Pull-to-refresh: re-fetches all data on the home screen.
  Future<void> refreshAll() async {
    isLoadingAll.value = true;
    await Future.wait([
      fetchDashboardData(),
      fetchCommunityChats(),
      fetchEnrolledCourses(),
      _taskController.fetchAllTasks(forceRefresh: true),
    ]);
    _updateTodaysQuickPicks();
    isLoadingAll.value = false;
  }

  void _initForYouList() {
    _jobController = Get.isRegistered<JobController>()
        ? Get.find<JobController>()
        : Get.put(JobController());

    _eventController = Get.isRegistered<StudentCampusEventController>()
        ? Get.find<StudentCampusEventController>()
        : Get.put(StudentCampusEventController());

    // Listen to changes in both controllers to update forYou list dynamically
    ever(_jobController.allJobs, (_) => _buildDynamicForYouList());
    ever(_eventController.events, (_) => _buildDynamicForYouList());

    // Initial build
    _buildDynamicForYouList();
  }

  void _buildDynamicForYouList() {
    final List<ForYouModel> items = [];

    // 1. Study Tip (AI Study Tips route)
    items.add(ForYouModel(
      icon: IconsPath.studyTipsIcon,
      title: "Study Tip",
      subtitle: "Based on your recent quiz, review Chapter 5 on Object-Oriented Programming.",
      onTap: () {
        Get.toNamed(AppRoute.studentAITipsPage);
      },
    ));

    // 2. Career Opportunities (Dynamic from JobController)
    if (_jobController.allJobs.isNotEmpty) {
      final jobsCount = _jobController.allJobs.length > 2 ? 2 : _jobController.allJobs.length;
      for (int i = 0; i < jobsCount; i++) {
        final job = _jobController.allJobs[i];
        items.add(ForYouModel(
          icon: IconsPath.careerOpportunityIcon,
          title: "Career Opportunity",
          subtitle: "New: ${job.title} at ${job.company} (${job.location}). Apply now!",
          onTap: () {
            Get.to(() => JobDetailsScreen(jobId: job.id));
          },
        ));
      }
    } else {
      items.add(ForYouModel(
        onTap: () {
          if (Get.isRegistered<NavbarController>(tag: UserProfile.student.name)) {
            Get.find<NavbarController>(tag: UserProfile.student.name).changeTab(3);
          } else {
            Get.toNamed(AppRoute.studentCareer);
          }
        },
        icon: IconsPath.careerOpportunityIcon,
        title: "Career Opportunity",
        subtitle: "New Internship at TechCorp: Software Development. Apply now!",
      ));
    }

    // 3. Library Renovation Update (Academic tab)
    items.add(ForYouModel(
      onTap: () {
        if (Get.isRegistered<NavbarController>(tag: UserProfile.student.name)) {
          Get.find<NavbarController>(tag: UserProfile.student.name).changeTab(1);
        } else {
          Get.toNamed(AppRoute.studentAcademics);
        }
      },
      icon: IconsPath.libraryRenovationUpdateIcon,
      title: "Library Renovation Update",
      subtitle: "Library hours extended for exam season starting next week.",
    ));

    // 4. Event Suggestions (Dynamic from StudentCampusEventController)
    if (_eventController.events.isNotEmpty) {
      final eventsCount = _eventController.events.length > 2 ? 2 : _eventController.events.length;
      for (int i = 0; i < eventsCount; i++) {
        final event = _eventController.events[i];
        items.add(ForYouModel(
          icon: IconsPath.eventSuggestionIcon,
          title: "Event Suggestion",
          subtitle: "${event.title} at ${event.location}. RSVP now!",
          onTap: () {
            Get.toNamed(
              AppRoute.studentCampusEventDetail,
              arguments: {
                'id': event.id,
                'title': event.title,
                'tag': event.status,
                'date': DateFormat('yyyy-MM-dd, hh:mm a').format(event.dateTime.toLocal()),
                'location': event.location,
                'rsvps': event.rsvps.toString(),
                'views': '${event.views} views',
                'description': event.description,
              },
            );
          },
        ));
      }
    } else {
      items.add(ForYouModel(
        onTap: () {
          if (Get.isRegistered<NavbarController>(tag: UserProfile.student.name)) {
            Get.find<NavbarController>(tag: UserProfile.student.name).changeTab(2);
          } else {
            Get.toNamed(AppRoute.studentCampus);
          }
        },
        icon: IconsPath.eventSuggestionIcon,
        title: "Event Suggestion",
        subtitle: """Guest lecture on "AI Ethics" next Tuesday. RSVP now!""",
      ));
    }

    forYou.assignAll(items);
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoadingDashboard.value = true;
      final items = await AcademicCourseService.getStudentDashboard();

      // Filter for classes
      final classes = items
          .where((e) => e.type.toLowerCase() == 'class')
          .toList();
      dashboardClasses.assignAll(classes);

      // Fetch upcoming schedule for Quick Pick and Reminders
      try {
        final schedules = await ClassScheduleService().getSchedules();
        final now = DateTime.now();
        final upcoming = schedules
            .where((s) => s.endDateTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
          
        upcomingClass.value = upcoming.firstOrNull;
        
        if (upcoming.isNotEmpty) {
          upcommingReminder.clear();
          for (int i = 0; i < upcoming.length; i++) {
            final s = upcoming[i];
            int daysAway = s.startDateTime.difference(DateTime.now()).inDays;
            if (daysAway < 0) daysAway = 0;
            
            upcommingReminder.add(
              UpcommingReminderModel(
                title: s.title,
                icon: IconsPath.calenderNodMac,
                day: daysAway,
                containercolor: i % 2 == 0
                    ? AppColors.createTaskButtonColorHomePage
                    : AppColors.upcomingReminderContainerColor2,
                containerBorderborderColor: i % 2 == 0
                    ? AppColors.createTaskButtonBorderColorHomePage
                    : AppColors.upcomingReminderContainerborderColor2,
              ),
            );
          }
        } else {
          upcommingReminder.clear();
        }
      } catch (e) {
        debugPrint('Failed to fetch class schedule: $e');
        upcommingReminder.clear();
      }
    } catch (e) {
      debugPrint("Error fetching student dashboard: $e");
      upcommingReminder.clear();
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  void _updateTodaysQuickPicks() {
    // Take the first 2 tasks (incomplete or completed) so they stay visible
    final tasks = _taskController.taskListItems.take(2).toList();

    todaysQuickPick.clear();
    for (var task in tasks) {
      todaysQuickPick.add(
        TodaysQuickPicksModel(
          title: task.title,
          initialChecked: task.isTapCheckBox.value,
          taskId: task.id,
        ),
      );
    }

    // If no tasks found, show fallback items
    if (todaysQuickPick.isEmpty) {
      todaysQuickPick.assignAll([
        TodaysQuickPicksModel(
          title: 'Submit Physics Lab Report',
          initialChecked: false,
        ),
        TodaysQuickPicksModel(
          title: 'Read Chapter 4 for Sociology',
          initialChecked: false,
        ),
      ]);
    }
  }

  Future<void> toggleTask(TodaysQuickPicksModel item) async {
    if (item.taskId == null) return;

    // Find index of this task in taskController
    final index = _taskController.taskListItems.indexWhere(
      (t) => t.id == item.taskId,
    );
    if (index != -1) {
      await _taskController.toggleCheckBox(index);
      _updateTodaysQuickPicks();
    }
  }

  Future<void> fetchCommunityChats() async {
    try {
      final repository = StudentChatRepository();
      final allRooms = await repository.getChats();

      // Show group rooms, or fallback to active initiated chats if groups are empty
      final groupRooms = allRooms.where((r) => r.isGroup).toList();
      final roomsToShow = groupRooms.isNotEmpty ? groupRooms : allRooms;

      if (roomsToShow.isNotEmpty) {
        community.clear();
        for (final room in roomsToShow) {
          final roomName = room.name.trim().isNotEmpty
              ? room.name.trim()
              : (room.participants.isNotEmpty
                  ? room.participants.first.user.displayName
                  : 'Student Chat');

          community.add(
            CommunityModel(
              ontap: () {
                Get.to(
                  () => CampusChatScreen(),
                  arguments: <String, dynamic>{
                    'chatId': room.id,
                    'chatName': roomName,
                    'isGroup': room.isGroup,
                  },
                );
              },
              icon: roomName.toLowerCase().contains('chess')
                  ? IconsPath.chessClubIcon
                  : IconsPath.physicsStudyGroupIcon,
              text: roomName,
              days: 1,
            ),
          );
        }
      } else {
        community.clear();
      }
    } catch (e) {
      debugPrint("Error fetching community chats: $e");
      community.clear();
    }
  }

  Future<void> fetchEnrolledCourses() async {
    try {
      isLoadingCourses.value = true;
      final response = await AcademicCourseService.getMyEnrolledCourses();
      if (response.courses != null) {
        enrolledCourses.assignAll(response.courses!);
      }
    } catch (e) {
      debugPrint("Error fetching enrolled courses: $e");
    } finally {
      isLoadingCourses.value = false;
    }
  }
}
