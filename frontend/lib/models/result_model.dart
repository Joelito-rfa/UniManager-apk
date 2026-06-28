class ResultModel {
  final int id;
  final String? code;
  final int? courseId;
  final int? studentId;
  final String? studentName;
  final String? studentNumber;
  final String? studentProgram;
  final String? studentLevel;
  final String? academicYear;
  final String? semester;
  final double average;
  final String? mention;
  final double? totalCredits;
  final double? earnedCredits;
  final String? decision;
  final String? subjectName;
  final String? subjectCode;
  final double? coefficient;
  final String? teacherName;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ResultModel({
    required this.id,
    this.code,
    this.courseId,
    this.studentId,
    this.studentName,
    this.studentNumber,
    this.studentProgram,
    this.studentLevel,
    this.academicYear,
    this.semester,
    required this.average,
    this.mention,
    this.totalCredits,
    this.earnedCredits,
    this.decision,
    this.subjectName,
    this.subjectCode,
    this.coefficient,
    this.teacherName,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPublished => publishedAt != null;
  bool get isPassed => decision == 'validated';
  bool get isRetake => decision == 'retake';

  String get mentionLabel {
    switch (mention) {
      case 'tres_bien': return 'Très Bien';
      case 'bien': return 'Bien';
      case 'assez_bien': return 'Assez Bien';
      case 'passable': return 'Passable';
      case 'insuffisant': return 'Insuffisant';
      default: return mention ?? '';
    }
  }

  String get decisionLabel {
    switch (decision) {
      case 'validated': return 'Validée';
      case 'retake': return 'Rattrapage';
      case 'failed': return 'Non validée';
      default: return decision ?? '';
    }
  }

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    final studentData = json['student'] as Map<String, dynamic>?;
    final courseData = json['course'] as Map<String, dynamic>?;
    final subjectData = courseData?['subject'] as Map<String, dynamic>?;
    final teacherData = courseData?['teacher'] as Map<String, dynamic>?;

    return ResultModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      courseId: json['course_id'] as int?,
      studentId: json['student_id'] as int? ?? studentData?['id'] as int?,
      studentName: studentData?['name'] as String?,
      studentNumber: studentData?['student_number'] as String?,
      studentProgram: studentData?['program'] as String?,
      studentLevel: studentData?['level'] as String?,
      academicYear: json['academic_year'] as String? ?? courseData?['academic_year'] as String?,
      semester: json['semester'] as String? ?? courseData?['semester'] as String?,
      average: (json['final_grade'] as num?)?.toDouble() ?? 0.0,
      mention: json['mention'] as String?,
      totalCredits: (subjectData?['credits'] as num?)?.toDouble(),
      earnedCredits: (json['credit_value'] as num?)?.toDouble(),
      decision: json['decision'] as String?,
      subjectName: subjectData?['name'] as String? ?? courseData?['name'] as String?,
      subjectCode: subjectData?['code'] as String?,
      coefficient: (subjectData?['coefficient'] as num?)?.toDouble(),
      teacherName: teacherData?['name'] as String?,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
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
      'course_id': courseId,
      'student_id': studentId,
      'final_grade': average,
      'mention': mention,
      'credit_value': earnedCredits,
      'decision': decision,
      'published_at': publishedAt?.toIso8601String(),
    };
  }

  ResultModel copyWith({
    int? id,
    String? code,
    int? courseId,
    int? studentId,
    String? studentName,
    String? studentNumber,
    String? studentProgram,
    String? studentLevel,
    String? academicYear,
    String? semester,
    double? average,
    String? mention,
    double? totalCredits,
    double? earnedCredits,
    String? decision,
    String? subjectName,
    String? subjectCode,
    double? coefficient,
    String? teacherName,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResultModel(
      id: id ?? this.id,
      code: code ?? this.code,
      courseId: courseId ?? this.courseId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentNumber: studentNumber ?? this.studentNumber,
      studentProgram: studentProgram ?? this.studentProgram,
      studentLevel: studentLevel ?? this.studentLevel,
      academicYear: academicYear ?? this.academicYear,
      semester: semester ?? this.semester,
      average: average ?? this.average,
      mention: mention ?? this.mention,
      totalCredits: totalCredits ?? this.totalCredits,
      earnedCredits: earnedCredits ?? this.earnedCredits,
      decision: decision ?? this.decision,
      subjectName: subjectName ?? this.subjectName,
      subjectCode: subjectCode ?? this.subjectCode,
      coefficient: coefficient ?? this.coefficient,
      teacherName: teacherName ?? this.teacherName,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
