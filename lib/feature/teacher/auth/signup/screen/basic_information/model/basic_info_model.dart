class BasicInfoModel {
  final String email;
  final String fullName;
  final String gender;
  final String? dateOfBirth;
  final int? universityId;
  final int? programId;
  final int? departmentId;
  final String? program;
  final String? faculty;
  final String? studentID;
  final int? enrollmentYear;
  final String? profilePicture;
  final String? bio;

  BasicInfoModel({
    required this.email,
    required this.fullName,
    required this.gender,
    this.dateOfBirth,
    this.universityId,
    this.programId,
    this.departmentId,
    this.program,
    this.faculty,
    this.studentID,
    this.enrollmentYear,
    this.profilePicture,
    this.bio,
  });

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (universityId != null) 'universityId': universityId,
      if (programId != null) 'programId': programId,
      if (departmentId != null) 'departmentId': departmentId,
      if (program != null) 'program': program,
      if (faculty != null) 'faculty': faculty,
      if (studentID != null) 'studentID': studentID,
      if (enrollmentYear != null) 'enrollmentYear': enrollmentYear,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (bio != null) 'bio': bio,
    };
  }

  // Create from JSON
  factory BasicInfoModel.fromJson(Map<String, dynamic> json) {
    return BasicInfoModel(
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'],
      universityId: json['universityId'],
      programId: json['programId'],
      departmentId: json['departmentId'],
      program: json['program'],
      faculty: json['faculty'],
      studentID: json['studentID'],
      enrollmentYear: json['enrollmentYear'],
      profilePicture: json['profilePicture'],
      bio: json['bio'],
    );
  }
}
