<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreStudentRequest;
use App\Http\Requests\Admin\UpdateStudentRequest;
use App\Http\Resources\StudentResource;
use App\Models\Student;
use App\Services\StudentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentController extends Controller
{
    public function __construct(private StudentService $studentService) {}

    public function index(Request $request): JsonResponse
    {
        $students = $this->studentService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => StudentResource::collection($students),
            'meta' => [
                'current_page' => $students->currentPage(),
                'last_page' => $students->lastPage(),
                'per_page' => $students->perPage(),
                'total' => $students->total(),
            ],
        ]);
    }

    public function store(StoreStudentRequest $request): JsonResponse
    {
        $student = $this->studentService->create($request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Étudiant créé avec succès',
            'data' => new StudentResource($student),
        ], 201);
    }

    public function show(Student $student): JsonResponse
    {
        $student->load(['user', 'program', 'level', 'enrollments.course.subject']);
        return response()->json([
            'success' => true,
            'data' => new StudentResource($student),
        ]);
    }

    public function update(UpdateStudentRequest $request, Student $student): JsonResponse
    {
        $student = $this->studentService->update($student, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Étudiant modifié avec succès',
            'data' => new StudentResource($student),
        ]);
    }

    public function nextNumber(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'next_number' => $this->studentService->generateStudentNumber(),
            ],
        ]);
    }

    public function destroy(Student $student): JsonResponse
    {
        $this->studentService->delete($student);
        return response()->json([
            'success' => true,
            'message' => 'Étudiant supprimé avec succès',
        ]);
    }
}
