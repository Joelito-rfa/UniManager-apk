<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateClassroomRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $id = $this->route('classroom')?->id ?? $this->route('id');

        return [
            'name' => 'sometimes|string|max:255',
            'code' => ['sometimes', 'string', 'max:50', Rule::unique('classrooms', 'code')->ignore($id)],
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
            'code.unique' => 'Ce code est déjà utilisé',
        ];
    }
}
