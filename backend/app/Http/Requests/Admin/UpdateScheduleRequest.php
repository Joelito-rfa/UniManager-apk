<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\DB;

class UpdateScheduleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'course_id' => 'sometimes|exists:courses,id',
            'classroom_id' => 'sometimes|exists:classrooms,id',
            'level_id' => 'nullable|exists:levels,id',
            'day_of_week' => 'sometimes|string|in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'start_time' => 'sometimes|date_format:H:i',
            'end_time' => 'sometimes|date_format:H:i|after:start_time',
            'type' => 'nullable|string|in:CM,TD,TP',
            'group' => 'nullable|string|max:50',
            'status' => 'nullable|string|in:active,inactive',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            $scheduleId = $this->route('schedule')?->id ?? $this->route('id');
            $data = array_merge(
                DB::table('schedules')->where('id', $scheduleId)->first() ? (array) DB::table('schedules')->where('id', $scheduleId)->first() : [],
                $this->validated()
            );

            if (!isset($data['classroom_id']) || !isset($data['day_of_week']) || !isset($data['start_time']) || !isset($data['end_time'])) {
                return;
            }

            // Vérification conflit salle (exclure le planning actuel)
            $classroomConflict = DB::table('schedules')
                ->where('id', '!=', $scheduleId)
                ->where('classroom_id', $data['classroom_id'])
                ->where('day_of_week', $data['day_of_week'])
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

            // Vérification conflit enseignant
            if (isset($data['course_id'])) {
                $course = DB::table('courses')->where('id', $data['course_id'])->first();
                if ($course) {
                    $teacherConflict = DB::table('schedules')
                        ->join('courses', 'schedules.course_id', '=', 'courses.id')
                        ->where('schedules.id', '!=', $scheduleId)
                        ->where('courses.teacher_id', $course->teacher_id)
                        ->where('schedules.day_of_week', $data['day_of_week'])
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
            }
        });
    }

    public function messages(): array
    {
        return [
            'course_id.exists' => 'Le cours sélectionné est invalide',
            'classroom_id.exists' => 'La salle sélectionnée est invalide',
            'day_of_week.in' => 'Le jour doit être un jour valide (Lundi-Dimanche)',
            'end_time.after' => 'L\'heure de fin doit être après l\'heure de début',
        ];
    }
}
