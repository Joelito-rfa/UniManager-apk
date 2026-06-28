<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreDepartmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'code' => 'sometimes|string|max:50|unique:departments,code',
            'description' => 'nullable|string',
            'head_of_department' => 'nullable|string|max:255',
            'status' => 'nullable|string|in:active,inactive',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Le nom du département est requis',
            'code.required' => 'Le code est requis',
            'code.unique' => 'Ce code est déjà utilisé',
        ];
    }
}
