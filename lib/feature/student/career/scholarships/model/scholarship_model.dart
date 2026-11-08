import 'package:msollaally/core/services/end_points.dart';

class ScholarshipModel {
  final int id;
  final String title;
  final String foundationName;
  final String amount;
  final String currency;
  final String description;
  final String openDate;
  final String dueDate;
  final List<String> fieldsOfStudy;
  final String country;
  final bool isFullyFunded;
  final String minimumGPA;
  final String applicationStatus;
  final String thumbnailUrl;
  final bool isActive;
  final String adminApproval;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String foundationLogo;
  final String companyLogo;
  final String applicationLink;
  final String sponsorEmail;
  final Author author;

  ScholarshipModel({
    required this.id,
    required this.title,
    required this.foundationName,
    this.foundationLogo = '',
    this.companyLogo = '',
    this.applicationLink = '',
    this.sponsorEmail = '',
    required this.amount,
    required this.currency,
    required this.description,
    required this.openDate,
    required this.dueDate,
    required this.fieldsOfStudy,
    required this.country,
    required this.isFullyFunded,
    required this.minimumGPA,
    required this.applicationStatus,
    required this.thumbnailUrl,
    required this.isActive,
    required this.adminApproval,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
  });

  String get fullThumbnailUrl {
    if (thumbnailUrl.isEmpty) return '';
    if (thumbnailUrl.startsWith('http')) return thumbnailUrl;
    return '${Urls.baseUrl}$thumbnailUrl';
  }

  String get effectiveFoundationLogo {
    if (foundationLogo.isNotEmpty) return foundationLogo;
    if (companyLogo.isNotEmpty) return companyLogo;
    return '';
  }

  String get fullFoundationLogoUrl {
    final logo = effectiveFoundationLogo;
    if (logo.isEmpty) return '';
    if (logo.startsWith('http')) return logo;
    return '${Urls.baseUrl}$logo';
  }

  factory ScholarshipModel.fromJson(Map<String, dynamic> json) {
    return ScholarshipModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      foundationName: json['foundationName'] ?? '',
      foundationLogo:
          json['foundationLogo'] ??
          json['companyLogo'] ??
          json['logo'] ??
          '',
      companyLogo:
          json['companyLogo'] ??
          json['foundationLogo'] ??
          json['logo'] ??
          '',
      applicationLink:
          json['applicationLink'] ??
          json['applicationUrl'] ??
          json['link'] ??
          json['websiteUrl'] ??
          json['url'] ??
          '',
      sponsorEmail:
          json['sponsorEmail'] ??
          json['recruiterEmail'] ??
          json['email'] ??
          '',
      amount: json['amount']?.toString() ?? '0',
      currency: json['currency'] ?? 'USD',
      description: json['description'] ?? '',
      openDate: json['openDate'] ?? '',
      dueDate: json['dueDate'] ?? '',
      fieldsOfStudy: List<String>.from(json['fieldsOfStudy'] ?? []),
      country: json['country'] ?? '',
      isFullyFunded: json['isFullyFunded'] ?? false,
      minimumGPA: json['minimumGPA']?.toString() ?? '0.0',
      applicationStatus: json['applicationStatus'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      isActive: json['isActive'] ?? false,
      adminApproval:
          json['admminApproval'] ??
          '', // Note the typo in JSON 'admminApproval'
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      author: Author.fromJson(json['author'] ?? {}),
    );
  }
}

class Author {
  final int id;
  final String username;

  Author({required this.id, required this.username});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(id: json['id'] ?? 0, username: json['username'] ?? '');
  }
}
