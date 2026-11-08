class GigAuthor {
  final int id;
  final String? username;
  final String? role;
  final String? phoneNumber;

  GigAuthor({required this.id, this.username, this.role, this.phoneNumber});

  factory GigAuthor.fromJson(Map<String, dynamic> json) => GigAuthor(
    id: json['id'] is int ? json['id'] : (int.tryParse('${json['id'] ?? json['userId'] ?? json['user_id']}') ?? 0),
    username: json['username'] ?? json['fullName'] ?? json['name'],
    role: json['role']?.toString(),
    phoneNumber: json['phoneNumber'] ?? json['phone'],
  );
}

class GigsModel {
  final int? gigId;
  final String title;
  final String description;
  final String price;
  final String currency;
  final String pricingType;
  final String locationType;
  final String address;
  final String country;
  final String city;
  final List<String> tags;
  final List<String> documents;
  final String? status;
  final GigAuthor? author;
  final String? createdAt;
  final String? updatedAt;

  GigsModel({
    this.gigId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.pricingType,
    required this.locationType,
    required this.address,
    required this.country,
    required this.city,
    this.tags = const [],
    this.documents = const [],
    this.status,
    this.author,
    this.createdAt,
    this.updatedAt,
  });

  factory GigsModel.fromJson(Map<String, dynamic> json) {
    final rawAuthor = json['author'] ?? json['user'] ?? json['student'] ?? json['creator'];
    final authorObj = rawAuthor is Map<String, dynamic>
        ? GigAuthor.fromJson(rawAuthor)
        : (rawAuthor is Map
            ? GigAuthor.fromJson(Map<String, dynamic>.from(rawAuthor))
            : (json['userId'] != null || json['user_id'] != null
                ? GigAuthor(
                    id: int.tryParse('${json['userId'] ?? json['user_id']}') ?? 0,
                    username: json['userName'] ?? json['username'],
                  )
                : null));

    return GigsModel(
      gigId: json['gigId'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? '0').toString(),
      currency: json['currency'] ?? 'USD',
      pricingType: json['pricingType'] ?? 'fixed',
      locationType: json['locationType'] ?? 'remote',
      address: json['address'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'],
      author: authorObj,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'price': double.tryParse(price) ?? 0,
    'currency': currency,
    'pricingType': pricingType,
    'locationType': locationType,
    'address': address,
    'country': country,
    'city': city,
    'tags': tags,
    'documents': documents,
  };
}
