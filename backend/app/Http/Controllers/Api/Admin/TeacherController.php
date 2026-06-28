<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreTeacherRequest;
use App\Http\Requests\Admin\UpdateTeacherRequest;
use App\Http\Resources\TeacherResource;
use App\Models\Teacher;
use App\Services\TeacherService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeacherController extends Controller
{
    public function __construct(private TeacherService $teacherService) {}

    public function index(Request $request): JsonResponse
    {
        $teachers = $this->teacherService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => TeacherResource::collection($teachers),
            'meta' => [
                'current_page' => $teachers->currentPage(),
                'last_page' => $teachers->lastPage(),
                'per_page' => $teachers->perPage(),
                'total' => $teachers->total(),
            ],
        ]);
    }

    public function store(StoreTeacherRequest $request): JsonResponse
    {
        $teacher = $this->teacherService->create($request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Enseignant créé avec succès',
            'data' => new TeacherResource($teacher),
        ], 201);
    }

    public function show(Teacher $teacher): JsonResponse
    {
        $teacher->load(['user', 'department', 'subjects', 'courses.subject']);
        return response()->json([
            'success' => true,
            'data' => new TeacherResource($teacher),
        ]);
    }

    public function update(UpdateTeacherRequest $request, Teacher $teacher): JsonResponse
    {
        $teacher = $this->teacherService->update($teacher, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Enseignant modifié avec succès',
            'data' => new TeacherResource($teacher),
        ]);
    }

    public function nextNumber(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'next_number' => $this->teacherService->generateTeacherNumber(),
            ],
        ]);
    }

    public function destroy(Teacher $teacher): JsonResponse
    {
        $this->teacherService->delete($teacher);
        return response()->json([
            'success' => true,
            'message' => 'Enseignant supprimé avec succès',
        ]);
    }
}
