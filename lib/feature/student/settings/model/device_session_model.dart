class DeviceSessionModel {
  final int id;
  final String ipAddress;
  final String userAgent;
  final String issuedAt;
  final String expiresAt;
  final bool isCurrentSession;

  DeviceSessionModel({
    required this.id,
    required this.ipAddress,
    required this.userAgent,
    required this.issuedAt,
    required this.expiresAt,
    required this.isCurrentSession,
  });

  factory DeviceSessionModel.fromJson(Map<String, dynamic> json) {
    return DeviceSessionModel(
      id: json['id'] ?? 0,
      ipAddress: json['ipAddress'] ?? '',
      userAgent: json['userAgent'] ?? '',
      issuedAt: json['issuedAt'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      isCurrentSession: json['isCurrentSession'] ?? false,
    );
  }
}
