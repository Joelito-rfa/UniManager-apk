<?php

namespace App\Listeners;

use App\Events\GradePublished;
use App\Services\NotificationService;

class SendGradePublishedNotification
{
    public function handle(GradePublished $event): void
    {
        $grade = $event->grade;
        $enrollment = $grade->enrollment;
        $course = $enrollment->course;
        $student = $enrollment->student;
        $user = $student->user;
        $courseName = $course->subject->name ?? $course->name ?? '';
        $gradedBy = $grade->gradedBy;

        // Notify the student
        app(NotificationService::class)->create(
            $user->id,
            'Note publiée',
            "Votre note pour {$courseName} a été publiée : {$grade->grade_value}/20",
            'info',
            [
                'grade_id' => $grade->id,
                'enrollment_id' => $enrollment->id,
            ]
        );

        // Notify the course teacher (if graded by admin, not teacher)
        if ($course->teacher && $course->teacher->user && (!$gradedBy || $course->teacher->user->id !== $gradedBy->id)) {
            app(NotificationService::class)->create(
                $course->teacher->user->id,
                'Note publiée',
                "Note de {$user->name} pour {$courseName} : {$grade->grade_value}/20",
                'info',
                [
                    'grade_id' => $grade->id,
                    'enrollment_id' => $enrollment->id,
                    'student_id' => $student->id,
                ]
            );
        }

        // Notify all admins (if graded by teacher, not admin)
        if (!$gradedBy || !$gradedBy->hasRole('admin')) {
            $adminUserIds = \App\Models\User::role('admin')->pluck('id')->toArray();
            app(NotificationService::class)->createForUsers(
                $adminUserIds,
                'Note publiée',
                "Note de {$user->name} pour {$courseName} : {$grade->grade_value}/20",
                'info',
                [
                    'grade_id' => $grade->id,
                    'course_id' => $course->id,
                ]
            );
        }
    }
}
