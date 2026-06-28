<?php

namespace App\Providers;

use App\Models\Course;
use App\Models\Grade;
use App\Models\LevelResult;
use App\Models\Result;
use App\Models\Student;
use App\Models\Subject;
use App\Policies\CoursePolicy;
use App\Policies\GradePolicy;
use App\Policies\LevelResultPolicy;
use App\Policies\ResultPolicy;
use App\Policies\StudentPolicy;
use App\Policies\SubjectPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        Student::class => StudentPolicy::class,
        Subject::class => SubjectPolicy::class,
        Course::class => CoursePolicy::class,
        Grade::class => GradePolicy::class,
        Result::class => ResultPolicy::class,
        LevelResult::class => LevelResultPolicy::class,
    ];

    public function boot(): void
    {
        $this->registerPolicies();
    }
}
