<?php

namespace App\Services;

use App\Models\Enrollment;
use App\Models\Student;
use App\Models\Course;
use App\Models\Subject;

class EnrollmentService
{
    public function paginate($request)
    {
        $query = Enrollment::with(['student.user', 'course.subject.program', 'course.classroom']);

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->student_id) {
            $query->where('student_id', $request->student_id);
        }

        if ($request->course_id) {
            $query->where('course_id', $request->course_id);
        }

        if ($request->status) {
            $query->where('status', $request->status);
        }

        if ($request->level_id) {
            $query->whereHas('student', fn($q) => $q->where('level_id', $request->level_id));
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function create(array $data): Enrollment
    {
        if (isset($data['course_id'])) {
            return $this->createSingle($data);
        }

        return $this->createByProgram($data);
    }

    private function createSingle(array $data): Enrollment
    {
        $this->validateStudent($data['student_id']);
        $this->validateCourse($data['course_id']);

        $exists = Enrollment::where('student_id', $data['student_id'])
            ->where('course_id', $data['course_id'])
            ->exists();

        if ($exists) {
            throw new \InvalidArgumentException('Cet étudiant est déjà inscrit à ce cours');
        }

        return Enrollment::create([
            'student_id' => $data['student_id'],
            'course_id' => $data['course_id'],
            'enrollment_date' => $data['enrollment_date'] ?? now(),
            'status' => $data['status'] ?? 'active',
        ])->fresh(['student.user', 'course.subject.program', 'course.classroom']);
    }

    private function createByProgram(array $data): Enrollment
    {
        $this->validateStudent($data['student_id']);

        $courses = Course::whereIn('subject_id', function ($q) use ($data) {
            $q->select('id')->from('subjects')->where('program_id', $data['program_id']);
        })->where('academic_year', $data['academic_year'])->get();

        if ($courses->isEmpty()) {
            $subjects = Subject::where('program_id', $data['program_id'])->pluck('name');
            $subjectsList = $subjects->isEmpty() ? '' : ' (' . $subjects->implode(', ') . ')';
            throw new \InvalidArgumentException(
                'Aucun cours trouvé pour ce programme et cette année académique.' . $subjectsList
            );
        }

        $firstEnrollment = null;
        $existingPairs = Enrollment::where('student_id', $data['student_id'])
            ->whereIn('course_id', $courses->pluck('id'))
            ->pluck('course_id')
            ->toArray();

        foreach ($courses as $course) {
            if (in_array($course->id, $existingPairs)) {
                continue;
            }

            $enrollment = Enrollment::create([
                'student_id' => $data['student_id'],
                'course_id' => $course->id,
                'enrollment_date' => $data['enrollment_date'] ?? now(),
                'status' => $data['status'] ?? 'active',
            ]);

            if ($firstEnrollment === null) {
                $firstEnrollment = $enrollment;
            }
        }

        if ($firstEnrollment === null) {
            throw new \InvalidArgumentException('Cet étudiant est déjà inscrit à tous les cours de ce programme');
        }

        return $firstEnrollment->fresh(['student.user', 'course.subject.program', 'course.classroom']);
    }

    public function update(Enrollment $enrollment, array $data): Enrollment
    {
        $enrollment->update([
            'status' => $data['status'] ?? $enrollment->status,
            'enrollment_date' => $data['enrollment_date'] ?? $enrollment->enrollment_date,
        ]);

        return $enrollment->fresh(['student.user', 'course.subject.program', 'course.classroom']);
    }

    public function delete(Enrollment $enrollment): void
    {
        $enrollment->delete();
    }

    private function validateStudent(int $studentId): void
    {
        if (!Student::where('id', $studentId)->exists()) {
            throw new \InvalidArgumentException('L\'étudiant spécifié n\'existe pas');
        }
    }

    private function validateCourse(int $courseId): void
    {
        if (!Course::where('id', $courseId)->exists()) {
            throw new \InvalidArgumentException('Le cours spécifié n\'existe pas');
        }
    }
}
