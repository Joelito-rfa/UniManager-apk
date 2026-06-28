class ClassroomModel {
  final int id;
  final String name;
  final String? code;
  final int? capacity;
  final String? building;
  final int? floor;
  final String? type;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClassroomModel({
    required this.id,
    required this.name,
    this.code,
    this.capacity,
    this.building,
    this.floor,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      capacity: json['capacity'] as int?,
      building: json['building'] as String?,
      floor: json['floor'] != null ? int.tryParse(json['floor'].toString()) : null,
      type: json['type'] as String?,
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
      'capacity': capacity,
      'building': building,
      'floor': floor,
      'type': type,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ClassroomModel copyWith({
    int? id,
    String? name,
    String? code,
    int? capacity,
    String? building,
    int? floor,
    String? type,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassroomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      capacity: capacity ?? this.capacity,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
