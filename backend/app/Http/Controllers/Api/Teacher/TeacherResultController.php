<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Http\Resources\ResultResource;
use App\Models\Course;
use App\Models\Student;
use App\Models\Result;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @OA\Tag(name="Enseignant - Résultats", description="Consultation des résultats par l'enseignant")
 */
class TeacherResultController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/teacher/results",
     *     summary="Résultats des matières enseignées",
     *     tags={"Enseignant - Résultats"},
     *     @OA\Parameter(name="course_id", in="query", @OA\Schema(type="integer")),
     *     @OA\Parameter(name="semester", in="query", @OA\Schema(type="string")),
     *     @OA\Parameter(name="academic_year", in="query", @OA\Schema(type="string")),
     *     @OA\Parameter(name="search", in="query", @OA\Schema(type="string")),
     *     @OA\Response(response=200, description="Liste des résultats")
     * )
     */
    public function index(Request $request): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'Enseignant introuvable'], 404);
        }

        $courseIds = Course::where('teacher_id', $teacher->id)->pluck('id');

        $query = Result::with(['student.user', 'course.subject'])
            ->whereIn('course_id', $courseIds);

        if ($request->course_id) {
            $query->where('course_id', $request->course_id);
        }

        if ($request->semester) {
            $query->where('semester', $request->semester);
        }

        if ($request->academic_year) {
            $query->where('academic_year', $request->academic_year);
        }

        if ($request->search) {
            $query->whereHas('student.user', fn($q) => $q->where('name', 'ilike', "%{$request->search}%"));
        }

        return response()->json([
            'success' => true,
            'data' => ResultResource::collection($query->paginate($request->per_page ?? 15)),
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/teacher/results/student/{student}",
     *     summary="Résultats d'un étudiant pour les matières de l'enseignant",
     *     tags={"Enseignant - Résultats"},
     *     @OA\Response(response=200, description="Résultats de l'étudiant")
     * )
     */
    public function studentResults(Student $student): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'Enseignant introuvable'], 404);
        }

        $courseIds = Course::where('teacher_id', $teacher->id)->pluck('id');

        $results = $student->results()
            ->whereIn('course_id', $courseIds)
            ->with(['course.subject'])
            ->get();

        return response()->json([
            'success' => true,
            'data' => ResultResource::collection($results),
        ]);
    }

    /**
     * @OA\Get(
     *     path="/api/teacher/results/export/{courseId}",
     *     summary="Exporter les résultats d'un cours en CSV",
     *     tags={"Enseignant - Résultats"},
     *     @OA\Response(response=200, description="Fichier CSV exporté")
     * )
     */
    public function export(int $courseId): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'Enseignant introuvable'], 404);
        }

        $course = Course::where('id', $courseId)->where('teacher_id', $teacher->id)->first();
        if (!$course) {
            return response()->json(['success' => false, 'message' => 'Cours non trouvé'], 404);
        }

        $service = app(\App\Services\ReportService::class);
        $path = $service->exportResultsExcel($courseId);

        return response()->json([
            'success' => true,
            'data' => ['path' => $path],
        ]);
    }
}
