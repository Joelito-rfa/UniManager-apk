class TeacherModel {
  final int id;
  final String? code;
  final int userId;
  final String teacherNumber;
  final String? speciality;
  final String? dateOfBirth;
  final String? address;
  final String? phone;
  final String? hireDate;
  final int? departmentId;
  final String? departmentName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TeacherModel({
    required this.id,
    this.code,
    required this.userId,
    required this.teacherNumber,
    this.speciality,
    this.dateOfBirth,
    this.address,
    this.phone,
    this.hireDate,
    this.departmentId,
    this.departmentName,
    this.firstName,
    this.lastName,
    this.email,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final nameParts = (user?['name'] as String? ?? '').split(' ');
    final department = json['department'] as Map<String, dynamic>?;

    return TeacherModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String?,
      userId: json['user_id'] as int? ?? 0,
      teacherNumber: json['teacher_number'] as String? ?? '',
      speciality: json['speciality'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      hireDate: json['hire_date'] as String?,
      departmentId: json['department_id'] as int?,
      departmentName: department?['name'] as String?,
      firstName: nameParts.length > 1 ? nameParts.sublist(0, nameParts.length - 1).join(' ') : nameParts.first,
      lastName: nameParts.length > 1 ? nameParts.last : '',
      email: user?['email'] as String?,
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
      'code': code,
      'teacher_number': teacherNumber,
      'speciality': speciality,
      'date_of_birth': dateOfBirth,
      'address': address,
      'phone': phone,
      'hire_date': hireDate,
      'department_id': departmentId,
      'name': fullName,
      'email': email,
    };
  }

  TeacherModel copyWith({
    int? id,
    String? code,
    int? userId,
    String? teacherNumber,
    String? speciality,
    String? dateOfBirth,
    String? address,
    String? phone,
    String? hireDate,
    int? departmentId,
    String? departmentName,
    String? firstName,
    String? lastName,
    String? email,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      code: code ?? this.code,
      userId: userId ?? this.userId,
      teacherNumber: teacherNumber ?? this.teacherNumber,
      speciality: speciality ?? this.speciality,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      hireDate: hireDate ?? this.hireDate,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
