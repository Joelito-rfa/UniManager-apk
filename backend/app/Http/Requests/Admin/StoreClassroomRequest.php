<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreClassroomRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'code' => 'sometimes|string|max:50|unique:classrooms,code',
            'building' => 'nullable|string|max:255',
            'floor' => 'nullable|string|max:50',
            'capacity' => 'nullable|integer|min:1',
            'type' => 'nullable|string|max:100',
            'status' => 'nullable|string|in:active,inactive',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Le nom de la salle est requis',
            'code.required' => 'Le code est requis',
            'code.unique' => 'Ce code est déjà utilisé',
        ];
    }
}
