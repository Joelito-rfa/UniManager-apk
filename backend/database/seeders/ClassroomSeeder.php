<?php
namespace Database\Seeders;

use App\Models\Classroom;
use Illuminate\Database\Seeder;

class ClassroomSeeder extends Seeder
{
    public function run(): void
    {
        $classrooms = [
            ['name' => 'Amphi A', 'building' => 'Bâtiment Principal', 'floor' => '0', 'capacity' => 200, 'type' => 'amphi'],
            ['name' => 'Amphi B', 'building' => 'Bâtiment Principal', 'floor' => '0', 'capacity' => 150, 'type' => 'amphi'],
            ['name' => 'Salle TD1', 'building' => 'Bâtiment A', 'floor' => '1', 'capacity' => 40, 'type' => 'td'],
            ['name' => 'Salle TD2', 'building' => 'Bâtiment A', 'floor' => '1', 'capacity' => 40, 'type' => 'td'],
            ['name' => 'Salle TP1', 'building' => 'Bâtiment B', 'floor' => '2', 'capacity' => 25, 'type' => 'tp'],
            ['name' => 'Salle TP2', 'building' => 'Bâtiment B', 'floor' => '2', 'capacity' => 25, 'type' => 'tp'],
            ['name' => 'Laboratoire 1', 'building' => 'Bâtiment C', 'floor' => '1', 'capacity' => 20, 'type' => 'lab'],
            ['name' => 'Laboratoire 2', 'building' => 'Bâtiment C', 'floor' => '1', 'capacity' => 20, 'type' => 'lab'],
        ];

        foreach ($classrooms as $room) {
            Classroom::create($room);
        }
    }
}
