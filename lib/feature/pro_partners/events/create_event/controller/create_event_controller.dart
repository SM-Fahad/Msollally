import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import '../../all_events/controller/all_events_controller.dart';
import '../../all_events/model/event_model.dart';

class CreateEventController extends GetxController {
  CreateEventController({this.event, this.isEdit = false});

  final EventModel? event;
  final bool isEdit;
  final _networkCaller = NetworkCaller();
  final _prefs = SharedPreferenceHelper();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final quill.QuillController quillController = quill.QuillController.basic();
  final locationController = TextEditingController();
  final onlineLinkController = TextEditingController();
  final maxAttendeesController = TextEditingController();
  final tagInputController = TextEditingController();
  final otherEventTypeController = TextEditingController();
  final otherTargetMajorController = TextEditingController();

  final startDateTime = Rxn<DateTime>();
  final endDateTime = Rxn<DateTime>();

  final eventType = ''.obs;
  final targetMajor = 'All'.obs;
  final targetYear = ''.obs;

  final guestGroupEnabled = false.obs;
  final isPublic = true.obs;
  final requiresApproval = false.obs;
  final isSubmitting = false.obs;

  final coverImagePath = RxnString();
  final selectedMediaType = RxnString(); // image, video, audio
  final uploadedCoverImageUrl = RxnString();

  final videoClipPath = RxnString();
  final uploadedVideoUrl = RxnString();
  final isUploadingVideo = false.obs;
  final videoUrlController = TextEditingController();

