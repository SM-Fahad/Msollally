import 'package:get/get.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/events/create_event/screen/create_event_screen.dart';
import '../model/event_model.dart';

class AllEventsController extends GetxController {
  final _networkCaller = NetworkCaller();
  final _prefs = SharedPreferenceHelper();

  final events = <EventModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final deletingEventIds = <String>{}.obs;
  final fetchingEventDetailIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyEvents();
  }

  Future<void> fetchMyEvents() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getMyEvent,
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        errorMessage.value = response.errorMessage;
        return;
      }

      final body = response.responseData;
      if (body is! Map<String, dynamic>) {
        events.clear();
        return;
      }

      final hostingRaw = body['hosting'];
      final hosting = hostingRaw is List ? hostingRaw : <dynamic>[];
      events.assignAll(
        hosting
            .whereType<Map<String, dynamic>>()
            .map(EventModel.fromJson)
            .toList(),
      );
    } catch (_) {
      errorMessage.value = 'Failed to load events';
    } finally {
      isLoading.value = false;
    }
  }

  void addEvent(EventModel event) {
    events.insert(0, event);
  }

  void removeEventById(String id) {
    events.removeWhere((e) => e.id == id);
  }

  Future<void> deleteEvent(String eventId) async {
    deletingEventIds.add(eventId);
    deletingEventIds.refresh();

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.deleteRequest(
        Urls.deleteEvent(eventId),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        Get.snackbar(
          'Error',
          _errorMessageForResponse(response.statusCode, response.errorMessage),
        );
        return;
      }

      removeEventById(eventId);
      Get.snackbar('Success', 'Event deleted successfully');
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete event');
    } finally {
      deletingEventIds.remove(eventId);
      deletingEventIds.refresh();
    }
  }

  Future<void> getEventByIdAndNavigateToUpdate(String eventId) async {
    fetchingEventDetailIds.add(eventId);
    fetchingEventDetailIds.refresh();

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getEventById(eventId),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        Get.snackbar(
          'Error',
          _errorMessageForResponse(response.statusCode, response.errorMessage),
        );
        return;
      }

      final eventBody = _extractEventBody(response.responseData);
      if (eventBody == null) {
        Get.snackbar('Error', 'Failed to load event details');
        return;
      }

      Get.to(
        () => CreateEventScreen(
          event: EventModel.fromJson(eventBody),
          isEdit: true,
        ),
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to load event details');
    } finally {
      fetchingEventDetailIds.remove(eventId);
      fetchingEventDetailIds.refresh();
    }
  }

  Map<String, dynamic>? _extractEventBody(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    if (body['event'] is Map<String, dynamic>) {
      return body['event'] as Map<String, dynamic>;
    }
    if (body['data'] is Map<String, dynamic>) {
      final data = body['data'] as Map<String, dynamic>;
      if (data['event'] is Map<String, dynamic>) {
        return data['event'] as Map<String, dynamic>;
      }
      return data;
    }
    return body;
  }

  String _errorMessageForResponse(int statusCode, String fallback) {
    if (statusCode == 403) return 'You are not allowed to manage this event';
    if (statusCode == 404) return 'Event not found';
    return fallback.isNotEmpty ? fallback : 'Something went wrong';
  }
}
