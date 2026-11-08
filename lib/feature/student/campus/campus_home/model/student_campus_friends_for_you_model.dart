class StudentCampusFriendsForYouModel {
  final int id;
  final String imageUrl;
  final String name;
  final int mutualNumber;
  final String uvName;
  final String program;
  final String yearOfStudy;

  StudentCampusFriendsForYouModel({
    this.id = 0,
    required this.name,
    required this.imageUrl,
    required this.mutualNumber,
    required this.uvName,
    this.program = '',
    this.yearOfStudy = '',
  });
}

