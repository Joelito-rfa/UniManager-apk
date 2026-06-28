<?php
namespace Database\Seeders;

use App\Models\Schedule;
use Illuminate\Database\Seeder;

class ScheduleSeeder extends Seeder
{
    public function run(): void
    {
        $schedules = [
            ['course_id' => 1, 'classroom_id' => 1, 'day_of_week' => 'Monday', 'start_time' => '08:00', 'end_time' => '10:00', 'type' => 'course'],
            ['course_id' => 2, 'classroom_id' => 3, 'day_of_week' => 'Monday', 'start_time' => '10:15', 'end_time' => '12:15', 'type' => 'td'],
            ['course_id' => 3, 'classroom_id' => 1, 'day_of_week' => 'Tuesday', 'start_time' => '08:00', 'end_time' => '10:00', 'type' => 'course'],
            ['course_id' => 4, 'classroom_id' => 4, 'day_of_week' => 'Tuesday', 'start_time' => '10:15', 'end_time' => '12:15', 'type' => 'td'],
            ['course_id' => 5, 'classroom_id' => 2, 'day_of_week' => 'Wednesday', 'start_time' => '08:00', 'end_time' => '10:00', 'type' => 'course'],
            ['course_id' => 6, 'classroom_id' => 2, 'day_of_week' => 'Thursday', 'start_time' => '14:00', 'end_time' => '16:00', 'type' => 'course'],
            ['course_id' => 7, 'classroom_id' => 5, 'day_of_week' => 'Friday', 'start_time' => '08:00', 'end_time' => '11:00', 'type' => 'tp'],
            ['course_id' => 8, 'classroom_id' => 1, 'day_of_week' => 'Wednesday', 'start_time' => '10:15', 'end_time' => '12:15', 'type' => 'course'],
        ];

        foreach ($schedules as $schedule) {
            Schedule::create($schedule);
        }
    }
}
