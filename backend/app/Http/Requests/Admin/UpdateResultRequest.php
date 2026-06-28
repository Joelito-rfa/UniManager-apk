<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class UpdateResultRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'final_grade' => 'sometimes|numeric|min:0|max:20',
            'decision' => 'sometimes|string|in:validated,failed,retake',
            'credit_value' => 'sometimes|integer|min:0',
        ];
    }

    public function messages(): array
    {
        return [
            'final_grade.numeric' => 'La note doit être un nombre',
            'final_grade.max' => 'La note ne peut pas dépasser 20',
            'decision.in' => 'La décision doit être validée, échouée ou rattrapage',
        ];
    }
}
