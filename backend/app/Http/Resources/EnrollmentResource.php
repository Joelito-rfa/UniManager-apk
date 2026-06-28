<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EnrollmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
            $studentName = $this->relationLoaded('student') && $this->student && $this->student->user ? $this->student->user->name : null;
        $studentNumber = $this->relationLoaded('student') && $this->student ? $this->student->student_number : null;
        $courseSubject = $this->course && $this->course->relationLoaded('subject') && $this->course->subject ? $this->course->subject : null;
        $programName = $courseSubject && $courseSubject->relationLoaded('program') && $courseSubject->program ? $courseSubject->program->name : null;

        return [
            'code' => $this->code,
            'id' => $this->id,
            'student_id' => $this->student_id,
            'course_id' => $this->course_id,
            'enrollment_date' => $this->enrollment_date,
            'status' => $this->status,
            'student_name' => $studentName,
            'student_number' => $studentNumber,
            'program_name' => $programName,
            'academic_year' => $this->course->academic_year ?? null,
            'student' => $this->when($this->relationLoaded('student') && $this->student, fn() => [
                'id' => $this->student->id,
                'name' => $studentName,
                'student_number' => $studentNumber,
            ]),
            'course' => $this->when($this->relationLoaded('course') && $this->course, fn() => [
                'id' => $this->course->id,
                'semester' => $this->course->semester,
                'academic_year' => $this->course->academic_year,
                'subject' => $courseSubject ? [
                    'name' => $courseSubject->name,
                ] : null,
            ]),
            'grades' => GradeResource::collection($this->whenLoaded('grades')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
