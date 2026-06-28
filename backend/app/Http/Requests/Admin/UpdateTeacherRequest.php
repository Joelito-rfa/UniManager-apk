<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateTeacherRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $teacherId = $this->route('teacher')?->id ?? $this->route('id');
        $userId = $this->route('teacher')?->user_id ?? null;

        return [
            'name' => 'sometimes|string|max:255',
            'email' => ['sometimes', 'email', Rule::unique('users', 'email')->ignore($userId)],
            'password' => 'nullable|string|min:8',
            'teacher_number' => ['sometimes', 'string', Rule::unique('teachers', 'teacher_number')->ignore($teacherId)],
            'department_id' => 'sometimes|exists:departments,id',
            'hire_date' => 'nullable|date',
            'speciality' => 'nullable|string|max:255',
            'date_of_birth' => 'nullable|date',
            'address' => 'nullable|string',
            'phone' => 'nullable|regex:/^\+?\d*$/|max:20',
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'Cet email est déjà utilisé',
            'teacher_number.unique' => 'Ce numéro d\'employé est déjà utilisé',
            'department_id.exists' => 'Le département sélectionné est invalide',
        ];
    }
}
