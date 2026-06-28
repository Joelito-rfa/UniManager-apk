<?php

namespace Tests\Unit\Services;

use App\Models\{User, Department, Course, Profile, Teacher, Student, Program, Level, Subject, Classroom, Schedule, Enrollment, Grade, Result, CourseResource, Notification};
use App\Services\IdentifierService;
use PHPUnit\Framework\TestCase;

class IdentifierServiceTest extends TestCase
{
    private IdentifierService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new IdentifierService();
    }

    public static function prefixProvider(): array
    {
        return [
            'User' => [User::class, 'USR', true],
            'Profile' => [Profile::class, 'PRO', true],
            'Teacher' => [Teacher::class, 'ENS', true],
            'Student' => [Student::class, 'ETU', true],
            'Department' => [Department::class, 'DEP', false],
            'Program' => [Program::class, 'FIL', false],
            'Level' => [Level::class, 'NIV', false],
            'Subject' => [Subject::class, 'MAT', false],
            'Course' => [Course::class, 'CRS', true],
            'Classroom' => [Classroom::class, 'SAL', false],
            'Schedule' => [Schedule::class, 'EDT', true],
            'Enrollment' => [Enrollment::class, 'INS', true],
            'Grade' => [Grade::class, 'NOT', true],
            'Result' => [Result::class, 'RES', true],
            'CourseResource' => [CourseResource::class, 'RSC', true],
            'Notification' => [Notification::class, 'NTF', true],
        ];
    }

    /** @dataProvider prefixProvider */
    public function test_generate_for_class_returns_correct_prefix(string $modelClass, string $expectedPrefix, bool $usesYear): void
    {
        $code = $this->service->generateForClass($modelClass);

        if ($usesYear) {
            $year = date('Y');
            $this->assertStringStartsWith("{$expectedPrefix}-{$year}-", $code);
            $this->assertMatchesRegularExpression("/^{$expectedPrefix}-\d{4}-\d{4}$/", $code);
        } else {
            $this->assertStringStartsWith("{$expectedPrefix}-", $code);
            $this->assertMatchesRegularExpression("/^{$expectedPrefix}-\d{4}$/", $code);
        }
    }

    /** @dataProvider prefixProvider */
    public function test_all_prefixes_are_defined(string $modelClass, string $expectedPrefix, bool $expectedYear): void
    {
        $config = IdentifierService::PREFIXES[$modelClass];

        $this->assertEquals($expectedPrefix, $config['prefix']);
        $this->assertEquals($expectedYear, $config['year']);
    }

    public function test_code_format_without_year(): void
    {
        $code = 'MAT-0001';
        $parts = explode('-', $code);
        $this->assertCount(2, $parts);
        $this->assertEquals('MAT', $parts[0]);
        $this->assertEquals('0001', $parts[1]);
    }

    public function test_code_format_with_year(): void
    {
        $code = 'ENS-2026-0001';
        $parts = explode('-', $code);
        $this->assertCount(3, $parts);
        $this->assertEquals('ENS', $parts[0]);
        $this->assertEquals('2026', $parts[1]);
        $this->assertEquals('0001', $parts[2]);
    }

    public function test_sequential_code_for_simple_entity(): void
    {
        $code1 = $this->service->generateForClass(Department::class);
        $this->assertEquals('DEP-0001', $code1);
    }

    public function test_sequential_code_for_year_entity(): void
    {
        $year = date('Y');
        $code = $this->service->generateForClass(Course::class);
        $this->assertEquals("CRS-{$year}-0001", $code);
    }

    public function test_parse_last_number_from_code_without_year(): void
    {
        $code = 'SAL-0099';
        $parts = explode('-', $code);
        $lastNum = (int) end($parts);
        $this->assertEquals(99, $lastNum);
    }

    public function test_parse_last_number_from_code_with_year(): void
    {
        $code = 'NOT-2026-0042';
        $parts = explode('-', $code);
        $lastNum = (int) end($parts);
        $this->assertEquals(42, $lastNum);
    }
}
