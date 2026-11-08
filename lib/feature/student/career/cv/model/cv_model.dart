class CvModel {
  final dynamic id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? sex;
  final String? dob;
  final String? nationality;
  final String? maritalStatus;
  final String? otherMaritalStatus;
  final List<String> languageProficiency;
  final String? contactAddress;
  final String? mobileNo;
  final String? email;
  final String? personalSummery;
  final List<CvEducation> educations;
  final List<CvExperience> experiences;
  final List<String> hobbies;
  final List<CvReferrer> referrers;

  CvModel({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.sex,
    this.dob,
    this.nationality,
    this.maritalStatus,
    this.otherMaritalStatus,
    this.languageProficiency = const [],
    this.contactAddress,
    this.mobileNo,
    this.email,
    this.personalSummery,
    this.educations = const [],
    this.experiences = const [],
    this.hobbies = const [],
    this.referrers = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (_hasValue(firstName)) 'firstName': firstName!.trim(),
      if (_hasValue(middleName)) 'middleName': middleName!.trim(),
      if (_hasValue(lastName)) 'lastName': lastName!.trim(),
      if (_hasValue(sex)) 'sex': sex!.trim(),
      if (_hasValue(dob)) 'dob': dob!.trim(),
      if (_hasValue(nationality)) 'nationality': nationality!.trim(),
      if (_hasValue(maritalStatus)) 'maritalStatus': maritalStatus!.trim(),
      if (_hasValue(otherMaritalStatus))
        'otherMaritalStatus': otherMaritalStatus!.trim(),
      if (languageProficiency.isNotEmpty)
        'languageProficiency': languageProficiency,
      if (_hasValue(contactAddress)) 'contactAddress': contactAddress!.trim(),
      if (_hasValue(mobileNo)) 'mobileNo': mobileNo!.trim(),
      if (_hasValue(email)) 'email': email!.trim(),
      if (_hasValue(personalSummery))
        'personalSummery': personalSummery!.trim(),
      'educations': educations.map((education) => education.toJson()).toList(),
      'experiences': experiences
          .map((experience) => experience.toJson())
          .toList(),
      'hobbies': hobbies,
      'referrers': referrers.map((referrer) => referrer.toJson()).toList(),
    };
  }
}

class CvEducation {
  final int? id;
  final String? institution;
  final String? degree;
  final String? startDate;
  final String? endDate;
  final String? gpa;
  final String? description;

  CvEducation({
    this.id,
    this.institution,
    this.degree,
    this.startDate,
    this.endDate,
    this.gpa,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (_hasValue(institution)) 'institution': institution!.trim(),
      if (_hasValue(degree)) 'degree': degree!.trim(),
      if (_hasValue(startDate)) 'startDate': startDate!.trim(),
      if (_hasValue(endDate)) 'endDate': endDate!.trim(),
      if (_hasValue(gpa)) 'gpa': gpa!.trim(),
      if (_hasValue(description)) 'description': description!.trim(),
    };
  }

  bool get hasData =>
      _hasValue(institution) ||
      _hasValue(degree) ||
      _hasValue(startDate) ||
      _hasValue(endDate) ||
      _hasValue(gpa) ||
      _hasValue(description);
}

class CvExperience {
  final int? id;
  final String? companyName;
  final String? position;
  final String? startDate;
  final String? endDate;
  final String? description;

  CvExperience({
    this.id,
    this.companyName,
    this.position,
    this.startDate,
    this.endDate,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (_hasValue(companyName)) 'companyName': companyName!.trim(),
      if (_hasValue(position)) 'position': position!.trim(),
      if (_hasValue(startDate)) 'startDate': startDate!.trim(),
      if (_hasValue(endDate)) 'endDate': endDate!.trim(),
      if (_hasValue(description)) 'description': description!.trim(),
    };
  }

  bool get hasData =>
      _hasValue(companyName) ||
      _hasValue(position) ||
      _hasValue(startDate) ||
      _hasValue(endDate) ||
      _hasValue(description);
}

class CvReferrer {
  final int? id;
  final String? name;
  final String? role;
  final String? organization;
  final String? address1;
  final String? address2;
  final String? phone;

  CvReferrer({
    this.id,
    this.name,
    this.role,
    this.organization,
    this.address1,
    this.address2,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (_hasValue(name)) 'name': name!.trim(),
      if (_hasValue(role)) 'role': role!.trim(),
      if (_hasValue(organization)) 'organization': organization!.trim(),
      if (_hasValue(address1)) 'address1': address1!.trim(),
      if (_hasValue(address2)) 'address2': address2!.trim(),
      if (_hasValue(phone)) 'phone': phone!.trim(),
    };
  }

  bool get hasData =>
      _hasValue(name) ||
      _hasValue(role) ||
      _hasValue(organization) ||
      _hasValue(address1) ||
      _hasValue(address2) ||
      _hasValue(phone);
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
