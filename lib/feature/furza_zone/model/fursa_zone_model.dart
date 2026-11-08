enum QuizStatus { completed, ongoing }

class FursaZoneModel {
  final String title;
  final String imagePath;
  final QuizStatus status;
  final int registeredUsers;
  final String? endDate;
  final double? price; // For payment
  final String? rightText;

  FursaZoneModel({
    required this.title,
    required this.imagePath,
    required this.status,
    required this.registeredUsers,
    this.endDate,
    this.price,
    this.rightText,
  });
}
