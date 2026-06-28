<?php

namespace App\Http\Controllers\Api\Admin;

use App\Events\StudentEnrolled;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreEnrollmentRequest;
use App\Http\Requests\Admin\UpdateEnrollmentRequest;
use App\Http\Resources\EnrollmentResource;
use App\Models\Enrollment;
use App\Services\EnrollmentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EnrollmentController extends Controller
{
    public function __construct(private EnrollmentService $enrollmentService) {}

    public function index(Request $request): JsonResponse
    {
        $enrollments = $this->enrollmentService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => EnrollmentResource::collection($enrollments),
            'meta' => [
                'current_page' => $enrollments->currentPage(),
                'last_page' => $enrollments->lastPage(),
                'per_page' => $enrollments->perPage(),
                'total' => $enrollments->total(),
            ],
        ]);
    }

    public function store(StoreEnrollmentRequest $request): JsonResponse
    {
        $enrollment = $this->enrollmentService->create($request->validated());
        event(new StudentEnrolled($enrollment));
        return response()->json([
            'success' => true,
            'message' => 'Inscription créée avec succès',
            'data' => new EnrollmentResource($enrollment),
        ], 201);
    }

    public function show(Enrollment $enrollment): JsonResponse
    {
        $enrollment->load(['student.user', 'course.subject', 'grades.gradedBy']);
        return response()->json([
            'success' => true,
            'data' => new EnrollmentResource($enrollment),
        ]);
    }

    public function update(UpdateEnrollmentRequest $request, Enrollment $enrollment): JsonResponse
    {
        $enrollment = $this->enrollmentService->update($enrollment, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Inscription modifiée avec succès',
            'data' => new EnrollmentResource($enrollment),
        ]);
    }

    public function destroy(Enrollment $enrollment): JsonResponse
    {
        $this->enrollmentService->delete($enrollment);
        return response()->json([
            'success' => true,
            'message' => 'Inscription supprimée avec succès',
        ]);
    }
}
