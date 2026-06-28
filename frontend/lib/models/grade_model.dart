class GradeModel {
  final int id;
  final int enrollmentId;
  final String? subjectName;
  final String? code;
  final String? gradeType;
  final double grade;
  final double? coefficient;
  final String? comment;
  final int? gradedBy;
  final String? gradedByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GradeModel({
    required this.id,
    required this.enrollmentId,
    this.subjectName,
    this.code,
    this.gradeType,
    required this.grade,
    this.coefficient,
    this.comment,
    this.gradedBy,
    this.gradedByName,
    this.createdAt,
    this.updatedAt,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    final enrollmentData = json['enrollment'] as Map<String, dynamic>?;
    final courseData = enrollmentData?['course'] as Map<String, dynamic>?;
    final subjectData = courseData?['subject'] as Map<String, dynamic>?;
    final gradedByUser = json['graded_by_user'] as Map<String, dynamic>?;

    return GradeModel(
      id: json['id'] as int? ?? 0,
      enrollmentId: json['enrollment_id'] as int? ?? 0,
      gradeType: json['grade_type'] as String?,
      grade: (json['grade_value'] as num?)?.toDouble() ?? 0.0,
      coefficient: (json['coefficient'] as num?)?.toDouble(),
      comment: json['comment'] as String?,
      gradedBy: json['graded_by'] as int?,
      gradedByName: gradedByUser?['name'] as String?,
      subjectName: subjectData?['name'] as String?,
      code: json['code'] as String?,
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
      'enrollment_id': enrollmentId,
      'grade_type': gradeType,
      'grade_value': grade,
      'coefficient': coefficient,
      'comment': comment,
      'graded_by': gradedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  GradeModel copyWith({
    int? id,
    int? enrollmentId,
    String? subjectName,
    String? code,
    String? gradeType,
    double? grade,
    double? coefficient,
    String? comment,
    int? gradedBy,
    String? gradedByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GradeModel(
      id: id ?? this.id,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      subjectName: subjectName ?? this.subjectName,
      code: code ?? this.code,
      gradeType: gradeType ?? this.gradeType,
      grade: grade ?? this.grade,
      coefficient: coefficient ?? this.coefficient,
      comment: comment ?? this.comment,
      gradedBy: gradedBy ?? this.gradedBy,
      gradedByName: gradedByName ?? this.gradedByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
