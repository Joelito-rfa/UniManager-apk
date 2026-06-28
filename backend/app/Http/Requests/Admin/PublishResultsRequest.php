<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class PublishResultsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'course_id' => 'nullable|integer|exists:courses,id',
            'level_id' => 'nullable|integer|exists:levels,id',
            'student_id' => 'nullable|integer|exists:students,id',
            'program_id' => 'nullable|integer|exists:programs,id',
            'academic_year' => 'nullable|string|max:20',
            'ids' => 'nullable|array',
            'ids.*' => 'integer|exists:results,id',
        ];
    }

    public function messages(): array
    {
        return [
            'course_id.exists' => 'Le cours sélectionné est invalide',
            'level_id.exists' => 'Le niveau sélectionné est invalide',
            'student_id.exists' => 'L\'étudiant sélectionné est invalide',
            'ids.*.exists' => 'Un ou plusieurs résultats sont invalides',
        ];
    }
}
