class TeacherMeResponse {
  final int? id;
  final TeacherProfile? profile;
  final List<dynamic> posts;
  final String? username;
  final String? phoneNumber;
  final String? role;
  final String? referCode;
  final String? referalLink;
  final bool? isSuspend;
  final List<dynamic> friends;

  const TeacherMeResponse({
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

  factory TeacherMeResponse.fromJson(Map<String, dynamic> json) {
    return TeacherMeResponse(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      profile: (json['profile'] is Map<String, dynamic>)
          ? TeacherProfile.fromJson(json['profile'] as Map<String, dynamic>)
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

class TeacherUniversity {
  final int? id;
  final String? name;
  final String? fullName;
  final String? description;
  final String? website;
  final String? type;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final int? foundedYear;
  final String? logoUrl;
  final String? contactEmail;
  final String? contactPhone;
  final bool? isVerified;
  final String? ranking;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TeacherUniversity({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.website,
    required this.type,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.foundedYear,
    required this.logoUrl,
    required this.contactEmail,
    required this.contactPhone,
    required this.isVerified,
    required this.ranking,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeacherUniversity.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) => v is int ? v : int.tryParse('$v');

    return TeacherUniversity(
      id: toInt(json['id']),
      name: json['name']?.toString(),
      fullName: json['fullName']?.toString(),
      description: json['description']?.toString(),
      website: json['website']?.toString(),
      type: json['type']?.toString(),
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      foundedYear: toInt(json['foundedYear']),
      logoUrl: json['logoUrl']?.toString(),
      contactEmail: json['contactEmail']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      isVerified: json['isVerified'] is bool
          ? json['isVerified'] as bool
          : null,
      ranking: json['ranking']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class TeacherProfile {
  final int? id;
  final String? email;
  final String? fullName;
  final String? gender;
  final String? dateOfBirth;
  final int? universityId;
  final int? programId;
  final int? departmentId;
  final TeacherUniversity? university;
  final String? faculty;
  final String? department;
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
  final String? companyType;
  final String? employeeCountRange;
  final String? location;
  final String? revenue;
  final String? profileVisibility;
  final String? seePlan;
  final String? sendRequest;
  final String? seeClass;
  final String? canMessage;
  final String? cellPhoneNumber;
  final String? companyName;
  final String? subjectTaught;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TeacherProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.universityId,
    required this.programId,
    required this.departmentId,
    required this.university,
    required this.faculty,
    this.department,
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
    required this.companyType,
    required this.employeeCountRange,
    required this.location,
    required this.revenue,
    required this.profileVisibility,
    required this.seePlan,
    required this.sendRequest,
    required this.seeClass,
    required this.canMessage,
    required this.cellPhoneNumber,
    required this.companyName,
    required this.subjectTaught,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) => v is int ? v : int.tryParse('$v');

    return TeacherProfile(
      id: toInt(json['id']),
      email: json['email']?.toString(),
      fullName: json['fullName']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      universityId: toInt(json['universityId']),
      programId: toInt(json['programId']),
      departmentId: toInt(json['departmentId']),
      university: json['university'] is Map<String, dynamic>
          ? TeacherUniversity.fromJson(
              json['university'] as Map<String, dynamic>,
            )
          : null,
      faculty: json['faculty']?.toString() ??
          (json['department'] is Map<String, dynamic>
              ? json['department']['name']?.toString()
              : json['department']?.toString()) ??
          json['departmentName']?.toString(),
      department: (json['department'] is Map<String, dynamic>
              ? json['department']['name']?.toString()
              : json['department']?.toString()) ??
          json['departmentName']?.toString() ??
          json['faculty']?.toString(),
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
      companyType: json['companyType']?.toString(),
      employeeCountRange: json['employeeCountRange']?.toString(),
      location: json['location']?.toString(),
      revenue: json['revenue']?.toString(),
      profileVisibility: json['profileVisibility']?.toString(),
      seePlan: json['seePlan']?.toString(),
      sendRequest: json['sendRequest']?.toString(),
      seeClass: json['seeClass']?.toString(),
      canMessage: json['canMessage']?.toString(),
      cellPhoneNumber: json['cellPhoneNumber']?.toString(),
      companyName: json['companyName']?.toString(),
      subjectTaught: json['subjectTaught']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}
