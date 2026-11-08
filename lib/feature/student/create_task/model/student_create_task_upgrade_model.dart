import 'package:get/get_rx/get_rx.dart';

class FeatureItem {
  final String title;
  final bool isAvailable;
  final String? subtitle;

  FeatureItem({
    required this.title,
    required this.isAvailable,
    this.subtitle,
  });
}

class PriceOption {
  final int id;
  final double amount;
  final String currency;
  final String billingInterval;
  final int durationInDays;
  final String formattedCharge;

  PriceOption({
    required this.id,
    required this.amount,
    required this.currency,
    required this.billingInterval,
    required this.durationInDays,
    required this.formattedCharge,
  });
}

class StudentCreateTaskUpgradeModel {
  final int? id;
  final String title;
  final String subTitle;
  final String discount;
  final bool isTrial;
  final List<String> features;
  final List<FeatureItem> detailedFeatures;
  final List<PriceOption> priceOptions;
  final RxBool isChecked;
  final Rxn<PriceOption> selectedPrice;

  StudentCreateTaskUpgradeModel({
    this.id,
    required this.title,
    required this.subTitle,
    this.discount = " ",
    this.isTrial = false,
    this.features = const [],
    this.detailedFeatures = const [],
    this.priceOptions = const [],
    PriceOption? initialSelectedPrice,
    bool initializedChecked = false,
  })  : isChecked = RxBool(initializedChecked),
        selectedPrice = Rxn<PriceOption>(initialSelectedPrice);

  int? get priceId => selectedPrice.value?.id;
  String get charge => selectedPrice.value?.formattedCharge ?? '';

  factory StudentCreateTaskUpgradeModel.fromJson(
    Map<String, dynamic> json, {
    bool initializedChecked = false,
  }) {
    final List<PriceOption> priceOptions = _extractPriceOptions(json['prices']);
    final initialSelectedPrice = priceOptions.isNotEmpty ? priceOptions.first : null;

    final List<String> features = [];
    if (json['features'] is List) {
      features.addAll((json['features'] as List).map((e) => e.toString()));
    }

    final List<FeatureItem> detailedFeatures = [];
    final planFeatures = json['planFeatures'] as Map<String, dynamic>?;
    final config = json['configuration'] as Map<String, dynamic>?;

    if (planFeatures != null) {
      void addBool(String key, String title) {
        if (planFeatures.containsKey(key)) {
          detailedFeatures.add(FeatureItem(title: title, isAvailable: planFeatures[key] == true));
        }
      }
      
      addBool('createAndDownloadCV', 'Create & Download CV');
      addBool('createGigs', 'Create Gigs');
      addBool('accessLibrary', 'Access Library');
      addBool('accessQuestionBank', 'Access Question Bank');
      addBool('applyForJobs', 'Apply for Jobs');
      addBool('applyForScholarships', 'Apply for Scholarships');
      addBool('accessFursaZone', 'Access Fursa Zone');
      addBool('convertFiles', 'Convert Files');
      addBool('aiChat', 'AI Chat');
      addBool('aiFindTodaysTasks', 'AI Find Today\'s Tasks');
      addBool('aiCreatePlans', 'AI Create Plans');
      addBool('aiExamQuizGeneration', 'AI Exam/Quiz Generation');
      addBool('aiStudyPlanCreation', 'AI Study Plan Creation');
      addBool('aiStudyPlanSessions', 'AI Study Plan Sessions');
      addBool('aiStudyPlanSessionChat', 'AI Study Plan Session Chat');
      addBool('referral', 'Referral Program');

      if (planFeatures.containsKey('aiQueryLimit')) {
        bool unlimited = planFeatures['aiUnlimited'] == true;
        int limit = _toInt(planFeatures['aiQueryLimit']) ?? 0;
        detailedFeatures.add(FeatureItem(
          title: 'AI Query Limit',
          isAvailable: unlimited || limit > 0,
          subtitle: unlimited ? 'Unlimited' : (limit > 0 ? '$limit' : null),
        ));
      }
      
      if (planFeatures.containsKey('fileConversionLimit')) {
        bool unlimited = planFeatures['fileConversionUnlimited'] == true;
        int limit = _toInt(planFeatures['fileConversionLimit']) ?? 0;
        detailedFeatures.add(FeatureItem(
          title: 'File Conversion Limit',
          isAvailable: unlimited || limit > 0,
          subtitle: unlimited ? 'Unlimited' : (limit > 0 ? '$limit' : null),
        ));
      }
    }

    if (config != null) {
      void addConfig(String limitKey, String periodKey, String title) {
        if (config.containsKey(limitKey)) {
          int limit = _toInt(config[limitKey]) ?? 0;
          String period = config[periodKey]?.toString() ?? '';
          detailedFeatures.add(FeatureItem(
            title: title,
            isAvailable: limit > 0,
            subtitle: limit > 0 ? '$limit per $period' : null,
          ));
        }
      }

      addConfig('bookAccessLimit', 'bookAccessPeriod', 'Book Access');
      addConfig('jobApplicationLimit', 'jobApplicationPeriod', 'Job Applications');
      addConfig('questionBankLimit', 'questionBankPeriod', 'Question Bank Access');
      addConfig('conversionLimit', 'conversionPeriod', 'Conversions');
      addConfig('cvGenerationLimit', 'cvGenerationPeriod', 'CV Generations');
    }

    return StudentCreateTaskUpgradeModel(
      id: _toInt(json['id']),
      title: json['name']?.toString() ?? 'Subscription',
      subTitle: json['description']?.toString() ?? '',
      isTrial: json['is_trial'] == true || json['isTrial'] == true,
      priceOptions: priceOptions,
      initialSelectedPrice: initialSelectedPrice,
      features: features,
      detailedFeatures: detailedFeatures,
      initializedChecked: initializedChecked,
    );
  }

  static List<PriceOption> _extractPriceOptions(dynamic prices) {
    if (prices is! List || prices.isEmpty) return [];

    final parsedPrices = prices
        .whereType<Map>()
        .where((price) => price['is_active'] == true)
        .map((price) {
          final id = _toInt(price['id']) ?? 0;
          final amount = _toDouble(price['amount']) ?? 0.0;
          final currency = price['currency']?.toString() ?? '';
          final billingInterval = price['billing_interval']?.toString() ?? 
                                  price['billingInterval']?.toString() ?? '';
          final duration = _toInt(price['duration_in_days']) ?? 0;
          
          return PriceOption(
            id: id,
            amount: amount,
            currency: currency,
            billingInterval: billingInterval,
            durationInDays: duration,
            formattedCharge: _formatCharge(amount: amount, currency: currency, billingInterval: billingInterval),
          );
        })
        .toList(growable: false);

    return parsedPrices;
  }

  static String _formatCharge({
    required double? amount,
    required String currency,
    required String billingInterval,
  }) {
    if (amount == null) return '';

    final normalizedAmount = amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    final normalizedCurrency = currency.isEmpty ? '' : '$currency ';
    final normalizedInterval = billingInterval.isEmpty
        ? ''
        : '/$billingInterval';

    return '$normalizedCurrency$normalizedAmount$normalizedInterval';
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
