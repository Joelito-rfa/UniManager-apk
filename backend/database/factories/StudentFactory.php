<?php
namespace Database\Factories;

use App\Models\Student;
use App\Models\User;
use App\Models\Program;
use App\Models\Level;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

class StudentFactory extends Factory
{
    protected $model = Student::class;

    public function definition(): array
    {
        $user = User::factory()->create([
            'password' => Hash::make('student123'),
        ]);
        $user->assignRole('student');

        return [
            'user_id' => $user->id,
            'program_id' => Program::factory(),
            'level_id' => Level::factory(),
            'student_number' => 'STU' . $this->faker->unique()->numerify('#####'),
            'enrollment_date' => $this->faker->date('Y-m-d', 'now'),
            'status' => $this->faker->randomElement(['active', 'inactive']),
            'emergency_contact' => $this->faker->name(),
            'emergency_phone' => $this->faker->phoneNumber(),
        ];
    }
}
