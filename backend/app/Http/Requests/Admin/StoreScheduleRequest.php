<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\DB;

class StoreScheduleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'course_id' => 'required|exists:courses,id',
            'classroom_id' => 'required|exists:classrooms,id',
            'level_id' => 'nullable|exists:levels,id',
            'day_of_week' => 'required|string|in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'type' => 'nullable|string|in:CM,TD,TP',
            'group' => 'nullable|string|max:50',
            'status' => 'nullable|string|in:active,inactive',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            $data = $this->validated();

            // Vérification conflit salle
            $classroomConflict = DB::table('schedules')
                ->where('classroom_id', $data['classroom_id'])
                ->where('day_of_week', $data['day_of_week'])
                ->where('status', 'active')
                ->where(function ($q) use ($data) {
                    $q->whereBetween('start_time', [$data['start_time'], $data['end_time']])
                      ->orWhereBetween('end_time', [$data['start_time'], $data['end_time']])
                      ->orWhere(function ($q2) use ($data) {
                          $q2->where('start_time', '<=', $data['start_time'])
                             ->where('end_time', '>=', $data['end_time']);
                      });
                })
                ->exists();

            if ($classroomConflict) {
                $validator->errors()->add('classroom_id', 'Cette salle est déjà occupée sur ce créneau.');
            }

            // Vérification conflit enseignant via le cours
            $course = DB::table('courses')->where('id', $data['course_id'])->first();
            if ($course) {
                $teacherConflict = DB::table('schedules')
                    ->join('courses', 'schedules.course_id', '=', 'courses.id')
                    ->where('courses.teacher_id', $course->teacher_id)
                    ->where('schedules.day_of_week', $data['day_of_week'])
                    ->where('schedules.status', 'active')
                    ->where(function ($q) use ($data) {
                        $q->whereBetween('schedules.start_time', [$data['start_time'], $data['end_time']])
                          ->orWhereBetween('schedules.end_time', [$data['start_time'], $data['end_time']])
                          ->orWhere(function ($q2) use ($data) {
                              $q2->where('schedules.start_time', '<=', $data['start_time'])
                                 ->where('schedules.end_time', '>=', $data['end_time']);
                          });
                    })
                    ->exists();

                if ($teacherConflict) {
                    $validator->errors()->add('course_id', 'L\'enseignant est déjà occupé sur ce créneau.');
                }
            }
        });
    }

    public function messages(): array
    {
        return [
            'course_id.required' => 'Le cours est requis',
            'course_id.exists' => 'Le cours sélectionné est invalide',
            'classroom_id.required' => 'La salle est requise',
            'classroom_id.exists' => 'La salle sélectionnée est invalide',
            'day_of_week.required' => 'Le jour de la semaine est requis',
            'day_of_week.in' => 'Le jour doit être un jour valide (Lundi-Dimanche)',
            'start_time.required' => 'L\'heure de début est requise',
            'end_time.required' => 'L\'heure de fin est requise',
            'end_time.after' => 'L\'heure de fin doit être après l\'heure de début',
        ];
    }
}
