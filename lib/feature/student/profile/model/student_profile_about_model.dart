import 'package:flutter/material.dart';

class StudentProfileAboutModel {
  final String? email;
  final String? fullName;
  final String? gender;
  final String? dateOfBirth;
  final String? program;
  final String? faculty;
  final String? studentID;
  final int? enrollmentYear;
  final String? profilePicture;
  final String? bio;
  final String title;
  final String titleValue;
  final VoidCallback? ontap;

  StudentProfileAboutModel({
    this.email,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.program,
    this.faculty,
    this.studentID,
    this.enrollmentYear,
    this.profilePicture,
    this.bio,
    required this.title,
    required this.titleValue,
    this.ontap,
  });

  factory StudentProfileAboutModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileAboutModel(
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      program: json['program'] as String?,
      faculty: json['faculty'] as String?,
      studentID: json['studentID'] as String?,
      enrollmentYear: json['enrollmentYear'] as int?,
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      title: json['title'] as String? ?? '',
      titleValue: json['titleValue'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'program': program,
      'faculty': faculty,
      'studentID': studentID,
      'enrollmentYear': enrollmentYear,
      'profilePicture': profilePicture,
      'bio': bio,
      'title': title,
      'titleValue': titleValue,
    };
  }

  StudentProfileAboutModel copyWith({
    String? email,
    String? fullName,
    String? gender,
    String? dateOfBirth,
    String? program,
    String? faculty,
    String? studentID,
    int? enrollmentYear,
    String? profilePicture,
    String? bio,
    String? title,
    String? titleValue,
    VoidCallback? ontap,
  }) {
    return StudentProfileAboutModel(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      program: program ?? this.program,
      faculty: faculty ?? this.faculty,
      studentID: studentID ?? this.studentID,
      enrollmentYear: enrollmentYear ?? this.enrollmentYear,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      title: title ?? this.title,
      titleValue: titleValue ?? this.titleValue,
      ontap: ontap ?? this.ontap,
    );
  }

  @override
  String toString() {
    return 'StudentProfileAboutModel('
        'email: $email, '
        'fullName: $fullName, '
        'gender: $gender, '
        'dateOfBirth: $dateOfBirth, '
        'program: $program, '
        'faculty: $faculty, '
        'studentID: $studentID, '
        'enrollmentYear: $enrollmentYear, '
        'profilePicture: $profilePicture, '
        'bio: $bio, '
        'title: $title, '
        'titleValue: $titleValue'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentProfileAboutModel &&
        other.email == email &&
        other.fullName == fullName &&
        other.gender == gender &&
        other.dateOfBirth == dateOfBirth &&
        other.program == program &&
        other.faculty == faculty &&
        other.studentID == studentID &&
        other.enrollmentYear == enrollmentYear &&
        other.profilePicture == profilePicture &&
        other.bio == bio &&
        other.title == title &&
        other.titleValue == titleValue;
  }

  @override
  int get hashCode {
    return Object.hash(
      email,
      fullName,
      gender,
      dateOfBirth,
      program,
      faculty,
      studentID,
      enrollmentYear,
      profilePicture,
      bio,
      title,
      titleValue,
    );
  }
}
