<?php
namespace App\Policies;

use App\Models\User;
use App\Models\Result;

class ResultPolicy
{
    public function viewAny(User $user): bool { return $user->hasPermissionTo('view-results'); }
    public function view(User $user, Result $result): bool { return $user->hasPermissionTo('view-results'); }
    public function create(User $user): bool { return $user->hasPermissionTo('create-results'); }
    public function update(User $user, Result $result): bool { return $user->hasPermissionTo('edit-results'); }
    public function delete(User $user, Result $result): bool { return $user->hasPermissionTo('delete-results'); }
}
