class ProPartnerMeResponse {
  final int? id;
  final ProPartnerProfile? profile;
  final List<dynamic> posts;
  final String? username;
  final String? phoneNumber;
  final String? role;
  final String? referCode;
  final String? referalLink;
  final bool? isSuspend;
  final List<dynamic> friends;

  const ProPartnerMeResponse({
    required this.id,
    required this.profile,
    required this.posts,
    required this.username,
    required this.phoneNumber,
    required this.role,
    required this.referCode,
    required this.referalLink,
    required this.isSuspend,
    required this.friends,
  });

  factory ProPartnerMeResponse.fromJson(Map<String, dynamic> json) {
    return ProPartnerMeResponse(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      profile: (json['profile'] is Map<String, dynamic>)
          ? ProPartnerProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
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

class ProPartnerProfile {
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
  final String? cellPhoneNumber;
  final String? subjectTaught;
  final String? location;
  final String? revenue;
  final String? profileVisibility;
  final String? seePlan;
  final String? sendRequest;
  final String? seeClass;
  final String? canMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProPartnerProfile({
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
    required this.cellPhoneNumber,
    required this.subjectTaught,
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

  factory ProPartnerProfile.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) => v is int ? v : int.tryParse('$v');

    return ProPartnerProfile(
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
      companyName: json['companyName']?.toString(),
      companyType: json['companyType']?.toString(),
      employeeCountRange: json['employeeCountRange']?.toString(),
      cellPhoneNumber: json['cellPhoneNumber']?.toString(),
      subjectTaught: json['subjectTaught']?.toString(),
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
