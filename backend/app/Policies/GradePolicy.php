<?php
namespace App\Policies;

use App\Models\User;
use App\Models\Grade;

class GradePolicy
{
    public function viewAny(User $user): bool { return $user->hasPermissionTo('view-grades'); }
    public function view(User $user, Grade $grade): bool { return $user->hasPermissionTo('view-grades'); }
    public function create(User $user): bool { return $user->hasPermissionTo('create-grades'); }
    public function update(User $user, Grade $grade): bool { return $user->hasPermissionTo('edit-grades'); }
    public function delete(User $user, Grade $grade): bool { return $user->hasPermissionTo('delete-grades'); }
}
