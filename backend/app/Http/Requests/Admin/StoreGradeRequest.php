<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreGradeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'enrollment_id' => 'required|exists:enrollments,id',
            'grade_type' => 'required|string|in:CC,TP,Exam',
            'grade_value' => 'required|numeric|min:0|max:20',
            'coefficient' => 'required|numeric|min:0.5|max:5',
            'comment' => 'nullable|string',
        ];
    }

    public function messages(): array
    {
        return [
            'enrollment_id.required' => 'L\'inscription est requise',
            'enrollment_id.exists' => 'L\'inscription sélectionnée est invalide',
            'grade_type.required' => 'Le type de note est requis',
            'grade_type.in' => 'Le type doit être CC, TP ou Exam',
            'grade_value.required' => 'La note est requise',
            'grade_value.numeric' => 'La note doit être un nombre',
            'grade_value.min' => 'La note minimale est 0',
            'grade_value.max' => 'La note maximale est 20',
            'coefficient.required' => 'Le coefficient est requis',
            'coefficient.numeric' => 'Le coefficient doit être un nombre',
            'coefficient.min' => 'Le coefficient minimal est 0.5',
            'coefficient.max' => 'Le coefficient maximal est 5',
        ];
    }
}
