<?php
namespace App\Policies;

use App\Models\User;
use App\Models\Course;

class CoursePolicy
{
    public function viewAny(User $user): bool { return $user->hasPermissionTo('view-courses'); }
    public function view(User $user, Course $course): bool { return $user->hasPermissionTo('view-courses'); }
    public function create(User $user): bool { return $user->hasPermissionTo('create-courses'); }
    public function update(User $user, Course $course): bool { return $user->hasPermissionTo('edit-courses'); }
    public function delete(User $user, Course $course): bool { return $user->hasPermissionTo('delete-courses'); }
}
