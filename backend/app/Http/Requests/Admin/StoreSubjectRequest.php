<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreSubjectRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'program_id' => 'required|exists:programs,id',
            'level_id' => 'nullable|exists:levels,id',
            'teacher_id' => 'nullable|exists:teachers,id',
            'name' => 'required|string|max:255',
            'code' => 'sometimes|string|max:50|unique:subjects,code',
            'description' => 'nullable|string',
            'credits' => 'nullable|integer|min:1|max:30',
            'coefficient' => 'nullable|numeric|min:0.5|max:10',
            'hours_total' => 'nullable|integer|min:1',
            'status' => 'nullable|string|in:active,inactive',
        ];
    }

    public function messages(): array
    {
        return [
            'program_id.required' => 'Le programme est requis',
            'program_id.exists' => 'Le programme sélectionné est invalide',
            'name.required' => 'Le nom de la matière est requis',
            'code.required' => 'Le code est requis',
            'code.unique' => 'Ce code est déjà utilisé',
        ];
    }
}
