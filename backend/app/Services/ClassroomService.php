<?php

namespace App\Services;

use App\Models\Classroom;

class ClassroomService
{
    public function paginate($request)
    {
        $query = Classroom::query();

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'ilike', "%{$request->search}%")
                  ->orWhere('code', 'ilike', "%{$request->search}%")
                  ->orWhere('building', 'ilike', "%{$request->search}%");
            });
        }

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->type) {
            $query->where('type', $request->type);
        }

        if ($request->level_id) {
            $query->whereHas('schedules', function ($q) use ($request) {
                $q->where('level_id', $request->level_id);
            });
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function all()
    {
        return Classroom::orderBy('name')->get();
    }

    public function create(array $data): Classroom
    {
        return Classroom::create([
            'name' => $data['name'],
            'code' => $data['code'] ?? null,
            'building' => $data['building'] ?? null,
            'floor' => $data['floor'] ?? null,
            'capacity' => $data['capacity'] ?? 0,
            'type' => $data['type'] ?? 'classroom',
        ]);
    }

    public function update(Classroom $classroom, array $data): Classroom
    {
        $classroom->update([
            'name' => $data['name'] ?? $classroom->name,
            'code' => $data['code'] ?? $classroom->code,
            'building' => $data['building'] ?? $classroom->building,
            'floor' => $data['floor'] ?? $classroom->floor,
            'capacity' => $data['capacity'] ?? $classroom->capacity,
            'type' => $data['type'] ?? $classroom->type,
        ]);

        return $classroom->fresh();
    }

    public function delete(Classroom $classroom): void
    {
        $classroom->delete();
    }
}
