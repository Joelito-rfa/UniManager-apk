<?php
namespace Database\Seeders;

use App\Models\Subject;
use Illuminate\Database\Seeder;

class SubjectSeeder extends Seeder
{
    public function run(): void
    {
        $subjects = [
            ['program_id' => 1, 'teacher_id' => 1, 'name' => 'Algorithmique et Programmation', 'description' => 'Introduction à l\'algorithmique et à la programmation en Python', 'credits' => 6, 'coefficient' => 3],
            ['program_id' => 1, 'teacher_id' => 2, 'name' => 'Bases de Données', 'description' => 'Conception et manipulation des bases de données relationnelles', 'credits' => 6, 'coefficient' => 3],
            ['program_id' => 1, 'teacher_id' => 3, 'name' => 'Réseaux Informatiques', 'description' => 'Fondamentaux des réseaux informatiques', 'credits' => 4, 'coefficient' => 2],
            ['program_id' => 1, 'teacher_id' => 4, 'name' => 'Intelligence Artificielle', 'description' => 'Concepts avancés en intelligence artificielle', 'credits' => 5, 'coefficient' => 2.5],
            ['program_id' => 1, 'teacher_id' => 5, 'name' => 'Développement Web', 'description' => 'Développement d\'applications web modernes', 'credits' => 5, 'coefficient' => 2.5],
            ['program_id' => 2, 'teacher_id' => 1, 'name' => 'Structures de Données', 'description' => 'Structures de données avancées', 'credits' => 6, 'coefficient' => 3],
            ['program_id' => 2, 'teacher_id' => 4, 'name' => 'Machine Learning', 'description' => 'Introduction au machine learning', 'credits' => 6, 'coefficient' => 3],
            ['program_id' => 1, 'teacher_id' => 2, 'name' => 'Programmation Orientée Objet', 'description' => 'Programmation orientée objet en Java', 'credits' => 5, 'coefficient' => 2.5],
        ];

        foreach ($subjects as $subject) {
            Subject::create($subject);
        }
    }
}
