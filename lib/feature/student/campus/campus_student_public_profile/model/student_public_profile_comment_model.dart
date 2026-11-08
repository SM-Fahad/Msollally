import 'package:get/get.dart';

class StudentPublicProfileCommentModel {
  final String name;
  final String comment;
  final int time;
  final String imageUrl;
  RxBool isLiked = false.obs;

  StudentPublicProfileCommentModel({
    required this.imageUrl,
    required this.name,
    required this.comment,
    required this.time,
    bool isLiked = false,
  }) {
    this.isLiked.value = isLiked;
  }
}
