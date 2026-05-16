/// Rôle d'un participant à un événement.
enum MemberRole {
  creator,
  guest;

  static MemberRole fromString(String value) =>
      MemberRole.values.firstWhere(
        (r) => r.name == value,
        orElse: () => MemberRole.guest,
      );

  String toJson() => name;
}

/// Membre d'un événement (`public.event_members`).
class MemberModel {
  const MemberModel({
    required this.id,
    required this.eventId,
    required this.userId,
    this.role = MemberRole.guest,
    this.hasResponded = false,
    this.joinedAt,
  });

  final String id;
  final String eventId;
  final String userId;
  final MemberRole role;
  final bool hasResponded;
  final DateTime? joinedAt;

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      role: MemberRole.fromString(json['role'] as String? ?? 'guest'),
      hasResponded: json['has_responded'] as bool? ?? false,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'user_id': userId,
        'role': role.toJson(),
        'has_responded': hasResponded,
        if (joinedAt != null) 'joined_at': joinedAt!.toIso8601String(),
      };

  /// Insertion membre invité — `has_responded` géré par trigger SQL.
  Map<String, dynamic> toInsertJson() => {
        'event_id': eventId,
        'user_id': userId,
        'role': role.toJson(),
      };
}
