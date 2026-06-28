<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreLevelRequest;
use App\Http\Requests\Admin\UpdateLevelRequest;
use App\Http\Resources\LevelResource;
use App\Models\Level;
use App\Services\LevelService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LevelController extends Controller
{
    public function __construct(private LevelService $levelService) {}

    public function index(Request $request): JsonResponse
    {
        if ($request->per_page == -1) {
            $levels = $this->levelService->all();
            return response()->json([
                'success' => true,
                'data' => LevelResource::collection($levels),
                'current_page' => 1,
                'last_page' => 1,
                'per_page' => $levels->count(),
                'total' => $levels->count(),
            ]);
        }

        $levels = $this->levelService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => LevelResource::collection($levels),
            'current_page' => $levels->currentPage(),
            'last_page' => $levels->lastPage(),
            'per_page' => $levels->perPage(),
            'total' => $levels->total(),
        ]);
    }

    public function store(StoreLevelRequest $request): JsonResponse
    {
        $level = $this->levelService->create($request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Niveau créé avec succès',
            'data' => new LevelResource($level),
        ], 201);
    }

    public function show(Level $level): JsonResponse
    {
        $level->load(['program', 'students.user']);
        return response()->json([
            'success' => true,
            'data' => new LevelResource($level),
        ]);
    }

    public function update(UpdateLevelRequest $request, Level $level): JsonResponse
    {
        $level = $this->levelService->update($level, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Niveau modifié avec succès',
            'data' => new LevelResource($level),
        ]);
    }

    public function destroy(Level $level): JsonResponse
    {
        $this->levelService->delete($level);
        return response()->json([
            'success' => true,
            'message' => 'Niveau supprimé avec succès',
        ]);
    }
}
