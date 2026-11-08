class StudentCampusLeaderboardModel {
  final String name;
  final String imageUrl;
  final int points;
  final int? streakDays;
  final String? weeklyWins;
  final String emoji;
  final int rank;
  final bool isCurrentUser;

  StudentCampusLeaderboardModel({
    required this.name,
    required this.imageUrl,
    required this.points,
    this.streakDays,
    required this.emoji,
    required this.rank,
    this.weeklyWins,
    this.isCurrentUser = false,
  });

  factory StudentCampusLeaderboardModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final profile = user['profile'] ?? {};
    final name =
        json['name'] ??
        json['fullName'] ??
        profile['fullName'] ??
        user['fullName'] ??
        user['name'] ??
        user['username'] ??
        'Unknown';
    final points = json['points'] ?? json['totalPoints'] ?? json['coins'] ?? 0;
    final rawPic =
        json['imageUrl'] ??
        json['imagePath'] ??
        profile['profilePicture'] ??
        user['profilePicture'] ??
        user['avatar'];
    final imageUrl = (rawPic != null && rawPic.toString().isNotEmpty)
        ? rawPic.toString()
        : '';

    return StudentCampusLeaderboardModel(
      name: name.toString(),
      imageUrl: imageUrl,
      points: points is int ? points : int.tryParse('$points') ?? 0,
      streakDays: json['streakDays'] is int
          ? json['streakDays']
          : int.tryParse('${json['streakDays']}'),
      emoji: json['emoji'] ?? '',
      rank: json['rank'] is int
          ? json['rank']
          : int.tryParse('${json['rank']}') ?? 0,
      weeklyWins: json['weeklyWins']?.toString(),
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }

  StudentCampusLeaderboardModel copyWith({
    String? name,
    String? imageUrl,
    int? points,
    int? streakDays,
    String? weeklyWins,
    String? emoji,
    int? rank,
    bool? isCurrentUser,
  }) {
    return StudentCampusLeaderboardModel(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      points: points ?? this.points,
      streakDays: streakDays ?? this.streakDays,
      weeklyWins: weeklyWins ?? this.weeklyWins,
      emoji: emoji ?? this.emoji,
      rank: rank ?? this.rank,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
