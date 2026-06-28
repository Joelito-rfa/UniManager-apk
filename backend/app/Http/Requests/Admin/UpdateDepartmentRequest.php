<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateDepartmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $id = $this->route('department')?->id ?? $this->route('id');

        return [
            'name' => 'sometimes|string|max:255',
            'code' => ['sometimes', 'string', 'max:50', Rule::unique('departments', 'code')->ignore($id)],
            'description' => 'nullable|string',
            'head_of_department' => 'nullable|string|max:255',
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
