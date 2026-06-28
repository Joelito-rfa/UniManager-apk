<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GradeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'code' => $this->code,
            'id' => $this->id,
            'enrollment_id' => $this->enrollment_id,
            'graded_by' => $this->graded_by,
            'grade_type' => $this->grade_type,
            'grade_value' => $this->grade_value,
            'coefficient' => $this->coefficient,
            'comment' => $this->comment,
            'enrollment' => $this->when($this->relationLoaded('enrollment') && $this->enrollment, fn() => [
                'id' => $this->enrollment->id,
                'student' => $this->enrollment->relationLoaded('student') && $this->enrollment->student ? [
                    'name' => $this->enrollment->student->user->name ?? null,
                ] : null,
                'course' => $this->enrollment->relationLoaded('course') && $this->enrollment->course ? [
                    'academic_year' => $this->enrollment->course->academic_year,
                    'subject' => $this->enrollment->course->relationLoaded('subject') && $this->enrollment->course->subject ? [
                        'name' => $this->enrollment->course->subject->name,
                    ] : null,
                ] : null,
            ]),
            'graded_by_user' => $this->when($this->relationLoaded('gradedBy') && $this->gradedBy, fn() => [
                'id' => $this->gradedBy->id,
                'name' => $this->gradedBy->name,
            ]),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
