class ScheduleModel {
  final int id;
  final String? code;
  final int? levelId;
  final String? levelName;
  final int? courseId;
  final String? courseName;
  final int? classroomId;
  final String? classroomName;
  final int? teacherId;
  final String? teacherName;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? session;
  final String? group;
  final String? status;
  final DateTime? date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ScheduleModel({
    required this.id,
    this.code,
    this.levelId,
    this.levelName,
    this.courseId,
    this.courseName,
    this.classroomId,
    this.classroomName,
    this.teacherId,
    this.teacherName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.session,
    this.group,
    this.status,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      levelId: json['level_id'] as int?,
      levelName: json['level_name'] as String?,
      courseId: json['course_id'] as int?,
      courseName: json['course_name'] as String?,
      classroomId: json['classroom_id'] as int?,
      classroomName: json['classroom_name'] as String?,
      teacherId: json['teacher_id'] as int?,
      teacherName: json['teacher_name'] as String?,
      dayOfWeek: json['day_of_week'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      session: json['session'] as String?,
      group: json['group'] as String?,
      status: json['status'] as String?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
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
      'level_id': levelId,
      'level_name': levelName,
      'course_id': courseId,
      'course_name': courseName,
      'classroom_id': classroomId,
      'classroom_name': classroomName,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'session': session,
      'group': group,
      'status': status,
      'date': date?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ScheduleModel copyWith({
    int? id,
    String? code,
    int? levelId,
    String? levelName,
    int? courseId,
    String? courseName,
    int? classroomId,
    String? classroomName,
    int? teacherId,
    String? teacherName,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? session,
    String? group,
    String? status,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      code: code ?? this.code,
      levelId: levelId ?? this.levelId,
      levelName: levelName ?? this.levelName,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      classroomId: classroomId ?? this.classroomId,
      classroomName: classroomName ?? this.classroomName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      session: session ?? this.session,
      group: group ?? this.group,
      status: status ?? this.status,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
