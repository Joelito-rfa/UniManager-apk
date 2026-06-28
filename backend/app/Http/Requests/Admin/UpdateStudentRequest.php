<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateStudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $studentId = $this->route('student')?->id ?? $this->route('id');
        $userId = $this->route('student')?->user_id ?? null;

        return [
            'name' => 'sometimes|string|max:255',
            'email' => ['sometimes', 'email', Rule::unique('users', 'email')->ignore($userId)],
            'password' => 'nullable|string|min:8',
            'student_number' => ['sometimes', 'string', Rule::unique('students', 'student_number')->ignore($studentId)],
            'date_of_birth' => 'nullable|date',
            'address' => 'nullable|string',
            'phone' => 'nullable|regex:/^\+?\d*$/|max:20',
            'program_id' => 'sometimes|exists:programs,id',
            'level_id' => 'sometimes|exists:levels,id',
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'Cet email est déjà utilisé',
            'student_number.unique' => 'Ce numéro d\'étudiant est déjà utilisé',
            'program_id.exists' => 'Le programme sélectionné est invalide',
            'level_id.exists' => 'Le niveau sélectionné est invalide',
        ];
    }
}
