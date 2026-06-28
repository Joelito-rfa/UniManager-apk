import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/admin/dashboard_screen.dart' as admin_dashboard;
import '../screens/admin/student_list_screen.dart' as admin_students;
import '../screens/admin/student_form_screen.dart' as admin_student_form;
import '../screens/admin/teacher_list_screen.dart' as admin_teachers;
import '../screens/admin/teacher_form_screen.dart' as admin_teacher_form;
import '../screens/admin/department_list_screen.dart' as admin_departments;
import '../screens/admin/department_form_screen.dart' as admin_department_form;
import '../screens/admin/program_list_screen.dart' as admin_programs;
import '../screens/admin/program_form_screen.dart' as admin_program_form;
import '../screens/admin/subject_list_screen.dart' as admin_subjects;
import '../screens/admin/subject_form_screen.dart' as admin_subject_form;
import '../screens/admin/course_list_screen.dart' as admin_courses;
import '../screens/admin/course_form_screen.dart' as admin_course_form;
import '../screens/admin/classroom_list_screen.dart' as admin_classrooms;
import '../screens/admin/classroom_form_screen.dart' as admin_classroom_form;
import '../screens/admin/schedule_list_screen.dart' as admin_schedules;
import '../screens/admin/schedule_form_screen.dart' as admin_schedule_form;
import '../screens/admin/enrollment_list_screen.dart' as admin_enrollments;
import '../screens/admin/enrollment_form_screen.dart' as admin_enrollment_form;
import '../screens/admin/grade_management_screen.dart' as admin_grades;
import '../screens/teacher/grade_input_screen.dart' as admin_grades_input;
import '../screens/admin/result_list_screen.dart' as admin_results;
import '../screens/teacher/dashboard_screen.dart' as teacher_dashboard;
import '../screens/teacher/course_list_screen.dart' as teacher_courses;
import '../screens/teacher/schedule_screen.dart' as teacher_schedule;
import '../screens/teacher/grade_input_screen.dart' as teacher_grades;
import '../screens/teacher/student_list_screen.dart' as teacher_students;
import '../screens/teacher/result_screen.dart' as teacher_results;
import '../screens/student/dashboard_screen.dart' as student_dashboard;
import '../screens/student/grade_screen.dart' as student_grades;
import '../screens/student/schedule_screen.dart' as student_schedule;
import '../screens/student/result_screen.dart' as student_results;
import '../screens/admin/exam_list_screen.dart' as admin_exams;
import '../screens/admin/exam_form_screen.dart' as admin_exam_form;
import '../screens/teacher/exam_list_screen.dart' as teacher_exams;
import '../screens/teacher/exam_form_screen.dart' as teacher_exam_form;
import '../screens/student/exam_list_screen.dart' as student_exams;
import '../screens/admin/settings_screen.dart' as admin_settings;
import '../screens/admin/admission_screen.dart' as admin_admission;
import '../screens/admin/course_resource_list_screen.dart' as admin_course_resources;
import '../screens/teacher/course_resource_list_screen.dart' as teacher_course_resources;

