/// Profil utilisateur (`public.profiles`).
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.firstName,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String firstName;
  final String? avatarUrl;
  final DateTime? createdAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}
