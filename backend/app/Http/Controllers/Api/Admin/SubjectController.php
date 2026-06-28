<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreSubjectRequest;
use App\Http\Requests\Admin\UpdateSubjectRequest;
use App\Http\Resources\SubjectResource;
use App\Models\Subject;
use App\Services\SubjectService;
use App\Services\IdentifierService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    public function __construct(private SubjectService $subjectService) {}

    public function index(Request $request): JsonResponse
    {
        $subjects = $this->subjectService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => SubjectResource::collection($subjects),
            'meta' => [
                'current_page' => $subjects->currentPage(),
                'last_page' => $subjects->lastPage(),
                'per_page' => $subjects->perPage(),
                'total' => $subjects->total(),
            ],
        ]);
    }

    public function store(StoreSubjectRequest $request): JsonResponse
    {
        $subject = $this->subjectService->create($request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Matière créée avec succès',
            'data' => new SubjectResource($subject),
        ], 201);
    }

    public function show(Subject $subject): JsonResponse
    {
        $subject->load(['program', 'teacher.user', 'courses']);
        return response()->json([
            'success' => true,
            'data' => new SubjectResource($subject),
        ]);
    }

    public function update(UpdateSubjectRequest $request, Subject $subject): JsonResponse
    {
        $subject = $this->subjectService->update($subject, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Matière modifiée avec succès',
            'data' => new SubjectResource($subject),
        ]);
    }

    public function nextCode(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'next_code' => app(IdentifierService::class)->generateForClass(Subject::class),
            ],
        ]);
    }

    public function destroy(Subject $subject): JsonResponse
    {
        $this->subjectService->delete($subject);
        return response()->json([
            'success' => true,
            'message' => 'Matière supprimée avec succès',
        ]);
    }
}
