<?php

namespace App\Services;

use App\Models\Level;

class LevelService
{
    public function paginate($request)
    {
        $query = Level::with('program');

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'ilike', "%{$request->search}%")
                  ->orWhere('code', 'ilike', "%{$request->search}%");
            });
        }

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->program_id) {
            $query->where('program_id', $request->program_id);
        }

        return $query->orderBy('name', 'asc')->paginate($request->per_page ?? 15);
    }

    public function all()
    {
        return Level::with('program')->orderBy('name')->get();
    }

    public function create(array $data): Level
    {
        return Level::create([
            'program_id' => $data['program_id'],
            'name' => $data['name'],
            'code' => $data['code'],

        ]);
    }

    public function update(Level $level, array $data): Level
    {
        $level->update([
            'program_id' => $data['program_id'] ?? $level->program_id,
            'name' => $data['name'] ?? $level->name,
            'code' => $data['code'] ?? $level->code,

        ]);

        return $level->fresh('program');
    }

    public function delete(Level $level): void
    {
        $level->delete();
    }
}
