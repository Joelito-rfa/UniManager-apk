<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreProgramRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'department_id' => 'required|exists:departments,id',
            'name' => 'required|string|max:255',
            'code' => 'sometimes|string|max:50|unique:programs,code',
            'description' => 'nullable|string',
            'duration_years' => 'nullable|integer|min:1|max:10',
            'status' => 'nullable|string|in:active,inactive',
        ];
    }

    public function messages(): array
    {
        return [
            'department_id.required' => 'Le département est requis',
            'department_id.exists' => 'Le département sélectionné est invalide',
            'name.required' => 'Le nom du programme est requis',
            'code.required' => 'Le code est requis',
            'code.unique' => 'Ce code est déjà utilisé',
        ];
    }
}
