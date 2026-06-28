class EnrollmentModel {
  final int id;
  final int studentId;
  final String? studentName;
  final String? studentNumber;
  final String? programName;
  final String? academicYear;
  final String? code;
  final String? enrollmentDate;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    this.studentName,
    this.studentNumber,
    this.programName,
    this.academicYear,
    this.code,
    this.enrollmentDate,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] as int? ?? 0,
      studentId: json['student_id'] as int? ?? 0,
      studentName: json['student_name'] as String?,
      studentNumber: json['student_number'] as String?,
      programName: json['program_name'] as String?,
      academicYear: json['academic_year'] as String?,
      code: json['code'] as String?,
      enrollmentDate: json['enrollment_date'] as String?,
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
      'student_id': studentId,
      'student_name': studentName,
      'student_number': studentNumber,
      'program_name': programName,
      'academic_year': academicYear,
      'code': code,
      'enrollment_date': enrollmentDate,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  EnrollmentModel copyWith({
    int? id,
    int? studentId,
    String? studentName,
    String? studentNumber,
    String? programName,
    String? academicYear,
    String? code,
    String? enrollmentDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnrollmentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentNumber: studentNumber ?? this.studentNumber,
      programName: programName ?? this.programName,
      academicYear: academicYear ?? this.academicYear,
      code: code ?? this.code,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
