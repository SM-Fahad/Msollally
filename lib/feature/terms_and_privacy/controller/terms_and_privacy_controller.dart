import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/terms_and_privacy/model/terms_and_privacy_model.dart';
import 'package:msollaally/feature/terms_and_privacy/service/terms_and_privacy_service.dart';

class TermsAndPrivacyController extends GetxController {
  final String type;
  TermsAndPrivacyController({required this.type});

  final TermsAndPrivacyService _service = TermsAndPrivacyService();
  var termsData = Rxn<TermsAndPrivacyModel>();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final data = await _service.fetchTermsAndPrivacy(type);
      if (data != null) {
        termsData.value = data;
      }
    } catch (e) {
      debugPrint("Failed to load terms and privacy data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
