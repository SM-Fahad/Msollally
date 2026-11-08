class TableModel {
  final String teamName;
  final double winPercentage;
  final int totalMatches;
  final int winCount;
  final int lossCount;
  final double averageScore;

  TableModel({
    required this.teamName,
    required this.winPercentage,
    required this.totalMatches,
    required this.winCount,
    required this.lossCount,
    required this.averageScore,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      teamName: json['team_name'] as String,
      winPercentage: (json['win_percentage'] as num).toDouble(),
      totalMatches: json['total_matches'] as int,
      winCount: json['win_count'] as int,
      lossCount: json['loss_count'] as int,
      averageScore: (json['average_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_name': teamName,
      'win_percentage': winPercentage,
      'total_matches': totalMatches,
      'win_count': winCount,
      'loss_count': lossCount,
      'average_score': averageScore,
    };
  }
}
