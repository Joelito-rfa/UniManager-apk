<?php
namespace Database\Factories;

use App\Models\Course;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\Classroom;
use Illuminate\Database\Eloquent\Factories\Factory;

class CourseFactory extends Factory
{
    protected $model = Course::class;

    public function definition(): array
    {
        return [
            'subject_id' => Subject::factory(),
            'teacher_id' => Teacher::factory(),
            'classroom_id' => Classroom::factory(),
            'name' => $this->faker->sentence(3),
            'code' => strtoupper($this->faker->unique()->bothify('???###')),
            'description' => $this->faker->optional()->paragraph(),
            'semester' => $this->faker->randomElement(['S1', 'S2', 'S3', 'S4', 'S5', 'S6']),
            'academic_year' => '2024/2025',
            'max_students' => $this->faker->numberBetween(20, 200),
            'status' => 'active',
        ];
    }
}
