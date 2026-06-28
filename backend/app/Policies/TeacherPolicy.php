<?php
namespace App\Policies;

use App\Models\User;
use App\Models\Teacher;

class TeacherPolicy
{
    public function viewAny(User $user): bool { return $user->hasPermissionTo('view-teachers'); }
    public function view(User $user, Teacher $teacher): bool { return $user->hasPermissionTo('view-teachers'); }
    public function create(User $user): bool { return $user->hasPermissionTo('create-teachers'); }
    public function update(User $user, Teacher $teacher): bool { return $user->hasPermissionTo('edit-teachers'); }
    public function delete(User $user, Teacher $teacher): bool { return $user->hasPermissionTo('delete-teachers'); }
}
