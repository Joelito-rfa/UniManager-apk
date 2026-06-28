<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreScheduleRequest;
use App\Http\Requests\Admin\UpdateScheduleRequest;
use App\Http\Resources\ScheduleResource;
use App\Models\Schedule;
use App\Models\User;
use App\Services\ScheduleService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    public function __construct(private ScheduleService $scheduleService) {}

    public function index(Request $request): JsonResponse
    {
        $schedules = $this->scheduleService->paginate($request);
        return response()->json([
            'success' => true,
            'data' => ScheduleResource::collection($schedules),
            'meta' => [
                'current_page' => $schedules->currentPage(),
                'last_page' => $schedules->lastPage(),
                'per_page' => $schedules->perPage(),
                'total' => $schedules->total(),
            ],
        ]);
    }

    public function store(StoreScheduleRequest $request): JsonResponse
    {
        $schedule = $this->scheduleService->create($request->validated());
        $schedule->load(['course.subject', 'course.teacher.user', 'classroom']);

        $daysFr = ['Monday' => 'Lundi', 'Tuesday' => 'Mardi', 'Wednesday' => 'Mercredi', 'Thursday' => 'Jeudi', 'Friday' => 'Vendredi', 'Saturday' => 'Samedi', 'Sunday' => 'Dimanche'];
        $dayFr = $daysFr[$schedule->day_of_week] ?? $schedule->day_of_week;
        $courseName = $schedule->course?->subject?->name ?? 'Cours';
        $startTime = substr($schedule->start_time, 0, 5);
        $endTime = substr($schedule->end_time, 0, 5);

        $users = User::where('id', '!=', auth()->id())->get();
        foreach ($users as $user) {
            $user->notifications()->create([
                'type' => 'schedule',
                'title' => 'Nouvelle séance programmée',
                'message' => "{$courseName} - {$dayFr} ({$startTime}-{$endTime})",
                'data' => [
                    'schedule_id' => $schedule->id,
                    'course_id' => $schedule->course_id,
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Séance planifiée avec succès',
            'data' => new ScheduleResource($schedule),
        ], 201);
    }

    public function show(Schedule $schedule): JsonResponse
    {
        $schedule->load(['course.subject', 'course.teacher.user', 'classroom']);
        return response()->json([
            'success' => true,
            'data' => new ScheduleResource($schedule),
        ]);
    }

    public function update(UpdateScheduleRequest $request, Schedule $schedule): JsonResponse
    {
        $schedule = $this->scheduleService->update($schedule, $request->validated());
        return response()->json([
            'success' => true,
            'message' => 'Séance modifiée avec succès',
            'data' => new ScheduleResource($schedule),
        ]);
    }

    public function destroy(Schedule $schedule): JsonResponse
    {
        $this->scheduleService->delete($schedule);
        return response()->json([
            'success' => true,
            'message' => 'Séance supprimée avec succès',
        ]);
    }
}
