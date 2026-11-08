import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';

class CreateCampaignController extends GetxController {
  final int? initialCampaignId;

  CreateCampaignController({this.initialCampaignId});

  final _networkCaller = NetworkCaller();
  final _prefs = SharedPreferenceHelper();

  late final TextEditingController captionController;
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController destinationUrlController;
  late final TextEditingController budgetController;
  late final TextEditingController otherGenderController;
  late final TextEditingController otherMajorController;
  late final TextEditingController videoUrlController;
  final quill.QuillController quillController = quill.QuillController.basic();

  final pickedFile = Rxn<PlatformFile>();
  final pickedFilePath = RxnString();
  final uploadedMediaUrl = RxnString();
  final uploadedMediaId = RxnString();
  final pickedMediaType = RxnString();
  final isUploadingMedia = false.obs;

  final coverImagePath = RxnString();
  final uploadedCoverImageUrl = RxnString();
  final videoClipPath = RxnString();
  final uploadedVideoUrl = RxnString();
  final isUploadingVideo = false.obs;

  final caption = ''.obs;
  final title = ''.obs;
  final description = ''.obs;
  final destinationUrl = ''.obs;
  final cta = ''.obs;
  final currentStatus = 'active'.obs;

  final campaignId = RxnInt();
  final isEditMode = false.obs;
  final isFetchingDetails = false.obs;

  final selectedUniversities = <String>[].obs;
  final gender = RxnString();
  final otherGender = ''.obs;
  final selectedMajors = <String>[].obs;
  final otherMajor = ''.obs;
  final year = RxnString();

  final budgetAmount = RxnDouble();
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  final notices = <String>[].obs;
  final universities = <String>[].obs;
  final isSubmitting = false.obs;
  final hasTriedSubmit = false.obs;

  final Map<String, String> genderLabelToValue = const {
    'Any': 'any',
    'Female': 'female',
    'Male': 'male',
  };
  final Map<String, String> majorLabelToValue = const {
    'All Departments': 'all',
    'Computer Science': 'computer_science',
    'Electrical Engineering': 'electrical_engineering',
    'Business Administration': 'business_administration',
    'Law': 'law',
    'Other': 'other',
  };
  final Map<String, String> ctaLabelToValue = const {
    'Apply Now': 'apply_now',
    'Learn More': 'learn_more',
    'Register': 'register',
    'Donate': 'donate',
    'Visit Site': 'visit_site',
  };

  String get primaryActionText => isEditMode.value
      ? (isSubmitting.value ? 'Updating...' : 'Update Campaign')
      : (isSubmitting.value ? 'Launching...' : 'Launch Campaign');

  bool get isTargetingValid => true;

  @override
  void onInit() {
    super.onInit();
    _initializeTextControllers();
    campaignId.value = initialCampaignId;
    isEditMode.value = initialCampaignId != null;
    fetchUniversities();
    if (initialCampaignId != null) {
      loadCampaignForEdit(initialCampaignId!);
    }
  }

  @override
  void onClose() {
    quillController.dispose();
    captionController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    destinationUrlController.dispose();
    budgetController.dispose();
    otherGenderController.dispose();
    otherMajorController.dispose();
    videoUrlController.dispose();
    super.onClose();
  }

  void _initializeTextControllers() {
    captionController = TextEditingController();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    destinationUrlController = TextEditingController();
    budgetController = TextEditingController();
    otherGenderController = TextEditingController();
    otherMajorController = TextEditingController();
    videoUrlController = TextEditingController();

    captionController.addListener(() => caption.value = captionController.text);
    titleController.addListener(() => title.value = titleController.text);
    otherGenderController.addListener(() => otherGender.value = otherGenderController.text);
    otherMajorController.addListener(() => otherMajor.value = otherMajorController.text);
    descriptionController.addListener(
      () => description.value = descriptionController.text,
    );
    quillController.addListener(() {
      final plain = quillController.document.toPlainText().trim();
      description.value = plain;
      if (descriptionController.text != plain) {
        descriptionController.text = plain;
      }
    });
    destinationUrlController.addListener(
      () => destinationUrl.value = destinationUrlController.text,
    );
    budgetController.addListener(() {
      budgetAmount.value = double.tryParse(budgetController.text.trim());
    });
    videoUrlController.addListener(() {
      uploadedVideoUrl.value = videoUrlController.text.trim();
    });
  }

