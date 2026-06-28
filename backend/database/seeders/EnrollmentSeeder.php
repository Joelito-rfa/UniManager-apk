<?php
namespace Database\Seeders;

use App\Models\Student;
use App\Models\Course;
use App\Models\Enrollment;
use Illuminate\Database\Seeder;

class EnrollmentSeeder extends Seeder
{
    public function run(): void
    {
        $students = Student::all();
        $courses = Course::all();

        foreach ($students as $student) {
            $nbCourses = min(mt_rand(3, 5), $courses->count());
            $selectedCourses = $courses->random($nbCourses);

            foreach ($selectedCourses as $course) {
                Enrollment::firstOrCreate([
                    'student_id' => $student->id,
                    'course_id' => $course->id,
                ], [
                    'enrollment_date' => now()->subMonths(mt_rand(1, 6)),
                    'status' => 'active',
                ]);
            }
        }
    }
}
