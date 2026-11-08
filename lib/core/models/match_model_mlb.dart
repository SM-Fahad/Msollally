class MatchModelMlb {
  final Prediction? prediction;
  final MatchInfo info;

  MatchModelMlb({required this.prediction, required this.info});

  factory MatchModelMlb.fromJson(Map<String, dynamic> json) {
    return MatchModelMlb(
      prediction: json['pred'] != null && json['pred']['error'] == null
          ? Prediction.fromJson(json['pred'])
          : (json['home_win_probability'] != null &&
                    json['home_win_probability'].toString().isNotEmpty
                ? Prediction.fromMlbJson(json)
                : null),
      info: MatchInfo.fromJson(json['info'] ?? {}),
    );
  }
}

class Prediction {
  final String? homeWinProbability;
  final String? awayWinProbability;
  final String? confidence;
  final Map<String, int>? predictedScores;

  Prediction({
    this.homeWinProbability,
    this.awayWinProbability,
    this.confidence,
    this.predictedScores,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      homeWinProbability: json['home_win_probability']?.toString(),
      awayWinProbability: json['away_win_probability']?.toString(),
      confidence: json['confidence']?.toString(),
      predictedScores: json['predicted_scores'] != null
          ? (json['predicted_scores'] as Map).map(
              (key, value) => MapEntry(
                key.toString(),
                value is int ? value : int.tryParse(value.toString()) ?? 0,
              ),
            )
          : null,
    );
  }

  factory Prediction.fromMlbJson(Map<String, dynamic> json) {
    return Prediction(
      homeWinProbability: json['home_win_probability']?.toString(),
      awayWinProbability: json['away_win_probability']?.toString(),
      confidence: json['confidence']?.toString(),
      predictedScores: json['predicted_scores'] != null
          ? (json['predicted_scores'] as Map).map(
              (key, value) => MapEntry(
                key.toString(),
                value is int ? value : int.tryParse(value.toString()) ?? 0,
              ),
            )
          : null,
    );
  }
}

class MatchInfo {
  final String date;
  final String timezone;
  final String seasonType;
  final String venue;
  final String formattedDate;
  final String datetimeUtc;
  final String hometeam;
  final String awayteam;

  MatchInfo({
    required this.date,
    required this.timezone,
    required this.seasonType,
    required this.venue,
    required this.formattedDate,
    required this.datetimeUtc,
    required this.hometeam,
    required this.awayteam,
  });

  factory MatchInfo.fromJson(Map<String, dynamic> json) {
    return MatchInfo(
      date: json['date']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      seasonType: json['seasonType']?.toString() ?? '',
      venue: json['venue']?.toString() ?? '',
      formattedDate: json['formatted_date']?.toString() ?? '',
      datetimeUtc: json['datetime_utc']?.toString() ?? '',
      hometeam: json['hometeam']?.toString() ?? '',
      awayteam: json['awayteam']?.toString() ?? '',
    );
  }
}
