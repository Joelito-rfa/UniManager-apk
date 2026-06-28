<?php

namespace App\Services;

use App\Enums\MentionEnum;
use App\Events\ResultPublished;
use App\Models\Result;
use App\Models\Enrollment;
use App\Models\Student;
use App\Models\Course;
use Illuminate\Support\Facades\DB;

class ResultService
{
    public function calculate(array $filters): \Illuminate\Support\Collection
    {
        $query = Enrollment::with(['course.subject', 'grades'])
            ->where('status', 'active');

        if (isset($filters['course_id'])) {
            $query->where('course_id', $filters['course_id']);
        }

        if (isset($filters['student_id'])) {
            $query->where('student_id', $filters['student_id']);
        }

        if (isset($filters['semester'])) {
            $query->whereHas('course', fn($q) => $q->where('semester', $filters['semester']));
        }

        if (isset($filters['academic_year'])) {
            $query->whereHas('course', fn($q) => $q->where('academic_year', $filters['academic_year']));
        }

        if (isset($filters['level_id'])) {
            $query->whereHas('course', fn($q) => $q->where('level_id', $filters['level_id']));
        }

        if (isset($filters['program_id'])) {
            $query->whereHas('student', fn($q) => $q->where('program_id', $filters['program_id']));
        }

        $enrollments = $query->get();
        $results = collect();

        foreach ($enrollments as $enrollment) {
            $grades = $enrollment->grades;
            if ($grades->isEmpty()) continue;

            $totalWeight = $grades->sum('coefficient');
            $weightedSum = $grades->sum(fn($g) => $g->grade_value * $g->coefficient);
            $average = $totalWeight > 0 ? round($weightedSum / $totalWeight, 2) : 0;
            $credits = $enrollment->course->subject->credits ?? 0;

            $decision = 'failed';
            if ($average >= 10) $decision = 'validated';
            elseif ($average >= 8) $decision = 'retake';

            $mention = MentionEnum::fromGrade($average);

            $result = Result::updateOrCreate(
                [
                    'student_id' => $enrollment->student_id,
                    'course_id' => $enrollment->course_id,
                    'semester' => $enrollment->course->semester,
                    'academic_year' => $enrollment->course->academic_year,
                ],
                [
                    'final_grade' => $average,
                    'mention' => $mention,
                    'credit_value' => $decision === 'validated' ? $credits : 0,
                    'grade_point' => $average >= 10 ? min(4.0, $average / 5) : 0,
                    'decision' => $decision,
                    'validated_by' => auth()->id(),
                    'validated_at' => now(),
                ]
            );

            event(new ResultPublished($result));
            $results->push($result);
        }

        return $results;
    }

