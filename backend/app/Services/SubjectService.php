<?php

namespace App\Services;

use App\Models\Subject;

class SubjectService
{
    public function paginate($request)
    {
        $query = Subject::with(['program', 'level', 'teacher.user']);

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

        if ($request->level_id) {
            $query->where('level_id', $request->level_id);
        }

        if ($request->teacher_id) {
            $query->where('teacher_id', $request->teacher_id);
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function all()
    {
        return Subject::with(['program', 'level'])->orderBy('name')->get();
    }

    public function create(array $data): Subject
    {
        return Subject::create([
            'program_id' => $data['program_id'],
            'level_id' => $data['level_id'] ?? null,
            'teacher_id' => $data['teacher_id'] ?? null,
            'name' => $data['name'],
            'code' => $data['code'] ?? null,
            'description' => $data['description'] ?? null,
            'credits' => $data['credits'] ?? 0,
            'coefficient' => $data['coefficient'] ?? 1.0,
            'hours_total' => $data['hours_total'] ?? null,
            'status' => $data['status'] ?? 'active',
        ]);
    }

    public function update(Subject $subject, array $data): Subject
    {
        $subject->update([
            'program_id' => $data['program_id'] ?? $subject->program_id,
            'level_id' => array_key_exists('level_id', $data) ? $data['level_id'] : $subject->level_id,
            'teacher_id' => $data['teacher_id'] ?? $subject->teacher_id,
            'name' => $data['name'] ?? $subject->name,
            'code' => $data['code'] ?? $subject->code,
            'description' => $data['description'] ?? $subject->description,
            'credits' => $data['credits'] ?? $subject->credits,
            'coefficient' => $data['coefficient'] ?? $subject->coefficient,
            'hours_total' => array_key_exists('hours_total', $data) ? $data['hours_total'] : $subject->hours_total,
            'status' => $data['status'] ?? $subject->status,
        ]);

        return $subject->fresh(['program', 'level', 'teacher.user']);
    }

    public function delete(Subject $subject): void
    {
        $subject->delete();
    }
}
