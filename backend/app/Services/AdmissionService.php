<?php

namespace App\Services;

use App\Models\Student;
use App\Models\Level;
use App\Models\LevelResult;

class AdmissionService
{
    /**
     * Récupère la décision finale d'un étudiant pour une année académique.
     * Utilisé par le module Admissions pour déterminer le passage au niveau supérieur.
     */
    public function getDecision(int $studentId, string $academicYear): ?LevelResult
    {
        return LevelResult::where('student_id', $studentId)
            ->where('academic_year', $academicYear)
            ->first();
    }

    /**
     * Vérifie si un étudiant est admissible au niveau supérieur.
     */
    public function isAdmissible(int $studentId, string $academicYear): bool
    {
        $result = $this->getDecision($studentId, $academicYear);
        if (!$result || !$result->isPublished()) {
            return false;
        }
        return $result->decision === 'admis';
    }

    /**
     * Vérifie si un étudiant est en rattrapage.
     */
    public function isRetake(int $studentId, string $academicYear): bool
    {
        $result = $this->getDecision($studentId, $academicYear);
        if (!$result || !$result->isPublished()) {
            return false;
        }
        return $result->decision === 'rattrapage';
    }

    /**
     * Vérifie si un étudiant est ajourné.
     */
    public function isFailed(int $studentId, string $academicYear): bool
    {
        $result = $this->getDecision($studentId, $academicYear);
        if (!$result || !$result->isPublished()) {
            return false;
        }
        return $result->decision === 'ajourne';
    }

    /**
     * Obtient la liste des étudiants admissibles au niveau supérieur.
     */
    public function getAdmissibleStudents(int $currentLevelId, string $academicYear): \Illuminate\Support\Collection
    {
        return LevelResult::with(['student.user', 'level'])
            ->whereHas('student', fn($q) => $q->where('level_id', $currentLevelId))
            ->where('academic_year', $academicYear)
            ->where('decision', 'admis')
            ->whereNotNull('published_at')
            ->get();
    }

    /**
     * Passe les étudiants admissibles au niveau supérieur.
     */
    public function promoteStudents(int $currentLevelId, string $academicYear): int
    {
        $level = Level::findOrFail($currentLevelId);
        $nextLevel = Level::where('program_id', $level->program_id)
            ->where('id', '>', $level->id)
            ->orderBy('id')
            ->first();

        if (!$nextLevel) {
            return 0;
        }

        $admissible = $this->getAdmissibleStudents($currentLevelId, $academicYear);
        $count = 0;

        foreach ($admissible as $levelResult) {
            $levelResult->student->update(['level_id' => $nextLevel->id]);
            $count++;
        }

        return $count;
    }
}
