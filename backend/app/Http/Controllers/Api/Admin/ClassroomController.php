<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreClassroomRequest;
use App\Http\Requests\Admin\UpdateClassroomRequest;
use App\Http\Resources\ClassroomResource;
use App\Models\Classroom;
use App\Services\ClassroomService;
use App\Services\IdentifierService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ClassroomController extends Controller
{
    public function __construct(private ClassroomService $classroomService) {}

    public function index(Request $request): JsonResponse
    {
        $classrooms = $this->classroomService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => ClassroomResource::collection($classrooms),
            'meta' => [
                'current_page' => $classrooms->currentPage(),
                'last_page' => $classrooms->lastPage(),
                'per_page' => $classrooms->perPage(),
                'total' => $classrooms->total(),
            ],
        ]);
    }

    public function store(StoreClassroomRequest $request): JsonResponse
    {
        $classroom = $this->classroomService->create($request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Salle créée avec succès',
            'data' => new ClassroomResource($classroom),
        ], 201);
    }

    public function show(Classroom $classroom): JsonResponse
    {
        $classroom->load(['courses.subject', 'schedules']);
        return response()->json([
            'success' => true,
            'data' => new ClassroomResource($classroom),
        ]);
    }

    public function update(UpdateClassroomRequest $request, Classroom $classroom): JsonResponse
    {
        $classroom = $this->classroomService->update($classroom, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Salle modifiée avec succès',
            'data' => new ClassroomResource($classroom),
        ]);
    }

    public function nextCode(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'next_code' => app(IdentifierService::class)->generateForClass(Classroom::class),
            ],
        ]);
    }

    public function destroy(Classroom $classroom): JsonResponse
    {
        $this->classroomService->delete($classroom);
        return response()->json([
            'success' => true,
            'message' => 'Salle supprimée avec succès',
        ]);
    }
}
