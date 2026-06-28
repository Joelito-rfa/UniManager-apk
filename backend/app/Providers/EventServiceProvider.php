<?php

namespace App\Providers;

use App\Events\GradePublished;
use App\Events\LevelResultPublished;
use App\Events\StudentEnrolled;
use App\Events\ResultPublished;
use App\Events\UserRegistered;
use App\Listeners\SendGradePublishedNotification;
use App\Listeners\SendLevelResultPublishedNotification;
use App\Listeners\SendStudentEnrolledNotification;
use App\Listeners\SendResultPublishedNotification;
use App\Listeners\SendUserRegisteredNotification;
use Illuminate\Auth\Events\Registered;
use Illuminate\Auth\Listeners\SendEmailVerificationNotification;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

class EventServiceProvider extends ServiceProvider
{
    protected $listen = [
        Registered::class => [
            SendEmailVerificationNotification::class,
        ],
        StudentEnrolled::class => [
            SendStudentEnrolledNotification::class,
        ],
        GradePublished::class => [
            SendGradePublishedNotification::class,
        ],
        ResultPublished::class => [
            SendResultPublishedNotification::class,
        ],
        LevelResultPublished::class => [
            SendLevelResultPublishedNotification::class,
        ],
        UserRegistered::class => [
            SendUserRegisteredNotification::class,
        ],
    ];

    public function boot(): void
    {
        //
    }

    public function shouldDiscoverEvents(): bool
    {
        return false;
    }
}
