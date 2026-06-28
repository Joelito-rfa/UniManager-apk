<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SubjectResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'program_id' => $this->program_id,
            'level_id' => $this->level_id,
            'teacher_id' => $this->teacher_id,
            'name' => $this->name,
            'description' => $this->description,
            'credits' => $this->credits,
            'coefficient' => $this->coefficient,
            'hours_total' => $this->hours_total,
            'status' => $this->status,
            'level_name' => $this->level?->name,
            'program_name' => $this->program?->name,
            'teacher_name' => $this->teacher?->user?->name,
            'level' => $this->when($this->relationLoaded('level'), fn() => [
                'id' => $this->level?->id,
                'name' => $this->level?->name,
            ]),
            'program' => $this->when($this->relationLoaded('program'), fn() => [
                'id' => $this->program?->id,
                'name' => $this->program?->name,
            ]),
            'teacher' => $this->when($this->relationLoaded('teacher') && $this->teacher, fn() => [
                'id' => $this->teacher->id,
                'name' => $this->teacher->user->name ?? null,
            ]),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
