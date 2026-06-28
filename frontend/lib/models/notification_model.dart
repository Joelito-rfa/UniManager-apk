class NotificationModel {
  final int id;
  final String? code;
  final String title;
  final String message;
  final String? type;
  final bool isRead;
  final String? link;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    this.code,
    required this.title,
    required this.message,
    this.type,
    required this.isRead,
    this.link,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      link: json['link'] as String?,
      userId: json['user_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'link': link,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? id,
    String? code,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? link,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      link: link ?? this.link,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
