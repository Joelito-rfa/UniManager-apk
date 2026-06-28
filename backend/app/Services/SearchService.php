<?php

namespace App\Services;

use App\Repositories\SearchRepository;

class SearchService
{
    public function __construct(private SearchRepository $repository) {}

    public function search(string $q, int $limit = 10): array
    {
        if (empty(trim($q))) {
            return [];
        }

        return [
            'students' => $this->repository->searchStudents($q, $limit),
            'teachers' => $this->repository->searchTeachers($q, $limit),
            'departments' => $this->repository->searchDepartments($q, $limit),
            'programs' => $this->repository->searchPrograms($q, $limit),
            'levels' => $this->repository->searchLevels($q, $limit),
            'subjects' => $this->repository->searchSubjects($q, $limit),
            'courses' => $this->repository->searchCourses($q, $limit),
            'classrooms' => $this->repository->searchClassrooms($q, $limit),
        ];
    }
}
