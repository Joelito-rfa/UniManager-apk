<?php

namespace App\Services;

use App\Models\Course;

class CourseService
{
    public function paginate($request)
    {
        $query = Course::with(['subject', 'level', 'teacher.user', 'classroom']);

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->subject_id) {
            $query->where('subject_id', $request->subject_id);
        }

        if ($request->teacher_id) {
            $query->where('teacher_id', $request->teacher_id);
        }

        if ($request->level_id) {
            $query->where('level_id', $request->level_id);
        }

        if ($request->semester) {
            $query->where('semester', $request->semester);
        }

        if ($request->academic_year) {
            $query->where('academic_year', $request->academic_year);
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function create(array $data): Course
    {
        return Course::create([
            'subject_id' => $data['subject_id'],
            'teacher_id' => $data['teacher_id'] ?? null,
            'classroom_id' => $data['classroom_id'] ?? null,
            'level_id' => $data['level_id'] ?? null,
            'semester' => $data['semester'],
            'academic_year' => $data['academic_year'],
        ]);
    }

    public function update(Course $course, array $data): Course
    {
        $course->update([
            'subject_id' => $data['subject_id'] ?? $course->subject_id,
            'teacher_id' => $data['teacher_id'] ?? $course->teacher_id,
            'classroom_id' => $data['classroom_id'] ?? $course->classroom_id,
            'level_id' => array_key_exists('level_id', $data) ? $data['level_id'] : $course->level_id,
            'semester' => $data['semester'] ?? $course->semester,
            'academic_year' => $data['academic_year'] ?? $course->academic_year,
        ]);

        return $course->fresh(['subject', 'level', 'teacher.user', 'classroom']);
    }

    public function delete(Course $course): void
    {
        $course->delete();
    }
}
