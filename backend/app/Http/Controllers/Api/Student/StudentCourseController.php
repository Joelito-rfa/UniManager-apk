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
        $student = auth()->user()->student;

        if (!$student) {
            return response()->json(['success' => false, 'message' => 'Profil étudiant introuvable'], 404);
        }

        $courses = Course::with(['subject', 'level', 'teacher.user', 'classroom'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => CourseResource::collection($courses),
        ]);
    }
}
