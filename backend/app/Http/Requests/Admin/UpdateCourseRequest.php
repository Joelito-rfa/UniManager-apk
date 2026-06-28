<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class UpdateCourseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'subject_id' => 'sometimes|exists:subjects,id',
            'teacher_id' => 'sometimes|exists:teachers,id',
            'classroom_id' => 'nullable|exists:classrooms,id',
            'level_id' => 'nullable|exists:levels,id',
            'semester' => 'nullable|string|max:50',
            'academic_year' => 'nullable|string|max:20',
            'status' => 'nullable|string|in:active,inactive',
        ];
    }

    public function messages(): array
    {
        return [
            'subject_id.exists' => 'La matière sélectionnée est invalide',
            'teacher_id.exists' => 'L\'enseignant sélectionné est invalide',
        ];
    }
}