import '../screens/student/course_resource_list_screen.dart' as student_course_resources;
import '../screens/student/course_resource_viewer_screen.dart' as student_resource_viewer;
import '../screens/student/course_list_screen.dart' as student_courses;
import '../screens/student/resources_screen.dart' as student_resources;
import '../screens/shared/not_found_screen.dart';
import '../core/constants/api_constants.dart';
import '../screens/shared/unauthorized_screen.dart';
import '../screens/shared/profile_screen.dart' as shared_profile;
import '../screens/shared/notification_list_screen.dart' as shared_notifications;
import '../widgets/common/app_scaffold.dart';
import '../models/course_model.dart';
import '../screens/messaging/messaging_list_screen.dart' as messaging_list;
import '../screens/messaging/chat_screen.dart' as messaging_chat;
import '../screens/messaging/new_conversation_screen.dart' as messaging_new;
import '../screens/auth/change_password_screen.dart' as change_password;

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';
      final isForgotPassword = state.matchedLocation == '/forgot-password';
      final isResetPassword = state.matchedLocation == '/reset-password';

      if (!isAuthenticated && !isLoggingIn && !isRegister && !isForgotPassword && !isResetPassword) {
        return '/login';
      }

      if (isAuthenticated && (isLoggingIn || isRegister)) {
        return _getDefaultRoute(authState.user?.role);
      }

      if (isAuthenticated) {
        final userRole = authState.user?.role;
        final location = state.matchedLocation;
        if (location.startsWith('/admin') && userRole != 'admin') {
          return '/unauthorized';
        }
        if (location.startsWith('/teacher') && userRole != 'teacher') {
          return '/unauthorized';
        }
        if (location.startsWith('/student') && userRole != 'student') {
          return '/unauthorized';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'resetPassword',
        builder: (context, state) => ResetPasswordScreen(email: state.extra as String?),
      ),
      GoRoute(
        path: '/unauthorized',
        name: 'unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            name: 'adminDashboard',
            builder: (context, state) => const admin_dashboard.DashboardScreen(),
          ),
          GoRoute(
            path: '/admin/students',
            name: 'adminStudents',
            builder: (context, state) => const admin_students.StudentListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'adminStudentAdd',
                builder: (context, state) => const admin_student_form.StudentFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'adminStudentEdit',
                builder: (context, state) => admin_student_form.StudentFormScreen(
                  studentId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/teachers',
            name: 'adminTeachers',
            builder: (context, state) => const admin_teachers.TeacherListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'adminTeacherAdd',
                builder: (context, state) => const admin_teacher_form.TeacherFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'adminTeacherEdit',
                builder: (context, state) => admin_teacher_form.TeacherFormScreen(
                  teacherId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/departments',
            name: 'adminDepartments',
            builder: (context, state) => const admin_departments.DepartmentListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'adminDepartmentAdd',
                builder: (context, state) => const admin_department_form.DepartmentFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'adminDepartmentEdit',
                builder: (context, state) => admin_department_form.DepartmentFormScreen(
                  departmentId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/programs',
            name: 'adminPrograms',
            builder: (context, state) => const admin_programs.ProgramListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'adminProgramAdd',
                builder: (context, state) => const admin_program_form.ProgramFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'adminProgramEdit',
                builder: (context, state) => admin_program_form.ProgramFormScreen(
                  programId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/subjects',
            name: 'adminSubjects',
            builder: (context, state) => const admin_subjects.SubjectListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'adminSubjectAdd',
                builder: (context, state) => const admin_subject_form.SubjectFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'adminSubjectEdit',
                builder: (context, state) => admin_subject_form.SubjectFormScreen(
                  subjectId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/courses',
            name: 'adminCourses',
            builder: (context, state) => const admin_courses.CourseListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'adminCourseAdd',
                builder: (context, state) => const admin_course_form.CourseFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'adminCourseEdit',
                builder: (context, state) => admin_course_form.CourseFormScreen(
                  courseId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: ':courseId/resources',
                name: 'adminCourseResources',
                builder: (context, state) {
                  final course = state.extra as CourseModel?;
                  return admin_course_resources.AdminCourseResourceListScreen(
                    course: course ?? CourseModel(id: int.parse(state.pathParameters['courseId']!), subjectName: ''),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/admin/classrooms',
            name: 'adminClassrooms',
            builder: (context, state) => const admin_classrooms.ClassroomListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'adminClassroomAdd',
                builder: (context, state) => const admin_classroom_form.ClassroomFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'adminClassroomEdit',
                builder: (context, state) => admin_classroom_form.ClassroomFormScreen(
                  classroomId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/schedules',
            name: 'adminSchedules',
            builder: (context, state) => const admin_schedules.ScheduleListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'adminScheduleAdd',
                builder: (context, state) => const admin_schedule_form.ScheduleFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'adminScheduleEdit',
                builder: (context, state) => admin_schedule_form.ScheduleFormScreen(
                  scheduleId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/enrollments',
            name: 'adminEnrollments',
            builder: (context, state) => const admin_enrollments.EnrollmentListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'adminEnrollmentAdd',
                builder: (context, state) => const admin_enrollment_form.EnrollmentFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'adminEnrollmentEdit',
                builder: (context, state) => admin_enrollment_form.EnrollmentFormScreen(
                  enrollmentId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/grades',
            name: 'adminGrades',
            builder: (context, state) => const admin_grades.GradeManagementScreen(),
            routes: [
              GoRoute(
                path: 'input/:courseId',
                name: 'adminGradeInput',
                builder: (context, state) => admin_grades_input.GradeInputScreen(
                  courseId: int.parse(state.pathParameters['courseId']!),
                  role: 'admin',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/results',
            name: 'adminResults',
            builder: (context, state) => const admin_results.ResultListScreen(),
          ),
          GoRoute(
            path: '/admin/exams',
            name: 'adminExams',
            builder: (context, state) => const admin_exams.ExamListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'adminExamAdd',
                builder: (context, state) => const admin_exam_form.ExamFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'adminExamEdit',
                builder: (context, state) => admin_exam_form.ExamFormScreen(
                  examId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/profile',
            name: 'adminProfile',
            builder: (context, state) => const shared_profile.ProfileScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            name: 'adminSettings',
            builder: (context, state) => const admin_settings.SettingsScreen(),
          ),
          GoRoute(
            path: '/admin/admissions',
            name: 'adminAdmissions',
            builder: (context, state) => const admin_admission.AdmissionScreen(),
          ),
          GoRoute(
            path: '/admin/resources/:resourceId/view',
            name: 'adminResourceView',
            builder: (context, state) {
              final resource = state.extra as dynamic;
              return student_resource_viewer.CourseResourceViewerScreen(
                resource: resource,
                downloadBaseEndpoint: ApiConstants.adminResourceDownload,
              );
            },
          ),
          GoRoute(
            path: '/admin/notifications',
            name: 'adminNotifications',
            builder: (context, state) => const shared_notifications.NotificationListScreen(),
          ),
          GoRoute(
            path: '/admin/messaging',
            name: 'adminMessaging',
            builder: (context, state) => const messaging_list.MessagingListScreen(),
          ),
          GoRoute(
            path: '/teacher/dashboard',
            name: 'teacherDashboard',
            builder: (context, state) => const teacher_dashboard.DashboardScreen(),
          ),
          GoRoute(
            path: '/teacher/courses',
            name: 'teacherCourses',
            builder: (context, state) => const teacher_courses.CourseListScreen(),
            routes: [
              GoRoute(
                path: ':courseId/resources',
                name: 'teacherCourseResources',
                builder: (context, state) {
                  final course = state.extra as CourseModel?;
                  return teacher_course_resources.CourseResourceListScreen(
                    course: course ?? CourseModel(id: int.parse(state.pathParameters['courseId']!), subjectName: ''),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/teacher/resources/:resourceId/view',
            name: 'teacherResourceView',
            builder: (context, state) {
              final resource = state.extra as dynamic;
              return student_resource_viewer.CourseResourceViewerScreen(
                resource: resource,
                downloadBaseEndpoint: ApiConstants.teacherResourceDownload,
              );
            },
          ),
          GoRoute(
            path: '/teacher/schedule',
            name: 'teacherSchedule',
            builder: (context, state) => const teacher_schedule.ScheduleScreen(),
          ),
          GoRoute(
            path: '/teacher/grades',
            name: 'teacherGrades',
            builder: (context, state) => const teacher_grades.GradeInputScreen(),
            routes: [
              GoRoute(
                path: 'course/:courseId',
                name: 'teacherGradeCourse',
                builder: (context, state) => teacher_grades.GradeInputScreen(
                  courseId: int.parse(state.pathParameters['courseId']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/teacher/students',
            name: 'teacherStudents',
            builder: (context, state) => const teacher_students.StudentListScreen(),
          ),
          GoRoute(
            path: '/teacher/results',
            name: 'teacherResults',
            builder: (context, state) => const teacher_results.TeacherResultScreen(),
          ),
          GoRoute(
            path: '/teacher/exams',
            name: 'teacherExams',
            builder: (context, state) => const teacher_exams.ExamListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'teacherExamAdd',
                builder: (context, state) => const teacher_exam_form.ExamFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'teacherExamEdit',
                builder: (context, state) => teacher_exam_form.ExamFormScreen(
                  examId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/teacher/profile',
            name: 'teacherProfile',
            builder: (context, state) => const shared_profile.ProfileScreen(),
          ),
          GoRoute(
            path: '/teacher/notifications',
            name: 'teacherNotifications',
            builder: (context, state) => const shared_notifications.NotificationListScreen(),
          ),
          GoRoute(
            path: '/teacher/messaging',
            name: 'teacherMessaging',
            builder: (context, state) => const messaging_list.MessagingListScreen(),
          ),
          GoRoute(
            path: '/student/dashboard',
            name: 'studentDashboard',
            builder: (context, state) => const student_dashboard.DashboardScreen(),
          ),
          GoRoute(
            path: '/student/profile',
            name: 'studentProfile',
            builder: (context, state) => const shared_profile.ProfileScreen(),
          ),
          GoRoute(
            path: '/student/courses',
            name: 'studentCourses',
            builder: (context, state) => const student_courses.StudentCourseListScreen(),
          ),
          GoRoute(
            path: '/student/exams',
            name: 'studentExams',
            builder: (context, state) => const student_exams.ExamListScreen(),
          ),
          GoRoute(
            path: '/student/grades',
            name: 'studentGrades',
            builder: (context, state) => const student_grades.GradeScreen(),
          ),
          GoRoute(
            path: '/student/schedule',
            name: 'studentSchedule',
            builder: (context, state) => const student_schedule.ScheduleScreen(),
          ),
          GoRoute(
            path: '/student/results',
            name: 'studentResults',
            builder: (context, state) => const student_results.ResultScreen(),
          ),
          GoRoute(
            path: '/student/resources',
            name: 'studentResources',
            builder: (context, state) => const student_resources.StudentResourcesScreen(),
          ),
          GoRoute(
            path: '/student/courses/:courseId/resources',
            name: 'studentCourseResources',
            builder: (context, state) {
              final course = state.extra as CourseModel?;
              return student_course_resources.StudentCourseResourceListScreen(
                course: course ?? CourseModel(id: int.parse(state.pathParameters['courseId']!), subjectName: ''),
              );
            },
          ),
          GoRoute(
            path: '/student/resources/:resourceId/view',
            name: 'studentResourceView',
            builder: (context, state) {
              final resource = state.extra as dynamic;
              return student_resource_viewer.CourseResourceViewerScreen(
                resource: resource,
              );
            },
          ),
          GoRoute(
            path: '/student/notifications',
            name: 'studentNotifications',
            builder: (context, state) => const shared_notifications.NotificationListScreen(),
          ),
          GoRoute(
            path: '/student/messaging',
            name: 'studentMessaging',
            builder: (context, state) => const messaging_list.MessagingListScreen(),
          ),
          // Shared messaging routes
          GoRoute(
            path: '/messaging/new',
            name: 'messagingNew',
            builder: (context, state) => const messaging_new.NewConversationScreen(),
          ),
          GoRoute(
            path: '/messaging/chat/:id',
            name: 'messagingChat',
            builder: (context, state) {
              final conv = state.extra as dynamic;
              return messaging_chat.ChatScreen(
                conversation: conv,
              );
            },
          ),
          // Shared auth routes
          GoRoute(
            path: '/change-password',
            name: 'changePassword',
            builder: (context, state) => const change_password.ChangePasswordScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});

String _getDefaultRoute(String? role) {
  switch (role) {
    case 'admin':
      return '/admin/dashboard';
    case 'teacher':
      return '/teacher/dashboard';
    case 'student':
      return '/student/dashboard';
    default:
      return '/login';
  }
}
