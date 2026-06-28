<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProgramResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'department_id' => $this->department_id,
            'department_name' => $this->department?->name,
            'name' => $this->name,
            'description' => $this->description,
            'duration' => $this->duration,
            'department' => $this->when($this->relationLoaded('department') && $this->department, fn() => [
                'id' => $this->department->id,
                'name' => $this->department->name,
            ]),
            'levels_count' => $this->whenCounted('levels'),
            'subjects_count' => $this->whenCounted('subjects'),
            'students_count' => $this->whenCounted('students'),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
