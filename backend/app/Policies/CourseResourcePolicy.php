<?php
namespace App\Policies;

use App\Models\User;
use App\Models\CourseResource;

class CourseResourcePolicy
{
    public function viewAny(User $user): bool { return $user->hasPermissionTo('view-resources'); }
    public function view(User $user, CourseResource $resource): bool { return $user->hasPermissionTo('view-resources'); }
    public function create(User $user): bool { return $user->hasPermissionTo('create-resources'); }
    public function update(User $user, CourseResource $resource): bool { return $user->hasPermissionTo('edit-resources'); }
    public function delete(User $user, CourseResource $resource): bool { return $user->hasPermissionTo('delete-resources'); }
}
