class StudentModel {
  final int id;
  final String? code;
  final int userId;
  final String studentNumber;
  final String? dateOfBirth;
  final String? address;
  final String? phone;
  final String? enrollmentDate;
  final int? programId;
  final int? levelId;
  final String? programName;
  final String? levelName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentModel({
    required this.id,
    this.code,
    required this.userId,
    required this.studentNumber,
    this.dateOfBirth,
    this.address,
    this.phone,
    this.enrollmentDate,
    this.programId,
    this.levelId,
    this.programName,
    this.levelName,
    this.firstName,
    this.lastName,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final nameParts = (user?['name'] as String? ?? '').split(' ');
    final program = json['program'] as Map<String, dynamic>?;
    final level = json['level'] as Map<String, dynamic>?;

    return StudentModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      userId: json['user_id'] as int? ?? 0,
      studentNumber: json['student_number'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      enrollmentDate: json['enrollment_date'] as String?,
      programId: json['program_id'] as int?,
      levelId: json['level_id'] as int?,
      programName: program?['name'] as String?,
      levelName: level?['name'] as String?,
      firstName: nameParts.length > 1 ? nameParts.sublist(0, nameParts.length - 1).join(' ') : nameParts.first,
      lastName: nameParts.length > 1 ? nameParts.last : '',
      email: user?['email'] as String?,
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
      'code': code,
      'student_number': studentNumber,
      'date_of_birth': dateOfBirth,
      'address': address,
      'phone': phone,
      'enrollment_date': enrollmentDate,
      'program_id': programId,
      'level_id': levelId,
      'name': fullName,
      'email': email,
    };
  }

  StudentModel copyWith({
    int? id,
    String? code,
    int? userId,
    String? studentNumber,
    String? dateOfBirth,
    String? address,
    String? phone,
    String? enrollmentDate,
    int? programId,
    int? levelId,
    String? programName,
    String? levelName,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      code: code ?? this.code,
      userId: userId ?? this.userId,
      studentNumber: studentNumber ?? this.studentNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      programId: programId ?? this.programId,
      levelId: levelId ?? this.levelId,
      programName: programName ?? this.programName,
      levelName: levelName ?? this.levelName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
