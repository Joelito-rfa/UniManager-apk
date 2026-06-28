<?php
namespace Database\Seeders;

use App\Models\Level;
use Illuminate\Database\Seeder;

class LevelSeeder extends Seeder
{
    public function run(): void
    {
        $programLevels = [
            1 => ['L1' => 'Première année', 'L2' => 'Deuxième année', 'L3' => 'Troisième année'],
            2 => ['M1' => 'Master 1', 'M2' => 'Master 2'],
            3 => ['L1' => 'Première année', 'L2' => 'Deuxième année', 'L3' => 'Troisième année'],
            4 => ['L1' => 'Première année', 'L2' => 'Deuxième année', 'L3' => 'Troisième année'],
            5 => ['L1' => 'Première année', 'L2' => 'Deuxième année', 'L3' => 'Troisième année'],
        ];

        foreach ($programLevels as $programId => $levels) {
            foreach ($levels as $code => $name) {
                Level::create([
                    'program_id' => $programId,
                    'name' => $name,
                ]);
            }
        }
    }
}
