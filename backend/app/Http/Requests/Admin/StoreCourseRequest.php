<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreCourseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'subject_id' => 'required|exists:subjects,id',
            'teacher_id' => 'required|exists:teachers,id',
            'classroom_id' => 'nullable|exists:classrooms,id',
            'level_id' => 'nullable|exists:levels,id',
            'semester' => 'required|string|max:50',
            'academic_year' => 'required|string|max:20',
            'status' => 'nullable|string|in:active,inactive',
        ];
    }

    public function messages(): array
    {
        return [
            'subject_id.required' => 'La matière est requise',
            'subject_id.exists' => 'La matière sélectionnée est invalide',
            'teacher_id.required' => 'L\'enseignant est requis',
            'teacher_id.exists' => 'L\'enseignant sélectionné est invalide',
            'semester.required' => 'Le semestre est requis',
            'academic_year.required' => 'L\'année académique est requise',
        ];
    }
}
