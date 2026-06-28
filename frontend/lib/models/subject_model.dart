class SubjectModel {
  final int id;
  final String name;
  final String? code;
  final int? credits;
  final int? hoursTotal;
  final double? coefficient;
  final String? description;
  final int? levelId;
  final String? levelName;
  final int? programId;
  final String? programName;
  final int? teacherId;
  final String? teacherName;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubjectModel({
    required this.id,
    required this.name,
    this.code,
    this.credits,
    this.hoursTotal,
    this.coefficient,
    this.description,
    this.levelId,
    this.levelName,
    this.programId,
    this.programName,
    this.teacherId,
    this.teacherName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final level = json['level'] as Map<String, dynamic>?;
    final program = json['program'] as Map<String, dynamic>?;
    final teacher = json['teacher'] as Map<String, dynamic>?;
    return SubjectModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      credits: (json['credits'] as num?)?.toInt(),
      hoursTotal: (json['hours_total'] as num?)?.toInt(),
      coefficient: (json['coefficient'] as num?)?.toDouble(),
      description: json['description'] as String?,
      levelId: json['level_id'] as int?,
      levelName: json['level_name'] as String? ?? level?['name'] as String?,
      programId: json['program_id'] as int?,
      programName: json['program_name'] as String? ?? program?['name'] as String?,
      teacherId: json['teacher_id'] as int?,
      teacherName: json['teacher_name'] as String? ?? teacher?['name'] as String?,
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
      'name': name,
      'code': code,
      'credits': credits,
      'hours_total': hoursTotal,
      'coefficient': coefficient,
      'description': description,
      'level_id': levelId,
      'level_name': levelName,
      'program_id': programId,
      'program_name': programName,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SubjectModel copyWith({
    int? id,
    String? name,
    String? code,
    int? credits,
    int? hoursTotal,
    double? coefficient,
    String? description,
    int? levelId,
    String? levelName,
    int? programId,
    String? programName,
    int? teacherId,
    String? teacherName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      credits: credits ?? this.credits,
      hoursTotal: hoursTotal ?? this.hoursTotal,
      coefficient: coefficient ?? this.coefficient,
      description: description ?? this.description,
      levelId: levelId ?? this.levelId,
      levelName: levelName ?? this.levelName,
      programId: programId ?? this.programId,
      programName: programName ?? this.programName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
