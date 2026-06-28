<?php

namespace App\Http\Requests\Teacher;

use Illuminate\Foundation\Http\FormRequest;

class UpdateCourseResourceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => 'sometimes|string|max:255',
            'description' => 'nullable|string|max:1000',
            'type' => 'sometimes|in:pdf,video,link,document',
            'file' => 'nullable|file|max:204800',
            'url' => 'nullable|url|max:500',
            'duration' => 'nullable|integer|min:0',
            'order_column' => 'nullable|integer|min:0',
            'is_published' => 'nullable|boolean',
        ];
    }

    public function messages(): array
    {
        return [
            'file.max' => 'Le fichier ne peut pas dépasser 200 Mo',
            'url.url' => 'L\'URL doit être valide',
        ];
    }
}
