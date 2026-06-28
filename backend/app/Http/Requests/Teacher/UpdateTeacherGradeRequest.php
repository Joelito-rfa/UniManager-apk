<?php

namespace App\Http\Requests\Teacher;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTeacherGradeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'grade_type' => 'sometimes|string|in:CC,TP,Exam',
            'grade_value' => 'sometimes|numeric|min:0|max:20',
            'coefficient' => 'sometimes|numeric|min:0.5|max:5',
            'comment' => 'nullable|string',
        ];
    }

    public function messages(): array
    {
        return [
            'grade_type.in' => 'Le type doit être CC, TP ou Exam',
            'grade_value.numeric' => 'La note doit être un nombre',
            'grade_value.min' => 'La note minimale est 0',
            'grade_value.max' => 'La note maximale est 20',
            'coefficient.numeric' => 'Le coefficient doit être un nombre',
            'coefficient.min' => 'Le coefficient minimal est 0.5',
            'coefficient.max' => 'Le coefficient maximal est 5',
        ];
    }
}
