class LevelResultModel {
  final int id;
  final String? code;
  final int? studentId;
  final int? levelId;
  final int? programId;
  final String? academicYear;
  final double totalPoints;
  final double totalCoefficients;
  final double averageGrade;
  final int totalCreditsObtained;
  final int totalCreditsRequired;
  final String? mention;
  final String decision;
  final DateTime? publishedAt;
  final String? studentName;
  final String? studentNumber;
  final String? levelName;
  final String? programName;

  LevelResultModel({
    required this.id,
    this.code,
    this.studentId,
    this.levelId,
    this.programId,
    this.academicYear,
    required this.totalPoints,
    required this.totalCoefficients,
    required this.averageGrade,
    required this.totalCreditsObtained,
    required this.totalCreditsRequired,
    this.mention,
    required this.decision,
    this.publishedAt,
    this.studentName,
    this.studentNumber,
    this.levelName,
    this.programName,
  });

  bool get isPublished => publishedAt != null;
  bool get isAdmis => decision == 'admis';
  bool get isRattrapage => decision == 'rattrapage';
  bool get isAjourne => decision == 'ajourne';

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
      case 'admis': return 'Admis';
      case 'rattrapage': return 'Rattrapage';
      case 'ajourne': return 'Ajourné';
      default: return decision;
    }
  }

  factory LevelResultModel.fromJson(Map<String, dynamic> json) {
    final studentData = json['student'] as Map<String, dynamic>?;
    final levelData = json['level'] as Map<String, dynamic>?;
    final programData = json['program'] as Map<String, dynamic>?;

    return LevelResultModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      studentId: json['student_id'] as int?,
      levelId: json['level_id'] as int?,
      programId: json['program_id'] as int?,
      academicYear: json['academic_year'] as String?,
      totalPoints: (json['total_points'] as num?)?.toDouble() ?? 0,
      totalCoefficients: (json['total_coefficients'] as num?)?.toDouble() ?? 0,
      averageGrade: (json['average_grade'] as num?)?.toDouble() ?? 0,
      totalCreditsObtained: json['total_credits_obtained'] as int? ?? 0,
      totalCreditsRequired: json['total_credits_required'] as int? ?? 0,
      mention: json['mention'] as String?,
      decision: json['decision'] as String? ?? 'ajourne',
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      studentName: studentData?['name'] as String?,
      studentNumber: studentData?['student_number'] as String?,
      levelName: levelData?['name'] as String?,
      programName: programData?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'student_id': studentId,
      'level_id': levelId,
      'program_id': programId,
      'academic_year': academicYear,
      'total_points': totalPoints,
      'total_coefficients': totalCoefficients,
      'average_grade': averageGrade,
      'total_credits_obtained': totalCreditsObtained,
      'total_credits_required': totalCreditsRequired,
      'mention': mention,
      'decision': decision,
    };
  }
}
