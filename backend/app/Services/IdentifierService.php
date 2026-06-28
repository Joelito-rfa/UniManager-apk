<?php

namespace App\Services;

use App\Models\{User, Profile, Teacher, Student, Department, Program, Level, Subject, Course, Classroom, Schedule, Enrollment, Grade, Result, LevelResult, CourseResource, Notification, Conversation, Message};
use Illuminate\Database\Eloquent\Model;

class IdentifierService
{
    const PREFIXES = [
        User::class => ['prefix' => 'USR', 'year' => true],
        Profile::class => ['prefix' => 'PRO', 'year' => true],
        Teacher::class => ['prefix' => 'ENS', 'year' => true],
        Student::class => ['prefix' => 'ETU', 'year' => true],
        Department::class => ['prefix' => 'DEP', 'year' => false],
        Program::class => ['prefix' => 'FIL', 'year' => false],
        Level::class => ['prefix' => 'NIV', 'year' => false],
        Subject::class => ['prefix' => 'MAT', 'year' => false],
        Course::class => ['prefix' => 'CRS', 'year' => true],
        Classroom::class => ['prefix' => 'SAL', 'year' => false],
        Schedule::class => ['prefix' => 'EDT', 'year' => true],
        Enrollment::class => ['prefix' => 'INS', 'year' => true],
        Grade::class => ['prefix' => 'NOT', 'year' => true],
        Result::class => ['prefix' => 'RES', 'year' => true],
        LevelResult::class => ['prefix' => 'RESNIV', 'year' => true],
        CourseResource::class => ['prefix' => 'RSC', 'year' => true],
        Notification::class => ['prefix' => 'NTF', 'year' => true],
        Conversation::class => ['prefix' => 'CONV', 'year' => true],
        Message::class => ['prefix' => 'MSG', 'year' => true],
    ];

    public function generate(Model $model): string
    {
        $config = $this->resolveConfig($model);
        $prefix = $config['prefix'];
        $useYear = $config['year'];

        $year = $useYear ? date('Y') : null;
        $codePrefix = $prefix . ($useYear ? '-' . $year . '-' : '-');

        $last = $model->where('code', 'like', $codePrefix . '%')
            ->orderBy('code', 'desc')
            ->value('code');

        if ($last) {
            $parts = explode('-', $last);
            $lastNum = (int) end($parts);
            $newNum = $lastNum + 1;
        } else {
            $newNum = 1;
        }

        return $codePrefix . str_pad($newNum, 4, '0', STR_PAD_LEFT);
    }

    public function resolveConfig(Model $model): array
    {
        $class = get_class($model);

        if (isset(self::PREFIXES[$class])) {
            return self::PREFIXES[$class];
        }

        // Fallback: match by suffix for mocked classes in tests
        foreach (self::PREFIXES as $modelClass => $config) {
            if (str_ends_with($class, $modelClass)) {
                return $config;
            }
        }

        throw new \InvalidArgumentException("No prefix configured for: {$class}");
    }

    public function generateForClass(string $modelClass): string
    {
        $config = self::PREFIXES[$modelClass] ?? throw new \InvalidArgumentException("No prefix configured for: {$modelClass}");
        $prefix = $config['prefix'];
        $useYear = $config['year'];

        $year = $useYear ? date('Y') : null;
        $codePrefix = $prefix . ($useYear ? '-' . $year . '-' : '-');

        $model = new $modelClass;
        $last = $model->where('code', 'like', $codePrefix . '%')
            ->orderBy('code', 'desc')
            ->value('code');

        if ($last) {
            $parts = explode('-', $last);
            $lastNum = (int) end($parts);
            $newNum = $lastNum + 1;
        } else {
            $newNum = 1;
        }

        return $codePrefix . str_pad($newNum, 4, '0', STR_PAD_LEFT);
    }
}
