class DashboardStatsModel {
  final int totalStudents;
  final int totalTeachers;
  final int totalPrograms;
  final int totalCourses;
  final int totalDepartments;
  final int totalClassrooms;
  final int activeEnrollments;
  final int pendingResults;
  final List<ProgramDistribution> programDistribution;
  final List<GradeEvolution> gradeEvolution;
  final List<RecentEnrollment> recentEnrollments;

  DashboardStatsModel({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalPrograms,
    required this.totalCourses,
    required this.totalDepartments,
    required this.totalClassrooms,
    required this.activeEnrollments,
    required this.pendingResults,
    this.programDistribution = const [],
    this.gradeEvolution = const [],
    this.recentEnrollments = const [],
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalStudents: json['total_students'] as int? ?? 0,
      totalTeachers: json['total_teachers'] as int? ?? 0,
      totalPrograms: json['total_programs'] as int? ?? 0,
      totalCourses: json['total_courses'] as int? ?? 0,
      totalDepartments: json['total_departments'] as int? ?? 0,
      totalClassrooms: json['total_classrooms'] as int? ?? 0,
      activeEnrollments: json['active_enrollments'] as int? ?? 0,
      pendingResults: json['pending_results'] as int? ?? 0,
      programDistribution: (json['program_distribution'] as List<dynamic>?)
              ?.map((e) => ProgramDistribution.fromJson(e))
              .toList() ??
          [],
      gradeEvolution: (json['grade_evolution'] as List<dynamic>?)
              ?.map((e) => GradeEvolution.fromJson(e))
              .toList() ??
          [],
      recentEnrollments: (json['recent_enrollments'] as List<dynamic>?)
              ?.map((e) => RecentEnrollment.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'total_programs': totalPrograms,
      'total_courses': totalCourses,
      'total_departments': totalDepartments,
      'total_classrooms': totalClassrooms,
      'active_enrollments': activeEnrollments,
      'pending_results': pendingResults,
      'program_distribution': programDistribution.map((e) => e.toJson()).toList(),
      'grade_evolution': gradeEvolution.map((e) => e.toJson()).toList(),
      'recent_enrollments': recentEnrollments.map((e) => e.toJson()).toList(),
    };
  }

  DashboardStatsModel copyWith({
    int? totalStudents,
    int? totalTeachers,
    int? totalPrograms,
    int? totalCourses,
    int? totalDepartments,
    int? totalClassrooms,
    int? activeEnrollments,
    int? pendingResults,
    List<ProgramDistribution>? programDistribution,
    List<GradeEvolution>? gradeEvolution,
    List<RecentEnrollment>? recentEnrollments,
  }) {
    return DashboardStatsModel(
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      totalPrograms: totalPrograms ?? this.totalPrograms,
      totalCourses: totalCourses ?? this.totalCourses,
      totalDepartments: totalDepartments ?? this.totalDepartments,
      totalClassrooms: totalClassrooms ?? this.totalClassrooms,
      activeEnrollments: activeEnrollments ?? this.activeEnrollments,
      pendingResults: pendingResults ?? this.pendingResults,
      programDistribution: programDistribution ?? this.programDistribution,
      gradeEvolution: gradeEvolution ?? this.gradeEvolution,
      recentEnrollments: recentEnrollments ?? this.recentEnrollments,
    );
  }
}

class ProgramDistribution {
  final String name;
  final int count;
  final double percentage;

  ProgramDistribution({
    required this.name,
    required this.count,
    required this.percentage,
  });

  factory ProgramDistribution.fromJson(Map<String, dynamic> json) {
    return ProgramDistribution(
      name: json['name'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
      'percentage': percentage,
    };
  }
}

class GradeEvolution {
  final String period;
  final double average;
  final double max;
  final double min;

  GradeEvolution({
    required this.period,
    required this.average,
    required this.max,
    required this.min,
  });

  factory GradeEvolution.fromJson(Map<String, dynamic> json) {
    return GradeEvolution(
      period: json['period'] as String? ?? '',
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 0.0,
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'average': average,
      'max': max,
      'min': min,
    };
  }
}

class RecentEnrollment {
  final int id;
  final String studentName;
  final String studentNumber;
  final String programName;
  final String levelName;
  final String enrollmentDate;
  final String status;

  RecentEnrollment({
    required this.id,
    required this.studentName,
    required this.studentNumber,
    required this.programName,
    required this.levelName,
    required this.enrollmentDate,
    required this.status,
  });

  factory RecentEnrollment.fromJson(Map<String, dynamic> json) {
    return RecentEnrollment(
      id: json['id'] as int? ?? 0,
      studentName: json['student_name'] as String? ?? '',
      studentNumber: json['student_number'] as String? ?? '',
      programName: json['program_name'] as String? ?? '',
      levelName: json['level_name'] as String? ?? '',
      enrollmentDate: json['enrollment_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'student_number': studentNumber,
      'program_name': programName,
      'level_name': levelName,
      'enrollment_date': enrollmentDate,
      'status': status,
    };
  }
}
