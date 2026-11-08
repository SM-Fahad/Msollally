import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import '../model/post_model.dart';

class EventOverviewController extends GetxController {
  EventOverviewController({this.eventId});

  final int? eventId;
  final _networkCaller = NetworkCaller();
  final _prefs = SharedPreferenceHelper();
  static const List<String> attendeeStatuses = [
    'all',
    'pending',
    'approved',
    'rejected',
    'cancelled',
    'attended',
  ];

  // Analytics values
  final views = 0.obs;
  final rsvps = 0.obs;
  final shares = 0.obs;
  final conversion = 0.0.obs;
  final isAnalyticsLoading = false.obs;
  final analyticsError = ''.obs;

  final eventCards = <Map<String, dynamic>>[].obs;

  final posts = <PostModel>[].obs;
  final attendees = <Map<String, dynamic>>[].obs;
  final selectedAttendeeStatus = 'all'.obs;
  final isAttendeesLoading = false.obs;
  final attendeeActionIds = <String>{}.obs;
  final attendeesError = ''.obs;

  // Draft state for create-post
  final TextEditingController draftController = TextEditingController();
  final pickedFilePath = RxnString(); // local path
  final pickedFileType = RxnString(); // 'image' or 'video'

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
    fetchAttendees();
    _loadSampleEventCard();
    _loadSamplePosts();
  }

  Future<void> fetchAttendees({String? status}) async {
    if (eventId == null) {
      attendees.clear();
      attendeesError.value = 'Event ID not found';
      return;
    }

    final nextStatus = status ?? selectedAttendeeStatus.value;
    selectedAttendeeStatus.value = nextStatus;
    isAttendeesLoading.value = true;
    attendeesError.value = '';

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getEventAttendees(
          eventId.toString(),
          nextStatus == 'all' ? '' : nextStatus,
        ),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        attendees.clear();
        attendeesError.value = response.errorMessage;
        return;
      }

      attendees.assignAll(_extractAttendees(response.responseData));
    } catch (_) {
      attendees.clear();
      attendeesError.value = 'Failed to load attendees';
    } finally {
      isAttendeesLoading.value = false;
    }
  }

  Future<void> updateAttendeeStatus({
    required String attendeeId,
    required String action,
  }) async {
    if (eventId == null) {
      Get.snackbar('Error', 'Event ID not found');
      return;
    }

    attendeeActionIds.add(attendeeId);
    attendeeActionIds.refresh();

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.postJsonRequest(
        Urls.updateStatusForAttendee(eventId.toString(), attendeeId),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
        body: {'action': action},
      );

      if (!response.isSuccess) {
        Get.snackbar('Error', response.errorMessage);
        return;
      }

      Get.snackbar('Success', 'Attendee ${action}d successfully');
      await fetchAttendees(status: selectedAttendeeStatus.value);
    } catch (_) {
      Get.snackbar('Error', 'Failed to update attendee status');
    } finally {
      attendeeActionIds.remove(attendeeId);
      attendeeActionIds.refresh();
    }
  }

  String buildAttendeeName(Map<String, dynamic> attendee) {
    final user = _asMap(attendee['user']);
    final profile = _asMap(user['profile']);
    final firstName = _firstNonEmpty([
      attendee['firstName'],
      profile['firstName'],
      user['firstName'],
    ]);
    final lastName = _firstNonEmpty([
      attendee['lastName'],
      profile['lastName'],
      user['lastName'],
    ]);
    final fullName = [firstName, lastName].where((e) => e.isNotEmpty).join(' ');
    return _firstNonEmpty([
      attendee['fullName'],
      profile['fullName'],
      user['fullName'],
      fullName,
      user['username'],
      attendee['name'],
      profile['name'],
      user['name'],
    ], fallback: 'Unknown Attendee');
  }

  String buildAttendeeMeta(Map<String, dynamic> attendee) {
    final user = _asMap(attendee['user']);
    final profile = _asMap(user['profile']);
    final parts =
        [
              attendee['department'],
              attendee['faculty'],
              attendee['designation'],
              attendee['program'],
              profile['department'],
              profile['faculty'],
              profile['designation'],
              profile['program'],
              profile['companyName'],
            ]
            .map((e) => e?.toString().trim() ?? '')
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();
    return parts.join(' · ');
  }

  String? attendeeProfileImage(Map<String, dynamic> attendee) {
    final user = _asMap(attendee['user']);
    final profile = _asMap(user['profile']);
    final value = _firstNonEmpty([
      attendee['profilePicture'],
      attendee['profileImage'],
      attendee['avatar'],
      profile['profilePicture'],
      profile['profileImage'],
      profile['avatar'],
      user['profilePicture'],
      user['profileImage'],
      user['avatar'],
    ]);
    return value.isEmpty ? null : value;
  }

  String attendeeStatus(Map<String, dynamic> attendee) {
    return _firstNonEmpty(
      [attendee['status'], attendee['attendeeStatus']],
      fallback: selectedAttendeeStatus.value == 'all'
          ? 'pending'
          : selectedAttendeeStatus.value,
    );
  }

  String attendeeId(Map<String, dynamic> attendee) {
    return _firstNonEmpty([
      attendee['id'],
      attendee['_id'],
      attendee['attendeeId'],
      attendee['userId'],
    ]);
  }

  String attendeeMetaInfo(Map<String, dynamic> attendee) {
    final profile = _asMap(_asMap(attendee['user'])['profile']);
    final checkedInAt = _formatAttendeeDate(attendee['checkedInAt']);
    if (checkedInAt.isNotEmpty) {
      return 'Checked in $checkedInAt';
    }

    final registeredAt = _formatAttendeeDate(
      attendee['registeredAt'] ?? attendee['createdAt'],
    );
    if (registeredAt.isNotEmpty) {
      return 'Registered $registeredAt';
    }

    return _firstNonEmpty([profile['companyName'], profile['company']]);
  }

  bool attendeeIsVerified(Map<String, dynamic> attendee) {
    final profile = _asMap(_asMap(attendee['user'])['profile']);
    final value =
        attendee['isVerified'] ?? profile['isVerified'] ?? attendee['verified'];
    return value == true;
  }

  List<Map<String, dynamic>> _extractAttendees(dynamic body) {
    final rawList = _findAttendeeList(body);
    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<dynamic> _findAttendeeList(dynamic value) {
    if (value is List) return value;
    if (value is! Map) return const [];

    final candidates = [
      value['data'],
      value['attendees'],
      value['results'],
      value['items'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) return candidate;
      if (candidate is Map) {
        final nested = _findAttendeeList(candidate);
        if (nested.isNotEmpty) return nested;
      }
    }

    return const [];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  String _firstNonEmpty(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return fallback;
  }

  String _formatAttendeeDate(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return '';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
  }

  Future<void> fetchAnalytics() async {
    if (eventId == null) {
      analyticsError.value = 'Event ID not found';
      return;
    }

    isAnalyticsLoading.value = true;
    analyticsError.value = '';

    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getEventAnalyticById(eventId!),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        analyticsError.value = response.errorMessage;
        return;
      }

      final body = response.responseData;
      if (body is! Map<String, dynamic>) {
        analyticsError.value = 'Invalid analytics response';
        return;
      }

      views.value = _toInt(body['totalViews']);
      rsvps.value = _toInt(body['totalRsvps']);
      shares.value = _toInt(body['totalShares']);
      conversion.value = _toDouble(body['conversionRate']);
    } catch (_) {
      analyticsError.value = 'Failed to load analytics';
    } finally {
      isAnalyticsLoading.value = false;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _loadSampleEventCard() {
    eventCards.assignAll([
      {
        'title': 'Tech Innovation Workshop',
        'date': '2025-02-15 at 2:00 PM',
        'location': 'Virtual',
        'rsvps': 1247,
        'description':
            'Join us for an exciting workshop on the latest tech innovations!',
        'cohosts': 'Sarah Johnson, Mike Chen',
      },
    ]);
  }

  void _loadSamplePosts() {
    posts.assignAll([
      PostModel(
        id: 'p1',
        authorName: 'TechCorp',
        authorInitials: 'TC',
        roleLabel: 'Partner',
        body:
            "Excited to share our tech workshop agenda! We'll be covering AI, machine learning, and the future of technology. Can't wait to see everyone 🚀",
        imageUrl: 'https://placehold.co/600x300',
        likes: 12,
        comments: 5,
        shares: 2,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
      PostModel(
        id: 'p2',
        authorName: 'Sarah Chen',
        authorInitials: 'SC',
        body:
            'Looking forward to this workshop! Any specific prerequisites or things we should prepare beforehand?',
        likes: 12,
        comments: 5,
        shares: 2,
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
      ),
    ]);
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        pickedFilePath.value = file.path;
        pickedFileType.value = 'image';
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
      if (file != null) {
        pickedFilePath.value = file.path;
        pickedFileType.value = 'video';
      }
    } catch (e) {
      // ignore
    }
  }

  void clearDraft() {
    draftController.clear();
    pickedFilePath.value = null;
    pickedFileType.value = null;
  }

  void addPostFromDraft() {
    final text = draftController.text.trim();
    if (text.isEmpty && pickedFilePath.value == null) return;

    final newPost = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'You',
      authorInitials: 'YOU',
      body: text.isEmpty && pickedFileType.value == 'video'
          ? 'Shared a video'
          : text,
      imageUrl: pickedFilePath.value,
      likes: 0,
      comments: 0,
      shares: 0,
      createdAt: DateTime.now(),
    );

    posts.insert(0, newPost);
    clearDraft();
  }

  void addPost(PostModel post) {
    posts.insert(0, post);
  }

  @override
  void onClose() {
    draftController.dispose();
    super.onClose();
  }
}
