<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\Api\Admin\{
    StudentController,
    TeacherController,
    DepartmentController,
    ProgramController,
    LevelController,
    SubjectController,
    CourseController,
    ClassroomController,
    ScheduleController,
    EnrollmentController,
    GradeController,
    ResultController,
    DashboardController,
    UserController,
    ReportController
};
use App\Http\Controllers\Api\Teacher\{
    TeacherCourseController,
    TeacherGradeController,
    TeacherResultController,
    TeacherScheduleController,
    TeacherStudentController,
    TeacherDashboardController,
    CourseResourceController as TeacherCourseResourceController
};
use App\Http\Controllers\Api\Admin\AdminCourseResourceController;
use App\Http\Controllers\Api\Admin\LevelResultController;
use App\Http\Controllers\Api\Student\StudentCourseResourceController;
use App\Http\Controllers\Api\Student\{
    StudentProfileController,
    StudentGradeController,
    StudentScheduleController,
    StudentResultController,
    StudentDashboardController,
    StudentCourseController
};
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\Api\MessagingController;
use App\Http\Controllers\Api\Admin\AdminMessagingController;
use App\Http\Controllers\Api\System\ServerStatusController;
use App\Http\Controllers\Api\System\BackupController;
use App\Http\Controllers\Api\ContactController;

