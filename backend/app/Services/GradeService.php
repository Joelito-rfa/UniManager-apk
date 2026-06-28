<?php

namespace App\Services;

use App\Events\ResultPublished;
use App\Models\Grade;
use App\Models\Result;
use App\Models\Enrollment;
use Illuminate\Support\Facades\DB;

class GradeService
{
    public function paginate($request)
    {
        $query = Grade::with(['enrollment.student.user', 'enrollment.course.subject', 'gradedBy']);

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->course_id) {
            $query->whereHas('enrollment', fn($q) => $q->where('course_id', $request->course_id));
        }

        if ($request->student_id) {
            $query->whereHas('enrollment', fn($q) => $q->where('student_id', $request->student_id));
        }

        if ($request->type) {
            $query->where('grade_type', $request->type);
        }

        if ($request->level_id) {
            $query->whereHas('enrollment.student', fn($q) => $q->where('level_id', $request->level_id));
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function create(array $data): Grade
    {
        return DB::transaction(function () use ($data) {
            $grade = Grade::create([
                'enrollment_id' => $data['enrollment_id'],
                'grade_type' => $data['grade_type'],
                'grade_value' => $data['grade_value'],
                'coefficient' => $data['coefficient'] ?? 1.0,
                'comment' => $data['comment'] ?? null,
                'graded_by' => auth()->id(),
            ]);

            $this->updateEnrollmentResult($grade->enrollment_id);

            return $grade->fresh(['enrollment.student.user', 'enrollment.course.subject', 'gradedBy']);
        });
    }

    public function update(Grade $grade, array $data): Grade
    {
        return DB::transaction(function () use ($grade, $data) {
            $grade->update([
                'grade_value' => $data['grade_value'] ?? $grade->grade_value,
                'grade_type' => $data['grade_type'] ?? $grade->grade_type,
                'coefficient' => $data['coefficient'] ?? $grade->coefficient,
                'comment' => $data['comment'] ?? $grade->comment,
            ]);

            $this->updateEnrollmentResult($grade->enrollment_id);

            return $grade->fresh(['enrollment.student.user', 'enrollment.course.subject', 'gradedBy']);
        });
    }

    public function delete(Grade $grade): void
    {
        DB::transaction(function () use ($grade) {
            $enrollmentId = $grade->enrollment_id;
            $grade->delete();
            $this->updateEnrollmentResult($enrollmentId);
        });
    }

    public function createBatch(array $grades): array
    {
        $created = [];
        DB::transaction(function () use ($grades, &$created) {
            foreach ($grades as $data) {
                $created[] = $this->create($data);
            }
        });
        return $created;
    }

    public function updateEnrollmentResult(int $enrollmentId): void
    {
        $enrollment = Enrollment::with(['course.subject'])->find($enrollmentId);
        if (!$enrollment) return;

        $grades = Grade::where('enrollment_id', $enrollmentId)->get();
        $totalWeight = $grades->sum('coefficient');
        $weightedSum = $grades->sum(fn($g) => $g->grade_value * $g->coefficient);
        $average = $totalWeight > 0 ? round($weightedSum / $totalWeight, 2) : 0;

        $credits = 0;
        $decision = 'failed';
        if ($enrollment->course && $enrollment->course->subject) {
            $credits = $enrollment->course->subject->credits ?? 0;
        }
        if ($average >= 10) {
            $decision = 'validated';
        } elseif ($average >= 8) {
            $decision = 'retake';
        }

        $result = Result::updateOrCreate(
            [
                'student_id' => $enrollment->student_id,
                'course_id' => $enrollment->course_id,
                'semester' => $enrollment->course->semester ?? null,
                'academic_year' => $enrollment->course->academic_year ?? null,
            ],
            [
                'final_grade' => $average,
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
