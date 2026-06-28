<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterStudentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'student_number' => 'required|string|exists:students,student_number',
            'date_of_birth' => 'required|date',
            'password' => 'required|string|min:8|confirmed',
        ];
    }

    public function messages(): array
    {
        return [
            'student_number.required' => 'Le matricule est requis',
            'student_number.exists' => 'Étudiant non trouvé. Veuillez contacter l\'administration.',
            'date_of_birth.required' => 'La date de naissance est requise',
            'date_of_birth.date' => 'La date de naissance est invalide',
            'password.required' => 'Le mot de passe est requis',
            'password.min' => 'Le mot de passe doit contenir au moins 8 caractères',
            'password.confirmed' => 'Les mots de passe ne correspondent pas',
        ];
    }
}
