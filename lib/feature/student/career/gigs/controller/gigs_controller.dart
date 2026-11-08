import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../model/gigs_model.dart';
import '../../../../../core/services/end_points.dart';
import '../../../../../core/services/network_caller.dart';
import '../../../../../core/services/share_preferrance_helper.dart';

class GigsController extends GetxController {
  final _networkCaller = NetworkCaller();
  final _prefs = SharedPreferenceHelper();

  // Observables
  var gigs = <GigsModel>[].obs;
  var myGigs = <GigsModel>[].obs;
  var filteredGigs = <GigsModel>[].obs;
  var filteredMyGigs = <GigsModel>[].obs;
  var isLoading = false.obs;
  var isMyGigsLoading = false.obs;
  var isSubmitting = false.obs;
  var isUploadingFile = false.obs;
  var errorMessage = ''.obs;
  var myGigsErrorMessage = ''.obs;
  var uploadedDocumentUrls = <String>[].obs;
  var tags = <String>[].obs;
  var uploadedFileName = Rxn<String>();
  var editingGigId = Rxn<int>(); // null = create mode, non-null = edit mode
  var currentUserId = (-1).obs;
  var searchQuery = ''.obs;

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final addressController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final tagInputController = TextEditingController();

  // Dropdown options — values must match backend DTO enums exactly
  final pricingTypes = ['fixed', 'negotiable', 'hourly', 'weekly', 'monthly'];
  final locationTypes = ['remote', 'in-person', 'flexible', 'onsite'];
  final currencies = ['TZS', 'USD', 'GBP', 'ZAR'];
  final statusOptions = ['active', 'paused', 'draft'];

