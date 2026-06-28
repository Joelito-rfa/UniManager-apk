<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ResultResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $subject = $this->course->relationLoaded('subject') ? $this->course->subject : null;
        $teacher = $this->course->relationLoaded('teacher') ? $this->course->teacher : null;

        return [
            'code' => $this->code,
            'id' => $this->id,
            'student_id' => $this->student_id,
            'course_id' => $this->course_id,
            'validated_by' => $this->validated_by,
            'semester' => $this->semester,
            'academic_year' => $this->academic_year,
            'final_grade' => $this->final_grade,
            'mention' => $this->mention,
            'credit_value' => $this->credit_value,
            'grade_point' => $this->grade_point,
            'decision' => $this->decision,
            'validated_at' => $this->validated_at,
            'published_at' => $this->published_at,
            'student' => $this->when($this->relationLoaded('student') && $this->student, fn() => [
                'id' => $this->student->id,
                'name' => $this->student->user->name ?? null,
                'student_number' => $this->student->student_number,
                'program' => $this->student->program?->name,
                'level' => $this->student->level?->name,
            ]),
            'course' => $this->when($this->relationLoaded('course') && $this->course, fn() => [
                'id' => $this->course->id,
                'name' => $this->course->name ?? $subject?->name,
                'code' => $this->course->code,
                'semester' => $this->course->semester,
                'academic_year' => $this->course->academic_year,
                'subject' => $subject ? [
                    'id' => $subject->id,
                    'name' => $subject->name,
                    'code' => $subject->code,
                    'credits' => $subject->credits,
                    'coefficient' => $subject->coefficient,
                ] : null,
                'teacher' => $teacher && $teacher->relationLoaded('user') ? [
                    'id' => $teacher->id,
                    'name' => $teacher->user->name ?? null,
                ] : null,
            ]),
            'validated_by_user' => $this->when($this->relationLoaded('validatedBy') && $this->validatedBy, fn() => [
                'id' => $this->validatedBy->id,
                'name' => $this->validatedBy->name,
            ]),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
