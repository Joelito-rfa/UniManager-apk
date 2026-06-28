<?php

namespace App\Services;

use App\Models\Notification;

class NotificationService
{
    public function create(int $userId, string $title, string $message, string $type = 'info', ?array $data = null): Notification
    {
        return Notification::create([
            'user_id' => $userId,
            'title' => $title,
            'message' => $message,
            'type' => $type,
            'data' => $data,
        ]);
    }

    public function createForUsers(array $userIds, string $title, string $message, string $type = 'info', ?array $data = null): void
    {
        foreach ($userIds as $userId) {
            $this->create($userId, $title, $message, $type, $data);
        }
    }

    public function createForAllStudents(string $title, string $message, string $type = 'info', ?array $data = null): void
    {
        $studentUserIds = \App\Models\User::role('student')->pluck('id')->toArray();
        $this->createForUsers($studentUserIds, $title, $message, $type, $data);
    }

    public function createForAllTeachers(string $title, string $message, string $type = 'info', ?array $data = null): void
    {
        $teacherUserIds = \App\Models\User::role('teacher')->pluck('id')->toArray();
        $this->createForUsers($teacherUserIds, $title, $message, $type, $data);
    }
}
