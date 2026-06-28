<?php
namespace Database\Factories;

use App\Models\Grade;
use App\Models\Enrollment;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class GradeFactory extends Factory
{
    protected $model = Grade::class;

    public function definition(): array
    {
        return [
            'enrollment_id' => Enrollment::factory(),
            'graded_by' => User::factory(),
            'type' => $this->faker->randomElement(['exam', 'td', 'tp', 'project']),
            'value' => $this->faker->randomFloat(2, 0, 20),
            'coefficient' => $this->faker->randomFloat(1, 1, 3),
            'comment' => $this->faker->optional(0.3)->sentence(),
            'graded_at' => $this->faker->dateTimeBetween('-1 month', 'now'),
        ];
    }
}
