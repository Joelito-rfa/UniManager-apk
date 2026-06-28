<?php
namespace Database\Seeders;

use App\Models\User;
use App\Models\Teacher;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class TeacherSeeder extends Seeder
{
    public function run(): void
    {
        $teachers = [
            ['name' => 'Dr. Ahmed Benali', 'email' => 'ahmed.benali@unimanager.com', 'phone' => '+212611111111', 'teacher_number' => 'TCH002', 'speciality' => 'Algorithmique et Programmation'],
            ['name' => 'Dr. Fatima Zahra', 'email' => 'fatima.zahra@unimanager.com', 'phone' => '+212611111112', 'teacher_number' => 'TCH003', 'speciality' => 'Bases de Données'],
            ['name' => 'Pr. Mohammed Alaoui', 'email' => 'mohammed.alaoui@unimanager.com', 'phone' => '+212611111113', 'teacher_number' => 'TCH004', 'speciality' => 'Réseaux et Télécommunications'],
            ['name' => 'Dr. Sara Idrissi', 'email' => 'sara.idrissi@unimanager.com', 'phone' => '+212611111114', 'teacher_number' => 'TCH005', 'speciality' => 'Intelligence Artificielle'],
            ['name' => 'Pr. Youssef El Amrani', 'email' => 'youssef.amrani@unimanager.com', 'phone' => '+212611111115', 'teacher_number' => 'TCH006', 'speciality' => 'Développement Web'],
        ];

        foreach ($teachers as $i => $data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make('teacher123'),
                'phone' => $data['phone'],
                'status' => 'active',
            ]);
            $user->assignRole('teacher');

            Teacher::create([
                'user_id' => $user->id,
                'department_id' => 1,
                'teacher_number' => $data['teacher_number'],
                'speciality' => $data['speciality'],
                'hire_date' => fake()->date('Y-m-d', '2022-01-01'),
            ]);
        }
    }
}
