import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_strings.dart';

class QuickActions extends ConsumerWidget {
  final String role;
  final bool compact;

  const QuickActions({super.key, required this.role, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);

    if (role == 'admin') {
      final actions = [
        _Action(s.addStudent, Icons.school_rounded, '/admin/students/add'),
        _Action(s.addTeacher, Icons.person_rounded, '/admin/teachers/add'),
        _Action(s.addDepartment, Icons.business_rounded, '/admin/departments/add'),
        _Action(s.addProgram, Icons.account_tree_rounded, '/admin/programs/add'),
        _Action(s.addSubject, Icons.book_rounded, '/admin/subjects/add'),
        _Action(s.addClassroom, Icons.meeting_room_rounded, '/admin/classrooms/add'),
        _Action(s.addCourse, Icons.menu_book_rounded, '/admin/courses/add'),
        _Action(s.addSchedule, Icons.calendar_month_rounded, '/admin/schedules/add'),
        _Action(s.addEnrollment, Icons.app_registration_rounded, '/admin/enrollments/add'),
      ];

      if (compact) {
        return Tooltip(
          message: s.newItem,
          child: PopupMenuButton<String>(
            offset: const Offset(0, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4,
            onSelected: (route) => context.go(route),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_rounded, color: Color(0xFFEF4444), size: 20),
            ),
            itemBuilder: (context) => actions.map((a) =>
              PopupMenuItem(value: a.route, child: Row(children: [Icon(a.icon, size: 18, color: const Color(0xFFEF4444)), const SizedBox(width: 12), Text(a.label)]))
            ).toList(),
          ),
        );
      }

      return PopupMenuButton<String>(
        offset: const Offset(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        onSelected: (route) => context.go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withAlpha(10),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: const Color(0xFFEF4444), size: 18),
              const SizedBox(width: 6),
              Text(s.newItem, style: TextStyle(color: const Color(0xFFEF4444), fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFFEF4444), size: 18),
            ],
          ),
        ),
        itemBuilder: (context) => actions.map((a) =>
          PopupMenuItem(value: a.route, child: Row(children: [Icon(a.icon, size: 18, color: const Color(0xFFEF4444)), const SizedBox(width: 12), Text(a.label)]))
        ).toList(),
      );
    }

    if (role == 'teacher') {
      final items = [
        _Action(s.addGrade, Icons.grade_rounded, '/teacher/grades'),
        _Action(s.addAssignment, Icons.assignment_rounded, '/teacher/exams'),
        _Action(s.addResource, Icons.upload_file_rounded, '/teacher/courses'),
      ];

      return Tooltip(
        message: s.newItem,
        child: PopupMenuButton<String>(
          offset: const Offset(0, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          onSelected: (route) => context.go(route),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withAlpha(10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add_rounded, color: Color(0xFFEF4444), size: 20),
          ),
          itemBuilder: (context) => items.map((a) =>
            PopupMenuItem(value: a.route, child: Row(children: [Icon(a.icon, size: 18, color: const Color(0xFFEF4444)), const SizedBox(width: 12), Text(a.label)]))
          ).toList(),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _Action {
  final String label;
  final IconData icon;
  final String route;
  const _Action(this.label, this.icon, this.route);
}
