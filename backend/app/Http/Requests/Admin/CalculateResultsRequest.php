<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class CalculateResultsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'course_id' => 'nullable|exists:courses,id',
            'semester' => 'nullable|string',
            'academic_year' => 'nullable|string',
            'student_id' => 'nullable|exists:students,id',
        ];
    }

    public function messages(): array
    {
        return [
            'course_id.exists' => 'Le cours sélectionné est invalide',
            'student_id.exists' => 'L\'étudiant sélectionné est invalide',
        ];
    }
}
