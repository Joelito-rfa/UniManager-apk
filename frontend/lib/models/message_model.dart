class MessageModel {
  final int id;
  final String? code;
  final int conversationId;
  final int senderId;
  final String? senderName;
  final String? senderAvatar;
  final String content;
  final List<ReactionModel> reactions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.id,
    this.code,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.content,
    this.reactions = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      conversationId: json['conversation_id'] as int? ?? 0,
      senderId: json['sender_id'] as int? ?? 0,
      senderName: json['sender_name'] as String?,
      senderAvatar: json['sender_avatar'] as String?,
      content: json['content'] as String? ?? '',
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => ReactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}

class ReactionModel {
  final int id;
  final int messageId;
  final int userId;
  final String? userName;
  final String reaction;
  final DateTime? createdAt;

  ReactionModel({
    required this.id,
    required this.messageId,
    required this.userId,
    this.userName,
    required this.reaction,
    this.createdAt,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'] as int? ?? 0,
      messageId: json['message_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String?,
      reaction: json['reaction'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
