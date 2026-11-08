class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final DateTime? endDateTime;
  final String location;
  final String status;
  final String coverImageUrl;
  final String mediaUrl;
  final String eventType;
  final String onlineLink;
  final String targetMajor;
  final String targetYear;
  final int maxAttendees;
  final bool allowGuestMessages;
  final List<String> tags;
  final bool isPublic;
  final bool requiresApproval;
  final int views;
  final int rsvps;
  final List<Map<String, dynamic>> coHosts;
  final bool isLikedByMe;
  final bool isRegisteredByMe;
  final bool isCheckedIn;
  final int likesCount;
  final String organizerName;
  final String organizerLogo;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.endDateTime,
    required this.location,
    required this.status,
    required this.coverImageUrl,
    required this.mediaUrl,
    required this.eventType,
    required this.onlineLink,
    required this.targetMajor,
    required this.targetYear,
    required this.maxAttendees,
    required this.allowGuestMessages,
    required this.tags,
    required this.isPublic,
    required this.requiresApproval,
    required this.views,
    required this.rsvps,
    required this.coHosts,
    this.isLikedByMe = false,
    this.isRegisteredByMe = false,
    this.isCheckedIn = false,
    this.likesCount = 0,
    this.organizerName = 'Partner',
    this.organizerLogo = '',
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final startDateRaw = json['startDate'];
    final startDate = DateTime.tryParse(startDateRaw?.toString() ?? '');
    final endDate = DateTime.tryParse(json['endDate']?.toString() ?? '');
    final computedStatus = _computeStatus(
      start: startDate,
      end: endDate,
      apiStatus: json['status']?.toString(),
    );
    final tagsRaw = json['tags'];

    final author = json['author'] ?? json['creator'] ?? json['user'] ?? json['organizer'] ?? json['company'] ?? json['sponsor'];
    String organizerName = (json['companyName'] ?? json['company'] ?? json['organizerName'] ?? json['organizationName'] ?? '').toString();
    String organizerLogo = (json['companyLogo'] ?? json['organizerLogo'] ?? json['organizationLogo'] ?? json['logo'] ?? '').toString();

    if (author is Map) {
      if (organizerName.isEmpty || organizerName == 'Partner') {
        organizerName = (author['companyName'] ??
                author['company'] ??
                author['proPartnerName'] ??
                author['fullName'] ??
                author['name'] ??
                author['username'] ??
                'Partner')
            .toString();
      }
      final profile = author['profile'] is Map ? author['profile'] : null;
      if (organizerLogo.isEmpty) {
        organizerLogo = (profile?['profilePicture'] ??
                profile?['companyLogo'] ??
                author['companyLogo'] ??
                author['profilePicture'] ??
                author['avatar'] ??
                author['logo'] ??
                '')
            .toString();
      }
    } else if (organizerName.isEmpty) {
      organizerName = 'Partner';
    }

    return EventModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      dateTime: startDate ?? DateTime.now(),
      endDateTime: endDate,
      location: (json['location'] ?? '').toString(),
      status: computedStatus,
      coverImageUrl: (json['coverImageUrl'] ?? '').toString(),
      mediaUrl: (json['mediaUrl'] ?? '').toString(),
      eventType: (json['eventType'] ?? '').toString(),
      onlineLink: (json['onlineLink'] ?? '').toString(),
      targetMajor: (json['targetMajor'] ?? '').toString(),
      targetYear: (json['targetYear'] ?? '').toString(),
      maxAttendees: _toInt(json['maxAttendees']),
      allowGuestMessages: json['allowGuestMessages'] == true,
      tags: tagsRaw is List
          ? tagsRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : [],
      isPublic: json['isPublic'] != false,
      requiresApproval: json['requiresApproval'] == true,
      views: _toInt(json['viewCount'] ?? json['views']),
      rsvps: _toInt(json['attendeeCount'] ?? json['rsvps']),
      coHosts: _parseCoHosts(json['coHosts'] ?? json['cohosts']),
      isLikedByMe: json['isLikedByMe'] == true,
      isRegisteredByMe: json['userAttendance'] != null,
      isCheckedIn:
          json['userAttendance'] is Map &&
          (json['userAttendance']['status']?.toString().toLowerCase() ==
                  'checked_in' ||
              json['userAttendance']['isCheckedIn'] == true ||
              json['userAttendance']['checkedIn'] == true),
      likesCount: _toInt(json['likeCount'] ?? json['likesCount']),
      organizerName: organizerName,
      organizerLogo: organizerLogo,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<Map<String, dynamic>> _parseCoHosts(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((entry) {
          final map = Map<String, dynamic>.from(entry);
          final profile = map['profile'];
          final profileMap = profile is Map<String, dynamic>
              ? profile
              : profile is Map
              ? Map<String, dynamic>.from(profile)
              : <String, dynamic>{};
          return {
            'id': _toInt(map['id']),
            'fullName':
                (profileMap['fullName'] ??
                        map['fullName'] ??
                        map['username'] ??
                        '')
                    .toString(),
            'image':
                (profileMap['profilePicture'] ??
                        map['image'] ??
                        map['profilePicture'] ??
                        '')
                    .toString(),
            'username': (map['username'] ?? '').toString(),
          };
        })
        .where((entry) => _toInt(entry['id']) > 0)
        .toList();
  }

  static String _computeStatus({
    required DateTime? start,
    required DateTime? end,
    required String? apiStatus,
  }) {
    final now = DateTime.now().toUtc();
    final normalizedApiStatus = (apiStatus ?? '').toLowerCase();
    if (normalizedApiStatus == 'cancelled') return 'Cancelled';
    if (start != null && now.isBefore(start.toUtc())) return 'Upcoming';
    if (end != null && now.isAfter(end.toUtc())) return 'Completed';
    if (normalizedApiStatus == 'draft') return 'Draft';
    return 'Live';
  }
}
