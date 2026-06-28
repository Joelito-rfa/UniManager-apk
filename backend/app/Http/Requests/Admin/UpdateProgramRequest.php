<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProgramRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $id = $this->route('program')?->id ?? $this->route('id');

        return [
            'department_id' => 'sometimes|exists:departments,id',
            'name' => 'sometimes|string|max:255',
            'code' => ['sometimes', 'string', 'max:50', Rule::unique('programs', 'code')->ignore($id)],
            'description' => 'nullable|string',
            'duration_years' => 'nullable|integer|min:1|max:10',
            'status' => 'nullable|string|in:active,inactive',
        ];
    }

    public function messages(): array
    {
        return [
            'department_id.exists' => 'Le département sélectionné est invalide',
            'code.unique' => 'Ce code est déjà utilisé',
        ];
    }
}