    public function paginate($request)
    {
        $query = Result::with(['student.user', 'course.subject', 'validatedBy']);

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->whereHas('student.user', fn($q) => $q->where('name', 'ilike', "%{$request->search}%"))
                  ->orWhereHas('student', fn($q) => $q->where('student_number', 'ilike', "%{$request->search}%"));
            });
        }

        if ($request->student_id) {
            $query->where('student_id', $request->student_id);
        }

        if ($request->course_id) {
            $query->where('course_id', $request->course_id);
        }

        if ($request->semester) {
            $query->where('semester', $request->semester);
        }

        if ($request->academic_year) {
            $query->where('academic_year', $request->academic_year);
        }

        if ($request->decision) {
            $query->where('decision', $request->decision);
        }

        if ($request->level_id) {
            $query->whereHas('student', fn($q) => $q->where('level_id', $request->level_id));
        }

        if ($request->program_id) {
            $query->whereHas('student', fn($q) => $q->where('program_id', $request->program_id));
        }

        if ($request->department_id) {
            $query->whereHas('student.program', fn($q) => $q->where('department_id', $request->department_id));
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function publish(array $filters): int
    {
        $query = Result::query();

        if (isset($filters['course_id'])) {
            $query->where('course_id', $filters['course_id']);
        }

        if (isset($filters['level_id'])) {
            $query->whereHas('student', fn($q) => $q->where('level_id', $filters['level_id']));
        }

        if (isset($filters['student_id'])) {
            $query->where('student_id', $filters['student_id']);
        }

        if (isset($filters['ids'])) {
            $query->whereIn('id', (array) $filters['ids']);
        }

        $count = $query->whereNull('published_at')->count();
        if ($count > 0) {
            $query->whereNull('published_at')->update([
                'published_at' => now(),
                'validated_by' => auth()->id(),
            ]);
        }

        return $count;
    }

    public function getStudentTranscript(int $studentId): array
    {
        $student = Student::with('user', 'program', 'level')->findOrFail($studentId);

        $results = Result::with(['course.subject', 'validatedBy'])
            ->where('student_id', $studentId)
            ->orderBy('academic_year', 'desc')
            ->orderBy('semester')
            ->get();

        $grouped = $results->groupBy('academic_year');

        $transcript = [];
        foreach ($grouped as $year => $yearResults) {
            $yearData = [
                'academic_year' => $year,
                'semesters' => $yearResults->groupBy('semester')->map(function ($semResults, $sem) {
                    $totalPoints = 0;
                    $totalCoeff = 0;
                    foreach ($semResults as $r) {
                        $coeff = $r->course->subject->coefficient ?? 1;
                        $totalPoints += $r->final_grade * $coeff;
                        $totalCoeff += $coeff;
                    }
                    return [
                        'semester' => $sem,
                        'average' => $totalCoeff > 0 ? round($totalPoints / $totalCoeff, 2) : 0,
                        'credits' => $semResults->sum('credit_value'),
                        'results' => $semResults->map(fn($r) => $this->formatResultItem($r)),
                    ];
                })->values(),
                'year_average' => round($yearResults->avg('final_grade'), 2),
                'year_credits' => $yearResults->sum('credit_value'),
            ];
            $transcript[] = $yearData;
        }

        $allResults = $results;
        $totalCredits = $allResults->sum('credit_value');
        $validatedCount = $allResults->where('decision', 'validated')->count();

        return [
            'student' => [
                'id' => $student->id,
                'name' => $student->user->name,
                'student_number' => $student->student_number,
                'program' => $student->program->name ?? null,
                'level' => $student->level->name ?? null,
            ],
            'summary' => [
                'total_credits' => $totalCredits,
                'average_grade' => round($allResults->avg('final_grade'), 2),
                'validated_courses' => $validatedCount,
                'total_courses' => $allResults->count(),
            ],
            'transcript' => $transcript,
        ];
    }

    public function getStudentResultsByFilters(int $studentId, array $filters): \Illuminate\Support\Collection
    {
        $query = Result::with(['course.subject', 'course.teacher.user', 'validatedBy'])
            ->where('student_id', $studentId);

        if (isset($filters['semester'])) {
            $query->where('semester', $filters['semester']);
        }

        if (isset($filters['academic_year'])) {
            $query->where('academic_year', $filters['academic_year']);
        }

        if (isset($filters['level_id'])) {
            $query->whereHas('course', fn($q) => $q->where('level_id', $filters['level_id']));
        }

        return $query->orderBy('semester')->get();
    }

    public function getSemesterResults(int $studentId, string $semester, string $academicYear): array
    {
        $results = Result::with(['course.subject', 'validatedBy'])
            ->where('student_id', $studentId)
            ->where('semester', $semester)
            ->where('academic_year', $academicYear)
            ->get();

        $totalCredits = $results->sum('credit_value');
        $totalPoints = 0;
        $totalCoefficient = 0;

        foreach ($results as $result) {
            $coeff = $result->course->subject->coefficient ?? 1;
            $totalPoints += $result->final_grade * $coeff;
            $totalCoefficient += $coeff;
        }

        $weightedAverage = $totalCoefficient > 0 ? round($totalPoints / $totalCoefficient, 2) : 0;

        return [
            'semester' => $semester,
            'academic_year' => $academicYear,
            'total_credits' => $totalCredits,
            'weighted_average' => $weightedAverage,
            'decision' => $weightedAverage >= 10 ? 'validated' : 'failed',
            'results' => $results->map(fn($r) => [
                'id' => $r->id,
                'course' => $r->course->name ?? null,
                'subject' => $r->course->subject->name ?? null,
                'final_grade' => $r->final_grade,
                'mention' => $r->mention,
                'credits' => $r->credit_value,
                'coefficient' => $r->course->subject->coefficient ?? 1,
                'decision' => $r->decision,
            ]),
        ];
    }

    public function recalculateAll(): void
    {
        $enrollments = Enrollment::with('course.subject')->where('status', 'active')->get();

        foreach ($enrollments as $enrollment) {
            $grades = $enrollment->grades;
            if ($grades->isEmpty()) continue;

            $totalWeight = $grades->sum('coefficient');
            $weightedSum = $grades->sum(fn($g) => $g->grade_value * $g->coefficient);
            $average = $totalWeight > 0 ? round($weightedSum / $totalWeight, 2) : 0;
            $credits = $enrollment->course->subject->credits ?? 0;

            $decision = 'failed';
            if ($average >= 10) $decision = 'validated';
            elseif ($average >= 8) $decision = 'retake';

            $mention = MentionEnum::fromGrade($average);

            $result = Result::updateOrCreate(
                [
                    'student_id' => $enrollment->student_id,
                    'course_id' => $enrollment->course_id,
                    'semester' => $enrollment->course->semester,
                    'academic_year' => $enrollment->course->academic_year,
                ],
                [
                    'final_grade' => $average,
                    'mention' => $mention,
                    'credit_value' => $decision === 'validated' ? $credits : 0,
                    'grade_point' => $average >= 10 ? min(4.0, $average / 5) : 0,
                    'decision' => $decision,
                    'validated_by' => auth()->id(),
                    'validated_at' => now(),
                ]
            );

            event(new ResultPublished($result));
        }
    }

    public function update(array $data, Result $result): Result
    {
        $result->update([
            'final_grade' => $data['final_grade'] ?? $result->final_grade,
            'decision' => $data['decision'] ?? $result->decision,
            'credit_value' => $data['credit_value'] ?? $result->credit_value,
            'validated_by' => auth()->id(),
            'validated_at' => now(),
        ]);

        return $result->fresh(['student.user', 'course.subject', 'validatedBy']);
    }

    public function delete(Result $result): void
    {
        $result->delete();
    }

    private function formatResultItem($result): array
    {
        $subject = $result->course->subject ?? null;
        return [
            'id' => $result->id,
            'code' => $result->code,
            'subject_name' => $subject->name ?? null,
            'subject_code' => $subject->code ?? null,
            'teacher_name' => $result->course->teacher->user->name ?? null,
            'coefficient' => $subject->coefficient ?? 1,
            'credits' => $subject->credits ?? 0,
            'final_grade' => $result->final_grade,
            'mention' => $result->mention,
            'decision' => $result->decision,
            'credit_value' => $result->credit_value,
            'semester' => $result->semester,
        ];
    }
}
