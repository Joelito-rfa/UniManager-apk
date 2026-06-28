<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreMessageRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'content' => 'required|string|max:5000',
        ];
    }

    public function messages(): array
    {
        return [
            'content.required' => 'Le message est requis',
            'content.max' => 'Le message ne peut pas dépasser 5000 caractères',
        ];
    }
}
