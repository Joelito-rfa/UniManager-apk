<?php

namespace App\Http\Requests\Teacher;

use Illuminate\Foundation\Http\FormRequest;

class BatchGradeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'grades' => 'required|array',
            'grades.*.enrollment_id' => 'required|exists:enrollments,id',
            'grades.*.grade_type' => 'required|string|in:CC,TP,Exam',
            'grades.*.grade_value' => 'required|numeric|min:0|max:20',
            'grades.*.coefficient' => 'required|numeric|min:0.5|max:5',
            'grades.*.comment' => 'nullable|string',
        ];
    }

    public function messages(): array
    {
        return [
            'grades.required' => 'La liste des notes est requise',
            'grades.array' => 'Les notes doivent être un tableau',
            'grades.*.enrollment_id.required' => 'L\'inscription est requise pour chaque note',
            'grades.*.enrollment_id.exists' => 'Une inscription sélectionnée est invalide',
            'grades.*.grade_type.required' => 'Le type de note est requis',
            'grades.*.grade_type.in' => 'Le type doit être CC, TP ou Exam',
            'grades.*.grade_value.required' => 'La note est requise',
            'grades.*.grade_value.min' => 'La note minimale est 0',
            'grades.*.grade_value.max' => 'La note maximale est 20',
            'grades.*.coefficient.required' => 'Le coefficient est requis',
            'grades.*.coefficient.min' => 'Le coefficient minimal est 0.5',
            'grades.*.coefficient.max' => 'Le coefficient maximal est 5',
        ];
    }
}
