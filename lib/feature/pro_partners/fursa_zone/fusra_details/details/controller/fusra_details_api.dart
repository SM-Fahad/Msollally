part of 'fusra_details_controller.dart';

extension FusraDetailsApiX on FusraDetailsController {
  Future<void> fetchCompetitionDetails(String id) async {
    isDetailsLoading.value = true;
    detailsError.value = '';
    videoError.value = '';
    try {
      final token = await _prefs.getAccessToken();
      final response = await _networkCaller.getRequest(
        Urls.getFursaDetails(id),
        token: token != null && token.isNotEmpty ? 'Bearer $token' : null,
      );
      if (!response.isSuccess) {
        detailsError.value = response.errorMessage.isEmpty
            ? 'Failed to load competition details'
            : response.errorMessage;
        return;
      }

      final body = response.responseData;
      final data = body is Map<String, dynamic> && body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body is Map<String, dynamic>
          ? body
          : <String, dynamic>{};

      competitionName.value = '${data['competitionName'] ?? ''}'.trim();
      brandSlogan.value = '${data['brandSlogan'] ?? ''}'.trim();
      partnerName.value = '${data['proPartner'] ?? data['authorName'] ?? ''}'
          .trim();
      promoImageLink.value = '${data['promoImageLink'] ?? ''}'.trim();
      promoVideoLink.value = '${data['promoVideoLink'] ?? ''}'.trim();
      partnerInfoFileLink.value = '${data['partnerInfoFileLink'] ?? ''}'.trim();

      await initializeVideo();
    } catch (_) {
      detailsError.value = 'Failed to load competition details';
    } finally {
      isDetailsLoading.value = false;
    }
  }
}
