<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Http\Resources\CourseResource;
use App\Http\Resources\EnrollmentResource;
use App\Http\Resources\StudentResource;
use App\Models\Course;
use App\Models\Enrollment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeacherCourseController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'L\'enseignant est introuvable'], 404);
        }

        $courses = Course::with(['subject', 'classroom', 'schedules', 'level'])
            ->when($request->semester, fn($q, $v) => $q->where('semester', $v))
            ->when($request->academic_year, fn($q, $v) => $q->where('academic_year', $v))
            ->when($request->status, fn($q, $v) => $q->where('status', $v))
            ->when($request->level_id, fn($q, $v) => $q->where('level_id', $v))
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => CourseResource::collection($courses),
        ]);
    }

    public function show(Course $course): JsonResponse
    {
        $course->load(['subject', 'classroom', 'schedules', 'enrollments.student.user']);
        return response()->json([
            'success' => true,
            'data' => new CourseResource($course),
        ]);
    }

    public function enrollments(Request $request): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'L\'enseignant est introuvable'], 404);
        }

        $enrollments = Enrollment::with(['student.user', 'course.subject'])
            ->when($request->course_id, fn($q, $v) => $q->where('course_id', $v))
            ->get();

        return response()->json([
            'success' => true,
            'data' => EnrollmentResource::collection($enrollments),
        ]);
    }

    public function students(Course $course): JsonResponse
    {
        $enrollments = Enrollment::where('course_id', $course->id)
            ->with(['student.user', 'student.program', 'student.level'])
            ->get();

        $students = $enrollments->pluck('student');

        return response()->json([
            'success' => true,
            'data' => StudentResource::collection($students),
        ]);
    }
}
