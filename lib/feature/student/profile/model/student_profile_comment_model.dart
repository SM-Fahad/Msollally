import 'package:get/get.dart';

class StudentCommentModel {
  final String name;
  final String comment;
  final int time;
  final String imageUrl;
  RxBool isLiked = false.obs;

  StudentCommentModel({
    required this.imageUrl,
    required this.name,
    required this.comment,
    required this.time,
    bool isLiked = false,
  }) {
    this.isLiked.value = isLiked;
  }
}
