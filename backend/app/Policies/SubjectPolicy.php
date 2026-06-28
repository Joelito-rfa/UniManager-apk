<?php
namespace App\Policies;

use App\Models\User;
use App\Models\Subject;

class SubjectPolicy
{
    public function viewAny(User $user): bool { return $user->hasPermissionTo('view-subjects'); }
    public function view(User $user, Subject $subject): bool { return $user->hasPermissionTo('view-subjects'); }
    public function create(User $user): bool { return $user->hasPermissionTo('create-subjects'); }
    public function update(User $user, Subject $subject): bool { return $user->hasPermissionTo('edit-subjects'); }
    public function delete(User $user, Subject $subject): bool { return $user->hasPermissionTo('delete-subjects'); }
}
