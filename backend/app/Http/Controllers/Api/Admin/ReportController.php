<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\Student;
use App\Models\Result;
use App\Models\Grade;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function __construct(private ReportService $reportService) {}

    public function studentReport(Request $request, Student $student): JsonResponse
    {
        $request->validate(['semester' => 'nullable|string', 'academic_year' => 'nullable|string']);
        $pdf = $this->reportService->generateStudentReport($student, $request->only(['semester', 'academic_year']));
        return $pdf->download('releve_notes_' . $student->student_number . '.pdf');
    }

    public function courseReport(Course $course): JsonResponse
    {
        $pdf = $this->reportService->generateCourseReport($course);
        return $pdf->download('rapport_cours_' . $course->code . '.pdf');
    }

    public function resultsExport(Request $request): JsonResponse
    {
        $request->validate(['course_id' => 'nullable|integer|exists:courses,id', 'semester' => 'nullable|string', 'academic_year' => 'nullable|string']);
        $excel = $this->reportService->exportResults($request->only(['course_id', 'semester', 'academic_year']));
        return $excel->download('resultats.xlsx');
    }

    public function gradeSheet(Request $request, Course $course): JsonResponse
    {
        $pdf = $this->reportService->generateGradeSheet($course);
        return $pdf->download('bulletin_notes_' . $course->code . '.pdf');
    }
}
