<?php

namespace App\Http\Requests\Student;

use Illuminate\Foundation\Http\FormRequest;

class UpdateStudentProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'sometimes|string|max:255',
            'phone' => 'nullable|regex:/^\+?\d*$/|max:20',
            'avatar' => 'nullable|string',
            'emergency_contact' => 'nullable|string|max:255',
            'emergency_phone' => 'nullable|regex:/^\+?\d*$/|max:20',
        ];
    }

    public function messages(): array
    {
        return [
            'name.max' => 'Le nom ne doit pas dépasser 255 caractères',
        ];
    }
}
