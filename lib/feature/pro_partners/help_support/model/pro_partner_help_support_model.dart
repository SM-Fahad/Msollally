class ProPartnerHelpSupportModel {
  final int? id;
  final String? title;
  final String? description;
  final String? type;
  final String? supportType;
  final String? otherSupportType;
  final String? pdfUrl;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProPartnerHelpSupportModel({
    this.id,
    this.title,
    this.description,
    this.type,
    this.supportType,
    this.otherSupportType,
    this.pdfUrl,
    this.imageUrl,
    this.videoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ProPartnerHelpSupportModel.fromJson(Map<String, dynamic> json) {
    return ProPartnerHelpSupportModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      type: json['type']?.toString(),
      supportType: json['supportType']?.toString(),
      otherSupportType: json['otherSupportType']?.toString(),
      pdfUrl: json['pdfUrl']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }
}

class ProPartnerHelpSupportResponseModel {
  final List<ProPartnerHelpSupportModel> data;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  ProPartnerHelpSupportResponseModel({
    required this.data,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory ProPartnerHelpSupportResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final dataNode = json['data'] is Map ? json['data'] : json;
      final metaNode = json['meta'] is Map ? json['meta'] : (dataNode['meta'] is Map ? dataNode['meta'] : {});
      
      List rawData = [];
      if (json['data'] is List) {
        rawData = json['data'];
      } else if (dataNode['data'] is List) {
        rawData = dataNode['data'];
      }

      final List<ProPartnerHelpSupportModel> parsedData = rawData
          .whereType<Map>()
          .map((item) => ProPartnerHelpSupportModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return ProPartnerHelpSupportResponseModel(
        data: parsedData,
        page: int.tryParse(metaNode['page']?.toString() ?? '') ?? 1,
        limit: int.tryParse(metaNode['limit']?.toString() ?? '') ?? 5,
        totalPages: int.tryParse(metaNode['totalPages']?.toString() ?? '') ?? 1,
        hasNextPage: metaNode['hasNextPage'] == true,
        hasPreviousPage: metaNode['hasPreviousPage'] == true,
      );
    } catch (e) {
      print("DEBUG: ProPartnerHelpSupportResponseModel Parse Error: $e");
      return ProPartnerHelpSupportResponseModel(
        data: [],
        page: 1,
        limit: 5,
        totalPages: 1,
        hasNextPage: false,
        hasPreviousPage: false,
      );
    }
  }
}
