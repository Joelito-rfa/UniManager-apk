<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\CalculateResultsRequest;
use App\Http\Requests\Admin\PublishResultsRequest;
use App\Http\Requests\Admin\UpdateResultRequest;
use App\Http\Resources\ResultResource;
use App\Models\Result;
use App\Services\ResultService;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @OA\Tag(name="Admin - Résultats", description="Gestion des résultats académiques")
 */
class ResultController extends Controller
{
    public function __construct(
        private ResultService $resultService,
        private ReportService $reportService
    ) {}

    /**
     * @OA\Get(
     *     path="/api/admin/results",
     *     summary="Liste paginée des résultats",
     *     tags={"Admin - Résultats"},
     *     @OA\Parameter(name="search", in="query", description="Recherche par nom ou matricule"),
     *     @OA\Parameter(name="student_id", in="query", @OA\Schema(type="integer")),
     *     @OA\Parameter(name="course_id", in="query", @OA\Schema(type="integer")),
     *     @OA\Parameter(name="semester", in="query", @OA\Schema(type="string")),
     *     @OA\Parameter(name="academic_year", in="query", @OA\Schema(type="string")),
     *     @OA\Parameter(name="level_id", in="query", @OA\Schema(type="integer")),
     *     @OA\Parameter(name="program_id", in="query", @OA\Schema(type="integer")),
     *     @OA\Parameter(name="department_id", in="query", @OA\Schema(type="integer")),
     *     @OA\Parameter(name="decision", in="query", @OA\Schema(type="string")),
     *     @OA\Response(response=200, description="Liste des résultats")
     * )
     */
    public function index(Request $request): JsonResponse
    {
        $results = $this->resultService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => ResultResource::collection($results),
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
     *     path="/api/admin/results/calculate",
     *     summary="Calculer les résultats à partir des notes",
     *     tags={"Admin - Résultats"},
     *     @OA\Response(response=200, description="Résultats calculés")
     * )
     */
    public function calculate(CalculateResultsRequest $request): JsonResponse
    {
        $results = $this->resultService->calculate($request->validated());
        return response()->json([
            'success' => true,
            'message' => count($results) . ' résultat(s) calculé(s) avec succès',
            'data' => ResultResource::collection($results),
        ]);
    }

    /**
     * @OA\Post(
     *     path="/api/admin/results/publish",
     *     summary="Publier les résultats",
     *     tags={"Admin - Résultats"},
     *     @OA\Response(response=200, description="Résultats publiés")
     * )
     */
    public function publish(PublishResultsRequest $request): JsonResponse
    {
        $count = $this->resultService->publish($request->validated());
        return response()->json([
            'success' => true,
            'message' => "$count résultat(s) publié(s) avec succès",
            'data' => ['published_count' => $count],
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/admin/results/{result}",
     *     summary="Détail d'un résultat",
     *     tags={"Admin - Résultats"},
     *     @OA\Response(response=200, description="Détail du résultat")
     * )
     */
    public function show(Result $result): JsonResponse
    {
        $result->load(['student.user', 'course.subject', 'course.teacher.user', 'validatedBy']);
        return response()->json([
            'success' => true,
            'data' => new ResultResource($result),
        ]);
    }

    /**
     * @OA\Put(
     *     path="/api/admin/results/{result}",
     *     summary="Modifier un résultat",
     *     tags={"Admin - Résultats"},
     *     @OA\Response(response=200, description="Résultat modifié")
     * )
     */
    public function update(UpdateResultRequest $request, Result $result): JsonResponse
    {
        $result = $this->resultService->update($request->validated(), $result);
        return response()->json([
            'success' => true,
            'message' => 'Résultat modifié avec succès',
            'data' => new ResultResource($result),
        ]);
    }

    /**
     * @OA\Delete(
     *     path="/api/admin/results/{result}",
     *     summary="Supprimer un résultat",
     *     tags={"Admin - Résultats"},
     *     @OA\Response(response=200, description="Résultat supprimé")
     * )
     */
    public function destroy(Result $result): JsonResponse
    {
        $this->resultService->delete($result);
        return response()->json([
            'success' => true,
            'message' => 'Résultat supprimé avec succès',
        ]);
    }

    /**
     * @OA\Post(
     *     path="/api/admin/results/recalculate",
     *     summary="Recalculer tous les résultats",
     *     tags={"Admin - Résultats"},
     *     @OA\Response(response=200, description="Tous les résultats ont été recalculés")
     * )
     */
    public function recalculateAll(): JsonResponse
    {
        $this->resultService->recalculateAll();
        return response()->json([
            'success' => true,
            'message' => 'Tous les résultats ont été recalculés',
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/admin/results/transcript/{studentId}",
     *     summary="Relevé de notes complet d'un étudiant",
     *     tags={"Admin - Résultats"},
     *     @OA\Response(response=200, description="Relevé de notes")
     * )
     */
    public function transcript(int $studentId): JsonResponse
    {
        $data = $this->resultService->getStudentTranscript($studentId);
        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/admin/results/export/pdf/{courseId}",
     *     summary="Exporter les résultats d'un cours en PDF",
     *     tags={"Admin - Résultats"},
     *     @OA\Response(response=200, description="PDF exporté")
     * )
     */
    public function exportPdf(int $courseId): \Illuminate\Http\Response
    {
        $pdf = $this->reportService->generateClassReport($courseId);
        return $pdf->download("resultats_cours_{$courseId}.pdf");
    }

    /**
     * @OA\Get(
     *     path="/api/admin/results/export/excel/{courseId}",
     *     summary="Exporter les résultats d'un cours en Excel",
     *     tags={"Admin - Résultats"},
     *     @OA\Response(response=200, description="Fichier Excel exporté")
     * )
     */
    public function exportExcel(int $courseId): JsonResponse
    {
        $path = $this->reportService->exportResultsExcel($courseId);
        return response()->json([
            'success' => true,
            'data' => ['path' => $path],
        ]);
    }
}
