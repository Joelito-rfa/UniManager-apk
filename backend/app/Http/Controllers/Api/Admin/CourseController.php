<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreCourseRequest;
use App\Http\Requests\Admin\UpdateCourseRequest;
use App\Http\Resources\CourseResource;
use App\Models\Course;
use App\Services\CourseService;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CourseController extends Controller
{
    public function __construct(private CourseService $courseService) {}

    public function index(Request $request): JsonResponse
    {
        $courses = $this->courseService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => CourseResource::collection($courses),
            'meta' => [
                'current_page' => $courses->currentPage(),
                'last_page' => $courses->lastPage(),
                'per_page' => $courses->perPage(),
                'total' => $courses->total(),
            ],
        ]);
    }

    public function store(StoreCourseRequest $request): JsonResponse
    {
        $data = $request->validated();
        $course = $this->courseService->create($data);

        if (!empty($data['teacher_id']) && $course->teacher && $course->teacher->user) {
            $subjectName = $course->subject->name ?? $course->name ?? '';
            app(NotificationService::class)->create(
                $course->teacher->user->id,
                'Cours assigné',
                "Vous avez été assigné au cours {$subjectName}",
                'info',
                ['course_id' => $course->id]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Cours créé avec succès',
            'data' => new CourseResource($course),
        ], 201);
    }

    public function show(Course $course): JsonResponse
    {
        $course->load(['subject', 'teacher.user', 'classroom', 'schedules.classroom', 'enrollments.student.user']);
        return response()->json([
            'success' => true,
            'data' => new CourseResource($course),
        ]);
    }

    public function update(UpdateCourseRequest $request, Course $course): JsonResponse
    {
        $data = $request->validated();
        $oldTeacherId = $course->teacher_id;
        $course = $this->courseService->update($course, $data);

        if (!empty($data['teacher_id']) && $data['teacher_id'] !== $oldTeacherId && $course->teacher && $course->teacher->user) {
            $subjectName = $course->subject->name ?? $course->name ?? '';
            app(NotificationService::class)->create(
                $course->teacher->user->id,
                'Cours assigné',
                "Vous avez été assigné au cours {$subjectName}",
                'info',
                ['course_id' => $course->id]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Cours modifié avec succès',
            'data' => new CourseResource($course),
        ]);
    }

    public function destroy(Course $course): JsonResponse
    {
        $this->courseService->delete($course);
        return response()->json([
            'success' => true,
            'message' => 'Cours supprimé avec succès',
        ]);
    }
}