  Future<void> loadCampaignForEdit(int id) async {
    try {
      isFetchingDetails.value = true;
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getCampaign('$id'),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );

      if (!response.isSuccess) {
        EasyLoading.showError(response.errorMessage);
        return;
      }

      final body = response.responseData;
      final data = body is Map<String, dynamic> ? body['data'] : null;
      if (data is! Map<String, dynamic>) {
        EasyLoading.showError('Invalid campaign details');
        return;
      }

      _applyCampaignDetails(data);
    } finally {
      isFetchingDetails.value = false;
    }
  }

  void _applyCampaignDetails(Map<String, dynamic> data) {
    campaignId.value = _toInt(data['id']) > 0
        ? _toInt(data['id'])
        : campaignId.value;
    isEditMode.value = true;

    titleController.text = _toText(data['campaignTitle']);
    final desc = _toText(data['description']);
    descriptionController.text = desc;
    description.value = desc;
    if (desc.isNotEmpty) {
      try {
        if (desc.trim().startsWith('[') && desc.trim().endsWith(']')) {
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
    captionController.text = _toText(data['caption']);
    destinationUrlController.text = _toText(data['destinationUrl']);

    cta.value = _reverseLookup(
      ctaLabelToValue,
      _firstString(data['callToAction']),
    );
    final rawGender = _firstString(data['gender']);
    if (rawGender.toLowerCase() == 'any') {
      gender.value = 'Any';
    } else {
      gender.value = _reverseLookup(
        genderLabelToValue,
        rawGender,
      );
    }
    otherGenderController.text = _toText(data['otherGender']);
    otherMajorController.text = _toText(data['otherMajor']);
    currentStatus.value = _normalizeStatus(_firstString(data['status']));
    
    final savedYear = _firstString(data['yearOfStudy']);
    year.value = (savedYear == '0' || savedYear.toLowerCase() == 'all')
        ? 'All Years'
        : savedYear;

    final budget = _toDouble(data['totalBudget']);
    budgetAmount.value = budget > 0 ? budget : null;
    budgetController.text = budget > 0 ? budget.toStringAsFixed(0) : '';

    startDate.value = _toDate(data['startDate']);
    endDate.value = _toDate(data['endDate']);

    final unis = _stringList(data['university']);
    if (unis.contains('all') || unis.contains('All Universities')) {
      selectedUniversities.assignAll(['All Universities']);
    } else {
      selectedUniversities.assignAll(unis);
    }

    final majs = _stringList(data['major']);
    if (majs.contains('all') || majs.contains('All Departments')) {
      selectedMajors.assignAll(['All Departments']);
    } else {
      selectedMajors.assignAll(
        majs
            .map((value) => _reverseLookup(majorLabelToValue, value))
            .where((label) => label.isNotEmpty)
            .toList(),
      );
    }

    final existingMedia = _toText(data['imageOrVideoLink']);
    uploadedMediaUrl.value = existingMedia.isEmpty ? null : existingMedia;
    uploadedMediaId.value = null;
    pickedFile.value = null;
    pickedFilePath.value = null;
    pickedMediaType.value = _detectMediaType(existingMedia);
    if (existingMedia.isNotEmpty) {
      if (existingMedia.endsWith('.mp4') ||
          existingMedia.endsWith('.webm') ||
          existingMedia.endsWith('.mov') ||
          existingMedia.contains('video')) {
        uploadedVideoUrl.value = existingMedia;
        videoUrlController.text = existingMedia;
      } else {
        uploadedCoverImageUrl.value = existingMedia;
      }
    }
    final coverLink = _toText(data['coverImageUrl']);
    if (coverLink.isNotEmpty) {
      uploadedCoverImageUrl.value = coverLink;
    }

    final rawNotices = data['notices'];
    if (rawNotices is List) {
      notices.assignAll(
        rawNotices
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty),
      );
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'mp4',
          'mov',
          'avi',
          'mkv',
          'webm',
          'jpg',
          'jpeg',
          'png',
          'webp',
        ],
        withData: false,
      );
    } catch (_) {
      result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        withData: false,
      );
    }

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      pickedFile.value = file;
      pickedFilePath.value = file.path;
      uploadedMediaUrl.value = null;
      uploadedMediaId.value = null;
      pickedMediaType.value = _detectMediaType(
        file.path ?? '',
        fallbackExt: file.extension,
      );

      await _uploadMediaImmediately();
    }
  }

  Future<void> _uploadMediaImmediately() async {
    final path = pickedFilePath.value;
    if (path == null || path.isEmpty) return;
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) return;

    try {
      isUploadingMedia.value = true;

      final response = await _networkCaller.uploadFileRequest(
        'https://api.nodmac.com/files/upload',
        File(path),
        token: 'Bearer $token',
        fieldName: 'files',
      );

      if (response.isSuccess) {
        final data = response.responseData;
        if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is Map) {
            uploadedMediaUrl.value = first['url']?.toString();
            uploadedMediaId.value = first['id']?.toString();
          }
        } else if (data is Map) {
          uploadedMediaUrl.value = data['url']?.toString();
          uploadedMediaId.value = data['id']?.toString();
        }
      } else {
        _clearLocalFile();
      }
    } finally {
      isUploadingMedia.value = false;
    }
  }

  void _clearLocalFile() {
    pickedFile.value = null;
    pickedFilePath.value = null;
    uploadedMediaUrl.value = null;
    uploadedMediaId.value = null;
    pickedMediaType.value = null;
  }

  Future<void> removeFile() async {
    final id = uploadedMediaId.value;
    if (id != null && id.isNotEmpty) {
      final token = await _prefs.getAccessToken();
      try {
        await _networkCaller.deleteRequest(
          'https://api.nodmac.com/files/$id',
          token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
        );
      } finally {}
    }
    _clearLocalFile();
  }

  Future<void> pickCoverImage() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    coverImagePath.value = image.path;
    final url = await _uploadFilePath(image.path);
    if (url != null) {
      uploadedCoverImageUrl.value = url;
    }
  }

  void clearCover() {
    coverImagePath.value = null;
    uploadedCoverImageUrl.value = null;
  }

  Future<void> pickVideoClip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.size > 50 * 1024 * 1024) {
      EasyLoading.showError('Video exceeds maximum size of 50MB');
      return;
    }
    if (file.path != null) {
      videoClipPath.value = file.path;
      isUploadingVideo.value = true;
      try {
        final url = await _uploadFilePath(file.path!);
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

  Future<String?> _uploadFilePath(String path) async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      final response = await _networkCaller.uploadFileRequest(
        'https://api.nodmac.com/files/upload',
        File(path),
        token: 'Bearer $token',
        fieldName: 'files',
      );
      if (response.isSuccess) {
        final data = response.responseData;
        if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is Map) {
            return first['url']?.toString();
          }
        } else if (data is Map) {
          return data['url']?.toString();
        }
      }
    } catch (_) {}
    return null;
  }

  void addNotice(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return;
    notices.add(normalized);
  }

  void clearNotices() => notices.clear();

  void addUniversity(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || selectedUniversities.contains(normalized)) return;
    
    if (normalized == 'All Universities') {
      selectedUniversities.assignAll(['All Universities']);
    } else {
      if (selectedUniversities.contains('All Universities')) {
        selectedUniversities.remove('All Universities');
      }
      selectedUniversities.add(normalized);
    }
  }

  void removeUniversity(String value) => selectedUniversities.remove(value);

  void addMajor(String label) {
    final normalized = label.trim();
    if (normalized.isEmpty || selectedMajors.contains(normalized)) return;
    if (!majorLabelToValue.containsKey(normalized)) return;
    
    if (normalized == 'All Departments') {
      selectedMajors.assignAll(['All Departments']);
    } else {
      if (selectedMajors.contains('All Departments')) {
        selectedMajors.remove('All Departments');
      }
      selectedMajors.add(normalized);
    }
  }

  void removeMajor(String label) => selectedMajors.remove(label);

  void setStartDate(DateTime d) => startDate.value = d;

  void setEndDate(DateTime d) => endDate.value = d;

  bool get hasSelectedMedia {
    return (pickedFilePath.value?.isNotEmpty ?? false) ||
        (uploadedMediaUrl.value?.isNotEmpty ?? false) ||
        (uploadedCoverImageUrl.value?.isNotEmpty ?? false) ||
        (uploadedVideoUrl.value?.isNotEmpty ?? false);
  }

  bool get hasTargetingFilters {
    return selectedUniversities.isNotEmpty ||
        (gender.value?.isNotEmpty ?? false) ||
        selectedMajors.isNotEmpty ||
        (year.value?.isNotEmpty ?? false);
  }

  String? get titleError =>
      _requiredTextError(title.value, 'Campaign title is required');
  String? get descriptionError =>
      _requiredTextError(description.value, 'Description is required');
  String? get destinationUrlError =>
      _requiredTextError(destinationUrl.value, 'Destination URL is required');
  String? get ctaError =>
      hasTriedSubmit.value &&
              (cta.value.isEmpty || ctaLabelToValue[cta.value] == null)
          ? 'Select a call-to-action'
          : null;
  String? get startDateError => hasTriedSubmit.value && startDate.value == null
      ? 'Choose a start date'
      : null;
  String? get endDateError {
    if (!hasTriedSubmit.value) return null;
    if (endDate.value == null) return 'Choose an end date';
    if (startDate.value != null && endDate.value!.isBefore(startDate.value!)) {
      return 'End date must be after start date';
    }
    return null;
  }

  String? get budgetError {
    if (!hasTriedSubmit.value) return null;
    if (budgetController.text.trim().isEmpty) return null;
    if (budgetAmount.value == null || budgetAmount.value! < 0) {
      return 'Budget cannot be negative';
    }
    return null;
  }

  String? get universityError => null;

  String? get genderError => null;

  String? get otherGenderError => null;

  String? get majorError => null;

  String? get otherMajorError =>
      hasTriedSubmit.value &&
              selectedMajors.contains('Other') &&
              otherMajor.value.trim().isEmpty
          ? 'Please specify other major'
          : null;

  String? get yearError => null;

  String? _requiredTextError(String value, String message) {
    if (!hasTriedSubmit.value) return null;
    return value.trim().isEmpty ? message : null;
  }

  bool validateRequiredFields({bool showMessage = false}) {
    hasTriedSubmit.value = true;
    final errors = <String?>[
      titleError,
      descriptionError,
      destinationUrlError,
      ctaError,
      startDateError,
      endDateError,
      budgetError,
      otherMajorError,
    ].whereType<String>().toList();
    if (errors.isEmpty) return true;
    if (showMessage) EasyLoading.showError(errors.first);
    return false;
  }

  Future<void> fetchUniversities() async {
    final token = await _prefs.getAccessToken();
    final response = await _networkCaller.getRequest(
      Urls.getUniversities,
      token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
    );
    if (!response.isSuccess) return;
    final data = response.responseData;
    final rawList = data is Map<String, dynamic> ? data['data'] : data;
    if (rawList is List) {
      final list = rawList
          .map(
            (e) => e is Map
                ? (e['fullName']?.toString() ?? e['name']?.toString() ?? '')
                : '',
          )
          .where((e) => e.trim().isNotEmpty)
          .toList();
      universities.assignAll(['All Universities', ...list]);
    }
  }

  Future<void> submitCampaign() async {
    if (!validateRequiredFields(showMessage: true)) return;

    try {
      isSubmitting.value = true;
      EasyLoading.show(
        status: isEditMode.value
            ? 'Updating campaign...'
            : 'Launching campaign...',
      );

      String? mediaUrl = uploadedMediaUrl.value;
      if (mediaUrl == null || mediaUrl.isEmpty) {
        if (pickedFilePath.value?.isNotEmpty == true) {
          EasyLoading.showError(
            'Media is still uploading or failed. Please wait or re-upload.',
          );
          return;
        }
      }

      final token = await _prefs.getAccessToken();
      final payload = _buildPayload(mediaUrl);
      var response = isEditMode.value
          ? await _networkCaller.patchJsonRequest(
              Urls.updateCampaign('${campaignId.value}'),
              body: payload,
              token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
            )
          : await _networkCaller.postJsonRequest(
              Urls.createCampaign,
              body: payload,
              token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
            );

      if (isEditMode.value && !response.isSuccess && response.statusCode == 404) {
        response = await _networkCaller.patchJsonRequest(
          '${Urls.baseUrl}/campaigns/${campaignId.value}',
          body: payload,
          token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
        );
      }

      if (response.isSuccess) {
        EasyLoading.showSuccess(
          isEditMode.value
              ? 'Campaign updated successfully'
              : 'Campaign launched successfully',
        );
        await Future.delayed(const Duration(milliseconds: 400));
        if (Get.isOverlaysOpen) {
          EasyLoading.dismiss();
        }
        if (Get.key.currentState?.canPop() ?? false) {
          Get.back(result: true);
        }
      } else {
        EasyLoading.showError(response.errorMessage);
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  String _getDescriptionPayload() {
    try {
      final delta = quillController.document.toDelta().toJson();
      final plain = quillController.document.toPlainText().trim();
      if (plain.isEmpty) return '';
      final hasFormatting = delta.any((op) =>
          op is Map &&
          op.containsKey('attributes') &&
          (op['attributes'] as Map).isNotEmpty);
      if (hasFormatting) {
        return jsonEncode(delta);
      }
      return plain;
    } catch (_) {
      return description.value.trim();
    }
  }

  Map<String, dynamic> _buildPayload(String? mediaUrl) {
    final payload = <String, dynamic>{
      'campaignTitle': title.value.trim(),
      'description': _getDescriptionPayload(),
      'destinationUrl': destinationUrl.value.trim(),
      'callToAction': ctaLabelToValue[cta.value],
      'status': _normalizeStatus(currentStatus.value),
      'startDate': _toUtcDayStartIso(startDate.value!),
      'endDate': _toUtcDayEndIso(endDate.value!),
    };

    final effectiveMedia = (uploadedVideoUrl.value?.isNotEmpty == true)
        ? uploadedVideoUrl.value
        : (videoUrlController.text.trim().isNotEmpty)
            ? videoUrlController.text.trim()
            : (uploadedCoverImageUrl.value?.isNotEmpty == true)
                ? uploadedCoverImageUrl.value
                : mediaUrl;
    if (effectiveMedia != null && effectiveMedia.isNotEmpty) {
      payload['imageOrVideoLink'] = effectiveMedia;
    }
    if (uploadedCoverImageUrl.value?.isNotEmpty == true) {
      payload['coverImageUrl'] = uploadedCoverImageUrl.value;
    }
    if (caption.value.trim().isNotEmpty) {
      payload['caption'] = caption.value.trim();
    }
    if (selectedUniversities.isNotEmpty) {
      if (selectedUniversities.contains('All Universities') ||
          selectedUniversities.contains('all')) {
        payload['university'] = ['all'];
      } else {
        payload['university'] = selectedUniversities.toList();
      }
    } else {
      payload['university'] = ['all'];
    }
    if (gender.value != null && gender.value!.isNotEmpty) {
      if (gender.value == 'Any' || gender.value == 'any') {
        payload['gender'] = ['any'];
      } else if (genderLabelToValue[gender.value] != null) {
        payload['gender'] = [genderLabelToValue[gender.value]!];
      }
    } else {
      payload['gender'] = ['any'];
    }
    if (selectedMajors.isNotEmpty) {
      if (selectedMajors.contains('All Departments') ||
          selectedMajors.contains('all')) {
        payload['major'] = ['all'];
      } else {
        final majorValues = selectedMajors
            .map((label) => majorLabelToValue[label])
            .whereType<String>()
            .toList();
        if (majorValues.isNotEmpty) {
          payload['major'] = majorValues;
          if (selectedMajors.contains('Other') &&
              otherMajor.value.trim().isNotEmpty) {
            payload['otherMajor'] = otherMajor.value.trim();
          }
        } else {
          payload['major'] = ['all'];
        }
      }
    } else {
      payload['major'] = ['all'];
    }
    final parsedYear = (year.value == 'All Years' ||
            year.value == 'All' ||
            year.value == '0' ||
            year.value == null ||
            year.value!.isEmpty)
        ? 0
        : int.tryParse(year.value ?? '');
    payload['yearOfStudy'] = parsedYear ?? 0;
    payload['totalBudget'] = (budgetAmount.value != null && budgetAmount.value! > 0)
        ? budgetAmount.value!.round()
        : 0;
    if (notices.isNotEmpty) {
      payload['notices'] = notices.toList();
    }
    return payload;
  }

  String _toUtcDayStartIso(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day).toIso8601String();
  }

  String _toUtcDayEndIso(DateTime date) {
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toIso8601String();
  }

  String _detectMediaType(String source, {String? fallbackExt}) {
    final raw = source.trim().toLowerCase();
    final ext = (fallbackExt ?? raw.split('?').first.split('.').last)
        .toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext)) {
      return 'image';
    }
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
      return 'video';
    }
    if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(ext)) {
      return 'audio';
    }
    if (raw.isEmpty) return '';
    return 'file';
  }

  String _reverseLookup(Map<String, String> map, String value) {
    for (final entry in map.entries) {
      if (entry.value == value) return entry.key;
    }
    return '';
  }

  String _normalizeStatus(String status) {
    final normalized = status.toLowerCase().trim();
    return normalized == 'paused' ? 'paused' : 'active';
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    final single = _toText(value);
    return single.isEmpty ? <String>[] : <String>[single];
  }

  String _firstString(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first?.toString().trim() ?? '';
    }
    return _toText(value);
  }

  int _toInt(dynamic value) => int.tryParse('$value') ?? 0;

  double _toDouble(dynamic value) => double.tryParse('$value') ?? 0;

  String _toText(dynamic value) => value?.toString().trim() ?? '';

  DateTime? _toDate(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '');
}
