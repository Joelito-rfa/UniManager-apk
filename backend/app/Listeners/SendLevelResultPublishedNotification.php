<?php

namespace App\Listeners;

use App\Events\LevelResultPublished;
use App\Models\Notification;

class SendLevelResultPublishedNotification
{
    public function handle(LevelResultPublished $event): void
    {
        $levelResult = $event->levelResult;
        $student = $levelResult->student;

        if ($student && $student->user) {
            Notification::create([
                'user_id' => $student->user_id,
                'title' => 'Résultats de niveau publiés',
                'body' => 'Vos résultats pour l\'année ' . $levelResult->academic_year . ' ont été publiés. Décision: ' . $levelResult->decision,
                'type' => 'result',
                'data' => [
                    'level_result_id' => $levelResult->id,
                    'decision' => $levelResult->decision,
                    'average_grade' => $levelResult->average_grade,
                ],
            ]);
        }
    }
}
