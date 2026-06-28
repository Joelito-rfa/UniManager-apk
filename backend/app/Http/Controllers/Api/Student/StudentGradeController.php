<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\GradeResource;
use App\Models\Enrollment;
use App\Models\Grade;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentGradeController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $student = auth()->user()->student;
        if (!$student) {
            return response()->json(['success' => true, 'data' => []]);
        }

        $grades = Grade::whereHas('enrollment', fn($q) => $q->where('student_id', $student->id))
            ->with(['enrollment.course.subject', 'gradedBy'])
            ->when($request->course_id, fn($q, $v) => $q->whereHas('enrollment', fn($q) => $q->where('course_id', $v)))
            ->when($request->type, fn($q, $v) => $q->where('grade_type', $v))
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => GradeResource::collection($grades),
        ]);
    }

    public function averages(): JsonResponse
    {
        $student = auth()->user()->student;
        if (!$student) {
            return response()->json([
                'success' => true,
                'data' => [
                    'overall_average' => null,
                    'course_averages' => [],
                ],
            ]);
        }

        $enrollments = Enrollment::where('student_id', $student->id)
            ->with(['course.subject', 'grades'])
            ->get();

        $averages = $enrollments->map(function ($enrollment) {
            $grades = $enrollment->grades;
            $totalCoefficient = $grades->sum('coefficient');
            $weightedSum = $grades->sum(fn($g) => $g->grade_value * $g->coefficient);
            $average = $totalCoefficient > 0 ? round($weightedSum / $totalCoefficient, 2) : null;

            return [
                'course_id' => $enrollment->course_id,
                'course_name' => $enrollment->course->name,
                'subject_name' => $enrollment->course->subject->name ?? null,
                'average' => $average,
                'grades_count' => $grades->count(),
                'total_coefficient' => $totalCoefficient,
            ];
        });

        $overallAverage = $averages->filter(fn($a) => $a['average'] !== null)->avg('average');

        return response()->json([
            'success' => true,
            'data' => [
                'overall_average' => $overallAverage ? round($overallAverage, 2) : null,
                'course_averages' => $averages,
            ],
        ]);
    }
}
