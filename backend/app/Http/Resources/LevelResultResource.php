<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LevelResultResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'student_id' => $this->student_id,
            'level_id' => $this->level_id,
            'program_id' => $this->program_id,
            'academic_year' => $this->academic_year,
            'total_points' => $this->total_points,
            'total_coefficients' => $this->total_coefficients,
            'average_grade' => $this->average_grade,
            'total_credits_obtained' => $this->total_credits_obtained,
            'total_credits_required' => $this->total_credits_required,
            'mention' => $this->mention,
            'decision' => $this->decision,
            'published_at' => $this->published_at,
            'validated_at' => $this->updated_at,
            'student' => $this->when($this->relationLoaded('student') && $this->student, fn() => [
                'id' => $this->student->id,
                'name' => $this->student->user->name ?? null,
                'student_number' => $this->student->student_number,
            ]),
            'level' => $this->when($this->relationLoaded('level') && $this->level, fn() => [
                'id' => $this->level->id,
                'name' => $this->level->name,
            ]),
            'program' => $this->when($this->relationLoaded('program') && $this->program, fn() => [
                'id' => $this->program->id,
                'name' => $this->program->name,
            ]),
            'validated_by' => $this->when($this->relationLoaded('validatedBy') && $this->validatedBy, fn() => [
                'id' => $this->validatedBy->id,
                'name' => $this->validatedBy->name,
            ]),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