  var selectedPricingType = 'fixed'.obs;
  var selectedLocationType = 'remote'.obs;
  var selectedCurrency = 'TZS'.obs;
  var selectedStatus = 'active'.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
    debounce(
      searchQuery,
      (_) => _applySearch(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> _initData() async {
    currentUserId.value = await getCurrentUserId();
    fetchAllGigs();
    fetchMyGigs();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    addressController.dispose();
    countryController.dispose();
    cityController.dispose();
    tagInputController.dispose();
    super.onClose();
  }

  /// Decodes the stored access token and returns the logged-in user's ID.
  /// Reads 'userID' from JWT payload — no extra API call needed.
  Future<int> getCurrentUserId() async {
    try {
      final savedId = await _prefs.getUserId();
      if (savedId != null && savedId.isNotEmpty) {
        final parsed = int.tryParse(savedId);
        if (parsed != null && parsed > 0) return parsed;
      }
      final token = await _prefs.getAccessToken();
      if (token == null || token.isEmpty) return -1;
      final parts = token.split('.');
      if (parts.length != 3) return -1;
      String payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = utf8.decode(base64Decode(payload));
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      final idNum = data['userID'] ?? data['id'] ?? data['userId'] ?? data['sub'];
      return (idNum as num?)?.toInt() ?? int.tryParse(idNum?.toString() ?? '') ?? -1;
    } catch (_) {
      return -1;
    }
  }

  Future<void> fetchAllGigs() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final token = await _prefs.getAccessToken();
      final result = await _networkCaller.getRequest(
        Urls.getAllGigs,
        token: 'Bearer $token',
      );
      if (result.isSuccess) {
        final List<dynamic> data =
            result.responseData['data'] as List<dynamic>? ?? [];
        gigs.value = data
            .map((e) => GigsModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _applySearch();
      } else {
        errorMessage.value = result.errorMessage;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load gigs. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyGigs() async {
    isMyGigsLoading.value = true;
    myGigsErrorMessage.value = '';
    try {
      final token = await _prefs.getAccessToken();
      final result = await _networkCaller.getRequest(
        Urls.getMyGigs,
        token: 'Bearer $token',
      );
      if (result.isSuccess) {
        final dynamic raw = result.responseData['data'] ?? result.responseData;
        final List<dynamic> data = raw is List ? raw : [];
        final parsed = data
            .map((e) => GigsModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (currentUserId.value != -1) {
          myGigs.value = parsed.where((g) => g.author?.id == currentUserId.value).toList();
        } else {
          myGigs.value = parsed;
        }
        _applySearch();
      } else {
        // Fallback: If my-gigs endpoint returns error/404, filter locally by logged in user ID
        _fallbackFilterMyGigs();
      }
    } catch (e) {
      _fallbackFilterMyGigs();
    } finally {
      isMyGigsLoading.value = false;
    }
  }

  void _fallbackFilterMyGigs() {
    if (currentUserId.value != -1) {
      myGigs.value = gigs
          .where((g) => g.author?.id == currentUserId.value)
          .toList();
      _applySearch();
    } else {
      myGigsErrorMessage.value = 'No personal gigs found.';
    }
  }

  Future<void> toggleGigStatus(int gigId, String newStatus) async {
    try {
      EasyLoading.show(status: 'Updating status...');
      final token = await _prefs.getAccessToken();
      final result = await _networkCaller.patchJsonRequest(
        Urls.updateGigById(gigId),
        body: {'status': newStatus},
        token: 'Bearer $token',
      );

      if (result.isSuccess) {
        void updateInList(RxList<GigsModel> list) {
          final idx = list.indexWhere((g) => g.gigId == gigId);
          if (idx != -1) {
            final old = list[idx];
            list[idx] = GigsModel(
              gigId: old.gigId,
              title: old.title,
              description: old.description,
              price: old.price,
              currency: old.currency,
              pricingType: old.pricingType,
              locationType: old.locationType,
              address: old.address,
              country: old.country,
              city: old.city,
              tags: old.tags,
              documents: old.documents,
              status: newStatus,
              author: old.author,
              createdAt: old.createdAt,
              updatedAt: DateTime.now().toIso8601String(),
            );
          }
        }

        updateInList(gigs);
        updateInList(myGigs);
        _applySearch();
        EasyLoading.showSuccess('Gig is now $newStatus');
      } else {
        EasyLoading.showError(result.errorMessage);
      }
    } catch (e) {
      EasyLoading.showError('Failed to update status.');
    }
  }

  void _applySearch() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredGigs.assignAll(gigs);
      filteredMyGigs.assignAll(myGigs);
      return;
    }

    bool matches(GigsModel g) {
      return g.title.toLowerCase().contains(query) ||
          g.description.toLowerCase().contains(query) ||
          g.tags.any((t) => t.toLowerCase().contains(query)) ||
          g.city.toLowerCase().contains(query) ||
          g.country.toLowerCase().contains(query);
    }

    filteredGigs.assignAll(gigs.where(matches).toList());
    filteredMyGigs.assignAll(myGigs.where(matches).toList());
  }

  Future<void> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    uploadedFileName.value = result.files.single.name;
    isUploadingFile.value = true;

    try {
      final token = await _prefs.getAccessToken();
      final uploadResult = await _networkCaller.uploadFileRequest(
        Urls.uploadFile,
        file,
        token: 'Bearer $token',
        fieldName: 'files',
      );

      if (uploadResult.isSuccess) {
        String url = '';
        final raw = uploadResult.responseData;
        if (raw is List && raw.isNotEmpty) {
          url = (raw[0]['url'] ?? '').toString();
        } else if (raw is Map) {
          final data = raw['data'];
          url = (data?['url'] ?? data?['secure_url'] ?? '').toString();
        }

        if (url.isNotEmpty) {
          uploadedDocumentUrls.add(url);
          log('File URL saved: $url', name: 'GigsController');
        } else {
          EasyLoading.showToast(
            '⚠️  File uploaded but no URL was returned',
            toastPosition: EasyLoadingToastPosition.bottom,
          );
          uploadedFileName.value = null;
        }
      } else {
        EasyLoading.showError(uploadResult.errorMessage);
        uploadedFileName.value = null;
      }
    } catch (e) {
      EasyLoading.showError('File upload failed. Please try again.');
      uploadedFileName.value = null;
    } finally {
      isUploadingFile.value = false;
    }
  }

  void removeUploadedFile(int index) {
    if (index >= 0 && index < uploadedDocumentUrls.length) {
      uploadedDocumentUrls.removeAt(index);
    }
    if (uploadedDocumentUrls.isEmpty) uploadedFileName.value = null;
  }

  void addTag() {
    final tag = tagInputController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
      tagInputController.clear();
    }
  }

  void removeTag(String tag) => tags.remove(tag);

  Future<void> createGig() async {
    if (!_validateForm()) return;

    isSubmitting.value = true;
    EasyLoading.show(status: 'Creating gig...');
    try {
      final token = await _prefs.getAccessToken();
      final result = await _networkCaller.postJsonRequest(
        Urls.createGig,
        body: _buildBody(),
        token: 'Bearer $token',
      );

      if (result.isSuccess) {
        final newGig = GigsModel.fromJson(
          result.responseData['data'] as Map<String, dynamic>,
        );
        gigs.insert(0, newGig);
        myGigs.insert(0, newGig);
        _applySearch();
        resetForm();
        Get.back();
        EasyLoading.showSuccess('Gig created successfully!');
      } else {
        EasyLoading.showError(result.errorMessage);
      }
    } catch (e, stack) {
      log('createGig error: $e\n$stack', name: 'GigsController');
      EasyLoading.showError('Failed to create gig. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateGig(int gigId) async {
    if (!_validateForm()) return;

    isSubmitting.value = true;
    EasyLoading.show(status: 'Updating gig...');
    try {
      final token = await _prefs.getAccessToken();
      final result = await _networkCaller.patchJsonRequest(
        Urls.updateGigById(gigId),
        body: _buildBody(),
        token: 'Bearer $token',
      );

      if (result.isSuccess) {
        final updated = GigsModel.fromJson(
          result.responseData['data'] as Map<String, dynamic>,
        );
        void updateInList(RxList<GigsModel> list) {
          final idx = list.indexWhere((g) => g.gigId == gigId);
          if (idx != -1) {
            list[idx] = updated;
            list.refresh();
          }
        }
        updateInList(gigs);
        updateInList(myGigs);
        _applySearch();
        resetForm();
        Get.back();
        EasyLoading.showSuccess('Gig updated successfully!');
      } else {
        EasyLoading.showError(result.errorMessage);
      }
    } catch (e) {
      EasyLoading.showError('Failed to update gig. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteGig(int gigId) async {
    EasyLoading.show(status: 'Deleting...');
    try {
      final token = await _prefs.getAccessToken();
      final result = await _networkCaller.deleteRequest(
        Urls.deleteGigById(gigId),
        token: 'Bearer $token',
      );

      if (result.isSuccess) {
        gigs.removeWhere((g) => g.gigId == gigId);
        myGigs.removeWhere((g) => g.gigId == gigId);
        _applySearch();
        Get.back();
        EasyLoading.showSuccess('Gig deleted!');
      } else {
        EasyLoading.showError(result.errorMessage);
      }
    } catch (e) {
      EasyLoading.showError('Failed to delete gig. Please try again.');
    }
  }

  Map<String, dynamic> _buildBody() {
    final body = <String, dynamic>{
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'price': num.tryParse(priceController.text.trim()) ?? 0,
      'currency': selectedCurrency.value,
      'pricingType': selectedPricingType.value,
      'locationType': selectedLocationType.value,
      'tags': tags.toList(),
      'documents': uploadedDocumentUrls.toList(),
      'status': selectedStatus.value,
    };

    final address = addressController.text.trim();
    final country = countryController.text.trim();
    final city = cityController.text.trim();
    if (address.isNotEmpty) body['address'] = address;
    if (country.isNotEmpty) body['country'] = country;
    if (city.isNotEmpty) body['city'] = city;

    return body;
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      EasyLoading.showError('Title cannot be empty');
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      EasyLoading.showError('Description cannot be empty');
      return false;
    }
    if (priceController.text.trim().isEmpty) {
      EasyLoading.showError('Price cannot be empty');
      return false;
    }
    final price = num.tryParse(priceController.text.trim());
    if (price == null || price <= 0) {
      EasyLoading.showError('Please enter a valid price (e.g. 500)');
      return false;
    }
    return true;
  }

  void resetForm() {
    editingGigId.value = null;
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    addressController.clear();
    countryController.clear();
    cityController.clear();
    tagInputController.clear();
    tags.clear();
    uploadedDocumentUrls.clear();
    uploadedFileName.value = null;
    selectedPricingType.value = 'fixed';
    selectedLocationType.value = 'remote';
    selectedCurrency.value = 'TZS';
    selectedStatus.value = 'active';
  }

  void populateFormForEdit(GigsModel gig) {
    editingGigId.value = gig.gigId;
    titleController.text = gig.title;
    descriptionController.text = gig.description;
    priceController.text = gig.price;
    addressController.text = gig.address;
    countryController.text = gig.country;
    cityController.text = gig.city;
    tags.value = List<String>.from(gig.tags);
    uploadedDocumentUrls.value = List<String>.from(gig.documents);
    selectedCurrency.value = currencies.contains(gig.currency)
        ? gig.currency
        : 'TZS';
    selectedPricingType.value = pricingTypes.contains(gig.pricingType)
        ? gig.pricingType
        : 'fixed';
    selectedLocationType.value = locationTypes.contains(gig.locationType)
        ? gig.locationType
        : 'remote';
    selectedStatus.value = statusOptions.contains(gig.status)
        ? gig.status!
        : 'active';
  }
}
