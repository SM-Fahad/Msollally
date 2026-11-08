import 'package:get/get.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String isbn;
  final String? pdfFileId;
  final PdfFile? pdfFile;
  final String coverImageId;
  final CoverImage? coverImage;
  final String pdfUrl; // Kept for backward compatibility or convenience
  final int pageCount;
  final RxInt totalLikes = 0.obs;
  final RxInt totalReads = 0.obs;
  final RxBool isLiked = false.obs;
  final bool isActive;
  final String accessType;
  final int categoryId;
  final Category? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  var isWishlisted = false.obs;
  var isRead = false.obs;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.isbn,
    this.pdfFileId,
    this.pdfFile,
    required this.coverImageId,
    this.coverImage,
    this.pdfUrl = '',
    required this.pageCount,
    required int totalLikes,
    required int totalReads,
    required this.isActive,
    required this.accessType,
    required this.categoryId,
    this.category,
    this.createdAt,
    this.updatedAt,
    bool isWishlistedValue = false,
    bool isReadValue = false,
    bool isLikedValue = false,
  }) {
    this.totalLikes.value = totalLikes;
    this.totalReads.value = totalReads;
    this.isLiked.value = isLikedValue;
    isWishlisted.value = isWishlistedValue;
    isRead.value = isReadValue;
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      isbn: map['isbn'] ?? '',
      pdfFileId: map['pdfFileId'],
      pdfFile: map['pdfFile'] != null ? PdfFile.fromMap(map['pdfFile']) : null,
      coverImageId: map['coverImageId'] ?? '',
      coverImage: map['coverImage'] != null
          ? CoverImage.fromMap(map['coverImage'])
          : null,
      pdfUrl:
          map['pdfUrl'] ??
          map['fileUrl'] ??
          map['url'] ??
          map['pdfFile']?['url'] ??
          '',
      pageCount: map['pageCount'] ?? 0,
      totalLikes: map['totalLikes'] ?? 0,
      totalReads: map['totalReads'] ?? 0,
      isActive: map['isActive'] ?? false,
      accessType: map['accessType'] ?? '',
      categoryId: map['categoryId'] ?? 0,
      category: map['category'] != null
          ? Category.fromMap(map['category'])
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      isWishlistedValue: map['isWishlisted'] ?? false,
      isReadValue: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'isbn': isbn,
      'pdfFileId': pdfFileId,
      'pdfFile': pdfFile?.toMap(),
      'coverImageId': coverImageId,
      'coverImage': coverImage?.toMap(),
      'pdfUrl': pdfUrl,
      'pageCount': pageCount,
      'totalLikes': totalLikes,
      'totalReads': totalReads,
      'isActive': isActive,
      'accessType': accessType,
      'categoryId': categoryId,
      'category': category?.toMap(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isWishlisted': isWishlisted.value,
      'isRead': isRead.value,
    };
  }
}

class PdfFile {
  final String id;
  final String filename;
  final String originalFilename;
  final String path;
  final String url;
  final String fileType;
  final String mimeType;
  final int size;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PdfFile({
    required this.id,
    required this.filename,
    required this.originalFilename,
    required this.path,
    required this.url,
    required this.fileType,
    required this.mimeType,
    required this.size,
    this.createdAt,
    this.updatedAt,
  });

  factory PdfFile.fromMap(Map<String, dynamic> map) {
    return PdfFile(
      id: map['id'] ?? '',
      filename: map['filename'] ?? '',
      originalFilename: map['originalFilename'] ?? '',
      path: map['path'] ?? '',
      url: map['url'] ?? '',
      fileType: map['fileType'] ?? '',
      mimeType: map['mimeType'] ?? '',
      size: map['size'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'originalFilename': originalFilename,
      'path': path,
      'url': url,
      'fileType': fileType,
      'mimeType': mimeType,
      'size': size,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class CoverImage {
  final String id;
  final String? filename;
  final String originalFilename;
  final String? path;
  final String url;
  final String? fileType;
  final String? mimeType;
  final int? size;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CoverImage({
    required this.id,
    this.filename,
    required this.originalFilename,
    this.path,
    required this.url,
    this.fileType,
    this.mimeType,
    this.size,
    this.createdAt,
    this.updatedAt,
  });

  factory CoverImage.fromMap(Map<String, dynamic> map) {
    return CoverImage(
      id: map['id'] ?? '',
      filename: map['filename'],
      originalFilename: map['originalFilename'] ?? '',
      path: map['path'],
      url: map['url'] ?? '',
      fileType: map['fileType'],
      mimeType: map['mimeType'],
      size: map['size'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'originalFilename': originalFilename,
      'path': path,
      'url': url,
      'fileType': fileType,
      'mimeType': mimeType,
      'size': size,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Category {
  final int id;
  final String name;
  final String iconUrl;
  final String? description;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.iconUrl,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      description: map['description'],
      isActive: map['isActive'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
