<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateSubjectRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $id = $this->route('subject')?->id ?? $this->route('id');

        return [
            'program_id' => 'sometimes|exists:programs,id',
            'level_id' => 'nullable|exists:levels,id',
            'teacher_id' => 'nullable|exists:teachers,id',
            'name' => 'sometimes|string|max:255',
            'code' => ['sometimes', 'string', 'max:50', Rule::unique('subjects', 'code')->ignore($id)],
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
            'program_id.exists' => 'Le programme sélectionné est invalide',
            'code.unique' => 'Ce code est déjà utilisé',
        ];
    }
}
