<?php

namespace App\Services;

use App\Models\Student;
use App\Models\Result;
use App\Models\Enrollment;
use Barryvdh\DomPDF\Facade\Pdf;

class ReportService
{
    public function generateStudentTranscript(int $studentId): \Barryvdh\DomPDF\PDF
    {
        $service = app(ResultService::class);
        $data = $service->getStudentTranscript($studentId);

        return Pdf::loadView('reports.transcript', $data);
    }

    public function generateSemesterReport(int $studentId, string $semester, string $academicYear): \Barryvdh\DomPDF\PDF
    {
        $service = app(ResultService::class);
        $data = $service->getSemesterResults($studentId, $semester, $academicYear);
        $data['student'] = Student::with('user')->findOrFail($studentId);

        return Pdf::loadView('reports.semester', $data);
    }

    public function generateClassReport(int $courseId): \Barryvdh\DomPDF\PDF
    {
        $enrollments = Enrollment::with(['student.user', 'grades', 'course.subject'])
            ->where('course_id', $courseId)
            ->where('status', 'active')
            ->get()
            ->map(function ($enrollment) {
                $grades = $enrollment->grades;
                $totalWeight = $grades->sum('coefficient');
                $weightedSum = $grades->sum(fn($g) => $g->grade_value * $g->coefficient);
                $average = $totalWeight > 0 ? round($weightedSum / $totalWeight, 2) : null;

                return [
                    'student_name' => $enrollment->student->user->name,
                    'student_number' => $enrollment->student->student_number,
                    'average' => $average,
                    'grades_count' => $grades->count(),
                    'status' => $average >= 10 ? 'validated' : ($average !== null ? 'failed' : 'pending'),
                ];
            });

        $course = \App\Models\Course::with('subject')->findOrFail($courseId);

        $data = [
            'course' => $course,
            'enrollments' => $enrollments,
            'generated_at' => now(),
        ];

        return Pdf::loadView('reports.class', $data);
    }

    public function generateProgramReport(int $programId, string $academicYear): \Barryvdh\DomPDF\PDF
    {
        $students = Student::with(['user', 'level', 'results' => function ($q) use ($academicYear) {
                $q->where('academic_year', $academicYear);
            }])
            ->where('program_id', $programId)
            ->get()
            ->map(function ($student) {
                $results = $student->results;
                return [
                    'name' => $student->user->name,
                    'student_number' => $student->student_number,
                    'level' => $student->level->name ?? null,
                    'total_credits' => $results->sum('credit_value'),
                    'average' => $results->avg('final_grade'),
                    'validated_count' => $results->where('decision', 'validated')->count(),
                ];
            });

        $program = \App\Models\Program::findOrFail($programId);

        $data = [
            'program' => $program,
            'academic_year' => $academicYear,
            'students' => $students,
            'generated_at' => now(),
        ];

        return Pdf::loadView('reports.program', $data);
    }

    public function exportResultsExcel(int $courseId): string
    {
        $enrollments = Enrollment::with(['student.user', 'grades'])
            ->where('course_id', $courseId)
            ->where('status', 'active')
            ->get();

        $csv = "Nom,Prénom,Numéro Étudiant,Moyenne,Statut\n";

        foreach ($enrollments as $enrollment) {
            $grades = $enrollment->grades;
            $totalWeight = $grades->sum('coefficient');
            $weightedSum = $grades->sum(fn($g) => $g->grade_value * $g->coefficient);
            $average = $totalWeight > 0 ? round($weightedSum / $totalWeight, 2) : '';
            $status = $average !== '' ? ($average >= 10 ? 'Validé' : 'Échoué') : 'En attente';

            $csv .= implode(',', [
                $enrollment->student->user->name ?? '',
                $enrollment->student->student_number ?? '',
                $average,
                $status,
            ]) . "\n";
        }

        $filename = "results_course_{$courseId}_" . now()->format('Ymd_His') . ".csv";
        $path = storage_path("app/exports/{$filename}");

        if (!is_dir(dirname($path))) {
            mkdir(dirname($path), 0755, true);
        }

        file_put_contents($path, $csv);

        return $path;
    }
}
