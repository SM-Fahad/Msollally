import 'package:flutter/rendering.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/feature/terms_and_privacy/model/terms_and_privacy_model.dart';

class TermsAndPrivacyService {
  final NetworkCaller _networkCaller = NetworkCaller();

  Future<TermsAndPrivacyModel?> fetchTermsAndPrivacy(String type) async {
    try {
      final response = await _networkCaller.getRequest(
        Urls.termsAndPrivacy(type),
      );
      if (response.isSuccess && response.responseData != null) {
        return TermsAndPrivacyModel.fromJson(response.responseData);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching terms and privacy: $e');
      return null;
    }
  }
}
