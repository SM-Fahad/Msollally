enum ProPartnersQuizStatus { completed, ongoing }

class ProPartnersFursaZoneModel {
  final int id;
  final String title;
  final String imageUrl;
  final ProPartnersQuizStatus status;
  final int registeredUsers;
  final String rawStatus;
  final DateTime? startDate;
  final DateTime? endDate;

  const ProPartnersFursaZoneModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.registeredUsers,
    required this.rawStatus,
    this.startDate,
    this.endDate,
  });

  factory ProPartnersFursaZoneModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? '').toString();
    final normalizedStatus = rawStatus.trim().toLowerCase();

    return ProPartnersFursaZoneModel(
      id: _toInt(json['id']),
      title:
          (json['competitionName'] ??
                  json['competitionname'] ??
                  json['title'] ??
                  'Untitled Competition')
              .toString(),
      imageUrl:
          (json['banner'] ??
                  json['promoImageLink'] ??
                  json['bannerImage'] ??
                  json['image'] ??
                  json['imageUrl'] ??
                  '')
              .toString(),
      status: normalizedStatus == 'completed'
          ? ProPartnersQuizStatus.completed
          : ProPartnersQuizStatus.ongoing,
      registeredUsers: _toInt(
        json['participants'] ??
            json['registeredUsers'] ??
            json['totalRegistrations'],
      ),
      rawStatus: rawStatus,
      startDate: _toDate(json['competitionStartDate'] ?? json['startdate']),
      endDate: _toDate(
        json['finalCompititionDate'] ??
            json['finalCompetitionDate'] ??
            json['qualificationDate'] ??
            json['endDate'],
      ),
    );
  }

  static int _toInt(dynamic value) => int.tryParse('$value') ?? 0;

  static DateTime? _toDate(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '');
}
