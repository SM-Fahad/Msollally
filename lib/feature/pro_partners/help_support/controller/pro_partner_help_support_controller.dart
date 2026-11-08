import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger_barta/logger_barta.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/pro_partners/help_support/model/pro_partner_help_support_model.dart';

class ProPartnerHelpSupportController extends GetxController {
  final _prefHelper = SharedPreferenceHelper();

  // State
  final supportList = <ProPartnerHelpSupportModel>[].obs;
  final supportDetail = Rxn<ProPartnerHelpSupportModel>();
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isDetailLoading = false.obs;
  final errorMessage = RxnString();

  // Pagination & Search
  final searchQuery = ''.obs;
  int _currentPage = 1;
  bool _hasNextPage = false;
  final int _limit = 8;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadSupport();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadSupport({bool isRefresh = false}) async {
    if (!isRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final accessToken = await _prefHelper.getAccessToken();
      final query = searchQuery.value.isNotEmpty
          ? '&search=${searchQuery.value}'
          : '';
      final url =
          'https://api.nodmac.com/emergency-support?page=$_currentPage&limit=$_limit$query';

      final response = await http.get(
        Uri.parse(url),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $accessToken'},
      );

      BartaLog.network(
        method: 'GET',
        endpoint: url,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final result = ProPartnerHelpSupportResponseModel.fromJson(decoded);

        if (_currentPage == 1) {
          supportList.assignAll(result.data);
        } else {
          supportList.addAll(result.data);
        }

        _hasNextPage = result.hasNextPage;
      } else {
        errorMessage.value = 'Failed to load support list';
      }
    } catch (e, st) {
      print('DEBUG: loadSupport error: $e');
      print('DEBUG: loadSupport stacktrace: $st');
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasNextPage || isLoading.value) return;

    isLoadingMore.value = true;
    _currentPage++;
    await loadSupport();
  }

  Future<void> refreshSupport() async {
    _currentPage = 1;
    await loadSupport(isRefresh: true);
  }

  void searchSupport(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchQuery.value != query) {
        searchQuery.value = query;
        _currentPage = 1;
        supportList.clear();
        loadSupport();
      }
    });
  }

  void clearSearch() {
    searchQuery.value = '';
    _currentPage = 1;
    supportList.clear();
    loadSupport();
  }

  Future<void> getSupportDetails(int id) async {
    isDetailLoading.value = true;
    errorMessage.value = null;

    try {
      final accessToken = await _prefHelper.getAccessToken();
      final url = 'https://api.nodmac.com/emergency-support/$id';

      final response = await http.get(
        Uri.parse(url),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $accessToken'},
      );

      BartaLog.network(
        method: 'GET',
        endpoint: url,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        supportDetail.value = ProPartnerHelpSupportModel.fromJson(decoded);
      } else {
        errorMessage.value = 'Failed to load support details';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isDetailLoading.value = false;
    }
  }
}
