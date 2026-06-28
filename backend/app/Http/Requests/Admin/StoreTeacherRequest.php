<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreTeacherRequest extends FormRequest
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
            'teacher_number' => 'sometimes|string|unique:teachers,teacher_number',
            'department_id' => 'required|exists:departments,id',
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
            'name.required' => 'Le nom est requis',
            'email.required' => 'L\'email est requis',
            'email.unique' => 'Cet email est déjà utilisé',
            'teacher_number.required' => 'Le numéro d\'employé est requis',
            'teacher_number.unique' => 'Ce numéro d\'employé est déjà utilisé',
            'department_id.required' => 'Le département est requis',
            'department_id.exists' => 'Le département sélectionné est invalide',
        ];
    }
}
