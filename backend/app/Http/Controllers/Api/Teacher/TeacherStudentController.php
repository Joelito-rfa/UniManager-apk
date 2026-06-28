<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Http\Resources\GradeResource;
use App\Http\Resources\ResultResource;
use App\Http\Resources\StudentResource;
use App\Models\Course;
use App\Models\Enrollment;
use App\Models\Grade;
use App\Models\Student;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeacherStudentController extends Controller
{
    public function students(Request $request): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'L\'enseignant est introuvable'], 404);
        }

        $courseIds = Course::where('teacher_id', $teacher->id)->pluck('id');

        $students = Student::whereHas('enrollments', fn($q) => $q->whereIn('course_id', $courseIds))
            ->with(['user', 'program', 'level'])
            ->when($request->search, fn($q, $v) => $q->where(function($q) use ($v) {
                $q->whereHas('user', fn($q) => $q->where('name', 'like', "%{$v}%"))
                  ->orWhere('student_number', 'like', "%{$v}%");
            }))
            ->when($request->program_id, fn($q, $v) => $q->where('program_id', $v))
            ->when($request->level_id, fn($q, $v) => $q->where('level_id', $v))
            ->distinct()
            ->paginate($request->per_page ?? 10);

        return response()->json($students);
    }

    public function studentResults(Student $student): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'L\'enseignant est introuvable'], 404);
        }

        $courseIds = Course::where('teacher_id', $teacher->id)->pluck('id');

        $results = $student->results()
            ->whereIn('course_id', $courseIds)
            ->with(['course.subject'])
            ->get();

        return response()->json([
            'success' => true,
            'data' => ResultResource::collection($results),
        ]);
    }

    public function studentGrades(Student $student): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'L\'enseignant est introuvable'], 404);
        }

        $courseIds = Course::where('teacher_id', $teacher->id)->pluck('id');

        $grades = Grade::whereHas('enrollment', fn($q) => $q->where('student_id', $student->id)->whereIn('course_id', $courseIds))
            ->with(['enrollment.course.subject', 'gradedBy'])
            ->get();

        return response()->json([
            'success' => true,
            'data' => GradeResource::collection($grades),
        ]);
    }
}
