<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ScheduleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'course_id' => $this->course_id,
            'classroom_id' => $this->classroom_id,
            'level_id' => $this->level_id,
            'day_of_week' => $this->day_of_week,
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
            'type' => $this->type,
            'course_name' => $this->course?->subject?->name,
            'teacher_name' => $this->course?->teacher?->user?->name,
            'classroom_name' => $this->classroom?->name,
            'level_name' => $this->level?->name,
            'course' => $this->when($this->relationLoaded('course') && $this->course, fn() => [
                'id' => $this->course->id,
                'semester' => $this->course->semester,
                'academic_year' => $this->course->academic_year,
                'subject' => $this->course->relationLoaded('subject') && $this->course->subject ? [
                    'name' => $this->course->subject->name,
                ] : null,
                'teacher' => $this->course->relationLoaded('teacher') && $this->course->teacher ? [
                    'name' => $this->course->teacher->user->name ?? null,
                ] : null,
            ]),
            'level' => $this->when($this->relationLoaded('level') && $this->level, fn() => [
                'id' => $this->level->id,
                'name' => $this->level->name,
            ]),
            'classroom' => $this->when($this->relationLoaded('classroom') && $this->classroom, fn() => [
                'id' => $this->classroom->id,
                'name' => $this->classroom->name,
                'code' => $this->classroom->code,
            ]),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
