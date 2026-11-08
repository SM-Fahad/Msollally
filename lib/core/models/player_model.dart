class PlayerModel {
  static List<Map<String, dynamic>> mapPlayersToTeam(List<dynamic> players) {
    return players.asMap().entries.map((entry) {
      final player = entry.value;

      List<Map<String, String>> stats = [];
      if (player['passing_touchdowns_used'] != null) {
        stats.add({
          'value': (player['passing_touchdowns_used'] as num)
              .toInt()
              .toString(),
          'label': 'Passing Touchdowns',
        });
      }
      if (player['interceptions_used'] != null) {
        stats.add({
          'value': (player['interceptions_used'] as num).toInt().toString(),
          'label': 'Interceptions',
        });
      }
      if (player['rushing_yards_used'] != null) {
        stats.add({
          'value': (player['rushing_yards_used'] as num).toInt().toString(),
          'label': 'Rushing Yards',
        });
      }
      if (player['rushing_touchdowns_used'] != null) {
        stats.add({
          'value': (player['rushing_touchdowns_used'] as num)
              .toInt()
              .toString(),
          'label': 'Rushing Touchdowns',
        });
      }
      if (player['receiving_yards_used'] != null) {
        stats.add({
          'value': (player['receiving_yards_used'] as num).toInt().toString(),
          'label': 'Receiving Yards',
        });
      }
      if (player['receiving_touchdowns_used'] != null) {
        stats.add({
          'value': (player['receiving_touchdowns_used'] as num)
              .toInt()
              .toString(),
          'label': 'Receiving Touchdowns',
        });
      }
      if (player['fumbles_used'] != null) {
        stats.add({
          'value': (player['fumbles_used'] as num).toInt().toString(),
          'label': 'Fumbles',
        });
      }
      if (player['total_tackles_used'] != null) {
        stats.add({
          'value': (player['total_tackles_used'] as num).toInt().toString(),
          'label': 'Total Tackles',
        });
      }
      if (player['sacks_used'] != null) {
        stats.add({
          'value': (player['sacks_used'] as num).toInt().toString(),
          'label': 'Sacks',
        });
      }
      if (player['forced_fumbles_used'] != null) {
        stats.add({
          'value': (player['forced_fumbles_used'] as num).toInt().toString(),
          'label': 'Forced Fumbles',
        });
      }

      return {
        'playerImagePath': 'assets/images/player.png',
        'playerName': player['player_name'] ?? 'Unknown Player',
        'playerPosition': player['player_position'] ?? 'Unknown Position',
        'aiConfidence': player['confidence_score'] != null
            ? '${(player['confidence_score'] * 100).toStringAsFixed(0)}%'
            : 'N/A',
        'stats': stats,
      };
    }).toList();
  }
}
