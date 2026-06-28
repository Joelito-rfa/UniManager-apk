<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\CourseResource;
use App\Models\Course;
use Illuminate\Http\JsonResponse;

class StudentCourseController extends Controller
{
    public function index(): JsonResponse
    {
        $courses = Course::with(['subject', 'level', 'teacher.user'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => CourseResource::collection($courses),
        ]);
    }
}
