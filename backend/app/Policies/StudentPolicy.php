<?php
namespace App\Policies;

use App\Models\User;
use App\Models\Student;

class StudentPolicy
{
    public function viewAny(User $user): bool { return $user->hasPermissionTo('view-students'); }
    public function view(User $user, Student $student): bool { return $user->hasPermissionTo('view-students'); }
    public function create(User $user): bool { return $user->hasPermissionTo('create-students'); }
    public function update(User $user, Student $student): bool { return $user->hasPermissionTo('edit-students'); }
    public function delete(User $user, Student $student): bool { return $user->hasPermissionTo('delete-students'); }
}
