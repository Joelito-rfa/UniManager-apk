<?php

namespace App\Repositories;

use App\Models\Classroom;
use App\Models\Course;
use App\Models\Department;
use App\Models\Level;
use App\Models\Program;
use App\Models\Student;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\User;

class SearchRepository
{
    public function searchStudents(string $q, int $limit = 10)
    {
        return Student::with('user', 'program', 'level')
            ->where(function ($query) use ($q) {
                $query->where('student_number', 'ilike', "%{$q}%")
                    ->orWhere('code', 'ilike', "%{$q}%")
                    ->orWhereHas('user', function ($u) use ($q) {
                        $u->where('name', 'ilike', "%{$q}%")
                            ->orWhere('email', 'ilike', "%{$q}%");
                    });
            })
            ->limit($limit)
            ->get()
            ->map(fn($s) => [
                'id' => $s->id,
                'name' => $s->user?->name ?? '',
                'code' => $s->code,
                'secondary' => $s->program?->name,
                'type' => 'student',
            ]);
    }

    public function searchTeachers(string $q, int $limit = 10)
    {
        return Teacher::with('user', 'department')
            ->where(function ($query) use ($q) {
                $query->where('teacher_number', 'ilike', "%{$q}%")
                    ->orWhere('code', 'ilike', "%{$q}%")
                    ->orWhereHas('user', function ($u) use ($q) {
                        $u->where('name', 'ilike', "%{$q}%")
                            ->orWhere('email', 'ilike', "%{$q}%");
                    });
            })
            ->limit($limit)
            ->get()
            ->map(fn($t) => [
                'id' => $t->id,
                'name' => $t->user?->name ?? '',
                'code' => $t->code,
                'secondary' => $t->department?->name,
                'type' => 'teacher',
            ]);
    }

    public function searchDepartments(string $q, int $limit = 10)
    {
        return Department::where('name', 'ilike', "%{$q}%")
            ->orWhere('code', 'ilike', "%{$q}%")
            ->limit($limit)
            ->get()
            ->map(fn($d) => [
                'id' => $d->id,
                'name' => $d->name,
                'code' => $d->code,
                'secondary' => null,
                'type' => 'department',
            ]);
    }

    public function searchPrograms(string $q, int $limit = 10)
    {
        return Program::with('department')
            ->where('name', 'ilike', "%{$q}%")
            ->orWhere('code', 'ilike', "%{$q}%")
            ->limit($limit)
            ->get()
            ->map(fn($p) => [
                'id' => $p->id,
                'name' => $p->name,
                'code' => $p->code,
                'secondary' => $p->department?->name,
                'type' => 'program',
            ]);
    }

    public function searchLevels(string $q, int $limit = 10)
    {
        return Level::where('name', 'ilike', "%{$q}%")
            ->orWhere('code', 'ilike', "%{$q}%")
            ->limit($limit)
            ->get()
            ->map(fn($l) => [
                'id' => $l->id,
                'name' => $l->name,
                'code' => $l->code,
                'secondary' => null,
                'type' => 'level',
            ]);
    }

    public function searchSubjects(string $q, int $limit = 10)
    {
        return Subject::with('teacher.user')
            ->where('name', 'ilike', "%{$q}%")
            ->orWhere('code', 'ilike', "%{$q}%")
            ->limit($limit)
            ->get()
            ->map(fn($s) => [
                'id' => $s->id,
                'name' => $s->name,
                'code' => $s->code,
                'secondary' => $s->teacher?->user?->name,
                'type' => 'subject',
            ]);
    }

    public function searchCourses(string $q, int $limit = 10)
    {
        return Course::with('subject', 'teacher.user', 'level')
            ->where(function ($query) use ($q) {
                $query->where('code', 'ilike', "%{$q}%")
                    ->orWhereHas('subject', function ($s) use ($q) {
                        $s->where('name', 'ilike', "%{$q}%");
                    });
            })
            ->limit($limit)
            ->get()
            ->map(fn($c) => [
                'id' => $c->id,
                'name' => $c->subject?->name ?? '',
                'code' => $c->code,
                'secondary' => $c->teacher?->user?->name,
                'type' => 'course',
            ]);
    }

    public function searchClassrooms(string $q, int $limit = 10)
    {
        return Classroom::where('name', 'ilike', "%{$q}%")
            ->orWhere('code', 'ilike', "%{$q}%")
            ->limit($limit)
            ->get()
            ->map(fn($c) => [
                'id' => $c->id,
                'name' => $c->name,
                'code' => $c->code,
                'secondary' => $c->capacity ? "{$c->capacity} places" : null,
                'type' => 'classroom',
            ]);
    }

    public function searchUsers(string $q, int $limit = 10)
    {
        return User::where('name', 'ilike', "%{$q}%")
            ->orWhere('email', 'ilike', "%{$q}%")
            ->orWhere('code', 'ilike', "%{$q}%")
            ->limit($limit)
            ->get()
            ->map(fn($u) => [
                'id' => $u->id,
                'name' => $u->name,
                'code' => $u->code,
                'secondary' => $u->email,
                'type' => 'user',
            ]);
    }
}
