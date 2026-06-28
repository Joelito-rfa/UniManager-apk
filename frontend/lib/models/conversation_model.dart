import 'message_model.dart';

class ConversationModel {
  final int id;
  final String? code;
  final String type;
  final bool isPublic;
  final String? publicAudience;
  final String? name;
  final List<ParticipantModel> participants;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ConversationModel({
    required this.id,
    this.code,
    required this.type,
    this.isPublic = false,
    this.publicAudience,
    this.name,
    this.participants = const [],
    this.lastMessage,
    this.unreadCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      type: json['type'] as String? ?? 'direct',
      isPublic: json['is_public'] as bool? ?? false,
      publicAudience: json['public_audience'] as String?,
      name: json['name'] as String?,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => ParticipantModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  String get audienceLabel {
    switch (publicAudience) {
      case 'all':
        return 'Tout le monde';
      case 'students':
        return 'Étudiants';
      case 'teachers':
        return 'Enseignants';
      case 'admin':
        return 'Administrateurs';
      default:
        return 'Tout le monde';
    }
  }

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (isPublic) return 'Annonces publiques';
    return participants.where((p) => p.userName != null).map((p) => p.userName!).join(', ');
  }
}

class ParticipantModel {
  final int id;
  final int userId;
  final String? userName;
  final String? userEmail;
  final String? userAvatar;
  final DateTime? lastReadAt;

  ParticipantModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.lastReadAt,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      userAvatar: json['user_avatar'] as String?,
      lastReadAt: json['last_read_at'] != null
          ? DateTime.tryParse(json['last_read_at'] as String)
          : null,
    );
  }
}
