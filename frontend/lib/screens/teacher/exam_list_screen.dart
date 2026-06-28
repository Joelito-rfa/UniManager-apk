import 'package:flutter/material.dart';
import '../admin/exam_list_screen.dart' as admin;

class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const admin.ExamListScreen(role: 'teacher');
  }
}
