<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Events\GradePublished;
use App\Http\Controllers\Controller;
use App\Http\Requests\Teacher\StoreTeacherGradeRequest;
use App\Http\Requests\Teacher\UpdateTeacherGradeRequest;
use App\Http\Resources\GradeResource;
use App\Models\Course;
use App\Models\Enrollment;
use App\Models\Grade;
use App\Services\GradeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeacherGradeController extends Controller
{
    public function __construct(private GradeService $gradeService) {}

    public function index(Request $request): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'L\'enseignant est introuvable'], 404);
        }

        $grades = Grade::with(['enrollment.student.user', 'enrollment.course.subject'])
            ->when($request->course_id, fn($q, $v) => $q->whereHas('enrollment', fn($q) => $q->where('course_id', $v)))
            ->when($request->type, fn($q, $v) => $q->where('grade_type', $v))
            ->when($request->level_id, fn($q, $v) => $q->whereHas('enrollment.student', fn($q) => $q->where('level_id', $v)))
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => GradeResource::collection($grades),
        ]);
    }

    public function storeBatch(Request $request): JsonResponse
    {
        $teacher = auth()->user()->teacher;
        if (!$teacher) {
            return response()->json(['success' => false, 'message' => 'L\'enseignant est introuvable'], 404);
        }

        $gradesData = $request->input('grades', []);
        if (empty($gradesData)) {
            return response()->json(['success' => false, 'message' => 'Aucune note n\'a été fournie'], 422);
        }

        $created = [];
        foreach ($gradesData as $data) {
            $enrollment = Enrollment::with('course')->findOrFail($data['enrollment_id']);

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

    public function store(StoreTeacherGradeRequest $request): JsonResponse
    {
        $enrollment = Enrollment::with('course')->findOrFail($request->enrollment_id);

        $grade = Grade::create([
            'enrollment_id' => $request->enrollment_id,
            'graded_by' => auth()->id(),
            'grade_type' => $request->grade_type,
            'grade_value' => $request->grade_value,
            'coefficient' => $request->coefficient ?? 1,
            'comment' => $request->comment,
        ]);

        $this->gradeService->updateEnrollmentResult($grade->enrollment_id);
        $grade->load(['enrollment.student.user', 'enrollment.course.subject']);
        event(new GradePublished($grade));

        return response()->json([
            'success' => true,
            'message' => 'Note ajoutée avec succès',
            'data' => new GradeResource($grade),
        ], 201);
    }

    public function update(UpdateTeacherGradeRequest $request, Grade $grade): JsonResponse
    {
        $grade->update([
            'grade_type' => $request->grade_type ?? $grade->grade_type,
            'grade_value' => $request->grade_value ?? $grade->grade_value,
            'coefficient' => $request->coefficient ?? $grade->coefficient,
            'comment' => $request->comment ?? $grade->comment,
        ]);

        $this->gradeService->updateEnrollmentResult($grade->enrollment_id);
        $grade->load(['enrollment.student.user', 'enrollment.course.subject']);

        return response()->json([
            'success' => true,
            'message' => 'Note modifiée avec succès',
            'data' => new GradeResource($grade),
        ]);
    }

    public function destroy(Grade $grade): JsonResponse
    {
        $enrollmentId = $grade->enrollment_id;
        $grade->delete();
        $this->gradeService->updateEnrollmentResult($enrollmentId);
        return response()->json([
            'success' => true,
            'message' => 'Note supprimée avec succès',
        ]);
    }
}
