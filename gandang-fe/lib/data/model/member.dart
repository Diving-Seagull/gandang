
class Member {
  final int id;
  final String email;
  final String name;
  final String? profile_image;
  final String social_type;
  final String language_code;

  Member({
        required this.id,
        required this.email,
        required this.name,
        required this.profile_image,
        required this.social_type,
        required this.language_code
      });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profile_image: json['profile_image'],
        social_type: json['social_type'],
        language_code: json['language_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profile_image,
      "social_type": social_type,
      "language_code": language_code
    };
  }
}
