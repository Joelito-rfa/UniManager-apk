<?php

namespace App\Services;

use App\Models\Department;

class DepartmentService
{
    public function paginate($request)
    {
        $query = Department::query();

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'ilike', "%{$request->search}%")
                  ->orWhere('code', 'ilike', "%{$request->search}%");
            });
        }

        if ($request->code) {
            $query->byCode($request->code);
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function all()
    {
        return Department::orderBy('name')->get();
    }

    public function create(array $data): Department
    {
        return Department::create([
            'name' => $data['name'],
            'code' => $data['code'] ?? null,
            'description' => $data['description'] ?? null,

        ]);
    }

    public function update(Department $department, array $data): Department
    {
        $department->update([
            'name' => $data['name'] ?? $department->name,
            'code' => $data['code'] ?? $department->code,
            'description' => $data['description'] ?? $department->description,

        ]);

        return $department->fresh();
    }

    public function delete(Department $department): void
    {
        $department->delete();
    }
}
