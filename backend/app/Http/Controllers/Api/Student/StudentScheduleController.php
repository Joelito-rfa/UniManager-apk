<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\ScheduleResource;
use App\Models\Schedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentScheduleController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $schedules = Schedule::with(['course.subject', 'course.teacher.user', 'classroom', 'level'])
            ->when($request->day_of_week, fn($q, $v) => $q->where('day_of_week', $v))
            ->when($request->status, fn($q, $v) => $q->where('status', $v))
            ->when($request->course_id, fn($q, $v) => $q->where('course_id', $v))
            ->orderBy('day_of_week')
            ->orderBy('start_time')
            ->get();

        return response()->json([
            'success' => true,
            'data' => ScheduleResource::collection($schedules),
        ]);
    }

    public function today(): JsonResponse
    {
        $dayOfWeek = now()->dayOfWeek;
        $dayMap = [1 => 7, 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 5, 0 => 6];
        $day = $dayMap[$dayOfWeek] ?? $dayOfWeek;

        $schedules = Schedule::with(['course.subject', 'course.teacher.user', 'classroom', 'level'])
            ->where('day_of_week', $day)
            ->where('status', 'active')
            ->orderBy('start_time')
            ->get();

        return response()->json([
            'success' => true,
            'data' => ScheduleResource::collection($schedules),
        ]);
    }
}
