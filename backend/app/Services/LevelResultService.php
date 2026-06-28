<?php

namespace App\Services;

use App\Enums\DecisionEnum;
use App\Enums\MentionEnum;
use App\Events\LevelResultPublished;
use App\Models\LevelResult;
use App\Models\Result;
use App\Models\Student;
use App\Models\Subject;
use Illuminate\Support\Facades\DB;

class LevelResultService
{
    public function paginate($request)
    {
        $query = LevelResult::with(['student.user', 'level', 'program', 'validatedBy']);

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->whereHas('student.user', fn($q) => $q->where('name', 'ilike', "%{$request->search}%"))
                  ->orWhereHas('student', fn($q) => $q->where('student_number', 'ilike', "%{$request->search}%"));
            });
        }

        if ($request->program_id) {
            $query->where('program_id', $request->program_id);
        }

        if ($request->level_id) {
            $query->where('level_id', $request->level_id);
        }

        if ($request->academic_year) {
            $query->where('academic_year', $request->academic_year);
        }

        if ($request->decision) {
            $query->where('decision', $request->decision);
        }

        if ($request->department_id) {
            $query->whereHas('program', fn($q) => $q->where('department_id', $request->department_id));
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function calculate(array $filters): \Illuminate\Support\Collection
    {
        $query = Student::with(['user', 'program', 'level', 'results.course.subject'])
            ->where('status', 'active');

        if (isset($filters['student_id'])) {
            $query->where('id', $filters['student_id']);
        }

        if (isset($filters['level_id'])) {
            $query->where('level_id', $filters['level_id']);
        }

        if (isset($filters['program_id'])) {
            $query->where('program_id', $filters['program_id']);
        }

        $students = $query->get();
        $academicYear = $filters['academic_year'] ?? now()->year . '/' . (now()->year + 1);
        $levelResults = collect();

        foreach ($students as $student) {
            $results = Result::with(['course.subject'])
                ->where('student_id', $student->id)
                ->where('academic_year', $academicYear)
                ->get();

            if ($results->isEmpty()) continue;

            $totalPoints = 0;
            $totalCoefficients = 0;
            $totalCreditsObtained = 0;
            $totalCreditsRequired = 0;
            $subjectIds = [];

            foreach ($results as $result) {
                $subject = $result->course->subject ?? null;
                if (!$subject) continue;

                $coeff = $subject->coefficient ?? 1;
                $totalPoints += $result->final_grade * $coeff;
                $totalCoefficients += $coeff;

                if ($subject->id && !in_array($subject->id, $subjectIds)) {
                    $totalCreditsRequired += $subject->credits ?? 0;
                    $subjectIds[] = $subject->id;
                }

                if ($result->decision === 'validated') {
                    $totalCreditsObtained += $result->credit_value;
                }
            }

            $average = $totalCoefficients > 0
                ? round($totalPoints / $totalCoefficients, 2)
                : 0;

            $mention = MentionEnum::fromGrade($average);
            $decision = $this->determineDecision($average, $totalCreditsObtained, $totalCreditsRequired);

            $levelResult = LevelResult::updateOrCreate(
                [
                    'student_id' => $student->id,
                    'level_id' => $student->level_id,
                    'academic_year' => $academicYear,
                ],
                [
                    'program_id' => $student->program_id,
                    'total_points' => $totalPoints,
                    'total_coefficients' => $totalCoefficients,
                    'average_grade' => $average,
                    'total_credits_obtained' => $totalCreditsObtained,
                    'total_credits_required' => $totalCreditsRequired,
                    'mention' => $mention,
                    'decision' => $decision,
                    'validated_by' => auth()->id(),
                ]
            );

            event(new LevelResultPublished($levelResult));
            $levelResults->push($levelResult->load(['student.user', 'level', 'program']));
        }

        return $levelResults;
    }

    private function determineDecision(float $average, int $creditsObtained, int $creditsRequired): string
    {
        if ($average >= 10 && $creditsObtained >= $creditsRequired) {
            return DecisionEnum::Admis->value;
        }

        if ($average >= 8 || ($average >= 10 && $creditsObtained < $creditsRequired)) {
            return DecisionEnum::Rattrapage->value;
        }

        return DecisionEnum::Ajourne->value;
    }

    public function publish(array $filters): int
    {
        $query = LevelResult::query();

        if (isset($filters['level_id'])) {
            $query->where('level_id', $filters['level_id']);
        }

        if (isset($filters['program_id'])) {
            $query->where('program_id', $filters['program_id']);
        }

        if (isset($filters['academic_year'])) {
            $query->where('academic_year', $filters['academic_year']);
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

    public function getStudentLevelResults(int $studentId): \Illuminate\Support\Collection
    {
        return LevelResult::with(['level', 'program'])
            ->where('student_id', $studentId)
            ->orderBy('academic_year', 'desc')
            ->get();
    }

    public function delete(LevelResult $levelResult): void
    {
        $levelResult->delete();
    }
}
