class StudentPublicProfileFriendsModel {
  final int? id;
  final String imageUrl;
  final String name;
  final int mutualNumber;
  final String uvName;

  StudentPublicProfileFriendsModel({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.mutualNumber,
    required this.uvName,
  });
}
