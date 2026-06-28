<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            RoleAndPermissionSeeder::class,
            AdminUserSeeder::class,
            DepartmentSeeder::class,
            ProgramSeeder::class,
            LevelSeeder::class,
            ClassroomSeeder::class,
            TeacherSeeder::class,
            SubjectSeeder::class,
            StudentSeeder::class,
            CourseSeeder::class,
            ScheduleSeeder::class,
            EnrollmentSeeder::class,
            GradeSeeder::class,
            LevelResultSeeder::class,
        ]);
    }
}
