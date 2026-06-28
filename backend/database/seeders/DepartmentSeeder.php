<?php
namespace Database\Seeders;

use App\Models\Department;
use Illuminate\Database\Seeder;

class DepartmentSeeder extends Seeder
{
    public function run(): void
    {
        $departments = [
            ['name' => 'Informatique', 'description' => 'Département des sciences informatiques'],
            ['name' => 'Mathématiques', 'description' => 'Département de mathématiques'],
            ['name' => 'Physique', 'description' => 'Département de physique'],
            ['name' => 'Lettres', 'description' => 'Département des lettres et langues'],
            ['name' => 'Sciences Économiques', 'description' => 'Département des sciences économiques'],
        ];

        foreach ($departments as $dept) {
            Department::create($dept);
        }
    }
}
