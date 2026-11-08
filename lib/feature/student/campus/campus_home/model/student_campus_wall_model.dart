class StudentCampusStatusModel {
  final String title;
  final String subtitle;
  final String imageUrl;
  final int time;
  final String status;
  final int like;
  final int comment;
  final int share;
  final String? statusImageUrl;

  StudentCampusStatusModel({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.time,
    required this.status,
    required this.like,
    required this.comment,
    required this.share,
    this.statusImageUrl,
  });
}
