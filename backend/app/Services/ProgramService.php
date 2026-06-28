<?php

namespace App\Services;

use App\Models\Program;

class ProgramService
{
    public function paginate($request)
    {
        $query = Program::with('department');

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'ilike', "%{$request->search}%")
                  ->orWhere('code', 'ilike', "%{$request->search}%");
            });
        }

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->department_id) {
            $query->where('department_id', $request->department_id);
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function all()
    {
        return Program::with('department')->orderBy('name')->get();
    }

    public function create(array $data): Program
    {
        return Program::create([
            'department_id' => $data['department_id'],
            'name' => $data['name'],
            'code' => $data['code'] ?? null,
            'description' => $data['description'] ?? null,
            'duration' => $data['duration'] ?? 3,
        ]);
    }

    public function update(Program $program, array $data): Program
    {
        $program->update([
            'department_id' => $data['department_id'] ?? $program->department_id,
            'name' => $data['name'] ?? $program->name,
            'code' => $data['code'] ?? $program->code,
            'description' => $data['description'] ?? $program->description,
            'duration' => $data['duration'] ?? $program->duration,
        ]);

        return $program->fresh('department');
    }

    public function delete(Program $program): void
    {
        $program->delete();
    }
}
