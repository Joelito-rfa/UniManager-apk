<?php

namespace App\Services;

use App\Models\Teacher;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class TeacherService
{
    public function paginate($request)
    {
        $query = Teacher::with(['user', 'department']);

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->whereHas('user', function ($u) use ($request) {
                    $u->where('name', 'ilike', "%{$request->search}%")
                      ->orWhere('email', 'ilike', "%{$request->search}%");
                })->orWhere('teacher_number', 'ilike', "%{$request->search}%");
            });
        }

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->department_id) {
            $query->where('department_id', $request->department_id);
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function generateTeacherNumber(): string
    {
        $last = Teacher::where('teacher_number', 'like', 'ENS%')
            ->orderBy('teacher_number', 'desc')
            ->value('teacher_number');

        if ($last) {
            $num = (int) substr($last, 3) + 1;
        } else {
            $num = 1;
        }

        return 'ENS' . str_pad($num, 5, '0', STR_PAD_LEFT);
    }

    public function create(array $data): Teacher
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password'] ?? 'password123'),
                'phone' => $data['phone'] ?? null,
            ]);
            $user->assignRole('teacher');

            return Teacher::create([
                'user_id' => $user->id,
                'department_id' => $data['department_id'],
                'teacher_number' => $data['teacher_number'] ?? $this->generateTeacherNumber(),
                'hire_date' => $data['hire_date'] ?? now(),
                'speciality' => $data['speciality'] ?? null,
                'date_of_birth' => $data['date_of_birth'] ?? null,
                'address' => $data['address'] ?? null,
                'phone' => $data['phone'] ?? null,
            ]);
        });
    }

    public function update(Teacher $teacher, array $data): Teacher
    {
        return DB::transaction(function () use ($teacher, $data) {
            $teacher->user->update([
                'name' => $data['name'] ?? $teacher->user->name,
                'email' => $data['email'] ?? $teacher->user->email,
                'phone' => $data['phone'] ?? $teacher->user->phone,
            ]);

            $teacher->update([
                'teacher_number' => $data['teacher_number'] ?? $teacher->teacher_number,
                'department_id' => $data['department_id'] ?? $teacher->department_id,
                'hire_date' => $data['hire_date'] ?? $teacher->hire_date,
                'speciality' => $data['speciality'] ?? $teacher->speciality,
                'date_of_birth' => $data['date_of_birth'] ?? $teacher->date_of_birth,
                'address' => $data['address'] ?? $teacher->address,
                'phone' => $data['phone'] ?? $teacher->phone,
            ]);

            return $teacher->fresh(['user', 'department']);
        });
    }

    public function delete(Teacher $teacher): void
    {
        DB::transaction(function () use ($teacher) {
            $user = $teacher->user;
            $teacher->delete();
            $user->delete();
        });
    }
}
