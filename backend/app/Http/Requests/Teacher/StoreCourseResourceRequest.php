<?php

namespace App\Http\Requests\Teacher;

use Illuminate\Foundation\Http\FormRequest;

class StoreCourseResourceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'type' => 'required|in:pdf,video,link,document',
            'file' => 'required_without:url|file|max:204800',
            'url' => 'required_without:file|url|max:500',
            'duration' => 'nullable|integer|min:0',
            'order_column' => 'nullable|integer|min:0',
            'is_published' => 'nullable|boolean',
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Le titre est requis',
            'type.required' => 'Le type de ressource est requis',
            'type.in' => 'Le type doit être: pdf, video, link ou document',
            'file.required_without' => 'Veuillez choisir un fichier ou fournir une URL',
            'file.max' => 'Le fichier ne peut pas dépasser 200 Mo',
            'url.required_without' => 'Veuillez fournir une URL ou choisir un fichier',
            'url.url' => 'L\'URL doit être valide',
        ];
    }
}
