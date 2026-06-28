<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreEnrollmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'student_id' => 'required|exists:students,id',
            'course_id' => 'sometimes|exists:courses,id',
            'program_id' => 'required_without:course_id|exists:programs,id',
            'academic_year' => 'required_without:course_id|string',
            'enrollment_date' => 'nullable|date',
            'status' => 'nullable|string|in:active,inactive,completed,suspended',
        ];
    }

    public function messages(): array
    {
        return [
            'student_id.required' => 'L\'étudiant est requis',
            'student_id.exists' => 'L\'étudiant sélectionné est invalide',
            'course_id.exists' => 'Le cours sélectionné est invalide',
            'program_id.required_without' => 'La filière ou le cours est requis',
            'program_id.exists' => 'La filière sélectionnée est invalide',
            'academic_year.required_without' => 'L\'année académique est requise',
        ];
    }
}
