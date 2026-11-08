class ProfileModel {
  final String id;
  final String? name;
  final String? userName;
  final String? phone;
  final String? image;
  final String? country;
  final String? userId;
  final String? email;

  ProfileModel({
    required this.id,
    this.name,
    this.userName,
    this.phone,
    this.image,
    this.country,
    this.userId,
    this.email,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['fullName'] as String?,
      userName: json['userName'] as String?,
      phone: json['phoneNumber'] as String?,
      image: json['image'] as String?,
      country: json['country'] as String?,
      userId: json['userId'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': name,
      'userName': userName,
      'phoneNumber': phone,
      'image': image,
      'country': country,
      'userId': userId,
      'email': email,
    };
  }
}
