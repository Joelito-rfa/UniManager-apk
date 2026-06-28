<?php
namespace Database\Seeders;

use App\Models\User;
use App\Models\Student;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class StudentSeeder extends Seeder
{
    public function run(): void
    {
        $firstNames = ['Ali', 'Imane', 'Omar', 'Salma', 'Hassan', 'Amina', 'Karim', 'Nadia', 'Reda', 'Mariam',
                       'Yassin', 'Loubna', 'Anass', 'Khadija', 'Sofiane', 'Fatima', 'Mehdi', 'Zineb', 'Rachid', 'Houda'];
        $lastNames = ['El Amrani', 'Bennani', 'Alaoui', 'Idrissi', 'Tazi', 'Fassi', 'Berrada', 'Zniber', 'Benjelloun', 'Ouazzani'];

        for ($i = 0; $i < 20; $i++) {
            $name = $firstNames[$i] . ' ' . $lastNames[array_rand($lastNames)];
            $email = strtolower(str_replace(' ', '.', $name)) . ($i + 1) . '@etu.unimanager.com';

            $user = User::create([
                'name' => $name,
                'email' => $email,
                'password' => Hash::make('student123'),
                'phone' => '+212622' . str_pad(mt_rand(0, 999999), 6, '0', STR_PAD_LEFT),
                'status' => 'active',
            ]);
            $user->assignRole('student');

            Student::create([
                'user_id' => $user->id,
                'program_id' => 1,
                'level_id' => 1,
                'student_number' => 'STU' . str_pad($i + 2, 5, '0', STR_PAD_LEFT),
                'enrollment_date' => now()->subMonths(mt_rand(1, 12)),
            ]);
        }
    }
}
