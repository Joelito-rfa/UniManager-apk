class LevelModel {
  final int id;
  final String name;
  final String code;
  final int? programId;
  final String? programName;

  LevelModel({
    required this.id,
    required this.name,
    required this.code,
    this.programId,
    this.programName,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    final program = json['program'] as Map<String, dynamic>?;
    return LevelModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      programId: json['program_id'] as int?,
      programName: program?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'program_id': programId,
    };
  }
}
