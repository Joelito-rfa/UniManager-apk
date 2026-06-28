<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LevelResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'program_id' => $this->program_id,
            'name' => $this->name,
            'program' => $this->when($this->relationLoaded('program') && $this->program, fn() => [
                'id' => $this->program->id,
                'name' => $this->program->name,
                'code' => $this->program->code,
            ]),
            'students_count' => $this->whenCounted('students'),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
