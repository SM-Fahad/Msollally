class StudentProfileFriendsModel {
  final int id;
  final String imageUrl;
  final String name;
  final int mutualNumber;
  final String uvName;

  StudentProfileFriendsModel({
    this.id = 0,
    required this.name,
    required this.imageUrl,
    required this.mutualNumber,
    required this.uvName,
  });
}
