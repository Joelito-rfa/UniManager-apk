<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserService
{
    public function paginate($request)
    {
        $query = User::with(['roles', 'student', 'teacher']);

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'ilike', "%{$request->search}%")
                  ->orWhere('email', 'ilike', "%{$request->search}%");
            });
        }

        if ($request->code) {
            $query->byCode($request->code);
        }

        if ($request->role) {
            $query->role($request->role);
        }

        if ($request->status) {
            $query->where('status', $request->status);
        }

        return $query->orderBy('created_at', 'desc')->paginate($request->per_page ?? 15);
    }

    public function create(array $data): User
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'phone' => $data['phone'] ?? null,
                'status' => $data['status'] ?? 'active',
            ]);

            if (isset($data['role'])) {
                $user->assignRole($data['role']);
            }

            return $user->fresh(['roles']);
        });
    }

    public function update(User $user, array $data): User
    {
        return DB::transaction(function () use ($user, $data) {
            $user->update([
                'name' => $data['name'] ?? $user->name,
                'email' => $data['email'] ?? $user->email,
                'phone' => $data['phone'] ?? $user->phone,
                'status' => $data['status'] ?? $user->status,
            ]);

            if (isset($data['password'])) {
                $user->password = Hash::make($data['password']);
                $user->save();
            }

            if (isset($data['role'])) {
                $user->syncRoles([$data['role']]);
            }

            return $user->fresh(['roles']);
        });
    }

    public function delete(User $user): void
    {
        DB::transaction(function () use ($user) {
            $user->delete();
        });
    }

    public function assignRoles(User $user, array $roles): User
    {
        $user->syncRoles($roles);
        return $user->fresh(['roles']);
    }
}
