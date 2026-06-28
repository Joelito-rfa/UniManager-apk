<?php

namespace App\Listeners;

use App\Events\ResultPublished;
use App\Services\NotificationService;

class SendResultPublishedNotification
{
    public function handle(ResultPublished $event): void
    {
        $result = $event->result;
        $course = $result->course;
        $student = $result->student;
        $user = $student->user;
        $courseName = $course->subject->name ?? $course->name ?? '';

        $decision = match ($result->decision) {
            'validated' => 'validée',
            'failed' => 'échouée',
            'retake' => 'rattrapage',
            default => $result->decision,
        };

        $type = $result->decision === 'validated' ? 'success' : 'warning';

        // Notify the student
        app(NotificationService::class)->create(
            $user->id,
            'Résultat disponible',
            "Votre résultat pour {$courseName} : {$result->final_grade}/20 ({$decision})",
            $type,
            [
                'result_id' => $result->id,
                'course_id' => $result->course_id,
            ]
        );

        // Notify the course teacher
        if ($course->teacher && $course->teacher->user) {
            app(NotificationService::class)->create(
                $course->teacher->user->id,
                'Résultat publié',
                "Résultat de {$user->name} pour {$courseName} : {$result->final_grade}/20 ({$decision})",
                $type,
                [
                    'result_id' => $result->id,
                    'course_id' => $course->id,
                ]
            );
        }

        // Notify all admins
        $adminUserIds = \App\Models\User::role('admin')->pluck('id')->toArray();
        app(NotificationService::class)->createForUsers(
            $adminUserIds,
            'Résultat publié',
            "Résultat de {$user->name} pour {$courseName} : {$result->final_grade}/20 ({$decision})",
            $type,
            [
                'result_id' => $result->id,
                'course_id' => $course->id,
            ]
        );
    }
}
