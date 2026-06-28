<?php

namespace App\Http\Controllers\Api\Admin;

use App\Events\GradePublished;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreGradeRequest;
use App\Http\Requests\Admin\UpdateGradeRequest;
use App\Http\Resources\GradeResource;
use App\Models\Grade;
use App\Services\GradeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GradeController extends Controller
{
    public function __construct(private GradeService $gradeService) {}

    public function index(Request $request): JsonResponse
    {
        $grades = $this->gradeService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => GradeResource::collection($grades),
            'meta' => [
                'current_page' => $grades->currentPage(),
                'last_page' => $grades->lastPage(),
                'per_page' => $grades->perPage(),
                'total' => $grades->total(),
            ],
        ]);
    }

    public function store(StoreGradeRequest $request): JsonResponse
    {
        $grade = $this->gradeService->create($request->validated());
        event(new GradePublished($grade));
        return response()->json([
            'success' => true,
            'message' => 'Note ajoutée avec succès',
            'data' => new GradeResource($grade),
        ], 201);
    }

    public function storeBatch(Request $request): JsonResponse
    {
        $gradesData = $request->input('grades', []);
        if (empty($gradesData)) {
            return response()->json(['success' => false, 'message' => 'Aucune note n\'a été fournie'], 422);
        }

        $created = [];
        foreach ($gradesData as $data) {
            $grade = Grade::create([
                'enrollment_id' => $data['enrollment_id'],
                'graded_by' => auth()->id(),
                'grade_type' => $data['grade_type'] ?? 'exam',
                'grade_value' => $data['grade_value'],
                'coefficient' => $data['coefficient'] ?? 1,
                'comment' => $data['comment'] ?? null,
            ]);

            $this->gradeService->updateEnrollmentResult($grade->enrollment_id);
            $grade->load(['enrollment.student.user', 'enrollment.course.subject']);
            event(new GradePublished($grade));
            $created[] = $grade;
        }

        return response()->json([
            'success' => true,
            'message' => count($created) . ' note(s) ajoutée(s) avec succès',
            'data' => GradeResource::collection($created),
        ], 201);
    }

    public function show(Grade $grade): JsonResponse
    {
        $grade->load(['enrollment.student.user', 'enrollment.course.subject', 'gradedBy']);
        return response()->json([
            'success' => true,
            'data' => new GradeResource($grade),
        ]);
    }

    public function update(UpdateGradeRequest $request, Grade $grade): JsonResponse
    {
        $grade = $this->gradeService->update($grade, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Note modifiée avec succès',
            'data' => new GradeResource($grade),
        ]);
    }

    public function destroy(Grade $grade): JsonResponse
    {
        $grade->delete();
        return response()->json([
            'success' => true,
            'message' => 'Note supprimée avec succès',
        ]);
    }
}
