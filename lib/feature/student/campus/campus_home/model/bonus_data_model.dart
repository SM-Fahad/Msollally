class BonusDataModel {
  final String type;
  final bool claimed;
  final int coins;

  BonusDataModel({
    required this.type,
    required this.claimed,
    required this.coins,
  });

  factory BonusDataModel.fromJson(Map<String, dynamic> json) {
    return BonusDataModel(
      type: json['type'] ?? '',
      claimed: json['claimed'] ?? false,
      coins: json['coins'] ?? 0,
    );
  }
}
