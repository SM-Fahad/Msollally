import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/events/all_events/model/event_model.dart';
import 'package:msollaally/feature/student/profile/service/profile_service.dart';
import '../service/student_campus_event_service.dart';

class StudentCampusEventController extends GetxController {
  final isLoading = false.obs;
  final isLoadMore = false.obs;
  final events = <EventModel>[].obs;
  final _eventService = StudentCampusEventService();
  final _profileService = ProfileService();

  int currentPage = 1;
  bool hasMore = true;
  Map<String, dynamic>? studentProfile;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    isLoading.value = true;
    currentPage = 1;
    hasMore = true;
    try {
      if (studentProfile == null) {
        final profileRes = await _profileService.fetchMe();
        if (profileRes != null) {
          studentProfile = (profileRes['data']?['profile'] ??
              profileRes['profile'] ??
              profileRes) as Map<String, dynamic>?;
        }
      }

      final fetchedEvents =
          await _eventService.fetchEvents(page: currentPage, limit: 50);
      final filtered = fetchedEvents
          .where((e) => _matchesEvent(e, studentProfile))
          .toList();
      events.value = filtered;
      if (fetchedEvents.length < 50) {
        hasMore = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreEvents() async {
    if (isLoadMore.value || !hasMore) return;
    isLoadMore.value = true;
    try {
      currentPage++;
      final fetchedEvents =
          await _eventService.fetchEvents(page: currentPage, limit: 20);
      if (fetchedEvents.isEmpty) {
        hasMore = false;
      } else {
        final filtered = fetchedEvents
            .where((e) => _matchesEvent(e, studentProfile))
            .toList();
        events.addAll(filtered);
        if (fetchedEvents.length < 20) {
          hasMore = false;
        }
      }
    } catch (_) {
      currentPage--;
    } finally {
      isLoadMore.value = false;
    }
  }

  bool _matchesEvent(EventModel event, Map<String, dynamic>? profile) {
    if (profile == null || profile.isEmpty) return true;
    final major = event.targetMajor.trim().toLowerCase();
    if (major.isNotEmpty && major != 'all' && major != 'all departments') {
      final deptStrings = <String>[];
      void addIfValid(dynamic val) {
        if (val == null) return;
        if (val is String && val.trim().isNotEmpty) {
          deptStrings.add(val.trim().toLowerCase());
        } else if (val is Map) {
          final name = val['name'] ??
              val['title'] ??
              val['departmentName'] ??
              val['facultyName'] ??
              val['faculty'];
          if (name != null && name.toString().trim().isNotEmpty) {
            deptStrings.add(name.toString().trim().toLowerCase());
          }
        }
      }

      addIfValid(profile['faculty']);
      addIfValid(profile['department']);
      addIfValid(profile['departmentName']);
      addIfValid(profile['program']);
      addIfValid(profile['major']);

      if (deptStrings.isEmpty) {
        return false;
      }

      final normMajor = major.replaceAll(RegExp(r'[\s_\-]+'), ' ').trim();
      final matchesAny = deptStrings.any((dept) {
        final normDept = dept.replaceAll(RegExp(r'[\s_\-]+'), ' ').trim();
        return normDept == normMajor ||
            normDept.contains(normMajor) ||
            normMajor.contains(normDept);
      });

      if (!matchesAny) {
        return false;
      }
    }

    final year = event.targetYear.trim();
    if (year.isNotEmpty &&
        year != '0' &&
        year.toLowerCase() != 'all' &&
        year.toLowerCase() != 'all years') {
      final studYear = (profile['enrollmentYear'] ??
              profile['year'] ??
              profile['yearOfStudy'] ??
              '')
          .toString()
          .trim();
      if (studYear.isNotEmpty && studYear != year) {
        return false;
      }
    }
    return true;
  }
}
