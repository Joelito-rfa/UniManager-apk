<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|max:255|unique:users,email,' . auth()->id(),
            'phone' => 'nullable|regex:/^\+?\d*$/|max:20',
            'avatar' => 'nullable|string',
        ];
    }

    public function messages(): array
    {
        return [
            'name.max' => 'Le nom ne doit pas dépasser 255 caractères',
            'email.email' => 'L\'email doit être valide',
            'email.unique' => 'Cet email est déjà utilisé',
        ];
    }
}