// Routes publiques
Route::post('auth/login', [AuthController::class, 'login']);
Route::post('auth/register/student', [AuthController::class, 'registerStudent']);
Route::post('auth/register/teacher', [AuthController::class, 'registerTeacher']);
Route::post('auth/register/admin', [AuthController::class, 'registerAdmin']);
Route::post('auth/check/student', [AuthController::class, 'checkStudent']);
Route::post('auth/check/teacher', [AuthController::class, 'checkTeacher']);
Route::post('auth/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('auth/reset-password', [AuthController::class, 'resetPassword']);
Route::post('auth/refresh', [AuthController::class, 'refresh']);

// Routes protégées
Route::middleware('auth:api')->group(function () {
    // Auth
    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::get('auth/me', [AuthController::class, 'me']);
    Route::put('auth/me', [AuthController::class, 'updateProfile']);
    Route::post('auth/change-password', [AuthController::class, 'changePassword']);

    // Recherche globale (tous les rôles)
    Route::get('search', [SearchController::class, 'search']);

    // Admin routes
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        Route::post('auth/generate-invitation', [AuthController::class, 'generateInvitationCode']);
        Route::get('students/next-number', [StudentController::class, 'nextNumber']);
        Route::apiResource('students', StudentController::class);
        Route::get('teachers/next-number', [TeacherController::class, 'nextNumber']);
        Route::apiResource('teachers', TeacherController::class);
        Route::get('departments/next-code', [DepartmentController::class, 'nextCode']);
        Route::apiResource('departments', DepartmentController::class);
        Route::get('programs/next-code', [ProgramController::class, 'nextCode']);
        Route::apiResource('programs', ProgramController::class);
        Route::apiResource('levels', LevelController::class);
        Route::get('subjects/next-code', [SubjectController::class, 'nextCode']);
        Route::apiResource('subjects', SubjectController::class);
        Route::apiResource('courses', CourseController::class);
        Route::get('classrooms/next-code', [ClassroomController::class, 'nextCode']);
        Route::apiResource('classrooms', ClassroomController::class);
        Route::apiResource('schedules', ScheduleController::class);
        Route::apiResource('enrollments', EnrollmentController::class);
        Route::apiResource('grades', GradeController::class);
        Route::post('grades/batch', [GradeController::class, 'storeBatch']);
        Route::get('results/transcript/{studentId}', [ResultController::class, 'transcript']);
        Route::post('results/calculate', [ResultController::class, 'calculate']);
        Route::post('results/publish', [ResultController::class, 'publish']);
        Route::post('results/recalculate', [ResultController::class, 'recalculateAll']);
        Route::get('results/export/pdf/{courseId}', [ResultController::class, 'exportPdf']);
        Route::get('results/export/excel/{courseId}', [ResultController::class, 'exportExcel']);
        Route::apiResource('results', ResultController::class)->except(['store']);
        Route::get('level-results', [LevelResultController::class, 'index']);
        Route::post('level-results/calculate', [LevelResultController::class, 'calculate']);
        Route::post('level-results/publish', [LevelResultController::class, 'publish']);
        Route::get('level-results/{levelResult}', [LevelResultController::class, 'show']);
        Route::delete('level-results/{levelResult}', [LevelResultController::class, 'destroy']);
        Route::apiResource('users', UserController::class);
        Route::get('dashboard/stats', [DashboardController::class, 'index']);
        Route::get('dashboard/charts', [DashboardController::class, 'charts']);
        Route::get('reports/students', [ReportController::class, 'students']);
        Route::get('reports/grades', [ReportController::class, 'grades']);
        Route::get('reports/export/students', [ReportController::class, 'exportStudents']);
        Route::get('reports/export/grades/{courseId}', [ReportController::class, 'exportGrades']);
        Route::get('courses/{course}/resources', [AdminCourseResourceController::class, 'index']);
        Route::post('courses/{course}/resources', [AdminCourseResourceController::class, 'store']);
        Route::get('resources/{resource}', [AdminCourseResourceController::class, 'show']);
        Route::put('resources/{resource}', [AdminCourseResourceController::class, 'update']);
        Route::delete('resources/{resource}', [AdminCourseResourceController::class, 'destroy']);
        Route::get('resources/{resource}/download', [AdminCourseResourceController::class, 'download']);
    });

    // Teacher routes
    Route::middleware('role:teacher')->prefix('teacher')->group(function () {
        Route::get('dashboard/stats', [TeacherDashboardController::class, 'index']);
        Route::get('courses', [TeacherCourseController::class, 'index']);
        Route::get('courses/{id}/students', [TeacherCourseController::class, 'students']);
        Route::get('schedule', [TeacherScheduleController::class, 'index']);
        Route::get('grades', [TeacherGradeController::class, 'index']);
        Route::post('grades', [TeacherGradeController::class, 'store']);
        Route::post('grades/batch', [TeacherGradeController::class, 'storeBatch']);
        Route::put('grades/{id}', [TeacherGradeController::class, 'update']);
        Route::get('enrollments', [TeacherCourseController::class, 'enrollments']);
        Route::get('students', [TeacherStudentController::class, 'students']);
        Route::get('results', [TeacherResultController::class, 'index']);
        Route::get('results/student/{student}', [TeacherResultController::class, 'studentResults']);
        Route::get('results/export/{courseId}', [TeacherResultController::class, 'export']);
        Route::get('courses/{course}/resources', [TeacherCourseResourceController::class, 'index']);
        Route::post('courses/{course}/resources', [TeacherCourseResourceController::class, 'store']);
        Route::get('resources/{resource}', [TeacherCourseResourceController::class, 'show']);
        Route::put('resources/{resource}', [TeacherCourseResourceController::class, 'update']);
        Route::delete('resources/{resource}', [TeacherCourseResourceController::class, 'destroy']);
        Route::get('resources/{resource}/download', [TeacherCourseResourceController::class, 'download']);
    });

    // Student routes
    Route::middleware('role:student')->prefix('student')->group(function () {
        Route::get('courses', [StudentCourseController::class, 'index']);
        Route::get('dashboard/stats', [StudentDashboardController::class, 'index']);
        Route::get('profile', [StudentProfileController::class, 'show']);
        Route::put('profile', [StudentProfileController::class, 'update']);
        Route::get('grades', [StudentGradeController::class, 'index']);
        Route::get('schedule', [StudentScheduleController::class, 'index']);
        Route::get('results', [StudentResultController::class, 'index']);
        Route::get('results/transcript', [StudentResultController::class, 'transcript']);
        Route::get('results/level', [StudentResultController::class, 'levelResults']);
        Route::get('results/summary', [StudentResultController::class, 'summary']);
        Route::get('results/download', [StudentResultController::class, 'downloadPdf']);
        Route::get('courses/{course}/resources', [StudentCourseResourceController::class, 'index']);
        Route::get('resources/{resource}', [StudentCourseResourceController::class, 'show']);
        Route::get('resources/{resource}/download', [StudentCourseResourceController::class, 'download']);
    });

    // Niveaux (tous les rôles)
    Route::get('levels', [\App\Http\Controllers\Api\Admin\LevelController::class, 'index']);

    // Notifications (tous les rôles)
    Route::get('notifications', [\App\Http\Controllers\Api\NotificationController::class, 'index']);
    Route::post('notifications', [\App\Http\Controllers\Api\NotificationController::class, 'store']);
    Route::get('notifications/unread-count', [\App\Http\Controllers\Api\NotificationController::class, 'unreadCount']);
    Route::put('notifications/{id}/read', [\App\Http\Controllers\Api\NotificationController::class, 'markAsRead']);
    Route::put('notifications/read-all', [\App\Http\Controllers\Api\NotificationController::class, 'markAllAsRead']);
    Route::delete('notifications/{id}', [\App\Http\Controllers\Api\NotificationController::class, 'destroy']);

    // Messagerie (tous les rôles)
    Route::prefix('conversations')->group(function () {
        Route::get('/', [MessagingController::class, 'index']);
        Route::get('/public', [MessagingController::class, 'publicConversations']);
        Route::get('/unread-count', [MessagingController::class, 'unreadCount']);
        Route::post('/', [MessagingController::class, 'store']);
        Route::get('{conversation}', [MessagingController::class, 'show']);
        Route::get('{conversation}/messages', [MessagingController::class, 'messages']);
        Route::post('{conversation}/messages', [MessagingController::class, 'sendMessage']);
        Route::put('{conversation}/read', [MessagingController::class, 'markAsRead']);
    });
    Route::delete('messages/{message}', [MessagingController::class, 'destroyMessage']);
    Route::post('messages/{message}/reactions', [MessagingController::class, 'addReaction']);
    Route::delete('messages/{message}/reactions', [MessagingController::class, 'removeReaction']);

    // Contact support (tous les rôles)
    Route::get('contact/support', [ContactController::class, 'support']);

    // Statut serveur (tous les rôles)
    Route::get('server/status', [ServerStatusController::class, 'index']);

    // Sauvegarde (admin uniquement)
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        Route::get('backups/last', [BackupController::class, 'lastBackup']);
        Route::post('backups/create', [BackupController::class, 'createBackup']);
    });

    // Admin Messagerie
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        Route::get('conversations', [AdminMessagingController::class, 'index']);
        Route::get('conversations/{conversation}', [AdminMessagingController::class, 'show']);
        Route::get('conversations/{conversation}/messages', [AdminMessagingController::class, 'messages']);
        Route::delete('messages/{message}', [AdminMessagingController::class, 'destroyMessage']);
    });
});