  final selectedCoHostIds = <int>[].obs;
  final selectedCoHosts = <Map<String, dynamic>>[].obs;
  final tags = <String>[].obs;
  final coHostSearchQuery = ''.obs;
  final coHostSearchLoading = false.obs;
  final coHostSearchResults = <Map<String, dynamic>>[].obs;
  Timer? _coHostSearchDebounce;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    quillController.addListener(() {
      final plain = quillController.document.toPlainText().trim();
      if (descriptionController.text != plain) {
        descriptionController.text = plain;
      }
    });
    _prefillIfNeeded();
  }

  void setStartDateTime(DateTime d) {
    startDateTime.value = d;
    if (endDateTime.value != null && endDateTime.value!.isBefore(d)) {
      endDateTime.value = d.add(Duration(hours: 1));
    }
  }

  void setEndDateTime(DateTime d) => endDateTime.value = d;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final ext = (file.extension ?? '').toLowerCase();
    coverImagePath.value = file.path;
    uploadedCoverImageUrl.value = null;

    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
      selectedMediaType.value = 'video';
    } else if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(ext)) {
      selectedMediaType.value = 'audio';
    } else {
      selectedMediaType.value = 'image';
    }

    await _uploadMediaImmediately();
  }

  Future<void> _uploadMediaImmediately() async {
    final path = coverImagePath.value;
    if (path == null || path.isEmpty) return;
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) return;

    final url = await _uploadPath(path);

    if (url != null) {
      uploadedCoverImageUrl.value = url;
    } else {
      clearCover();
    }
  }

  void clearCover() {
    coverImagePath.value = null;
    uploadedCoverImageUrl.value = null;
    selectedMediaType.value = null;
  }

  Future<void> pickVideoClip() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'webm'],
        withData: false,
      );
    } catch (_) {
      result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: false,
      );
    }
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    videoClipPath.value = file.path;
    uploadedVideoUrl.value = null;

    if (file.path != null && file.path!.isNotEmpty) {
      isUploadingVideo.value = true;
      try {
        final url = await _uploadPath(file.path!);
        if (url != null) {
          uploadedVideoUrl.value = url;
          videoUrlController.text = url;
        }
      } finally {
        isUploadingVideo.value = false;
      }
    }
  }

  void clearVideoClip() {
    videoClipPath.value = null;
    uploadedVideoUrl.value = null;
    videoUrlController.clear();
  }

  void toggleCoHost(Map<String, dynamic> user) {
    final int? id = user['id'] as int?;
    if (id == null) return;
    final exists = selectedCoHostIds.contains(id);
    if (exists) {
      selectedCoHostIds.remove(id);
      selectedCoHosts.removeWhere((u) => u['id'] == id);
    } else {
      selectedCoHostIds.add(id);
      selectedCoHosts.add(user);
    }
    selectedCoHostIds.refresh();
    selectedCoHosts.refresh();
  }

  bool isSelectedCoHost(int id) => selectedCoHostIds.contains(id);

  void addTagFromInput() {
    final tag = tagInputController.text.trim();
    if (tag.isEmpty) return;
    if (tags.contains(tag)) {
      tagInputController.clear();
      return;
    }
    tags.add(tag);
    tagInputController.clear();
  }

  void removeTag(String tag) {
    tags.remove(tag);
    tags.refresh();
  }

  void onCoHostSearchChanged(String value) {
    coHostSearchQuery.value = value;
    _coHostSearchDebounce?.cancel();
    _coHostSearchDebounce = Timer(Duration(milliseconds: 400), () {
      _performCoHostSearch(value);
    });
  }

  Future<void> _performCoHostSearch(String value) async {
    final q = value.trim();
    if (q.isEmpty) {
      coHostSearchResults.clear();
      coHostSearchLoading.value = false;
      return;
    }
    coHostSearchLoading.value = true;
    final users = await searchCoHosts(q);
    coHostSearchResults.assignAll(users);
    coHostSearchLoading.value = false;
  }

  Future<List<Map<String, dynamic>>> searchCoHosts(String query) async {
    final token = await _prefs.getAccessToken();
    final url =
        '${Urls.searchCoHost}?search=${Uri.encodeQueryComponent(query)}&page=1&limit=10';
    final response = await _networkCaller.getRequest(
      url,
      token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
    );
    if (!response.isSuccess) return [];
    final body = response.responseData;
    final dynamic rawList = body['users'] ?? body['data'];
    final List rawUsers = rawList is List
        ? rawList
        : (rawList is Map && rawList['users'] is List ? rawList['users'] : []);
    if (rawUsers.isEmpty) return [];
    return rawUsers
        .whereType<Map>()
        .map((u) {
          final profile = u['profile'];
          final profileMap = profile is Map ? profile : {};
          final fullName = (profileMap['fullName'] ?? u['username'] ?? '')
              .toString();
          final avatar = (profileMap['profilePicture'] ?? '').toString();
          return {
            'id': u['id'] is int ? u['id'] as int : int.tryParse('${u['id']}'),
            'fullName': fullName,
            'image': avatar,
            'username': (u['username'] ?? '').toString(),
          };
        })
        .where((u) => u['id'] != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  String? _extractUploadedFileUrl(dynamic rawBody) {
    dynamic decoded = rawBody;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {}
    }
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map) {
        return (first['url'] ?? first['secure_url'] ?? first['fileUrl'])
            ?.toString();
      }
    }
    if (decoded is Map) {
      final top = decoded['url'] ?? decoded['secure_url'] ?? decoded['fileUrl'];
      if (top != null) return top.toString();
      final data = decoded['data'];
      if (data is List && data.isNotEmpty && data.first is Map) {
        final first = data.first as Map;
        return (first['url'] ?? first['secure_url'] ?? first['fileUrl'])
            ?.toString();
      }
      if (data is Map) {
        return (data['url'] ?? data['secure_url'] ?? data['fileUrl'])
            ?.toString();
      }
    }
    return null;
  }

  Future<String?> _uploadPath(String path) async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) return null;
    final response = await _networkCaller.uploadFileRequest(
      Urls.uploadCloudinaryFile,
      File(path),
      token: 'Bearer $token',
      fieldName: 'files',
    );
    if (!response.isSuccess) return null;
    return _extractUploadedFileUrl(response.responseData);
  }

  void _prefillIfNeeded() {
    if (!isEdit || event == null) return;

    titleController.text = event!.title;
    final desc = event!.description;
    descriptionController.text = desc;
    if (desc.isNotEmpty) {
      try {
        if (desc.startsWith('[') && desc.endsWith(']')) {
          final decoded = jsonDecode(desc);
          if (decoded is List) {
            quillController.document = quill.Document.fromJson(decoded);
          } else {
            quillController.document = quill.Document()..insert(0, desc);
          }
        } else {
          quillController.document = quill.Document()..insert(0, desc);
        }
      } catch (_) {
        quillController.document = quill.Document()..insert(0, desc);
      }
    }
    locationController.text = event!.location;
    onlineLinkController.text = event!.onlineLink;
    maxAttendeesController.text = event!.maxAttendees > 0
        ? event!.maxAttendees.toString()
        : '';
    startDateTime.value = event!.dateTime;
    endDateTime.value =
        event!.endDateTime ?? event!.dateTime.add(Duration(hours: 1));
    eventType.value = _eventTypeLabel(event!.eventType);
    targetMajor.value = event!.targetMajor.isEmpty ? 'All' : event!.targetMajor;
    targetYear.value = event!.targetYear;
    guestGroupEnabled.value = event!.allowGuestMessages;
    isPublic.value = event!.isPublic;
    requiresApproval.value = event!.requiresApproval;
    uploadedCoverImageUrl.value = event!.coverImageUrl;
    uploadedVideoUrl.value = event!.mediaUrl;
    videoUrlController.text = event!.mediaUrl;
    tags.assignAll(event!.tags);
    selectedCoHosts.assignAll(event!.coHosts);
    selectedCoHostIds.assignAll(
      event!.coHosts
          .map((host) => host['id'])
          .whereType<int>()
          .where((id) => id > 0),
    );
  }

  String _eventTypeLabel(String value) {
    switch (value) {
      case 'in_person':
        return 'In-person';
      case 'hybrid':
        return 'Hybrid';
      case 'other':
        return 'Others';
      default:
        return 'Virtual';
    }
  }

  String _eventTypePayloadValue() {
    final eventTypeMap = {
      'Virtual': 'virtual',
      'In-person': 'in_person',
      'Hybrid': 'hybrid',
      'Others': 'other',
      'Other': 'other',
    };
    return eventTypeMap[eventType.value] ?? event?.eventType ?? 'virtual';
  }

  String _getDescriptionPayload() {
    try {
      final delta = quillController.document.toDelta().toJson();
      final plain = quillController.document.toPlainText().trim();
      if (plain.isEmpty) return descriptionController.text.trim();
      final hasFormatting = delta.any((op) =>
          op is Map &&
          op.containsKey('attributes') &&
          (op['attributes'] as Map).isNotEmpty);
      if (hasFormatting) {
        return jsonEncode(delta);
      }
      return plain;
    } catch (_) {
      return descriptionController.text.trim();
    }
  }

  Future<void> submitEvent() async {
    if (titleController.text.trim().isEmpty) {
      return EasyLoading.showError('Please enter an event title');
    }
    final descText = descriptionController.text.trim();
    if (descText.isEmpty) {
      return EasyLoading.showError('Please enter description');
    }
    if (startDateTime.value == null || endDateTime.value == null) {
      return EasyLoading.showError('Select start and end date-time');
    }
    if (endDateTime.value!.isBefore(startDateTime.value!)) {
      return EasyLoading.showError(
        'End date-time must be after start date-time',
      );
    }
    if (eventType.value.isEmpty) {
      return EasyLoading.showError('Select event type');
    }
    if ((eventType.value == 'Others' || eventType.value == 'Other') &&
        otherEventTypeController.text.trim().isEmpty) {
      return EasyLoading.showError('Please specify other event type');
    }
    if (targetMajor.value == 'Other' &&
        otherTargetMajorController.text.trim().isEmpty) {
      return EasyLoading.showError('Please specify other target major');
    }

    try {
      isSubmitting.value = true;
      EasyLoading.show(
        status: isEdit ? 'Updating event...' : 'Creating event...',
      );

      String? coverUrl = uploadedCoverImageUrl.value;
      if ((coverUrl == null || coverUrl.isEmpty) &&
          coverImagePath.value != null &&
          coverImagePath.value!.isNotEmpty) {
        coverUrl = await _uploadPath(coverImagePath.value!);
        uploadedCoverImageUrl.value = coverUrl;
      }

      String? videoUrl = uploadedVideoUrl.value;
      if ((videoUrl == null || videoUrl.isEmpty) &&
          videoClipPath.value != null &&
          videoClipPath.value!.isNotEmpty) {
        videoUrl = await _uploadPath(videoClipPath.value!);
        uploadedVideoUrl.value = videoUrl;
      }
      if (videoUrl == null || videoUrl.isEmpty) {
        videoUrl = videoUrlController.text.trim();
      }

      final token = await _prefs.getAccessToken();
      final selectedMajor = targetMajor.value.trim();
      final majorPayload = (selectedMajor.isEmpty || selectedMajor.toLowerCase() == 'all')
          ? 'All'
          : (selectedMajor == 'Other'
              ? otherTargetMajorController.text.trim()
              : selectedMajor);

      final payload = {
        'title': titleController.text.trim(),
        'description': _getDescriptionPayload(),
        'coverImageUrl': coverUrl ?? '',
        if (videoUrl != null && videoUrl.isNotEmpty) 'mediaUrl': videoUrl,
        'startDate': startDateTime.value!.toUtc().toIso8601String(),
        'endDate': endDateTime.value!.toUtc().toIso8601String(),
        'eventType': _eventTypePayloadValue(),
        'location': locationController.text.trim(),
        'onlineLink': onlineLinkController.text.trim(),
        'hostableType': 'union',
        'hostableId': 1,
        'targetMajor': majorPayload,
        'targetYear': targetYear.value == 'All' ? '0' : targetYear.value,
        'maxAttendees': int.tryParse(maxAttendeesController.text.trim()) ?? 100,
        'allowGuestMessages': guestGroupEnabled.value,
        'tags': tags.toList(),
        'isPublic': isPublic.value,
        'requiresApproval': requiresApproval.value,
      };

      if (!isEdit) {
        payload['coHostIds'] = selectedCoHostIds.toList();
      }

      if (eventType.value == 'Others' || eventType.value == 'Other') {
        payload['otherEventType'] = otherEventTypeController.text.trim();
        payload['eventType'] = 'other';
      }

      final response = isEdit
          ? await _networkCaller.putJsonRequest(
              Urls.updateEvent(event!.id),
              body: payload,
              token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
            )
          : await _networkCaller.postJsonRequest(
              Urls.createEvent,
              body: payload,
              token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
            );
      EasyLoading.dismiss();
      if (response.isSuccess) {
        if (Get.isRegistered<AllEventsController>()) {
          await Get.find<AllEventsController>().fetchMyEvents();
        }
        EasyLoading.showSuccess(
          isEdit ? 'Event updated successfully' : 'Event created successfully',
        );
        Get.back(result: true);
      } else {
        EasyLoading.showError(response.errorMessage);
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    _coHostSearchDebounce?.cancel();
    quillController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    onlineLinkController.dispose();
    maxAttendeesController.dispose();
    tagInputController.dispose();
    otherEventTypeController.dispose();
    otherTargetMajorController.dispose();
    videoUrlController.dispose();
    super.onClose();
  }
}
