class PlayerModelMlb {
  static List<Map<String, dynamic>> mapPlayersToTeam(List<dynamic> players) {
    return players.asMap().entries.map((entry) {
      final player = entry.value;

      List<Map<String, String>> stats = [];
      if (player['batting_average'] != null) {
        stats.add({
          'value': (player['batting_average'] as num).toStringAsFixed(3),
          'label': 'Batting Average',
        });
      }
      if (player['games_played'] != null) {
        stats.add({
          'value': (player['games_played'] as num).toInt().toString(),
          'label': 'Games Played',
        });
      }
      if (player['runs'] != null) {
        stats.add({
          'value': (player['runs'] as num).toInt().toString(),
          'label': 'Runs',
        });
      }
      if (player['hits'] != null) {
        stats.add({
          'value': (player['hits'] as num).toInt().toString(),
          'label': 'Hits',
        });
      }
      if (player['innings_pitched'] != null) {
        stats.add({
          'value': (player['innings_pitched'] as num).toStringAsFixed(1),
          'label': 'Innings Pitched',
        });
      }
      if (player['strikeouts'] != null) {
        stats.add({
          'value': (player['strikeouts'] as num).toInt().toString(),
          'label': 'Strikeouts',
        });
      }
      if (player['earned_runs'] != null) {
        stats.add({
          'value': (player['earned_runs'] as num).toInt().toString(),
          'label': 'Earned Runs',
        });
      }
      if (player['performance_score'] != null) {
        stats.add({
          'value': (player['performance_score'] as num).toStringAsFixed(3),
          'label': 'Predicted Score',
        });
      }

      return {
        'playerImagePath': 'assets/images/player.png',
        'playerName': player['player_name'] ?? 'Unknown Player',
        'playerPosition': player['player_position'] ?? 'Unknown Position',
        'aiConfidence': player['confidence_score'] != null
            ? '${((player['confidence_score'] as num) * 100).toStringAsFixed(0)}%'
            : 'N/A',
        'stats': stats,
      };
    }).toList();
  }
}
