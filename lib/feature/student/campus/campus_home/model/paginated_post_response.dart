import 'package:msollaally/feature/student/campus/campus_home/model/post_model.dart';

class PaginatedPostResponse {
  final List<PostModel> posts;
  final bool hasNextPage;

  PaginatedPostResponse({
    required this.posts,
    required this.hasNextPage,
  });
}
