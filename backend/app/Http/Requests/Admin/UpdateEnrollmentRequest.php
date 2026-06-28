<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class UpdateEnrollmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'student_id' => 'sometimes|exists:students,id',
            'course_id' => 'sometimes|exists:courses,id',
            'enrollment_date' => 'nullable|date',
            'status' => 'nullable|string|in:active,inactive,completed,suspended',
        ];
    }

    public function messages(): array
    {
        return [
            'student_id.exists' => 'L\'étudiant sélectionné est invalide',
            'course_id.exists' => 'Le cours sélectionné est invalide',
        ];
    }
}
