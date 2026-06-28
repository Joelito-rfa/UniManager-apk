<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class CalculateLevelResultsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'student_id' => 'nullable|exists:students,id',
            'level_id' => 'nullable|exists:levels,id',
            'program_id' => 'nullable|exists:programs,id',
            'academic_year' => 'nullable|string|max:20',
        ];
    }

    public function messages(): array
    {
        return [
            'student_id.exists' => 'L\'étudiant sélectionné est invalide',
            'level_id.exists' => 'Le niveau sélectionné est invalide',
            'program_id.exists' => 'Le programme sélectionné est invalide',
        ];
    }
}
