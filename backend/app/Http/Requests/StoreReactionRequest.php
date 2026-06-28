<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreReactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'reaction' => 'required|string|in:like,love,haha,wow,sad',
        ];
    }

    public function messages(): array
    {
        return [
            'reaction.required' => 'La réaction est requise',
            'reaction.in' => 'La réaction est invalide (like, love, haha, wow, sad)',
        ];
    }
}
