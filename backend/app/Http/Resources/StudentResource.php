<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StudentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'user_id' => $this->user_id,
            'student_number' => $this->student_number,
            'enrollment_date' => $this->enrollment_date,
            'date_of_birth' => $this->date_of_birth,
            'address' => $this->address,
            'phone' => $this->phone,
            'user' => $this->when($this->relationLoaded('user') && $this->user, fn() => [
                'name' => $this->user->name,
                'email' => $this->user->email,
            ]),
            'program' => $this->when($this->relationLoaded('program') && $this->program, fn() => [
                'id' => $this->program->id,
                'name' => $this->program->name,
                'code' => $this->program->code,
            ]),
            'level' => $this->when($this->relationLoaded('level') && $this->level, fn() => [
                'id' => $this->level->id,
                'name' => $this->level->name,
                'code' => $this->level->code,
            ]),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
