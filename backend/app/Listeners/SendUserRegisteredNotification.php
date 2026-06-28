<?php

namespace App\Listeners;

use App\Events\UserRegistered;
use App\Services\NotificationService;

class SendUserRegisteredNotification
{
    public function handle(UserRegistered $event): void
    {
        $user = $event->user;
        $role = $event->role;

        $roleLabel = match ($role) {
            'student' => 'étudiant',
            'teacher' => 'enseignant',
            default => $role,
        };

        $adminUserIds = \App\Models\User::role('admin')->pluck('id')->toArray();
        app(NotificationService::class)->createForUsers(
            $adminUserIds,
            'Nouvel utilisateur',
            "{$user->name} vient de s'inscrire en tant que {$roleLabel}",
            'info',
            [
                'user_id' => $user->id,
                'role' => $role,
            ]
        );
    }
}
