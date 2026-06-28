class ProgramModel {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final int? duration;
  final int? departmentId;
  final String? departmentName;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProgramModel({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.duration,
    this.departmentId,
    this.departmentName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    final department = json['department'] as Map<String, dynamic>?;
    return ProgramModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      departmentId: json['department_id'] as int?,
      departmentName: json['department_name'] as String? ?? department?['name'] as String?,
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
      'description': description,
      'duration': duration,
      'department_id': departmentId,
      'department_name': departmentName,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProgramModel copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    int? duration,
    int? departmentId,
    String? departmentName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
