<?php

namespace App\Services;

use App\Models\Schedule;
use App\Models\Course;
use Illuminate\Support\Facades\DB;

class ScheduleService
{
    public function paginate($request)
    {
        $query = Schedule::with(['course.subject', 'course.teacher.user', 'classroom', 'level']);

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->course_id) {
            $query->where('course_id', $request->course_id);
        }

        if ($request->classroom_id) {
            $query->where('classroom_id', $request->classroom_id);
        }

        if ($request->level_id) {
            $query->where('level_id', $request->level_id);
        }

        if ($request->day_of_week) {
            $query->where('day_of_week', $request->day_of_week);
        }

        return $query->orderBy('day_of_week')->orderBy('start_time')->paginate($request->per_page ?? 15);
    }

    public function create(array $data): Schedule
    {
        $this->validateTimes($data);
        $this->checkClassroomConflict($data);
        $this->checkTeacherConflict($data);

        return Schedule::create([
            'course_id' => $data['course_id'],
            'classroom_id' => $data['classroom_id'],
            'level_id' => $data['level_id'] ?? null,
            'day_of_week' => $data['day_of_week'],
            'start_time' => $data['start_time'],
            'end_time' => $data['end_time'],
            'type' => $data['type'] ?? 'CM',
            'group' => $data['group'] ?? null,
            'session' => $data['session'] ?? null,
            'status' => $data['status'] ?? 'active',
        ]);
    }

    public function update(Schedule $schedule, array $data): Schedule
    {
        $merged = array_merge($schedule->toArray(), $data);
        $this->validateTimes($merged);
        $this->checkClassroomConflict($merged, $schedule->id);
        $this->checkTeacherConflict($merged, $schedule->id);

        $schedule->update([
            'course_id' => $data['course_id'] ?? $schedule->course_id,
            'classroom_id' => $data['classroom_id'] ?? $schedule->classroom_id,
            'level_id' => array_key_exists('level_id', $data) ? $data['level_id'] : $schedule->level_id,
            'day_of_week' => $data['day_of_week'] ?? $schedule->day_of_week,
            'start_time' => $data['start_time'] ?? $schedule->start_time,
            'end_time' => $data['end_time'] ?? $schedule->end_time,
            'type' => $data['type'] ?? $schedule->type,
            'group' => array_key_exists('group', $data) ? $data['group'] : $schedule->group,
            'session' => array_key_exists('session', $data) ? $data['session'] : $schedule->session,
            'status' => array_key_exists('status', $data) ? $data['status'] : $schedule->status,
        ]);

        return $schedule->fresh(['course.subject', 'course.teacher.user', 'classroom', 'level']);
    }

    public function delete(Schedule $schedule): void
    {
        $schedule->delete();
    }

    private function validateTimes(array $data): void
    {
        if ($data['start_time'] >= $data['end_time']) {
            throw new \InvalidArgumentException('L\'heure de début doit être antérieure à l\'heure de fin');
        }
    }

    private function checkClassroomConflict(array $data, ?int $excludeId = null): void
    {
        $query = Schedule::where('classroom_id', $data['classroom_id'])
            ->where('day_of_week', $data['day_of_week'])
            ->where(function ($q) use ($data) {
                $q->whereBetween('start_time', [$data['start_time'], $data['end_time']])
                  ->orWhereBetween('end_time', [$data['start_time'], $data['end_time']])
                  ->orWhere(function ($q) use ($data) {
                      $q->where('start_time', '<=', $data['start_time'])
                        ->where('end_time', '>=', $data['end_time']);
                  });
            });

        if ($excludeId) {
            $query->where('id', '!=', $excludeId);
        }

        if ($query->exists()) {
            throw new \InvalidArgumentException('La salle est déjà occupée sur ce créneau');
        }
    }

    private function checkTeacherConflict(array $data, ?int $excludeId = null): void
    {
        $course = Course::with('schedules')->findOrFail($data['course_id']);
        $teacherId = $course->teacher_id;

        if (!$teacherId) return;

        $query = Schedule::whereHas('course', function ($q) use ($teacherId) {
                $q->where('teacher_id', $teacherId);
            })
            ->where('day_of_week', $data['day_of_week'])
            ->where(function ($q) use ($data) {
                $q->whereBetween('start_time', [$data['start_time'], $data['end_time']])
                  ->orWhereBetween('end_time', [$data['start_time'], $data['end_time']])
                  ->orWhere(function ($q) use ($data) {
                      $q->where('start_time', '<=', $data['start_time'])
                        ->where('end_time', '>=', $data['end_time']);
                  });
            });

        if ($excludeId) {
            $query->where('id', '!=', $excludeId);
        }

        if ($query->exists()) {
            throw new \InvalidArgumentException('L\'enseignant est déjà occupé sur ce créneau');
        }
    }
}
