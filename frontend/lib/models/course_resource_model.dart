class CourseResourceModel {
  final int id;
  final String? code;
  final int courseId;
  final String title;
  final String? description;
  final String type;
  final String? filePath;
  final String? thumbnailUrl;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileSizeFormatted;
  final String? mimeType;
  final String? url;
  final int? duration;
  final int orderColumn;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseResourceModel({
    required this.id,
    this.code,
    required this.courseId,
    required this.title,
    this.description,
    required this.type,
    this.filePath,
    this.thumbnailUrl,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileSizeFormatted,
    this.mimeType,
    this.url,
    this.duration,
    this.orderColumn = 0,
    this.isPublished = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseResourceModel.fromJson(Map<String, dynamic> json) {
    return CourseResourceModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      courseId: json['course_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'pdf',
      filePath: json['file_path'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
      fileSizeFormatted: json['file_size_formatted'] as String?,
      mimeType: json['mime_type'] as String?,
      url: json['url'] as String?,
      duration: json['duration'] as int?,
      orderColumn: json['order_column'] as int? ?? 0,
      isPublished: json['is_published'] as bool? ?? true,
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
      'course_id': courseId,
      'title': title,
      'description': description,
      'type': type,
      'file_path': filePath,
      'thumbnail_url': thumbnailUrl,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'file_size_formatted': fileSizeFormatted,
      'mime_type': mimeType,
      'url': url,
      'duration': duration,
      'order_column': orderColumn,
      'is_published': isPublished,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CourseResourceModel copyWith({
    int? id,
    String? code,
    int? courseId,
    String? title,
    String? description,
    String? type,
    String? filePath,
    String? thumbnailUrl,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileSizeFormatted,
    String? mimeType,
    String? url,
    int? duration,
    int? orderColumn,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseResourceModel(
      id: id ?? this.id,
      code: code ?? this.code,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileSizeFormatted: fileSizeFormatted ?? this.fileSizeFormatted,
      mimeType: mimeType ?? this.mimeType,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      orderColumn: orderColumn ?? this.orderColumn,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
