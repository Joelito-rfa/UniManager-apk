<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreConversationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $rules = [
            'user_ids' => 'required_without:is_public|array|min:1',
            'user_ids.*' => 'exists:users,id',
            'type' => 'nullable|string|in:direct,group',
            'name' => 'nullable|string|max:255',
            'is_public' => 'nullable|boolean',
            'public_audience' => 'nullable|string|in:all,students,teachers,admin',
        ];

        return $rules;
    }

    public function messages(): array
    {
        return [
            'user_ids.required_without' => 'Au moins un participant est requis pour une conversation privée',
            'user_ids.*.exists' => 'L\'utilisateur est invalide',
        ];
    }
}
