<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreLevelRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'program_id' => 'required|exists:programs,id',
            'name' => 'required|string|max:255',
            'code' => 'sometimes|string|max:50|unique:levels,code',
            'description' => 'nullable|string',
            'order' => 'nullable|integer|min:1',
            'status' => 'nullable|string|in:active,inactive',
        ];
    }

    public function messages(): array
    {
        return [
            'program_id.required' => 'Le programme est requis',
            'program_id.exists' => 'Le programme sélectionné est invalide',
            'name.required' => 'Le nom du niveau est requis',
            'code.required' => 'Le code est requis',
            'code.unique' => 'Ce code est déjà utilisé',
        ];
    }
}
