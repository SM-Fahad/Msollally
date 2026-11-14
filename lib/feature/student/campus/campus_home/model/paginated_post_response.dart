import 'package:msollaally/feature/student/campus/campus_home/model/post_model.dart';

class PaginatedPostResponse {
  final List<PostModel> posts;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedPostResponse({
    required this.posts,
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 1,
    required this.hasNextPage,
    this.hasPreviousPage = false,
  });

  factory PaginatedPostResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> postsData =
        (json['data'] is List) ? json['data'] as List : [];
    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : <String, dynamic>{};

    return PaginatedPostResponse(
      posts: postsData
          .whereType<Map<String, dynamic>>()
          .map((e) => PostModel.fromJson(e))
          .toList(),
      page: meta['page'] is int
          ? meta['page']
          : int.tryParse('${meta['page']}') ?? 1,
      limit: meta['limit'] is int
          ? meta['limit']
          : int.tryParse('${meta['limit']}') ?? 20,
      total: meta['total'] is int
          ? meta['total']
          : int.tryParse('${meta['total']}') ?? postsData.length,
      totalPages: meta['totalPages'] is int
          ? meta['totalPages']
          : int.tryParse('${meta['totalPages']}') ?? 1,
      hasNextPage: meta['hasNextPage'] == true,
      hasPreviousPage: meta['hasPreviousPage'] == true,
    );
  }
}
