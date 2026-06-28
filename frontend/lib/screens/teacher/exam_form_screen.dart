import 'package:flutter/material.dart';
import '../admin/exam_form_screen.dart' as admin;

class ExamFormScreen extends StatelessWidget {
  final int? examId;

  const ExamFormScreen({super.key, this.examId});

  @override
  Widget build(BuildContext context) {
    return admin.ExamFormScreen(examId: examId, role: 'teacher');
  }
}
