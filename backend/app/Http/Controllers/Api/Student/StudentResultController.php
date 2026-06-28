<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\ResultResource;
use App\Http\Resources\LevelResultResource;
use App\Services\ResultService;
use App\Services\LevelResultService;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @OA\Tag(name="Étudiant - Résultats", description="Consultation des résultats par l'étudiant")
 */
class StudentResultController extends Controller
{
    public function __construct(
        private ResultService $resultService,
        private LevelResultService $levelResultService,
        private ReportService $reportService
    ) {}

    /**
     * @OA\Get(
     *     path="/api/student/results",
     *     summary="Résultats par matière de l'étudiant connecté",
     *     tags={"Étudiant - Résultats"},
     *     @OA\Parameter(name="semester", in="query", @OA\Schema(type="string")),
     *     @OA\Parameter(name="academic_year", in="query", @OA\Schema(type="string")),
     *     @OA\Parameter(name="level_id", in="query", @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Liste des résultats")
     * )
     */
    public function index(Request $request): JsonResponse
    {
        $student = auth()->user()->student;
        if (!$student) {
            return response()->json(['success' => true, 'data' => []]);
        }

        $results = $this->resultService->getStudentResultsByFilters(
            $student->id,
            $request->only(['semester', 'academic_year', 'level_id'])
        );

        return response()->json([
            'success' => true,
            'data' => ResultResource::collection($results),
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/student/results/transcript",
     *     summary="Relevé de notes complet",
     *     tags={"Étudiant - Résultats"},
     *     @OA\Response(response=200, description="Relevé de notes")
     * )
     */
    public function transcript(): JsonResponse
    {
        $student = auth()->user()->student;
        if (!$student) {
            return response()->json(['success' => true, 'data' => null]);
        }

        $data = $this->resultService->getStudentTranscript($student->id);
        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/student/results/level",
     *     summary="Résultats finaux par niveau",
     *     tags={"Étudiant - Résultats"},
     *     @OA\Response(response=200, description="Résultats niveau")
     * )
     */
    public function levelResults(): JsonResponse
    {
        $student = auth()->user()->student;
        if (!$student) {
            return response()->json(['success' => true, 'data' => []]);
        }

        $results = $this->levelResultService->getStudentLevelResults($student->id);
        return response()->json([
            'success' => true,
            'data' => LevelResultResource::collection($results),
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/student/results/summary",
     *     summary="Récapitulatif des résultats",
     *     tags={"Étudiant - Résultats"},
     *     @OA\Response(response=200, description="Récapitulatif")
     * )
     */
    public function summary(): JsonResponse
    {
        $student = auth()->user()->student;
        if (!$student) {
            return response()->json(['success' => true, 'data' => [
                'total_credits' => 0,
                'validated_credits' => 0,
                'overall_gpa' => null,
                'results_count' => 0,
                'validated_count' => 0,
                'failed_count' => 0,
                'retake_count' => 0,
                'current_level_result' => null,
            ]]);
        }

        $results = $student->results()->with('course.subject')->get();
        $levelResults = $student->levelResults()->get();

        $totalCredits = $results->sum('credit_value');
        $validatedCredits = $results->where('decision', 'validated')->sum('credit_value');
        $overallGpa = $results->count() > 0
            ? round($results->sum(fn($r) => $r->grade_point * $r->credit_value) / max($results->sum('credit_value'), 1), 2)
            : null;

        return response()->json([
            'success' => true,
            'data' => [
                'total_credits' => $totalCredits,
                'validated_credits' => $validatedCredits,
                'overall_gpa' => $overallGpa,
                'results_count' => $results->count(),
                'validated_count' => $results->where('decision', 'validated')->count(),
                'failed_count' => $results->where('decision', 'failed')->count(),
                'retake_count' => $results->where('decision', 'retake')->count(),
                'current_level_result' => $levelResults->sortByDesc('academic_year')->first() ? [
                    'average_grade' => $levelResults->sortByDesc('academic_year')->first()->average_grade,
                    'decision' => $levelResults->sortByDesc('academic_year')->first()->decision,
                    'mention' => $levelResults->sortByDesc('academic_year')->first()->mention,
                    'total_credits_obtained' => $levelResults->sortByDesc('academic_year')->first()->total_credits_obtained,
                    'total_credits_required' => $levelResults->sortByDesc('academic_year')->first()->total_credits_required,
                ] : null,
            ],
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/student/results/download",
     *     summary="Télécharger le relevé de notes en PDF",
     *     tags={"Étudiant - Résultats"},
     *     @OA\Response(response=200, description="PDF téléchargé")
     * )
     */
    public function downloadPdf(Request $request)
    {
        $student = auth()->user()->student;
        if (!$student) {
            return response()->json(['success' => false, 'message' => 'Étudiant introuvable'], 404);
        }

        $request->validate([
            'semester' => 'nullable|string',
            'academic_year' => 'nullable|string',
        ]);

        $pdf = $this->reportService->generateStudentReport($student, $request->only(['semester', 'academic_year']));
        return $pdf->download('releve_notes_' . $student->student_number . '.pdf');
    }
}
