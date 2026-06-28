class CourseModel {
  final int id;
  final int? subjectId;
  final String? subjectName;
  final int? teacherId;
  final String? teacherName;
  final int? levelId;
  final String? levelName;
  final int? classroomId;
  final String? classroomName;
  final String? semester;
  final String? academicYear;
  final String? code;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.id,
    this.subjectId,
    this.subjectName,
    this.teacherId,
    this.teacherName,
    this.levelId,
    this.levelName,
    this.classroomId,
    this.classroomName,
    this.semester,
    this.academicYear,
    this.code,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final level = json['level'] as Map<String, dynamic>?;
    return CourseModel(
      id: json['id'] as int? ?? 0,
      subjectId: json['subject_id'] as int?,
      subjectName: json['subject_name'] as String? ?? json['subject']?['name'] as String?,
      teacherId: json['teacher_id'] as int?,
      teacherName: json['teacher_name'] as String? ?? json['teacher']?['name'] as String?,
      levelId: json['level_id'] as int?,
      levelName: json['level_name'] as String? ?? level?['name'] as String?,
      classroomId: json['classroom_id'] as int?,
      classroomName: json['classroom_name'] as String?,
      semester: json['semester'] as String?,
      academicYear: json['academic_year'] as String?,
      code: json['code'] as String?,
      status: json['status'] as String?,
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
      'subject_id': subjectId,
      'subject_name': subjectName,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'level_id': levelId,
      'level_name': levelName,
      'classroom_id': classroomId,
      'classroom_name': classroomName,
      'semester': semester,
      'academic_year': academicYear,
      'code': code,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CourseModel copyWith({
    int? id,
    int? subjectId,
    String? subjectName,
    int? teacherId,
    String? teacherName,
    int? levelId,
    String? levelName,
    int? classroomId,
    String? classroomName,
    String? semester,
    String? academicYear,
    String? code,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      levelId: levelId ?? this.levelId,
      levelName: levelName ?? this.levelName,
      classroomId: classroomId ?? this.classroomId,
      classroomName: classroomName ?? this.classroomName,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      code: code ?? this.code,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
