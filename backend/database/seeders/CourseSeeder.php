<?php
namespace Database\Seeders;

use App\Models\Course;
use Illuminate\Database\Seeder;

class CourseSeeder extends Seeder
{
    public function run(): void
    {
        $courses = [
            ['subject_id' => 1, 'teacher_id' => 1, 'classroom_id' => 1, 'semester' => 'S1', 'academic_year' => '2024/2025', 'group_name' => 'G1'],
            ['subject_id' => 1, 'teacher_id' => 1, 'classroom_id' => 3, 'semester' => 'S1', 'academic_year' => '2024/2025', 'group_name' => 'TD-G1'],
            ['subject_id' => 2, 'teacher_id' => 2, 'classroom_id' => 1, 'semester' => 'S1', 'academic_year' => '2024/2025', 'group_name' => 'G1'],
            ['subject_id' => 2, 'teacher_id' => 2, 'classroom_id' => 4, 'semester' => 'S1', 'academic_year' => '2024/2025', 'group_name' => 'TD-G1'],
            ['subject_id' => 3, 'teacher_id' => 3, 'classroom_id' => 2, 'semester' => 'S1', 'academic_year' => '2024/2025', 'group_name' => 'G1'],
            ['subject_id' => 4, 'teacher_id' => 4, 'classroom_id' => 2, 'semester' => 'S2', 'academic_year' => '2024/2025', 'group_name' => 'G1'],
            ['subject_id' => 5, 'teacher_id' => 5, 'classroom_id' => 5, 'semester' => 'S2', 'academic_year' => '2024/2025', 'group_name' => 'TP-G1'],
            ['subject_id' => 8, 'teacher_id' => 2, 'classroom_id' => 1, 'semester' => 'S1', 'academic_year' => '2024/2025', 'group_name' => 'G1'],
        ];

        foreach ($courses as $course) {
            Course::create($course);
        }
    }
}
