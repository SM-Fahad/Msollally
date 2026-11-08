class RecruiterMeResponse {
  final int? id;
  final RecruiterProfile? profile;
  final String? profilePicture;
  final String? coverPhoto;
  final List<dynamic> posts;
  final String? username;
  final String? phoneNumber;
  final String? role;
  final String? referCode;
  final String? referalLink;
  final bool? isSuspend;
  final List<dynamic> friends;

  const RecruiterMeResponse({
    required this.id,
    required this.profile,
    required this.profilePicture,
    required this.coverPhoto,
    required this.posts,
    required this.username,
    required this.phoneNumber,
    required this.role,
    required this.referCode,
    required this.referalLink,
    required this.isSuspend,
    required this.friends,
  });

  factory RecruiterMeResponse.fromJson(Map<String, dynamic> json) {
    final rawProfile = json['profile'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['profile'] as Map<String, dynamic>)
        : <String, dynamic>{};
    if (json['profilePicture'] != null &&
        rawProfile['profilePicture'] == null) {
      rawProfile['profilePicture'] = json['profilePicture'];
    }
    if (json['coverPhoto'] != null && rawProfile['coverPhoto'] == null) {
      rawProfile['coverPhoto'] = json['coverPhoto'];
    }

    return RecruiterMeResponse(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      profile: rawProfile.isNotEmpty
          ? RecruiterProfile.fromJson(rawProfile)
          : null,
      profilePicture:
          json['profilePicture']?.toString() ??
          rawProfile['profilePicture']?.toString(),
      coverPhoto:
          json['coverPhoto']?.toString() ??
          rawProfile['coverPhoto']?.toString(),
      posts: (json['posts'] is List)
          ? List<dynamic>.from(json['posts'])
          : const [],
      username: json['username']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      role: json['role']?.toString(),
      referCode: json['refer_code']?.toString(),
      referalLink: json['referal_link']?.toString(),
      isSuspend: json['isSuspend'] is bool ? json['isSuspend'] as bool : null,
      friends: (json['friends'] is List)
          ? List<dynamic>.from(json['friends'])
          : const [],
    );
  }
}

class RecruiterProfile {
  final int? id;
  final String? email;
  final String? fullName;
  final String? gender;
  final String? dateOfBirth;
  final int? universityId;
  final int? programId;
  final int? departmentId;
  final String? faculty;
  final bool? isVerified;
  final String? designation;
  final String? studentId;
  final int? enrollmentYear;
  final String? bio;
  final String? profilePicture;
  final String? coverPhoto;
  final bool? isReferalEnabled;
  final String? referalStatusLevel;
  final String? memberShip;
  final String? companyName;
  final String? companyType;
  final String? employeeCountRange;
  final String? location;
  final String? revenue;
  final String? profileVisibility;
  final String? seePlan;
  final String? sendRequest;
  final String? seeClass;
  final String? canMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RecruiterProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.universityId,
    required this.programId,
    required this.departmentId,
    required this.faculty,
    required this.isVerified,
    required this.designation,
    required this.studentId,
    required this.enrollmentYear,
    required this.bio,
    required this.profilePicture,
    required this.coverPhoto,
    required this.isReferalEnabled,
    required this.referalStatusLevel,
    required this.memberShip,
    required this.companyName,
    required this.companyType,
    required this.employeeCountRange,
    required this.location,
    required this.revenue,
    required this.profileVisibility,
    required this.seePlan,
    required this.sendRequest,
    required this.seeClass,
    required this.canMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecruiterProfile.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) => v is int ? v : int.tryParse('$v');

    return RecruiterProfile(
      id: toInt(json['id']),
      email: json['email']?.toString(),
      fullName: json['fullName']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      universityId: toInt(json['universityId']),
      programId: toInt(json['programId']),
      departmentId: toInt(json['departmentId']),
      faculty: json['faculty']?.toString(),
      isVerified: json['isVerified'] is bool
          ? json['isVerified'] as bool
          : null,
      designation: json['designation']?.toString(),
      studentId: json['studentID']?.toString(),
      enrollmentYear: toInt(json['enrollmentYear']),
      bio: json['bio']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      coverPhoto: json['coverPhoto']?.toString(),
      isReferalEnabled: json['is_referal_enabled'] is bool
          ? json['is_referal_enabled'] as bool
          : null,
      referalStatusLevel: json['referal_status_level']?.toString(),
      memberShip: json['memberShip']?.toString(),
      companyName:
          json['companyName']?.toString() ?? json['companyType']?.toString(),
      companyType: json['companyType']?.toString(),
      employeeCountRange: json['employeeCountRange']?.toString(),
      location: json['location']?.toString(),
      revenue: json['revenue']?.toString(),
      profileVisibility: json['profileVisibility']?.toString(),
      seePlan: json['seePlan']?.toString(),
      sendRequest: json['sendRequest']?.toString(),
      seeClass: json['seeClass']?.toString(),
      canMessage: json['canMessage']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}
