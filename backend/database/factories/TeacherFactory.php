<?php
namespace Database\Factories;

use App\Models\Teacher;
use App\Models\User;
use App\Models\Department;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

class TeacherFactory extends Factory
{
    protected $model = Teacher::class;

    public function definition(): array
    {
        $user = User::factory()->create([
            'password' => Hash::make('teacher123'),
        ]);
        $user->assignRole('teacher');

        return [
            'user_id' => $user->id,
            'department_id' => Department::factory(),
            'employee_number' => 'TCH' . $this->faker->unique()->numerify('#####'),
            'specialization' => $this->faker->randomElement([
                'Informatique', 'Mathématiques', 'Physique', 'Chimie', 'Biologie',
                'Littérature', 'Histoire', 'Économie', 'Droit',
            ]),
            'hire_date' => $this->faker->date('Y-m-d', '2022-01-01'),
            'status' => $this->faker->randomElement(['active', 'inactive']),
            'office_hours' => $this->faker->optional()->sentence(),
        ];
    }
}
