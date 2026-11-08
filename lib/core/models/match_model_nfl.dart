class MatchModelNfl {
  final Prediction? prediction;
  final MatchInfo info;

  MatchModelNfl({required this.prediction, required this.info});

  factory MatchModelNfl.fromJson(Map<String, dynamic> json) {
    return MatchModelNfl(
      prediction: json['pred'] != null && json['pred']['error'] == null
          ? Prediction.fromJson(json['pred'])
          : json['home_win_probability'] != null &&
                json['home_win_probability'] != ''
          ? Prediction.fromNFLJson(json)
          : null,
      info: MatchInfo.fromJson(json['info'] ?? json),
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
          ? Map<String, int>.from(
              json['predicted_scores'].map(
                (key, value) => MapEntry(
                  key,
                  value is int ? value : int.parse(value.toString()),
                ),
              ),
            )
          : null,
    );
  }

  factory Prediction.fromNFLJson(Map<String, dynamic> json) {
    return Prediction(
      homeWinProbability: json['home_win_probability']?.toString(),
      awayWinProbability: json['away_win_probability']?.toString(),
      confidence: json['confidence']?.toString(),
      predictedScores: json['predicted_scores'] != null
          ? Map<String, int>.from(
              json['predicted_scores'].map(
                (key, value) => MapEntry(
                  key,
                  value is int
                      ? value
                      : (value != '' ? int.parse(value.toString()) : 0),
                ),
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
      date: json['@time'] ?? json['date'] ?? '',
      timezone: json['timezone'] ?? '',
      seasonType: json['@status'] ?? json['seasonType'] ?? '',
      venue: json['@venue'] ?? json['venue'] ?? '',
      formattedDate: json['@formatted_date'] ?? json['formatted_date'] ?? '',
      datetimeUtc: json['@datetime_utc'] ?? json['datetime_utc'] ?? '',
      hometeam:
          json['home_team'] ??
          json['hometeam']?['@name'] ??
          json['hometeam'] ??
          '',
      awayteam:
          json['away_team'] ??
          json['awayteam']?['@name'] ??
          json['awayteam'] ??
          '',
    );
  }
}
