<?php

namespace App\Listeners;

use App\Events\StudentEnrolled;
use App\Services\NotificationService;

class SendStudentEnrolledNotification
{
    public function handle(StudentEnrolled $event): void
    {
        $enrollment = $event->enrollment;
        $student = $enrollment->student;
        $course = $enrollment->course;
        $user = $student->user;

        $courseName = $course->subject->name ?? $course->name ?? '';

        // Notify the student
        app(NotificationService::class)->create(
            $user->id,
            'Inscription confirmée',
            "Vous avez été inscrit au cours : {$courseName}",
            'success',
            [
                'enrollment_id' => $enrollment->id,
                'course_id' => $course->id,
            ]
        );

        // Notify the course teacher
        if ($course->teacher && $course->teacher->user) {
            app(NotificationService::class)->create(
                $course->teacher->user->id,
                'Nouvel inscrit',
                "Un étudiant ({$user->name}) s'est inscrit à votre cours : {$courseName}",
                'info',
                [
                    'enrollment_id' => $enrollment->id,
                    'course_id' => $course->id,
                    'student_id' => $student->id,
                ]
            );
        }

        // Notify all admins
        $adminUserIds = \App\Models\User::role('admin')->pluck('id')->toArray();
        app(NotificationService::class)->createForUsers(
            $adminUserIds,
            'Nouvelle inscription',
            "{$user->name} inscrit au cours : {$courseName}",
            'info',
            [
                'enrollment_id' => $enrollment->id,
                'course_id' => $course->id,
            ]
        );
    }
}
