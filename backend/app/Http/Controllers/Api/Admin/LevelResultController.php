<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\CalculateLevelResultsRequest;
use App\Http\Requests\Admin\PublishResultsRequest;
use App\Http\Resources\LevelResultResource;
use App\Models\LevelResult;
use App\Services\LevelResultService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @OA\Tag(name="Admin - Résultats Niveau", description="Gestion des résultats finaux par niveau")
 */
class LevelResultController extends Controller
{
    public function __construct(private LevelResultService $levelResultService) {}

    /**
     * @OA\Get(
     *     path="/api/admin/level-results",
     *     summary="Liste paginée des résultats finaux par niveau",
     *     tags={"Admin - Résultats Niveau"},
     *     @OA\Response(response=200, description="Liste des résultats niveau")
     * )
     */
    public function index(Request $request): JsonResponse
    {
        $results = $this->levelResultService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => LevelResultResource::collection($results),
            'meta' => [
                'current_page' => $results->currentPage(),
                'last_page' => $results->lastPage(),
                'per_page' => $results->perPage(),
                'total' => $results->total(),
            ],
        ]);
    }

    /**
     * @OA\Post(
     *     path="/api/admin/level-results/calculate",
     *     summary="Calculer les résultats finaux par niveau",
     *     tags={"Admin - Résultats Niveau"},
     *     @OA\Response(response=200, description="Résultats niveau calculés")
     * )
     */
    public function calculate(CalculateLevelResultsRequest $request): JsonResponse
    {
        $results = $this->levelResultService->calculate($request->validated());
        return response()->json([
            'success' => true,
            'message' => count($results) . ' résultat(s) de niveau calculé(s) avec succès',
            'data' => LevelResultResource::collection($results),
        ]);
    }

    /**
     * @OA\Post(
     *     path="/api/admin/level-results/publish",
     *     summary="Publier les résultats finaux par niveau",
     *     tags={"Admin - Résultats Niveau"},
     *     @OA\Response(response=200, description="Résultats niveau publiés")
     * )
     */
    public function publish(PublishResultsRequest $request): JsonResponse
    {
        $count = $this->levelResultService->publish($request->validated());
        return response()->json([
            'success' => true,
            'message' => "$count résultat(s) de niveau publié(s) avec succès",
            'data' => ['published_count' => $count],
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/admin/level-results/{levelResult}",
     *     summary="Détail d'un résultat niveau",
     *     tags={"Admin - Résultats Niveau"},
     *     @OA\Response(response=200, description="Détail du résultat niveau")
     * )
     */
    public function show(LevelResult $levelResult): JsonResponse
    {
        $levelResult->load(['student.user', 'level', 'program', 'validatedBy']);
        return response()->json([
            'success' => true,
            'data' => new LevelResultResource($levelResult),
        ]);
    }

    /**
     * @OA\Delete(
     *     path="/api/admin/level-results/{levelResult}",
     *     summary="Supprimer un résultat niveau",
     *     tags={"Admin - Résultats Niveau"},
     *     @OA\Response(response=200, description="Résultat niveau supprimé")
     * )
     */
    public function destroy(LevelResult $levelResult): JsonResponse
    {
        $this->levelResultService->delete($levelResult);
        return response()->json([
            'success' => true,
            'message' => 'Résultat de niveau supprimé avec succès',
        ]);
    }
}
