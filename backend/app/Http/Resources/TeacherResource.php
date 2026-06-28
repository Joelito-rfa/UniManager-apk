<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TeacherResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'user_id' => $this->user_id,
            'department_id' => $this->department_id,
            'teacher_number' => $this->teacher_number,
            'hire_date' => $this->hire_date,
            'speciality' => $this->speciality,
            'date_of_birth' => $this->date_of_birth,
            'address' => $this->address,
            'phone' => $this->phone,
            'user' => $this->when($this->relationLoaded('user') && $this->user, fn() => [
                'id' => $this->user->id,
                'name' => $this->user->name,
                'email' => $this->user->email,
            ]),
            'department' => $this->when($this->relationLoaded('department') && $this->department, fn() => [
                'id' => $this->department->id,
                'name' => $this->department->name,
            ]),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
