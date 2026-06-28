<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreStudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'nullable|string|min:8',
            'student_number' => 'sometimes|string|unique:students,student_number',
            'date_of_birth' => 'nullable|date',
            'address' => 'nullable|string',
            'phone' => 'nullable|regex:/^\+?\d*$/|max:20',
            'program_id' => 'required|exists:programs,id',
            'level_id' => 'required|exists:levels,id',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Le nom est requis',
            'email.required' => 'L\'email est requis',
            'email.unique' => 'Cet email est déjà utilisé',
            'student_number.required' => 'Le numéro d\'étudiant est requis',
            'student_number.unique' => 'Ce numéro d\'étudiant est déjà utilisé',
            'program_id.required' => 'Le programme est requis',
            'program_id.exists' => 'Le programme sélectionné est invalide',
            'level_id.required' => 'Le niveau est requis',
            'level_id.exists' => 'Le niveau sélectionné est invalide',
        ];
    }
}
