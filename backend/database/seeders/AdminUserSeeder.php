<?php
namespace Database\Seeders;

use App\Models\User;
use App\Models\Teacher;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        $admin = User::firstOrCreate(
            ['email' => 'admin@unimanager.com'],
            [
                'name' => 'Admin Système',
                'password' => Hash::make('admin123'),
                'phone' => '+212600000000',
                'status' => 'active',
            ]
        );
        $admin->assignRole('admin');

        $teacherUser = User::firstOrCreate(
            ['email' => 'teacher@unimanager.com'],
            [
                'name' => 'Professeur Test',
                'password' => Hash::make('teacher123'),
                'phone' => '+212600000001',
                'status' => 'active',
            ]
        );
        $teacherUser->assignRole('teacher');

        Teacher::firstOrCreate(
            ['user_id' => $teacherUser->id],
            [
                'teacher_number' => 'TCH001',
                'speciality' => 'Informatique',
                'hire_date' => '2020-09-01',
            ]
        );

        $studentUser = User::firstOrCreate(
            ['email' => 'student@unimanager.com'],
            [
                'name' => 'Étudiant Test',
                'password' => Hash::make('student123'),
                'phone' => '+212600000002',
                'status' => 'active',
            ]
        );
        $studentUser->assignRole('student');
    }
}
