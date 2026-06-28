<?php
namespace Database\Seeders;

use App\Models\Enrollment;
use App\Models\Grade;
use Illuminate\Database\Seeder;

class GradeSeeder extends Seeder
{
    public function run(): void
    {
        $enrollments = Enrollment::all();

        foreach ($enrollments as $enrollment) {
            $types = ['exam', 'td', 'tp', 'project'];
            $nbGrades = mt_rand(1, 3);

            for ($i = 0; $i < $nbGrades; $i++) {
                Grade::create([
                    'enrollment_id' => $enrollment->id,
                    'graded_by' => $enrollment->course->teacher->user_id,
                    'grade_type' => $types[array_rand($types)],
                    'grade_value' => round(mt_rand(0, 200) / 10, 2),
                    'coefficient' => rand(1, 3),
                    'comment' => fake()->optional(0.3)->sentence(),
                ]);
            }
        }
    }
}
