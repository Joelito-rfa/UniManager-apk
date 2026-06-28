<?php

namespace Tests\Unit\Services;

use App\Models\Classroom;
use App\Models\Department;
use App\Models\Level;
use App\Models\Program;
use App\Models\Student;
use App\Models\Subject;
use App\Models\User;
use App\Repositories\SearchRepository;
use App\Services\SearchService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SearchServiceTest extends TestCase
{
    use RefreshDatabase;

    private SearchService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new SearchService(new SearchRepository());
    }

    public function test_search_returns_empty_for_empty_query(): void
    {
        $results = $this->service->search('');
        $this->assertEmpty($results);
    }

    public function test_search_finds_departments_by_name(): void
    {
        Department::create(['name' => 'Informatique', 'description' => 'Desc']);
        Department::create(['name' => 'Mathématiques', 'description' => 'Desc']);

        $results = $this->service->search('Info');

        $this->assertCount(1, $results['departments']);
        $this->assertEquals('Informatique', $results['departments'][0]['name']);
    }

    public function test_search_finds_departments_by_code(): void
    {
        Department::create(['name' => 'Informatique', 'description' => 'Desc']);

        $results = $this->service->search('DEP-0001');

        $this->assertCount(1, $results['departments']);
        $this->assertEquals('Informatique', $results['departments'][0]['name']);
    }

    public function test_search_finds_programs_by_name(): void
    {
        $dept = Department::create(['name' => 'Info', 'description' => 'Desc']);
        Program::create(['name' => 'Licence Informatique', 'department_id' => $dept->id, 'duration' => 3]);

        $results = $this->service->search('Informatique');

        $this->assertCount(1, $results['programs']);
        $this->assertEquals('Licence Informatique', $results['programs'][0]['name']);
    }

    public function test_search_finds_subjects_by_name(): void
    {
        $dept = Department::create(['name' => 'Info', 'description' => 'Desc']);
        $program = Program::create(['name' => 'Licence', 'department_id' => $dept->id, 'duration' => 3]);
        $level = Level::create(['name' => 'L1', 'program_id' => $program->id]);
        Subject::create(['name' => 'Algorithmique', 'program_id' => $program->id, 'level_id' => $level->id, 'hours' => 30, 'coefficient' => 1]);
        Subject::create(['name' => 'Mathématiques', 'program_id' => $program->id, 'level_id' => $level->id, 'hours' => 40, 'coefficient' => 1]);

        $results = $this->service->search('Math');

        $this->assertCount(1, $results['subjects']);
        $this->assertEquals('Mathématiques', $results['subjects'][0]['name']);
    }

    public function test_search_finds_classrooms_by_name(): void
    {
        Classroom::create(['name' => 'Amphi A', 'capacity' => 100]);

        $results = $this->service->search('Amphi');

        $this->assertCount(1, $results['classrooms']);
        $this->assertEquals('Amphi A', $results['classrooms'][0]['name']);
    }

    public function test_search_finds_students_by_user_name(): void
    {
        $user = User::create(['name' => 'Jean Rakoto', 'email' => 'jean@test.com', 'password' => bcrypt('password')]);
        $dept = Department::create(['name' => 'Info', 'description' => 'Desc']);
        $program = Program::create(['name' => 'Licence', 'department_id' => $dept->id, 'duration' => 3]);
        $level = Level::create(['name' => 'L1', 'program_id' => $program->id]);
        Student::create([
            'user_id' => $user->id,
            'student_number' => 'STU00001',
            'program_id' => $program->id,
            'level_id' => $level->id,
        ]);

        $results = $this->service->search('Rakoto');

        $this->assertCount(1, $results['students']);
        $this->assertEquals('Jean Rakoto', $results['students'][0]['name']);
    }

    public function test_search_is_case_insensitive(): void
    {
        Department::create(['name' => 'Informatique', 'description' => 'Desc']);

        $results = $this->service->search('informatique');

        $this->assertCount(1, $results['departments']);
        $this->assertEquals('Informatique', $results['departments'][0]['name']);
    }

    public function test_search_limits_results_per_category(): void
    {
        for ($i = 1; $i <= 15; $i++) {
            Department::create(['name' => "Department {$i}", 'description' => 'Desc']);
        }

        $results = $this->service->search('Department', 5);

        $this->assertCount(5, $results['departments']);
    }
}
