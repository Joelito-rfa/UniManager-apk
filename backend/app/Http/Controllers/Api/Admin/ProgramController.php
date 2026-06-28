<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreProgramRequest;
use App\Http\Requests\Admin\UpdateProgramRequest;
use App\Http\Resources\ProgramResource;
use App\Models\Program;
use App\Services\ProgramService;
use App\Services\IdentifierService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProgramController extends Controller
{
    public function __construct(private ProgramService $programService) {}

    public function index(Request $request): JsonResponse
    {
        $programs = $this->programService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => ProgramResource::collection($programs),
            'meta' => [
                'current_page' => $programs->currentPage(),
                'last_page' => $programs->lastPage(),
                'per_page' => $programs->perPage(),
                'total' => $programs->total(),
            ],
        ]);
    }

    public function store(StoreProgramRequest $request): JsonResponse
    {
        $program = $this->programService->create($request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Programme créé avec succès',
            'data' => new ProgramResource($program),
        ], 201);
    }

    public function show(Program $program): JsonResponse
    {
        $program->load(['department', 'levels', 'subjects', 'students']);
        return response()->json([
            'success' => true,
            'data' => new ProgramResource($program),
        ]);
    }

    public function update(UpdateProgramRequest $request, Program $program): JsonResponse
    {
        $program = $this->programService->update($program, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Programme modifié avec succès',
            'data' => new ProgramResource($program),
        ]);
    }

    public function nextCode(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'next_code' => app(IdentifierService::class)->generateForClass(Program::class),
            ],
        ]);
    }

    public function destroy(Program $program): JsonResponse
    {
        $this->programService->delete($program);
        return response()->json([
            'success' => true,
            'message' => 'Programme supprimé avec succès',
        ]);
    }
}
