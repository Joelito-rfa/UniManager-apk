<?php
namespace Database\Seeders;

use App\Enums\DecisionEnum;
use App\Enums\MentionEnum;
use App\Models\LevelResult;
use App\Models\Result;
use App\Models\Student;
use App\Models\Enrollment;
use App\Models\Course;
use App\Models\Grade;
use App\Models\Subject;
use Illuminate\Database\Seeder;

class LevelResultSeeder extends Seeder
{
    public function run(): void
    {
        $academicYear = '2025/2026';
        $students = Student::with('user')->whereHas('user', fn($q) => $q->where('status', 'active'))->get();

        if ($students->isEmpty()) {
            $this->command->warn('No active students found.');
            return;
        }

        $this->command->info('Found ' . $students->count() . ' active students.');
        $levelResultCount = 0;

        foreach ($students as $student) {
            $enrollments = Enrollment::with('course.subject')
                ->where('student_id', $student->id)
                ->where('status', 'active')
                ->get();

            if ($enrollments->isEmpty()) continue;

            $totalPoints = 0;
            $totalCoefficients = 0;
            $totalCreditsObtained = 0;
            $totalCreditsRequired = 0;
            $subjectIds = [];
            $resultsCreated = 0;

            foreach ($enrollments as $enrollment) {
                $course = $enrollment->course;
                if (!$course || !$course->subject) continue;
                $subject = $course->subject;

                $grades = Grade::where('enrollment_id', $enrollment->id)->get();
                if ($grades->isEmpty()) continue;

                $sumGradeCoeff = 0;
                $sumCoeff = 0;
                foreach ($grades as $grade) {
                    $sumGradeCoeff += $grade->grade_value * $grade->coefficient;
                    $sumCoeff += $grade->coefficient;
                }

                $finalGrade = $sumCoeff > 0 ? round($sumGradeCoeff / $sumCoeff, 2) : 0;
                $coeff = $subject->coefficient ?? 1;
                $totalPoints += $finalGrade * $coeff;
                $totalCoefficients += $coeff;

                if (!in_array($subject->id, $subjectIds)) {
                    $totalCreditsRequired += $subject->credits ?? 0;
                    $subjectIds[] = $subject->id;
                }

                $passed = $finalGrade >= 10;
                if ($passed) $totalCreditsObtained += $subject->credits ?? 0;

                $semester = $course->semester ?? ($course->id % 2 === 0 ? 'S2' : 'S1');

                Result::updateOrCreate(
                    [
                        'student_id' => $student->id,
                        'course_id' => $course->id,
                        'semester' => $semester,
                        'academic_year' => $academicYear,
                    ],
                    [
                        'final_grade' => $finalGrade,
                        'mention' => MentionEnum::fromGrade($finalGrade),
                        'credits_obtained' => $subject->credits ?? 0,
                        'credit_value' => $passed ? ($subject->credits ?? 0) : 0,
                        'status' => $passed ? 'validated' : 'failed',
                        'decision' => $passed ? 'validated' : 'failed',
                        'grade_point' => round($finalGrade / 20 * 4, 2),
                        'validated_by' => 1,
                        'validated_at' => now()->subDays(rand(1, 30)),
                        'published_at' => now()->subDays(rand(1, 10)),
                    ]
                );
                $resultsCreated++;
            }

            if ($totalCoefficients <= 0) continue;

            $average = round($totalPoints / $totalCoefficients, 2);
            $decision = $this->determineDecision($average, $totalCreditsObtained, $totalCreditsRequired);

            LevelResult::updateOrCreate(
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
                    'mention' => MentionEnum::fromGrade($average),
                    'decision' => $decision,
                    'published_at' => now()->subDays(rand(1, 5)),
                ]
            );
            $levelResultCount++;

            $this->command->info("  Student {$student->id}: {$resultsCreated} results, avg={$average}, decision={$decision}");
        }

        $this->command->info("Created {$levelResultCount} level results for academic year {$academicYear}.");
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
}
