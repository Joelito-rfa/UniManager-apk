<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Requests\Student\UpdateStudentProfileRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentProfileController extends Controller
{
    public function show(): JsonResponse
    {
        $user = auth()->user()->load(['student.program', 'student.level', 'student.enrollments.course.subject']);
        return response()->json([
            'success' => true,
            'data' => new UserResource($user),
        ]);
    }

    public function update(UpdateStudentProfileRequest $request): JsonResponse
    {
        $user = auth()->user();
        $data = $request->validated();

        if (isset($data['name']) || isset($data['phone']) || isset($data['avatar'])) {
            $user->update(array_intersect_key($data, array_flip(['name', 'phone', 'avatar'])));
        }

        $studentData = array_intersect_key($data, array_flip(['emergency_contact', 'emergency_phone']));
        if (!empty($studentData) && $user->student) {
            $user->student->update($studentData);
        }

        return response()->json([
            'success' => true,
            'message' => 'Profil mis à jour avec succès',
            'data' => new UserResource($user->load(['student.program', 'student.level'])),
        ]);
    }
}
