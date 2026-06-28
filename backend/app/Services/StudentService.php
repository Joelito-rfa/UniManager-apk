<?php

namespace App\Services;

use App\Models\Student;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class StudentService
{
    public function paginate($request)
    {
        $query = Student::with(['user', 'program', 'level']);

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->whereHas('user', function ($u) use ($request) {
                    $u->where('name', 'ilike', "%{$request->search}%")
                      ->orWhere('email', 'ilike', "%{$request->search}%");
                })->orWhere('student_number', 'ilike', "%{$request->search}%");
            });
        }

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->program_id) {
            $query->where('program_id', $request->program_id);
        }

        if ($request->level_id) {
            $query->where('level_id', $request->level_id);
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function generateStudentNumber(): string
    {
        $last = Student::where('student_number', 'like', 'STU%')
            ->orderBy('student_number', 'desc')
            ->value('student_number');

        if ($last) {
            $num = (int) substr($last, 3) + 1;
        } else {
            $num = 1;
        }

        return 'STU' . str_pad($num, 5, '0', STR_PAD_LEFT);
    }

    public function create(array $data): Student
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password'] ?? 'password123'),
                'phone' => $data['phone'] ?? null,
            ]);
            $user->assignRole('student');

            return Student::create([
                'user_id' => $user->id,
                'student_number' => $data['student_number'] ?? $this->generateStudentNumber(),
                'enrollment_date' => $data['enrollment_date'] ?? now(),
                'program_id' => $data['program_id'],
                'level_id' => $data['level_id'],
                'date_of_birth' => $data['date_of_birth'] ?? null,
                'address' => $data['address'] ?? null,
                'phone' => $data['phone'] ?? null,
            ]);
        });
    }

    public function update(Student $student, array $data): Student
    {
        return DB::transaction(function () use ($student, $data) {
            $student->user->update([
                'name' => $data['name'] ?? $student->user->name,
                'email' => $data['email'] ?? $student->user->email,
                'phone' => $data['phone'] ?? $student->user->phone,
            ]);

            $student->update([
                'student_number' => $data['student_number'] ?? $student->student_number,
                'program_id' => $data['program_id'] ?? $student->program_id,
                'level_id' => $data['level_id'] ?? $student->level_id,
                'date_of_birth' => $data['date_of_birth'] ?? $student->date_of_birth,
                'address' => $data['address'] ?? $student->address,
                'phone' => $data['phone'] ?? $student->phone,
            ]);

            return $student->fresh(['user', 'program', 'level']);
        });
    }

    public function delete(Student $student): void
    {
        DB::transaction(function () use ($student) {
            $user = $student->user;
            $student->delete();
            $user->delete();
        });
    }
}
