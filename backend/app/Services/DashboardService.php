<?php

namespace App\Services;

use App\Models\Student;
use App\Models\Teacher;
use App\Models\Program;
use App\Models\Course;
use App\Models\Enrollment;
use App\Models\Result;

class DashboardService
{
    public function getStats(): array
    {
        return [
            'total_students' => Student::count(),
            'total_teachers' => Teacher::count(),
            'total_programs' => Program::count(),
            'total_courses' => Course::count(),
            'active_enrollments' => Enrollment::where('status', 'active')->count(),
            'validated_results' => Result::where('decision', 'validated')->count(),
            'failed_results' => Result::where('decision', 'failed')->count(),
            'recent_students' => Student::with('user')->latest()->take(5)->get()->map(fn($s) => [
                'id' => $s->id,
                'name' => $s->user->name,
                'student_number' => $s->student_number,
                'created_at' => $s->created_at,
            ]),
        ];
    }

    public function getTeacherStats(int $teacherId): array
    {
        $courseIds = Course::where('teacher_id', $teacherId)->pluck('id');

        return [
            'total_courses' => $courseIds->count(),
            'total_students' => Enrollment::whereIn('course_id', $courseIds)
                ->distinct('student_id')
                ->count('student_id'),
            'total_classrooms' => Course::where('teacher_id', $teacherId)
                ->whereNotNull('classroom_id')
                ->distinct('classroom_id')
                ->count(),
            'pending_results' => Enrollment::whereIn('course_id', $courseIds)
                ->where('status', 'active')
                ->whereDoesntHave('grades')
                ->count(),
            'total_teachers' => 1,
            'total_programs' => Course::where('teacher_id', $teacherId)
                ->whereHas('level', fn($q) => $q->whereNotNull('program_id'))
                ->distinct('level_id')
                ->count(),
            'total_departments' => 0,
            'active_enrollments' => Enrollment::whereIn('course_id', $courseIds)
                ->where('status', 'active')
                ->count(),
            'program_distribution' => [],
            'grade_evolution' => [],
            'recent_enrollments' => [],
        ];
    }

    public function getStudentStats(int $studentId): array
    {
        $enrollments = Enrollment::where('student_id', $studentId)->pluck('course_id');

        return [
            'total_courses' => $enrollments->count(),
            'total_students' => 0,
            'total_teachers' => 0,
            'total_programs' => 0,
            'total_departments' => 0,
            'total_classrooms' => 0,
            'active_enrollments' => $enrollments->count(),
            'pending_results' => 0,
            'program_distribution' => [],
            'grade_evolution' => [],
            'recent_enrollments' => [],
        ];
    }

    public function getChartData(): array
    {
        return [
            'students_by_program' => Program::withCount('students')->get()->map(fn($p) => [
                'program' => $p->name,
                'count' => $p->students_count,
            ]),
            'results_distribution' => [
                'validated' => Result::where('decision', 'validated')->count(),
                'failed' => Result::where('decision', 'failed')->count(),
                'retake' => Result::where('decision', 'retake')->count(),
            ],
            'enrollments_by_month' => Enrollment::selectRaw("TO_CHAR(enrollment_date, 'YYYY-MM') as month, COUNT(*) as count")
                ->groupBy('month')
                ->orderBy('month')
                ->get(),
        ];
    }
}
