<?php
namespace Database\Seeders;

use App\Models\Program;
use Illuminate\Database\Seeder;

class ProgramSeeder extends Seeder
{
    public function run(): void
    {
        $programs = [
            ['department_id' => 1, 'name' => 'Licence Informatique', 'description' => 'Licence en sciences informatiques', 'duration' => 3],
            ['department_id' => 1, 'name' => 'Master Data Science', 'description' => 'Master en data science et intelligence artificielle', 'duration' => 2],
            ['department_id' => 2, 'name' => 'Licence Mathématiques', 'description' => 'Licence en mathématiques fondamentales', 'duration' => 3],
            ['department_id' => 3, 'name' => 'Licence Physique', 'description' => 'Licence en physique fondamentale', 'duration' => 3],
            ['department_id' => 5, 'name' => 'Licence Économie', 'description' => 'Licence en sciences économiques', 'duration' => 3],
        ];

        foreach ($programs as $program) {
            Program::create($program);
        }
    }
}
