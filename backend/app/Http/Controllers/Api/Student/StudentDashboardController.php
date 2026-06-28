<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Services\DashboardService;
use Illuminate\Http\JsonResponse;

class StudentDashboardController extends Controller
{
    public function __construct(private DashboardService $dashboardService) {}

    public function index(): JsonResponse
    {
        $student = auth()->user()->student;

        if (!$student) {
            return response()->json([
                'success' => true,
                'data' => [
                    'total_courses' => 0,
                    'total_students' => 0,
                    'total_teachers' => 0,
                    'total_programs' => 0,
                    'total_departments' => 0,
                    'total_classrooms' => 0,
                    'active_enrollments' => 0,
                    'pending_results' => 0,
                    'program_distribution' => [],
                    'grade_evolution' => [],
                    'recent_enrollments' => [],
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $this->dashboardService->getStudentStats($student->id),
        ]);
    }
}
