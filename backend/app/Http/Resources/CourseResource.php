<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CourseResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'subject_id' => $this->subject_id,
            'teacher_id' => $this->teacher_id,
            'classroom_id' => $this->classroom_id,
            'level_id' => $this->level_id,
            'semester' => $this->semester,
            'academic_year' => $this->academic_year,
            'level_name' => $this->level?->name,
            'subject_name' => $this->subject?->name,
            'teacher_name' => $this->teacher?->user?->name,
            'classroom_name' => $this->classroom?->name,
            'status' => $this->status ?? 'active',
            'subject' => $this->when($this->relationLoaded('subject'), fn() => [
                'id' => $this->subject?->id,
                'name' => $this->subject?->name,
                'code' => $this->subject?->code,
                'credits' => $this->subject?->credits,
            ]),
            'level' => $this->when($this->relationLoaded('level'), fn() => [
                'id' => $this->level?->id,
                'name' => $this->level?->name,
            ]),
            'teacher' => $this->when($this->relationLoaded('teacher') && $this->teacher, fn() => [
                'id' => $this->teacher->id,
                'name' => $this->teacher->user->name ?? null,
            ]),
            'classroom' => $this->when($this->relationLoaded('classroom'), fn() => [
                'id' => $this->classroom?->id,
                'name' => $this->classroom?->name,
                'code' => $this->classroom?->code,
            ]),
            'enrollments_count' => $this->whenCounted('enrollments'),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
